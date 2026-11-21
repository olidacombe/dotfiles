#!/bin/bash
# Unattended end-to-end test of the archinstall ISO.
#
#   run.sh all         build (if needed) -> install -> pre -> bootstrap -> post
#   run.sh build       build the ISO non-interactively (needs sudo for mkarchiso)
#   run.sh install     boot ISO, unattended archinstall      -> out/installed.qcow2
#   run.sh pre         boot installed snapshot, run pre-bootstrap tests
#   run.sh bootstrap   pre tests + run bootstrap.sh            -> out/bootstrapped.qcow2
#   run.sh post        boot bootstrapped snapshot, run post-bootstrap tests
#   run.sh shell [installed|bootstrapped]   boot a snapshot and ssh in
#   run.sh exec <snapshot> <cmd>            boot a snapshot, run cmd as the user
#   run.sh stop        stop a running harness, its VM and file servers
#
# E2E_DOTFILES=local (default) tests this working tree; =github tests what a
# real machine would pull (olidacombe/dotfiles main).
#
# Snapshots are qcow2 overlays, so pre/bootstrap/post can be re-run without
# reinstalling. Logs and results go to archinstall/e2e/out/.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

E2E_USER="${E2E_USER:-$USER}"
INSTALL_TIMEOUT="${E2E_INSTALL_TIMEOUT:-3600}"
BOOTSTRAP_TIMEOUT="${E2E_BOOTSTRAP_TIMEOUT:-10800}"

cleanup() { stop_serving; vm_alive && { warn "cleaning up running VM"; stop_vm; } ; return 0; }
trap cleanup EXIT

# ---------------------------------------------------------------- build
iso_has_hook() {
    grep -q e2e.autorun "$ARCHINSTALL_DIR/archiso/airootfs/root/.zprofile" 2>/dev/null
}

stage_build() {
    log "building ISO for user '$E2E_USER' (placeholder password; e2e overrides it)"
    warn "this ISO has a locked user password: rebuild with plain 'make' before burning"
    ( cd "$ARCHINSTALL_DIR" && make clean && \
      NO_BOOT=1 ARCH_USER="$E2E_USER" ARCH_PASSWORD_HASH='!' ./build-and-test.sh ./archiso true )
}

ensure_iso() {
    if [ -z "$(latest_iso)" ] || [ -n "${E2E_REBUILD:-}" ]; then
        stage_build
    fi
    iso_has_hook || die "ISO predates the e2e hook in autorun.sh; run 'make e2e-build'"
    local baked_user
    baked_user=$(jq -r '.users[0].username' "$ARCHINSTALL_DIR/archiso/airootfs/root/user_credentials.json")
    [ "$baked_user" = "$E2E_USER" ] || { E2E_USER=$baked_user; log "ISO user is '$E2E_USER'"; }
}

# ---------------------------------------------------------------- install
live_status() { vm_ssh root 'cat /root/e2e/status 2>/dev/null' 2>/dev/null; }
install_finished() { local s; s=$(live_status) && [ -n "$s" ] && [ "$s" != running ]; }

stage_install() {
    ensure_iso
    ensure_ssh_key
    local iso; iso=$(latest_iso)
    log "installing from $(basename "$iso")"
    rm -rf "$OUT/install"; mkdir -p "$OUT/install"
    rm -f "$OUT"/installed.* "$OUT"/bootstrapped.* "$OUT/disk.qcow2"
    qemu-img create -q -f qcow2 "$OUT/disk.qcow2" "$DISK_SIZE"
    cp "$OVMF_VARS" "$OUT/OVMF_VARS.fd"

    mkpasswd -m yescrypt "$E2E_PASSWORD" > "$OUT/password.hash"
    add_cred ssh.authorized_keys.root "$OUT/id_ed25519.pub"
    add_cred e2e.user-authorized-keys "$OUT/id_ed25519.pub"
    add_cred e2e.password-hash "$OUT/password.hash"
    add_cred e2e.config-overlay "$E2E_DIR/guest/config-overlay.jq"
    add_cred e2e.autorun "$E2E_DIR/guest/live-install.sh"

    start_vm install \
        -drive file="$iso",if=none,id=cd0,media=cdrom,format=raw,readonly=on \
        -device virtio-scsi-pci -device scsi-cd,drive=cd0,bootindex=1
    wait_for "live ISO ssh" 300 vm_ssh root true 2>/dev/null
    wait_for "unattended archinstall" "$INSTALL_TIMEOUT" install_finished
    local status; status=$(live_status)
    vm_scp_from root /root/e2e/. "$OUT/install/" || warn "could not fetch install logs"
    if [ "$status" != ok ]; then
        screendump install-failure
        die "install: $status (logs in $OUT/install/)"
    fi
    log "install: ok"
    stop_vm root
    snapshot installed
}

