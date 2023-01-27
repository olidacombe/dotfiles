#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Nomad Internal
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName nomad
# @raycast.needsConfirmation false


# Documentation:
# @raycast.description Auth and open `nomad.internal`
# @raycast.author Oli Dacombe
# @raycast.authorURL

set -euo pipefail

mnomad internal ui -authenticate
