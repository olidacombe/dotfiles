#!/usr/bin/env bash

set -euo pipefail

if ! [ -f ${HOME}/.ssh/config ]; then

cat > ${HOME}/.ssh/config << EOF
AddKeysToAgent yes
EOF

fi