# ---------------------------------------------------------------- snapshots
snapshot() {  # freeze current disk + vars as <name>
    qemu-img convert -O qcow2 "$OUT/disk.qcow2" "$OUT/$1.qcow2"
    cp "$OUT/OVMF_VARS.fd" "$OUT/$1.vars"
    log "snapshot: $1"
}
from_snapshot() {  # fresh writable overlay on top of <name>
    [ -f "$OUT/$1.qcow2" ] || die "no '$1' snapshot; run the earlier stage first"
    qemu-img create -q -f qcow2 -b "$OUT/$1.qcow2" -F qcow2 "$OUT/disk.qcow2"
    cp "$OUT/$1.vars" "$OUT/OVMF_VARS.fd"
}
boot_installed() {  # <snapshot> <stage>
    from_snapshot "$1"
    start_vm "$2"
    wait_for "installed system ssh" 300 vm_ssh "$E2E_USER" true 2>/dev/null
    local state; state=$(vm_ssh "$E2E_USER" 'systemctl is-system-running --wait' || true)
    log "system state: $state"
    screendump "$2-booted"
}
snapshot_user() {  # recover E2E_USER when stages run separately
    [ -f "$OUT/user" ] && E2E_USER=$(cat "$OUT/user"); return 0
}

# ---------------------------------------------------------------- tests
run_tests() {  # <name> [ENV=val...]
    local name=$1; shift
    log "running $name tests"
    local rc=0
    cat "$E2E_DIR/tests/lib.sh" "$E2E_DIR/tests/$name.sh" \
        | vm_ssh "$E2E_USER" env E2E_USER="$E2E_USER" "E2E_PASSWORD='$E2E_PASSWORD'" "$@" bash -s \
        | tee "$OUT/$name.tap" || rc=$?
    [ "$rc" -eq 0 ] && log "$name: PASS" || warn "$name: FAIL (see $OUT/$name.tap)"
    return "$rc"
}

pre_tests() {
    run_tests pre-bootstrap \
        E2E_HYPR_SHA256="$(sha256sum "$REPO_DIR/dot_config/hypr/hyprland.lua" | cut -d' ' -f1)"
}

stage_pre() {
    snapshot_user
    boot_installed installed pre
    local rc=0; pre_tests || rc=$?
    stop_vm "$E2E_USER"
    return "$rc"
}

# ---------------------------------------------------------------- bootstrap
bootstrap_settled() {  # background jobs bootstrap.sh disowned have finished
    ! vm_ssh "$E2E_USER" 'pgrep -u "$USER" -f "nvim --headless|brew bundle|cargo binstall" >/dev/null'
}

