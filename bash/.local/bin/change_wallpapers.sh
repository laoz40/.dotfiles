#!/usr/bin/env bash

WALLPAPER_DIRECTORY=~/Pictures/Wallpapers

SELECTED_FILE=$(find -L "$WALLPAPER_DIRECTORY" -type f | shuf -n 1)

WALLPAPER=$(realpath "$SELECTED_FILE")

if [ -z "$WALLPAPER" ]; then
    echo "No wallpaper found!"
    exit 1
fi

hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper "$MONITOR,$WALLPAPER"

sleep 1

hyprctl hyprpaper unload unused
