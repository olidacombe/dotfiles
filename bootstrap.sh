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

# mise is the one piece of this setup that cannot be lazy: it is what installs
# everything else on first use. Installs itself into `~/.local/bin` when the
# package manager has not provided it.
function ensure_mise() {
    command -v mise &> /dev/null && return 0
    echo "installing mise"
    curl -fsSL https://mise.run | sh
    export PATH="${HOME}/.local/bin:${PATH}"
    command -v mise &> /dev/null || err "mise installed but not on PATH — check ~/.zshenv"
}

# Lazy tool shims arrived in mise 2026.9.0 (`mise --version` prints e.g.
# "2026.11.3 linux-x64 (2026-11-07)"). Shell arithmetic, not awk: a numeric-vs-strnum
# compare in awk falls back to string order, so a version it cannot read looks new.
function mise_has_lazy() {
    local version year rest month
    version=$(mise --version 2>/dev/null | awk '{ print $1 }')
    year=${version%%.*}
    rest=${version#*.}
    month=${rest%%.*}
    case "${year}${month}" in
        '' | *[!0-9]*) return 1 ;;   # unreadable version: don't gamble on it
    esac
    [ "$year" -gt 2026 ] || { [ "$year" -eq 2026 ] && [ "$month" -ge 9 ]; }
}

# lazy-mise: install the eager core set (conf.d/10-core.toml) and publish
# bootstrap shims for the rest (conf.d/50-lazy.toml), which install themselves
# the first time you run them. Set MISE_WARM=1 to also fetch the lazy set in the
# background — same effect as the old up-front install, staggered off the critical
# path instead of blocking it.
function mise_bootstrap() {
    ensure_mise
    if ! mise_has_lazy; then
        echo "mise $(mise --version) is too old for lazy tool shims (need >= 2026.9.0), updating"
        mise self-update || err "mise self-update failed"
    fi
    # chezmoi may have just written ~/.config/mise; make sure mise sees it and the shims
    mise reshim
    # later steps in this script (and anything they spawn) should see mise's tools,
    # and a non-interactive bootstrap never sources ~/.zshrc, so add both dirs here
    export PATH="$(dirname "$(mise which mise 2>/dev/null || command -v mise)"):${HOME}/.local/share/mise/shims:${HOME}/.local/bin:${PATH}"
    mise install || echo "WARN mise install had failures (see \`mise ls\`)"
    if [ "${MISE_WARM:-}" = "1" ]; then
        echo "warming lazy tools in the background (mise install --include-lazy)"
        mise install --include-lazy --jobs "${MISE_JOBS:-4}" & disown
    else
        echo "lazy tools will install on first use — \`mise install --include-lazy\` to warm now"
    fi
}

