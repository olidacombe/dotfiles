#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Vault Dev
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName vault
# @raycast.needsConfirmation false


# Documentation:
# @raycast.description Dev Vault (oidc auth)
# @raycast.author Oli Dacombe
# @raycast.authorURL

set -euo pipefail

open -a 'Google Chrome' https://vault.dev.blockchain.info/ui/vault/auth?with=oidc
