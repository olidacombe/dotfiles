# shellcheck shell=bash
# Stage: after bootstrap.sh has run (via the user's first interactive zsh) and
# the machine has been rebooted.
# Env: E2E_USER E2E_PASSWORD E2E_EMAIL

U=$E2E_USER
H=/home/$U
export PATH="$H/bin:$H/.local/bin:$PATH"

section "bootstrap run"
check "bootstrap.log exists" test -s "$H/bootstrap.log"
check "bootstrap.sh exited 0" grep -q 'COMMAND_EXIT_CODE="0"' "$H/bootstrap.log"

section "still a healthy system after reboot"
check_eq "system finished booting cleanly" running systemctl is-system-running
warn     "no failed units" bash -c '[ -z "$(systemctl --failed --no-legend)" ] || { systemctl --failed --no-legend; false; }'
check    "sddm active" unit_active sddm
check_eq "login shell is zsh" /usr/bin/zsh bash -c "realpath \"\$(getent passwd $U | cut -d: -f7)\""
check    "e2e sudo shim removed" test ! -e /etc/sudoers.d/99-e2e-bootstrap
check    "sudo still requires a password" bash -c '! sudo -n -k true 2>/dev/null'
check    "sudo works with the password" bash -c "printf '%s\n' \"\$E2E_PASSWORD\" | sudo -S -k -p '' true"

section "chezmoi"
check "chezmoi installed" command -v chezmoi
check "source is the dotfiles repo" bash -c 'git -C "$(chezmoi source-path)" remote -v | grep -q olidacombe/dotfiles'
warn  "chezmoi verify (target matches source)" chezmoi verify --exclude scripts
check ".zshrc is managed (no bootstrap line)" bash -c "! grep -q 'bootstrap.sh' $H/.zshrc"
check "hypr config present" test -d "$H/.config/hypr"

section "identity"
check_eq "git user.email" "$E2E_EMAIL" git config --global user.email
check "gpg secret key for $E2E_EMAIL" bash -c "gpg --list-secret-keys --with-colons '$E2E_EMAIL' | grep -q '^sec'"
check "pam-gnupg wired into PAM" grep -rq pam_gnupg.so /etc/pam.d
check_eq "~/.pam-gnupg holds the encryption subkey keygrip" \
    "$(gpg -K --with-keygrip "$E2E_EMAIL" 2>/dev/null | grep -A1 '\[E\]$' | awk '/Keygrip =/ { print $3 }')" \
    cat "$H/.pam-gnupg"
check "test pinentry shim removed" test ! -e "$H/.e2e"
check "gpg-agent uses the real pinentry" grep -qx 'pinentry-program /usr/bin/pinentry' "$H/.gnupg/gpg-agent.conf"

section "packages"
SRC=$(chezmoi source-path)
check "yay installed" command -v yay
check "pacfile-core packages installed" all_pkgs_from "$SRC/pacfile-core"
check "pacfile-full packages installed" all_pkgs_from "$SRC/pacfile-full"
warn  "yayfile-core packages installed" all_pkgs_from "$SRC/yayfile-core"
warn  "yayfile-full packages installed" all_pkgs_from "$SRC/yayfile-full"
check "sddm astronaut theme configured" grep -q 'Current=sddm-astronaut-theme' /etc/sddm.conf

section "toolchains"
check "mise installed" command -v mise
check "nvim installed" command -v nvim
check "ghcup installed" test -x "$H/.ghcup/bin/ghcup"

finish
