#!/usr/bin/env bash

set -euo pipefail

if [ "$(uname)" = "Darwin" ]; then
    # font repo cloned by chezmoiexternals
    ln -sf ${HOME}/.fonts/noto-emoji/fonts/NotoEmoji-Regular.ttf ${HOME}/Library/Fonts/NotoColorEmoji-Regular.otf
fi
