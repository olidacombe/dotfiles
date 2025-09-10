#!/usr/bin/env bash

set -euo pipefail

KEY="$(chezmoi data | jq -r '.gpg.signing.key // ""')"

if [ -z "$KEY" ]; then
    exit 0
fi

gpg -K --with-keygrip "$KEY" \
    | grep -A1 '\[E\]$' \
    | awk '/Keygrip =/ { print $3 }' \
    > "${HOME}/.pam-gnupg"
