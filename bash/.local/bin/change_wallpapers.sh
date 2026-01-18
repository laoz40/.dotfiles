#!/usr/bin/env bash

WALLPAPER_DIRECTORY=~/Pictures/Wallpapers

SELECTED_FILE=$(find -L "$WALLPAPER_DIRECTORY" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)

WALLPAPER=$(realpath "$SELECTED_FILE")

if [ -z "$WALLPAPER" ]; then
    notify-send "No wallpapers found" -u critical
    exit 1
fi

hyprctl hyprpaper preload "$WALLPAPER"
MONITORS=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')

for MONITOR in $MONITORS; do             
	hyprctl hyprpaper wallpaper "$MONITOR,$WALLPAPER"
done

sleep 1

hyprctl hyprpaper unload unused
