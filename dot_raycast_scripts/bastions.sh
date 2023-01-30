#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title bastions
# @raycast.mode silent

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

osascript << EOF
tell app "${APP}" 
    activate
end tell
tell app "${APP}" 
    do script "$(dirname "$0")/tmux-switch.sh \"$SESSION\""
end tell
EOF
