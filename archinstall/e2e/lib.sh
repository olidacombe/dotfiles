# shellcheck shell=bash
# Host-side helpers for the archinstall e2e harness. Sourced by run.sh.

E2E_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHINSTALL_DIR="$(dirname "$E2E_DIR")"
REPO_DIR="$(dirname "$ARCHINSTALL_DIR")"
OUT="${E2E_OUT:-$E2E_DIR/out}"

SSH_PORT="${E2E_SSH_PORT:-2222}"
VM_CPUS="${E2E_CPUS:-$(( $(nproc) / 2 ))}"
VM_MEM="${E2E_MEM:-8192}"
DISK_SIZE="${E2E_DISK_SIZE:-60G}"
OVMF_CODE=/usr/share/edk2/x64/OVMF_CODE.4m.fd
OVMF_VARS=/usr/share/edk2/x64/OVMF_VARS.4m.fd
[ -f "$OVMF_CODE" ] || OVMF_CODE=/usr/share/ovmf/x64/OVMF_CODE.4m.fd
[ -f "$OVMF_VARS" ] || OVMF_VARS=/usr/share/ovmf/x64/OVMF_VARS.4m.fd

# Where the guest gets dotfiles from during bootstrap:
#   local  - a snapshot of this working tree (incl. uncommitted/untracked files),
#            served from the host; bootstrap.sh is fetched from it too
#   github - exactly what a real machine gets (olidacombe/dotfiles main)
E2E_DOTFILES="${E2E_DOTFILES:-local}"
GIT_PORT="${E2E_GIT_PORT:-9418}"
HTTP_PORT="${E2E_HTTP_PORT:-8418}"
HOST_FROM_GUEST=10.0.2.2   # QEMU user-net alias for host loopback

# Throwaway test identity. The password only ever exists inside test VMs.
E2E_PASSWORD="${E2E_PASSWORD:-e2e-test-password}"
E2E_EMAIL="${E2E_EMAIL:-e2e@example.invalid}"

log()  { printf '\e[1;34m[e2e %(%H:%M:%S)T]\e[0m %s\n' -1 "$*" >&2; }
warn() { printf '\e[1;33m[e2e %(%H:%M:%S)T] WARN\e[0m %s\n' -1 "$*" >&2; }
die()  { printf '\e[1;31m[e2e %(%H:%M:%S)T] FAIL\e[0m %s\n' -1 "$*" >&2; exit 1; }

latest_iso() {
    ls -t "$ARCHINSTALL_DIR"/archiso/out/archlinux-*.iso 2>/dev/null | head -n 1
}

ensure_ssh_key() {
    mkdir -p "$OUT"
    [ -f "$OUT/id_ed25519" ] || ssh-keygen -q -t ed25519 -N '' -C e2e -f "$OUT/id_ed25519"
}

COMMON_SSH_OPTS=(
    -i "$OUT/id_ed25519"
    -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
    -o LogLevel=ERROR -o BatchMode=yes -o ConnectTimeout=5
    -o ServerAliveInterval=15 -o ServerAliveCountMax=8
)
vm_ssh() { local user=$1; shift; ssh "${COMMON_SSH_OPTS[@]}" -p "$SSH_PORT" "$user@127.0.0.1" "$@"; }
vm_scp_from() {  # user remote-src local-dst
    scp -q -r "${COMMON_SSH_OPTS[@]}" -P "$SSH_PORT" "$1@127.0.0.1:$2" "$3"
}

vm_alive() { [ -f "$OUT/qemu.pid" ] && kill -0 "$(cat "$OUT/qemu.pid")" 2>/dev/null; }

# Poll until "$@" succeeds. Fails fast if the VM dies; fails after $timeout seconds.
wait_for() {
    local what=$1 timeout=$2; shift 2
    local start=$SECONDS delay=2
    log "waiting for $what (timeout ${timeout}s)"
    until "$@"; do
        vm_alive || die "VM exited while waiting for $what"
        (( SECONDS - start > timeout )) && die "timed out waiting for $what"
        sleep "$delay"
        (( delay < 15 )) && delay=$(( delay + 2 ))
    done
    log "$what: ready after $(( SECONDS - start ))s"
}

# systemd credentials passed via SMBIOS type 11 OEM strings.
QEMU_CREDS=()
add_cred() {  # name file
    QEMU_CREDS+=(-smbios "type=11,value=io.systemd.credential.binary:$1=$(base64 -w0 < "$2")")
}

# start_vm <stage> [extra qemu args...]
start_vm() {
    local stage=$1; shift
    vm_alive && die "a VM is already running (pid $(cat "$OUT/qemu.pid"))"
    local display=(-display none)
    [ -n "${E2E_DISPLAY:-}" ] && display=(-display "$E2E_DISPLAY")
    log "starting VM for stage '$stage' (ssh on 127.0.0.1:$SSH_PORT)"
    qemu-system-x86_64 \
        -name "archinstall-e2e-$stage" \
        -machine q35,accel=kvm -cpu host -smp "$VM_CPUS" -m "$VM_MEM" \
        -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
        -drive if=pflash,format=raw,file="$OUT/OVMF_VARS.fd" \
        -drive file="$OUT/disk.qcow2",if=none,id=hdd0,format=qcow2,discard=unmap,cache=unsafe \
        -device virtio-blk-pci,drive=hdd0,bootindex=2 \
        -netdev user,id=n0,hostfwd=tcp:127.0.0.1:"$SSH_PORT"-:22 \
        -device virtio-net-pci,netdev=n0 \
        -device virtio-vga \
        -serial file:"$OUT/serial-$stage.log" \
        -qmp unix:"$OUT/qmp.sock",server=on,wait=off \
        -pidfile "$OUT/qemu.pid" \
        "${display[@]}" \
        "${QEMU_CREDS[@]}" \
        "$@" \
        > "$OUT/qemu-$stage.log" 2>&1 &
    local qpid=$! i
    QEMU_CREDS=()
    for i in $(seq 1 40); do
        [ -s "$OUT/qemu.pid" ] && return 0
        kill -0 "$qpid" 2>/dev/null || { cat "$OUT/qemu-$stage.log" >&2; die "qemu failed to start"; }
        sleep 0.5
    done
    die "qemu did not write a pidfile"
}

