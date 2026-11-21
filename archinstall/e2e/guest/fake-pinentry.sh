#!/bin/sh
# Test-only pinentry: answers every GETPIN with the passphrase in
# ~/.e2e/passphrase, so `gpg --quick-generate-key` in bootstrap.sh needs no human.
# Speaks just enough of the Assuan protocol for gpg-agent.
pass=$(cat "$HOME/.e2e/passphrase")
echo "OK fake pinentry ready"
while IFS= read -r line; do
    case "$line" in
        GETPIN*)  printf 'D %s\nOK\n' "$pass" ;;
        BYE*)     echo OK; exit 0 ;;
        *)        echo OK ;;
    esac
done
