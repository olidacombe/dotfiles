#!/usr/bin/env bash

set -euo pipefail

if ! [ -f ${HOME}/.ssh/config ]; then

mkdir -p "${HOME}/.ssh"
chmod 0700 "${HOME}/.ssh"

cat > ${HOME}/.ssh/config << EOF
AddKeysToAgent yes
EOF

fi
