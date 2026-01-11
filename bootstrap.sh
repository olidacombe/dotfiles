#!/usr/bin/env zsh

set -euo pipefail

GH_USER=olidacombe
LINUX="linux"
MACOS="macos"

function is_gitpod() {
    gp version &> /dev/null
}

function strip_comment() {
    cat "$@" | sed -e 's/#.*//' | awk NF
}

function pac_install() {
	sudo pacman -Sy --noconfirm "$@"
}

function apt_install() {
    sudo apt-get install -y "$@"
}

function linux_distro() {
    if grep -e '^ID_LIKE=' /etc/os-release &> /dev/null; then
        # For distros that use ID_LIKE
        cat /etc/os-release | awk -F= '/^ID_LIKE=/ { print $2 }' | tr -d '"'
        return
    fi
    cat /etc/os-release | awk -F= '/^ID=/ { print $2 }' | tr -d '"'
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

function install_neovim_x64_linux() {
    curl -sLo nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    sudo tar zxvf nvim.tar.gz -C /usr --strip-components=1
    rm nvim.tar.gz
}

function install_yay() {
    cat << EOF
 ▄         ▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄         ▄ 
▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌
▐░▌       ▐░▌▐░█▀▀▀▀▀▀▀█░▌▐░▌       ▐░▌
▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌
▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
 ▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌ ▀▀▀▀█░█▀▀▀▀ 
     ▐░▌     ▐░▌       ▐░▌     ▐░▌     
     ▐░▌     ▐░▌       ▐░▌     ▐░▌     
     ▐░▌     ▐░▌       ▐░▌     ▐░▌     
      ▀       ▀         ▀       ▀      
EOF
    sudo pacman -S --needed git base-devel
    YAYDIR="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay.git "$YAYDIR"
    pushd "$YAYDIR"
    makepkg -si
    popd
    rm -rf "$YAYDIR"
}

# No small amount of inspiration from
# [unlock GPG magically](https://petrmanek.cz/blog/2022/unlocking-gpg-agent/)
function setup_pam() {
    for pam in system-local-login sddm; do
        if ! grep -q '^auth[[:blank:]]*optional[[:blank:]]*pam_gnupg.so[[:blank:]]*store-only[[:blank:]]*debug$' "/etc/pam.d/${pam}"; then
            echo 'auth     optional  pam_gnupg.so store-only debug' | sudo tee -a "/etc/pam.d/${pam}"
        fi
        if ! grep -q '^session[[:blank:]]*optional[[:blank:]]*pam_gnupg.so[[:blank:]]*debug$' "/etc/pam.d/${pam}"; then
            echo 'session  optional  pam_gnupg.so debug' | sudo tee -a "/etc/pam.d/${pam}"
        fi
    done
}

function setup_sddm_theme() {
    local THEME_DIR=/usr/share/sddm/themes/sddm-astronaut-theme
    if [ ! -d "$THEME_DIR" ]; then
        sudo git clone -b master --depth 1 https://github.com/olidacombe/sddm-astronaut-theme.git /usr/share/sddm/themes/sddm-astronaut-theme
    else
        pushd "$THEME_DIR"
        sudo git pull
        popd
    fi
    sudo cp -r /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/
    echo "[Theme]\nCurrent=sddm-astronaut-theme" | sudo tee /etc/sddm.conf
    sudo mkdir -p /etc/sddm.conf.d
    echo "[General]\nInputMethod=qtvirtualkeyboard" | sudo tee /etc/sddm.conf.d/virtualkbd.conf
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
    command -v gpg &> /dev/null && echo gpg found || $INSTALLER gpg2
    if [ "$OS" = "$MACOS" ]; then
        $INSTALLER pinentry-mac
    fi
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
else
        if is_gitpod; then
            brew install chezmoi
            sudo cp /etc/resolv.conf{,.bak}
            echo nameserver 8.8.8.8 | sudo tee /etc/resolv.conf
            chezmoi init --apply olidacombe
        else
            GET_CHEZMOI="$(curl -fsLS get.chezmoi.io)"
            cd "$HOME"
            [ -z "$GET_CHEZMOI" ] && err "error fetching \`chezmoi\` install script, if it's a cert trust error, consider \`brew install curl\` first?"
            # workaround because the apply below calls some `run_*` scripts that expect chezmoi to be in PATH
            export PATH="${HOME}/bin:${PATH}"
            sh -c "$GET_CHEZMOI" -- init --apply olidacombe || err "chezmoi install failed"
        fi
fi
pushd "$(chezmoi source-path)"

if [ "$OS" = "$MACOS" ]; then
	echo running \`brew bundle\`
	brew bundle & disown
else
    case "$DISTRO" in
        "arch")
            if ! command -v yay &> /dev/null; then
                install_yay
            fi
            if is_gitpod; then
                pac_install $( strip_comment pacfile-core )
                yes | yay -qS $( strip_comment yayfile-core ) <<< "A\nN\n"
            else
                pac_install $( strip_comment pacfile-{core,full} )
                # FIXME
                yes | yay -qS $( strip_comment yayfile-{core,full} ) <<< "A\nN\n" || true # I didn't figure out why this is failing
                setup_pam
                setup_sddm_theme
            fi
            ;;
        "debian")
            sudo apt-get update
            if is_gitpod; then
                apt_install $( strip_comment aptfile-core )
            else
                apt_install $( strip_comment aptfile-{core,full} )
                if ! pyenv virtualenv-init -; then
                    mkdir -p "$(pyenv root)/plugins"
                    git clone https://github.com/pyenv/pyenv-virtualenv.git "$(pyenv root)/plugins/pyenv-virtualenv"
                fi
            fi
            install_neovim_x64_linux
            ;;
        *)
            ;;
    esac
fi

# Force default shell in linux
if [ "$OS" = "$LINUX" ]; then
    sudo usermod --shell "$(which zsh)" "$(whoami)"
fi

# we have neovim by now, so pre-install plugins...
nvim --headless "+Lazy! install" +qa & disown

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
if [ -f "${HOME}/.cargo/env" ]; then
    . ${HOME}/.cargo/env
fi
rustup default || rustup default stable
rustup component add rust-analyzer

#  ▄ .▄ ▄▄▄· .▄▄ · ▄ •▄ ▄▄▄ .▄▄▌  ▄▄▌  
# ██▪▐█▐█ ▀█ ▐█ ▀. █▌▄▌▪▀▄.▀·██•  ██•  
# ██▀▐█▄█▀▀█ ▄▀▀▀█▄▐▀▀▄·▐▀▀▪▄██▪  ██▪  
# ██▌▐▀▐█ ▪▐▌▐█▄▪▐█▐█.█▌▐█▄▄▌▐█▌▐▌▐█▌▐▌
# ▀▀▀ · ▀  ▀  ▀▀▀▀ ·▀  ▀ ▀▀▀ .▀▀▀ .▀▀▀ 
command -v ghc &> /dev/null && echo haskell found || curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh


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
 
 cargo install cargo-binstall

if is_gitpod; then
    strip_comment crates-core.txt
else
    strip_comment crates-{core,full}.txt
fi | xargs cargo binstall & disown

# :::.    :::.:::      .::..        :   
# `;;;;,  `;;;';;,   ,;;;' ;;,.    ;;;  
#   [[[[[. '[[ \[[  .[[/   [[[[, ,[[[[, 
#   $$$ "Y$c$$  Y$c.$$"    $$$$$$$$"$$$ 
#   888    Y88   Y88P      888 Y88" 888o
#   MMM     YM    MP       MMM  M'  "MMM
if [ "$OS" = "$LINUX" ] && ! command -v nvm &> /dev/null; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

# Node
[[ -f "${HOME}/.nvm/nvm.sh" ]] && . "${HOME}/.nvm/nvm.sh"
if command -v nvm &> /dev/null; then
    # install node if we don't have it
    command -v node &> /dev/null || nvm install node
    strip_comment npm_globals | xargs npm i -g & disown
fi

# let's leave it here for the moment
if is_gitpod && [ -f "/etc/resolv.conf.bak"]; then
    sudo mv /etc/resolv.conf{.bak,}
fi
exit 0

# Install ESP dev toolchain (`espup` installed above)
#  _____  ___ ____  _   _ ____  
# | ___ |/___)  _ \| | | |  _ \ 
# | ____|___ | |_| | |_| | |_| |
# |_____|___/|  __/|____/|  __/ 
#            |_|         |_|    
espup install
