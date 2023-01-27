#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title bastions
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName ssh
# @raycast.needsConfirmation false


# Documentation:
# @raycast.description Focus the `bastions` session
# @raycast.author Oli Dacombe
# @raycast.authorURL

set -euo pipefail

APP='Terminal'
SESSION='basties'

osascript -e "tell app \"${APP}\" to do script \"tmux switch-client -t basties\""