qmp() {  # send one QMP command (JSON) and print the response
    printf '{"execute":"qmp_capabilities"}\n%s\n' "$1" \
        | socat - UNIX-CONNECT:"$OUT/qmp.sock" 2>/dev/null | tail -n +2
}

qmp_type() {  # type a string (+ Enter) into the VM's keyboard
    local str=$1 i c k cmds='{"execute":"qmp_capabilities"}'$'\n'
    for (( i = 0; i < ${#str}; i++ )); do
        c=${str:i:1}
        case "$c" in
            [a-z0-9]) k=$c ;;
            -) k=minus ;; .) k=dot ;; _) k='shift","data":"minus' ;; ' ') k=spc ;;
            [A-Z]) k='shift"},{"type":"qcode","data":"'"${c,,}" ;;
            *) die "qmp_type: unsupported char '$c'" ;;
        esac
        cmds+='{"execute":"send-key","arguments":{"keys":[{"type":"qcode","data":"'"$k"'"}]}}'$'\n'
    done
    cmds+='{"execute":"send-key","arguments":{"keys":[{"type":"qcode","data":"ret"}]}}'$'\n'
    printf '%s' "$cmds" | socat -t 2 - UNIX-CONNECT:"$OUT/qmp.sock" >/dev/null
}

stop_vm() {  # graceful poweroff via ssh, then ACPI, then kill
    local user=${1:-}
    vm_alive || return 0
    if [ "$user" = root ]; then
        vm_ssh root 'systemctl poweroff' &>/dev/null || true
    elif [ -n "$user" ]; then
        printf '%s\n' "$E2E_PASSWORD" | vm_ssh "$user" "sudo -S -p '' systemctl poweroff" &>/dev/null || true
    fi
    local i
    [ -n "$user" ] && for i in $(seq 1 60); do vm_alive || break; sleep 1; done
    if vm_alive; then
        warn "VM did not power off; sending ACPI powerdown"
        qmp '{"execute":"system_powerdown"}' >/dev/null || true
        for i in $(seq 1 30); do vm_alive || break; sleep 1; done
    fi
    if vm_alive; then
        warn "killing VM"
        kill "$(cat "$OUT/qemu.pid")" || true
        sleep 2
    fi
    rm -f "$OUT/qemu.pid"
}

screendump() {  # screendump <name>  -> $OUT/<name>.png
    qmp "{\"execute\":\"screendump\",\"arguments\":{\"filename\":\"$OUT/$1.ppm\"}}" >/dev/null || return 0
    sleep 1
    [ -f "$OUT/$1.ppm" ] && python3 -c 'import sys; from PIL import Image; Image.open(sys.argv[1]).save(sys.argv[2])' \
        "$OUT/$1.ppm" "$OUT/$1.png" 2>/dev/null && rm -f "$OUT/$1.ppm"
    return 0
}

# Serve a snapshot of the dotfiles working tree to the guest:
#   git://10.0.2.2/olidacombe/dotfiles  (path keeps bootstrap.sh's remote check happy)
#   http://10.0.2.2/bootstrap.sh
serve_dotfiles() {
    local snap="$OUT/serve" idx commit
    rm -rf "$snap"; mkdir -p "$snap/git/olidacombe" "$snap/http"
    idx=$(mktemp)
    commit=$(
        export GIT_INDEX_FILE=$idx
        cd "$REPO_DIR"
        git read-tree HEAD && git add -A && \
        git commit-tree "$(git write-tree)" -p HEAD -m "e2e working tree snapshot"
    )
    rm -f "$idx"
    git clone -q --bare "$REPO_DIR" "$snap/git/olidacombe/dotfiles"
    git -C "$REPO_DIR" push -q "$snap/git/olidacombe/dotfiles" "$commit:refs/heads/main" -f
    git -C "$snap/git/olidacombe/dotfiles" symbolic-ref HEAD refs/heads/main
    git -C "$REPO_DIR" show "$commit:bootstrap.sh" > "$snap/http/bootstrap.sh"
    log "serving working tree snapshot $(git -C "$REPO_DIR" rev-parse --short "$commit") (based on $(git -C "$REPO_DIR" rev-parse --abbrev-ref HEAD))"

    git daemon --reuseaddr --export-all --base-path="$snap/git" \
        --listen=127.0.0.1 --port="$GIT_PORT" "$snap/git" &>"$OUT/git-daemon.log" &
    echo $! > "$OUT/git-daemon.pid"
    python3 -m http.server -b 127.0.0.1 -d "$snap/http" "$HTTP_PORT" &>"$OUT/http.log" &
    echo $! > "$OUT/http.pid"
    sleep 1
    curl -fsS -o /dev/null "http://127.0.0.1:$HTTP_PORT/bootstrap.sh" || die "http server failed"
    git ls-remote "git://127.0.0.1:$GIT_PORT/olidacombe/dotfiles" >/dev/null || die "git daemon failed"
}
stop_serving() {
    local f
    for f in "$OUT/git-daemon.pid" "$OUT/http.pid"; do
        [ -f "$f" ] && { kill "$(cat "$f")" 2>/dev/null || true; rm -f "$f"; }
    done
    return 0
}
