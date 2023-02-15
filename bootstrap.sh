#!/usr/bin/env zsh

set -euo pipefail

command -v brew &> /dev/null && echo homebrew found || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
command -v chezmoi &> /dev/null && echo chezmoi found || sh -c "$(curl -fsLS get.chezmoi.io)"

#  _______           _______ _________
# (  ____ )|\     /|(  ____ \\__   __/
# | (    )|| )   ( || (    \/   ) (   
# | (____)|| |   | || (_____    | |   
# |     __)| |   | |(_____  )   | |   
# | (\ (   | |   | |      ) |   | |   
# | ) \ \__| (___) |/\____) |   | |   
# |/   \__/(_______)\_______)   )_(   
#                                     
command -v rustc &> /dev/null && echo rust found || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

 #      ___           ___           ___           ___           ___     
 #     /\  \         /\  \         /\  \         /\  \         /\  \    
 #    /::\  \       /::\  \       /::\  \       /::\  \       /::\  \   
 #   /:/\:\  \     /:/\:\  \     /:/\:\  \     /:/\:\  \     /:/\:\  \  
 #  /:/  \:\  \   /::\~\:\  \   /::\~\:\  \   /:/  \:\  \   /:/  \:\  \ 
 # /:/__/ \:\__\ /:/\:\ \:\__\ /:/\:\ \:\__\ /:/__/_\:\__\ /:/__/ \:\__\
 # \:\  \  \/__/ \/__\:\/:/  / \/_|::\/:/  / \:\  /\ \/__/ \:\  \ /:/  /
 #  \:\  \            \::/  /     |:|::/  /   \:\ \:\__\    \:\  /:/  / 
 #   \:\  \           /:/  /      |:|\/__/     \:\/:/  /     \:\/:/  /  
 #    \:\__\         /:/  /       |:|  |        \::/  /       \::/  /   
 #     \/__/         \/__/         \|__|         \/__/         \/__/    
 #
 #  This is SUPER GOOD: https://nickgerace.dev/post/how-to-manage-rust-tools-and-applications/
 #  get current list with `cargo install --list | rg -o "^\S*\S" > crates.txt`
( sed -e 's/#.*//' | awk NF | xargs cargo install ) < crates.txt

# Install ESP dev toolchain (`espup` installed above)
#  _____  ___ ____  _   _ ____  
# | ___ |/___)  _ \| | | |  _ \ 
# | ____|___ | |_| | |_| | |_| |
# |_____|___/|  __/|____/|  __/ 
#            |_|         |_|    
espup install

[[ -d "${HOME}/.sdkman" ]] && echo sdkman found || curl -s "https://get.sdkman.io" | bash
# TODO get auto usage of `sdk` working as attempted below
# ensure sdkman env is available
# export SDKMAN_DIR="$HOME/.sdkman"
# [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
#
# command -v kotlinc &> /dev/null && echo kotlin found || sdk install kotlin
# command -v gradle &> /dev/null && echo kotlin found || sdk install gradle

# TODO work out hydrating templates so this will work
# echo running \`chezmoi apply\`
# chezmoi apply

echo running \`brew bundle\`
brew bundle

# TODO deprecate for lazy.nvim
PACKER_DIR="${HOME}/.local/share/nvim/site/pack/packer/start/packer.nvim"
[[ -d "$PACKER_DIR" ]] || \
    git clone --depth 1 https://github.com/wbthomason/packer.nvim "$PACKER_DIR"

#  __________ 
# < firebase >
#  ---------- 
#   \            .    .     .   
#    \      .  . .     `  ,     
#     \    .; .  : .' :  :  : . 
#      \   i..`: i` i.i.,i  i . 
#       \   `,--.|i |i|ii|ii|i: 
#            UooU\.'@@@@@@`.||' 
#            \__/(@@@@@@@@@@)'  
#                 (@@@@@@@@)    
#                 `YY~~~~YY'    
#                  ||    ||     
#
command -v firebase &> /dev/null && echo firebase found || curl -sL firebase.tools | bash
