#!/usr/bin/env bash

set -euo pipefail

PUSH="push"
PULL="pull"
MODE=${1:-"$PULL"}
REPO=${REPO:-"${HOME}/od/buku"}
FILE=${FILE:-"bookmarks.html"}

function show_usage() {
    echo "Usage: $0 [push|pull]"
}

pre_sync() {
    cd "$REPO"
    git checkout main
    git pull origin main
}

function push() {
    pre_sync
    local NEW="${FILE}.new"
    rm -f "$NEW"
    buku -e "$NEW"
    mv "$NEW" "${FILE}"
    git add "$FILE"
    git commit -m "buku push: $(date)"
    git push origin HEAD
}

function pull() {
    pre_sync
    buku -i "$FILE" --tacit
}

if [ "$MODE" = "$PUSH" ]; then
    push
elif [[ "$MODE" = "$PULL" ]]; then
    pull
else
    show_usage
    exit 0
fi