function pac_install() {
	sudo pacman -Sy --needed --noconfirm "$@"
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
    sudo pacman -S --needed --noconfirm git base-devel
    YAYDIR="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay.git "$YAYDIR"
    pushd "$YAYDIR"
    makepkg -si --noconfirm
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

# Ask for the sudo password once, up front, and keep the ticket alive until we exit.
if sudo -v; then
    while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
fi
export DEBIAN_FRONTEND=noninteractive
export NONINTERACTIVE=1                     # homebrew installer
export BOOTSTRAP_HASKELL_NONINTERACTIVE=1   # ghcup installer

if uname -a | grep -i linux; then
    export INSTALLER=$(linux_installer)
	export OS="$LINUX"
    export DISTRO=$(linux_distro)
else
	command -v brew &> /dev/null && echo homebrew found || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	export INSTALLER="brew install"
	export OS="$MACOS"
fi

# Identity is resolved once here and handed to chezmoi via BOOTSTRAP_* env vars
# (read by .chezmoi.toml.tmpl), so nothing asks for it twice. Override any of
# BOOTSTRAP_NAME / BOOTSTRAP_EMAIL / BOOTSTRAP_GPG_KEY to skip detection entirely.
export BOOTSTRAP_NAME="${BOOTSTRAP_NAME:-Oli Dacombe}"

function gpg_secret_fpr() {
    gpg --list-secret-keys --with-colons "$@" 2>/dev/null | awk -F: '/^fpr:/ { print $10; exit }'
}

function resolve_email() {
    [ -n "${BOOTSTRAP_EMAIL:-}" ] && return 0
    BOOTSTRAP_EMAIL="$(git config --global user.email 2>/dev/null || true)"
    if [ -z "$BOOTSTRAP_EMAIL" ] && [ -n "${BOOTSTRAP_GPG_KEY:-}" ]; then
        BOOTSTRAP_EMAIL="$(gpg --list-secret-keys --with-colons "$BOOTSTRAP_GPG_KEY" \
            | awk -F: '/^uid:/ { print $10; exit }' | sed -n 's/.*<\(.*\)>.*/\1/p')"
    fi
    while [ -z "$BOOTSTRAP_EMAIL" ]; do
        read -r "BOOTSTRAP_EMAIL?email: "
    done
}

function bootstrap_gpg() {
    # helpful https://stackoverflow.com/questions/39494631/gpg-failed-to-sign-the-data-fatal-failed-to-write-commit-object-git-2-10-0
    command -v gpg &> /dev/null && echo gpg found || $INSTALLER gnupg
    if [ "$OS" = "$MACOS" ]; then
        command -v pinentry-mac &> /dev/null || $INSTALLER pinentry-mac
    fi
    BOOTSTRAP_GPG_KEY="${BOOTSTRAP_GPG_KEY:-$(gpg_secret_fpr)}"
    resolve_email
    if [ -z "$BOOTSTRAP_GPG_KEY" ]; then
        echo "generating GPG key for ${BOOTSTRAP_NAME} <${BOOTSTRAP_EMAIL}>"
        echo "  passphrase: use your login password so pam-gnupg can unlock it at login"
        gpg --batch --quick-generate-key "${BOOTSTRAP_NAME} <${BOOTSTRAP_EMAIL}>" ed25519 sign,cert never
        BOOTSTRAP_GPG_KEY="$(gpg_secret_fpr "$BOOTSTRAP_EMAIL")"
        # encryption subkey: its keygrip is what ~/.pam-gnupg wants
        gpg --batch --quick-add-key "$BOOTSTRAP_GPG_KEY" cv25519 encr never
    fi
    echo "using GPG key ${BOOTSTRAP_GPG_KEY} for ${BOOTSTRAP_EMAIL}"
    export BOOTSTRAP_EMAIL BOOTSTRAP_GPG_KEY
}

is_gitpod || bootstrap_gpg

# Set USE_MISE=0 to restore the pre-mise rust/crates/npm installs (rustup +
# cargo-binstall + npm -g). The mise path covers the same software, declared in
# ~/.config/mise by chezmoi, with the rarely-used part deferred to first use.
# Default: mise.
function use_mise() {
    [ "${USE_MISE:-1}" = "1" ]
}

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

# `mise run bootstrap-packages` installs everything in conf.d/20-packages.toml,
# i.e. the non-dev-tool packages, without any package-manager-specific shell code.
# Experimental: it is not the default path yet because `bootstrap packages apply`
# is a destructive command class and AUR builds are slow, so bootstrap.sh keeps
# driving pacman/yay/apt/brew directly. Try it with MISE_PACKAGES=1; it needs
# mise before the package step, hence ensure_mise here rather than later.
if [ "${MISE_PACKAGES:-}" = "1" ] && command -v mise &>/dev/null; then
    ensure_mise
    if mise tasks ls 2>/dev/null | grep -q '^bootstrap-packages'; then
        echo "installing host packages via \`mise run bootstrap-packages\`"
        mise run bootstrap-packages
    else
        echo "WARN no bootstrap-packages task found — is ~/.config/mise applied?"
    fi
fi

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
                yay -S --needed --noconfirm --answerclean None --answerdiff None --answeredit None $( strip_comment yayfile-core )
            else
                pac_install $( strip_comment pacfile-{core,full} )
                # FIXME
                yay -S --needed --noconfirm --answerclean None --answerdiff None --answeredit None \
                    $( strip_comment yayfile-{core,full} ) || echo "WARN some AUR packages failed"
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
if [ "$OS" = "$LINUX" ] && [ "$(getent passwd "$(whoami)" | cut -d: -f7)" != "$(which zsh)" ]; then
    sudo usermod --shell "$(which zsh)" "$(whoami)"
fi

# we have neovim by now, so pre-install plugins...
command -v nvim &> /dev/null && nvim --headless "+Lazy! install" +qa & disown

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
# mise's rust core tool installs rustup itself, so this block is only for the
# pre-mise path (see `mise_bootstrap` / README "lazy-mise").
function legacy_rust() {
command -v rustc &> /dev/null && echo rust found || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
if [ -f "${HOME}/.cargo/env" ]; then
    . ${HOME}/.cargo/env
fi
rustup default || rustup default stable
rustup component add rust-analyzer
}

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
 
function legacy_crates_and_npm() {
cargo install cargo-binstall

if is_gitpod; then
    strip_comment crates-core.txt
else
    strip_comment crates-{core,full}.txt
fi | xargs cargo binstall & disown

# Node
# install node if we don't have it
command -v node &> /dev/null || mise use -g node@lts
# TODO replace all with `bun`?
strip_comment npm_globals | xargs npm i -g & disown
}

#  _                              _       _
# | |                            (_)     | |
# | |     __ _ _ __ ___  ___ _ __ _ _ __ | |_
# | |    / _` | '_ ` _ \/ __| '__| | '_ \| __|
# | |___| (_| | | | | | \__ \ |  | | | | | |_
# |_____|\__,_|_| |_| |_|___/_|  |_|_| |_|\__|
#
# `crates-*.txt` and `npm_globals` are both rendered into ~/.config/mise by
# chezmoi, so mise covers them — and `cargo:` entries resolve through
# cargo-binstall, so prebuilt binaries where they exist instead of compiling.
# The lazy set then installs itself on first use.
if use_mise; then
    mise_bootstrap
else
    legacy_rust
    legacy_crates_and_npm
    # legacy mode deliberately skips `mise install`: the generated config declares
    # the same crates/npm packages, and installing both would fight over them.
    command -v mise &> /dev/null && mise reshim
fi

#  ▄ .▄ ▄▄▄· .▄▄ · ▄ •▄ ▄▄▄ .▄▄▌  ▄▄▌  
# ██▪▐█▐█ ▀█ ▐█ ▀. █▌▄▌▪▀▄.▀·██•  ██•  
# ██▀▐█▄█▀▀█ ▄▀▀▀█▄▐▀▀▄·▐▀▀▪▄██▪  ██▪  
# ██▌▐▀▐█ ▪▐▌▐█▄▪▐█▐█.█▌▐█▄▄▌▐█▌▐▌▐█▌▐▌
# ▀▀▀ · ▀  ▀  ▀▀▀▀ ·▀  ▀ ▀▀▀ .▀▀▀ .▀▀▀ 
command -v ghc &> /dev/null && echo haskell found || curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

# let's leave it here for the moment
if is_gitpod && [ -f "/etc/resolv.conf.bak" ]; then
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
