#!/usr/bin/env bash

set -euo pipefail

SESSIONIZER_DIRS=(~/od)
if [ -f ~/.sessionizer_dirs ]; then
    export SESSIONIZER_DIRS=($(cat ~/.sessionizer_dirs))
fi

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find "${SESSIONIZER_DIRS[@]/#\~/${HOME}}" -mindepth 1 -maxdepth 5 -type d | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# if [[ -z "${TMUX+x}" ]] && [[ -z "$tmux_running" ]]; then
if [[ -z "${TMUX+x}" ]] && [[ -z "$tmux_running" ]]; then
    tmux new-session -s $selected_name -c $selected
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected
fi

if [[ -z "${TMUX+x}" ]]; then
    tmux attach -t $selected_name
    exit 0
fi
tmux switch-client -t $selected_name