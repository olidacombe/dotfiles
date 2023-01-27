#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Vault Staging
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName vault
# @raycast.needsConfirmation false


# Documentation:
# @raycast.description Staging Vault (oidc auth)
# @raycast.author Oli Dacombe
# @raycast.authorURL

set -euo pipefail

open -a 'Google Chrome' https://vault.staging.blockchain.info/ui/vault/auth?with=oidc
