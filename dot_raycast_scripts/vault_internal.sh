#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Vault Internal
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName vault
# @raycast.needsConfirmation false


# Documentation:
# @raycast.description Internal Vault (oidc auth)
# @raycast.author Oli Dacombe
# @raycast.authorURL

set -euo pipefail

open -a 'Google Chrome' https://vault.internal.blockchain.info/ui/vault/auth?with=oidc
