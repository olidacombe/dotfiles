#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Vault Prod
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName vault
# @raycast.needsConfirmation false


# Documentation:
# @raycast.description Prod Vault (oidc auth)
# @raycast.author Oli Dacombe
# @raycast.authorURL

set -euo pipefail

open -a 'Google Chrome' https://vault.prod.blockchain.info/ui/vault/auth?with=oidc
