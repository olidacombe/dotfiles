# Setup fzf
# ---------
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/usr/local/opt/fzf/shell/key-bindings.zsh"

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
