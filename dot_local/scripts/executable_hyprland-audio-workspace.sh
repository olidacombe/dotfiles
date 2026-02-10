#!/bin/sh

function maybe_spawn() {
    local app="$1"
    (hyprctl clients | grep -q "class: audio.${app}") || \
        hyprctl dispatch exec "ghostty --class=audio.${app} -e ${app}"
}

hyprctl dispatch togglespecialworkspace audio
maybe_spawn "cava"
maybe_spawn "pulsemixer"
