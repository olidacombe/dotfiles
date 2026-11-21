# shellcheck shell=bash
# Run as the user on the installed system: `bash -s install|remove`.
# Puts the only two things that would otherwise need a human during
# bootstrap.sh in place, and takes them away again afterwards:
#   - sudo: bootstrap.sh does `sudo -v` up front on its tty
#   - gpg:  bootstrap.sh generates a key, gpg-agent asks pinentry for a passphrase
# Env: E2E_PASSWORD, FAKE_PINENTRY (script contents)
set -euo pipefail
SHIM=/etc/sudoers.d/99-e2e-bootstrap
root() { printf '%s\n' "$E2E_PASSWORD" | sudo -S -p '' "$@"; }

case "$1" in
install)
    root sh -c "echo 'Defaults:$USER !authenticate' > $SHIM && chmod 440 $SHIM && visudo -cf $SHIM >/dev/null"
    sudo -n -k true || { echo "sudo shim not effective" >&2; exit 1; }
    mkdir -p -m 700 ~/.e2e ~/.gnupg
    printf '%s' "$E2E_PASSWORD" > ~/.e2e/passphrase
    printf '%s\n' "$FAKE_PINENTRY" > ~/.e2e/pinentry
    chmod 700 ~/.e2e/pinentry
    echo "pinentry-program $HOME/.e2e/pinentry" > ~/.gnupg/gpg-agent.conf
    gpgconf --kill gpg-agent 2>/dev/null || true
    ;;
remove)
    sudo -n rm -f "$SHIM" || root rm -f "$SHIM"
    rm -rf ~/.e2e
    # chezmoi has written the real gpg-agent.conf by now; restart onto it.
    gpgconf --kill gpg-agent 2>/dev/null || true
    ;;
esac
