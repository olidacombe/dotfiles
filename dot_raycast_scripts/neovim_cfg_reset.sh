#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Neovim config reset
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName nvim
# @raycast.needsConfirmation false


# Documentation:
# @raycast.description Resets neovim config
# @raycast.author Oli Dacombe
# @raycast.authorURL

set -euo pipefail

# TODO get this dir another way?
CONFIG_DIR="${HOME}/.config/nvim"

rm -rf "$CONFIG_DIR" && chezmoi apply --force "$CONFIG_DIR"
