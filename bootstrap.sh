#!/usr/bin/env zsh

set -euo pipefail

GH_USER=olidacombe
LINUX="linux"
MACOS="macos"

function is_gitpod() {
    gp version &> /dev/null
}

function strip_comment() {
	sed -e 's/#.*//' "$1" | awk NF
}

function pac_install() {
	sudo pacman -Sy --noconfirm "$@"
}

function apt_install() {
    sudo apt-get install -y "$@"
}

function linux_distro() {
    cat /etc/os-release | awk -F= '/^ID_LIKE=/ { print $2 }'
}

function linux_installer() {
    case "$(linux_distro)" in
    "arch")
        echo pac_install
        ;;
    "debian")
        echo apt_install
        ;;
    *)
        ;;
    esac
}

if uname -a | grep -i linux; then
    export INSTALLER=$(linux_installer)
	export OS="$LINUX"
    export DISTRO=$(linux_distro)
else
	command -v brew &> /dev/null && echo homebrew found || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	export INSTALLER="brew install"
	export OS="$MACOS"
fi

if ! is_gitpod; then
    # helpful https://stackoverflow.com/questions/39494631/gpg-failed-to-sign-the-data-fatal-failed-to-write-commit-object-git-2-10-0
    command -v gpg &> /dev/null && echo gpg found || $INSTALLER gpg2 pinentry-mac
    export GPG_KEYS="$(gpg --list-secret-keys --keyid-format=long)"
    [ -z "$GPG_KEYS" ] && gpg --full-generate-key && export GPG_KEYS="$(gpg --list-secret-keys --keyid-format=long)"
    echo "$GPG_KEYS"
fi

function quit() {
        echo "$*"
        exit 0
}

function err() {
        echo "$*"
        exit 1
}

if command -v chezmoi &> /dev/null; then
        echo chezmoi found
        pushd "$(chezmoi source-path)"
else
        GET_CHEZMOI="$(curl -fsLS get.chezmoi.io)"
        cd "$HOME"
        [ -z "$GET_CHEZMOI" ] && err "error fetching \`chezmoi\` install script, if it's a cert trust error, consider \`brew install curl\` first?"

        sh -c "$GET_CHEZMOI" -- init --apply olidacombe || err "chezmoi install failed"
        pushd "$("${HOME}/bin/chezmoi" source-path)"
fi

if [ "$OS" = "$MACOS" ]; then
	echo running \`brew bundle\`
	brew bundle
else
    case "$DISTRO" in
        "arch")
            pac_install $( strip_comment pacfile )
            yes | yay -qS $( strip_comment yayfile ) <<< "A\nN\n"
            ;;
        "debian")
            apt_install $( strip_comment aptfile )
            ;;
        *)
            ;;
    esac
fi

# Setup fzf a bit more
# $(brew --prefix)/opt/fzf/install

echo "checking if we're in \`dotfiles\` working copy"
git remote -v | grep "${GH_USER}/dotfiles" || quit "we're not, time to \`chezmoi cd\` and run again" && echo "we are, continuing"

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
strip_comment crates.txt | xargs cargo install

# NPM
. "${HOME}/.nvm/nvm.sh"
command -v node &> /dev/null || nvm install node

# let's leave it here for the moment
exit 0

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