stage_bootstrap() {
    snapshot_user
    boot_installed installed bootstrap
    pre_tests || die "pre-bootstrap tests failed; not running bootstrap"

    local shim_env=(env "E2E_PASSWORD='$E2E_PASSWORD'" "FAKE_PINENTRY=$(printf '%q' "$(cat "$E2E_DIR/guest/fake-pinentry.sh")")")
    vm_ssh "$E2E_USER" "${shim_env[@]}" bash -s install < "$E2E_DIR/guest/bootstrap-shims.sh" \
        || die "could not install bootstrap shims"

    local boot_env="BOOTSTRAP_EMAIL='$E2E_EMAIL'"
    if [ "$E2E_DOTFILES" = local ]; then
        serve_dotfiles
        # Only divergence from a real first login: where .zshrc curls bootstrap.sh
        # from, and which repo chezmoi inits.
        vm_ssh "$E2E_USER" "sed -i 's|https://github.com/olidacombe/dotfiles/raw/main/bootstrap.sh|http://$HOST_FROM_GUEST:$HTTP_PORT/bootstrap.sh|' ~/.zshrc && grep -q $HOST_FROM_GUEST ~/.zshrc" \
            || die "could not point .zshrc at local bootstrap.sh"
        boot_env+=" BOOTSTRAP_REPO=git://$HOST_FROM_GUEST:$GIT_PORT/olidacombe/dotfiles"
    else
        log "using dotfiles from github (olidacombe/dotfiles main)"
    fi

    # The first interactive zsh runs .zshrc, which runs bootstrap.sh (as a user
    # opening a terminal would). -tt gives it a real tty.
    log "running bootstrap.sh via first interactive zsh (timeout ${BOOTSTRAP_TIMEOUT}s; console -> out/bootstrap-console.log)"
    # stdin is held open (never EOF) so script(1) doesn't see the tty close.
    local rc=0
    timeout "$BOOTSTRAP_TIMEOUT" \
        ssh -tt "${COMMON_SSH_OPTS[@]}" -p "$SSH_PORT" "$E2E_USER@127.0.0.1" \
        "$boot_env zsh -lic exit" < <(exec sleep infinity) \
        > "$OUT/bootstrap-console.log" 2>&1 || rc=$?
    kill $! 2>/dev/null || true
    log "interactive shell exited ($rc)"
    wait_for "bootstrap background jobs" 1800 bootstrap_settled
    stop_serving

    vm_ssh "$E2E_USER" "${shim_env[@]}" bash -s remove < "$E2E_DIR/guest/bootstrap-shims.sh" \
        || warn "could not remove bootstrap shims"
    vm_scp_from "$E2E_USER" bootstrap.log "$OUT/bootstrap.log" || warn "no bootstrap.log"
    stop_vm "$E2E_USER"
    snapshot bootstrapped
}

graphical_session_up() {
    vm_ssh "$E2E_USER" 'loginctl list-sessions --no-legend | while read -r id _ user _; do
        [ "$user" = "$USER" ] && [ "$(loginctl show-session "$id" -p Type --value)" = wayland ] && exit 0
    done; exit 1' && vm_ssh "$E2E_USER" 'pgrep -u "$USER" -x Hyprland >/dev/null'
}

graphical_login() {  # log in through the greeter like a human would
    log "logging in through sddm"
    sleep 5   # let the greeter take focus
    qmp_type "$E2E_PASSWORD"
    local start=$SECONDS
    until graphical_session_up; do
        if (( SECONDS - start > 90 )); then
            screendump graphical-login-failure
            warn "no Hyprland wayland session 90s after greeter login"
            return 1
        fi
        sleep 3
    done
    sleep 5; screendump desktop
    log "graphical login: Hyprland session running"
}

stage_post() {
    snapshot_user
    boot_installed bootstrapped post
    local rc=0; run_tests post-bootstrap E2E_EMAIL="$E2E_EMAIL" || rc=$?
    graphical_login || rc=1
    stop_vm "$E2E_USER"
    return "$rc"
}

stage_shell() {
    snapshot_user
    boot_installed "${1:-installed}" shell
    log "ssh -p $SSH_PORT -i $OUT/id_ed25519 $E2E_USER@127.0.0.1   (password: $E2E_PASSWORD)"
    ssh -t "${COMMON_SSH_OPTS[@]}" -p "$SSH_PORT" "$E2E_USER@127.0.0.1" || true
    stop_vm "$E2E_USER"
}

stage_exec() {  # <snapshot> <command...> : boot, run one command as the user, power off
    snapshot_user
    local snap=$1; shift
    boot_installed "$snap" exec
    local rc=0; vm_ssh "$E2E_USER" "$@" || rc=$?
    stop_vm "$E2E_USER"
    return "$rc"
}

# ---------------------------------------------------------------- main
mkdir -p "$OUT"
cmd=${1:-all}; shift || true
[ "$cmd" = stop ] || echo $$ > "$OUT/run.pid"
case "$cmd" in
    build)     stage_build ;;
    install)   stage_install; echo "$E2E_USER" > "$OUT/user" ;;
    pre)       stage_pre ;;
    bootstrap) stage_bootstrap ;;
    post)      stage_post ;;
    shell)     stage_shell "$@" ;;
    exec)      stage_exec "$@" ;;
    stop)      [ -f "$OUT/run.pid" ] && kill "$(cat "$OUT/run.pid")" 2>/dev/null; stop_vm; stop_serving ;;
    all)
        start=$SECONDS
        stage_install; echo "$E2E_USER" > "$OUT/user"
        stage_bootstrap   # includes the pre-bootstrap tests
        stage_post
        log "ALL STAGES PASSED in $(( (SECONDS - start) / 60 )) min"
        ;;
    *) sed -n '2,18p' "$0"; exit 2 ;;
esac
