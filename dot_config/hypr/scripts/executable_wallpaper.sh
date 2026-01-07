#!/usr/bin/env bash

WALLPAPER_DIR="${HOME}/wallpapers/"

# FIXME
# CURRENT_WALL=$(hyprctl hyprpaper listloaded)
# Get a random wallpaper that is not the current one
# WALLPAPER=$(find "$WALLPAPER_DIR" -type f ! -name "$(basename "$CURRENT_WALL")" | shuf -n 1)

# Temporary workaround: just get a random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Apply the selected wallpaper
hyprctl hyprpaper wallpaper ,"$WALLPAPER"
