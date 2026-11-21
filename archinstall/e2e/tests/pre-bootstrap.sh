# shellcheck shell=bash
# Stage: freshly installed system, before bootstrap.sh has ever run.
# Asserts what archinstall + our config must provide, and what bootstrap.sh
# relies on being there already.
# Env: E2E_USER E2E_PASSWORD E2E_HYPR_SHA256

U=$E2E_USER
H=/home/$U

section "boot"
check_eq "system finished booting cleanly" running systemctl is-system-running
warn     "no failed units" bash -c '[ -z "$(systemctl --failed --no-legend)" ] || { systemctl --failed --no-legend; false; }'
check    "systemd-boot is installed" as_root bootctl is-installed
check    "graphical.target is the default" bash -c '[ "$(systemctl get-default)" = graphical.target ]'

section "system config (user_configuration.json)"
check_eq "hostname" nemesis cat /etc/hostname
check_eq "timezone" Europe/London timedatectl show -p Timezone --value
check    "LANG is en_US.UTF-8" grep -qx 'LANG=en_US.UTF-8' /etc/locale.conf
check    "console keymap is us" grep -qx 'KEYMAP=us' /etc/vconsole.conf
check_eq "NTP enabled" yes timedatectl show -p NTP --value
check    "zram swap active" bash -c 'swapon --show=NAME --noheadings | grep -q zram'

section "user"
check    "user $U exists" id "$U"
check_eq "login shell is zsh" /usr/bin/zsh bash -c "realpath \"\$(getent passwd $U | cut -d: -f7)\""
check    "in uucp group" bash -c "id -nG $U | tr ' ' '\n' | grep -qx uucp"
check    "in wheel group" bash -c "id -nG $U | tr ' ' '\n' | grep -qx wheel"
check    "sudo works with the password" bash -c "printf '%s\n' \"\$E2E_PASSWORD\" | sudo -S -k -p '' true"
check    "sudo requires a password" bash -c '! sudo -n -k true 2>/dev/null'
check_eq "home owned by user" "$U:$U" stat -c %U:%G "$H"
check_eq "hyprland.lua matches repo" "$E2E_HYPR_SHA256" bash -c "sha256sum $H/.config/hypr/hyprland.lua | cut -d' ' -f1"
check_eq "hyprland.lua owned by user" "$U:$U" stat -c %U:%G "$H/.config/hypr/hyprland.lua"
check    ".zshrc will run bootstrap.sh" grep -q 'olidacombe/dotfiles/raw/main/bootstrap.sh' "$H/.zshrc"

section "packages & services"
for p in base sudo zsh jq ghostty hyprland sddm networkmanager pipewire wireplumber bluez; do
    check "package $p installed" has_pkg "$p"
done
check "NetworkManager enabled" unit_enabled NetworkManager
check "NetworkManager active" unit_active NetworkManager
check "sddm enabled" unit_enabled sddm
check "sddm active" unit_active sddm
check "bluetooth enabled" unit_enabled bluetooth

section "prerequisites for bootstrap.sh"
check "online (https to github.com)" curl -fsS --max-time 20 -o /dev/null https://github.com
check "curl available" command -v curl
# bootstrap.sh installs git itself (install_yay) before it needs it
warn  "git preinstalled" command -v git
check "script(1) available" command -v script
check "pacman can sync" as_root pacman -Sy --noconfirm

finish
