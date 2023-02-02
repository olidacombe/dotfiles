#!/usr/bin/env zsh

set -euo pipefail

command -v brew &> /dev/null && echo homebrew found || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
command -v chezmoi &> /dev/null && echo chezmoi found || sh -c "$(curl -fsLS get.chezmoi.io)"
command -v rustc &> /dev/null && echo rust found || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

[[ -d "${HOME}/.sdkman" ]] && echo sdkman found || curl -s "https://get.sdkman.io" | bash
# TODO get auto usage of `sdk` working as attempted below
# ensure sdkman env is available
# export SDKMAN_DIR="$HOME/.sdkman"
# [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
#
# command -v kotlinc &> /dev/null && echo kotlin found || sdk install kotlin

# TODO work out hydrating templates so this will work
# echo running \`chezmoi apply\`
# chezmoi apply

echo running \`brew bundle\`
brew bundle

PACKER_DIR="${HOME}/.local/share/nvim/site/pack/packer/start/packer.nvim"
[[ -d "$PACKER_DIR" ]] || \
    git clone --depth 1 https://github.com/wbthomason/packer.nvim "$PACKER_DIR"
