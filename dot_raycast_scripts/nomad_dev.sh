#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Nomad Dev
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName nomad
# @raycast.needsConfirmation false


# Documentation:
# @raycast.description Auth and open `nomad.dev`
# @raycast.author Oli Dacombe
# @raycast.authorURL

set -euo pipefail

mnomad dev ui -authenticate
