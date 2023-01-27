#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Nomad Prod
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName nomad
# @raycast.needsConfirmation false


# Documentation:
# @raycast.description Auth and open `nomad.prod`
# @raycast.author Oli Dacombe
# @raycast.authorURL

set -euo pipefail

mnomad prod ui -authenticate
