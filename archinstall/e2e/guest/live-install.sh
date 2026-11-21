#!/bin/bash
# Runs on the live ISO (tty1) instead of the interactive flow when the e2e
# harness passes it in as the `e2e.autorun` systemd credential.
# Progress is reported via /root/e2e/status: running | ok | fail <reason>.
set -uo pipefail

CREDS=/run/credentials/@system
W=/root/e2e
DISK=/dev/vda
mkdir -p "$W"
status() { echo "$*" > "$W/status"; echo "e2e status: $*" >> "$W/live-install.log"; }
logw()   { echo "$*" | tee -a "$W/live-install.log"; }

status running

# pacman keyring init, mirror selection etc. must finish first.
logw "waiting for boot to settle: $(systemctl is-system-running --wait)"

user=$(jq -r '.users[0].username' /root/user_credentials.json)
[ -n "$user" ] && [ "$user" != null ] || { status "fail no user in baked creds"; exit 1; }
[ -b "$DISK" ] || { status "fail no $DISK"; exit 1; }
disk_mib=$(( $(blockdev --getsize64 "$DISK") / 1048576 ))

jq --arg user "$user" \
   --arg keys "$(cat "$CREDS/e2e.user-authorized-keys")" \
   --arg disk "$DISK" --argjson disk_mib "$disk_mib" \
   -f "$CREDS/e2e.config-overlay" \
   /root/user_configuration.json > "$W/config.json" \
   || { status "fail config overlay"; exit 1; }

jq --arg hash "$(cat "$CREDS/e2e.password-hash")" \
   '.users |= map(.enc_password = $hash)' \
   /root/user_credentials.json > "$W/creds.json" \
   || { status "fail creds overlay"; exit 1; }

logw "running archinstall for user '$user' on $DISK (${disk_mib} MiB)"
archinstall --config "$W/config.json" --creds "$W/creds.json" --silent
rc=$?
cp -r /var/log/archinstall "$W/archinstall-logs" 2>/dev/null

if [ "$rc" -eq 0 ]; then
    status ok
else
    status "fail archinstall exit $rc"
fi
