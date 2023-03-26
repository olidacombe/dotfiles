OS="$(uname)"

# Setup fzf
# ---------
if [ "$OS" = "Darwin" ]; then
    if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
      PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
    fi

    # Auto-completion
    # ---------------
    [[ $- == *i* ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2> /dev/null

    # Key bindings
    # ------------
    source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
elif [ "$OS" = "Linux" ]; then
    # use custom fd command for fzf incl. showing hidden files by default
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

    # source some shell plugins for fzf
    source /usr/share/fzf/completion.zsh
    source /usr/share/fzf/key-bindings.zsh
fi

_fzf_complete_gitget() {
    _fzf_complete --multi --reverse --prompt="repo> " -- "$@" < <(
        gh repo list --json nameWithOwner | jq -r ".[] | .nameWithOwner"
    )
}

# [fif](https://github.com/roosta/fif)
source ~/.local/share/fif/fif.plugin.sh

FZF_BINDINGS="
  ${FZF_BINDINGS}
  --bind=ctrl-o:toggle-all
  --bind=ctrl-d:preview-half-page-down
  --bind=ctrl-u:preview-half-page-up
  --bind=ctrl-p:toggle-preview
  --bind=ctrl-x:clear-query
"

# https://github.com/junegunn/fzf/blob/master/README-VIM.md#explanation-of-gfzf_colors
FZF_COLORS="
  --color=fg:-1
  --color=fg+:-1
  --color=bg:-1
  --color=bg+:${FZF_GRAY_COLOR}
  --color=preview-bg:-1
  --color=hl+:${FZF_YELLOW_COLOR}
  --color=hl:${FZF_YELLOW_COLOR}
  --color=info:${FZF_ORANGE_COLOR}
  --color=prompt:${FZF_ORANGE_COLOR}
  --color=pointer:${FZF_ORANGE_COLOR}
  --color=spinner:${FZF_ORANGE_COLOR}
  --color=header:#BBB529
  --color=border:-1
  --color=gutter:-1
"
export FZF_DEFAULT_OPTS="${FZF_OPTS} ${FZF_BINDINGS} ${FZF_COLORS}"
