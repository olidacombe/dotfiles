# Sourced by root's zsh login shell on the live ISO (installed as /root/.zprofile).

# Only drive the install from the autologin console; ssh / other ttys get a plain shell.
[[ $(tty) == /dev/tty1 ]] || return 0

# Unattended test hook: archinstall/e2e passes a script in as a systemd credential
# (SMBIOS OEM string from QEMU). Real hardware never has this credential.
if [[ -r /run/credentials/@system/e2e.autorun ]]; then
    bash /run/credentials/@system/e2e.autorun
    return
fi

systemctl start NetworkManager
# Skip the network TUI when we're already online (e.g. wired DHCP).
if ! curl -fsS --max-time 5 -o /dev/null https://archlinux.org; then
    nmtui
fi
archinstall --config user_configuration.json --creds user_credentials.json
