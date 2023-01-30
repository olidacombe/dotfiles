#!/usr/bin/env bash

set -euo pipefail

SESSION=${1:-'🧙'}

if [ -z "${TMUX+x}" ]; then
    tmux new-session -As "$SESSION"
fi

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    TMUX= tmux new-session -ds "$SESSION"
fi

tmux switch-client -t "$SESSION"
