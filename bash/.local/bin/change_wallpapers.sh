#!/usr/bin/env bash

WALLPAPER_DIRECTORY=~/Pictures/Wallpapers

SELECTED_FILE=$(find -L "$WALLPAPER_DIRECTORY" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)

WALLPAPER=$(realpath "$SELECTED_FILE")

if [ -z "$WALLPAPER" ]; then
    notify-send "No wallpapers found" -u critical
    exit 1
fi

MONITORS=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')

change_wallpaper() {
for MONITOR in $MONITORS; do
	hyprctl hyprpaper wallpaper "$MONITOR,$WALLPAPER"
	notify-send "Wallpaper changed to $(basename $WALLPAPER)" -u low
done
}

if [[ $1 == "get_random" ]]; then
	change_wallpaper
	exit 0
fi

selection=$(ls "$WALLPAPER_DIRECTORY" | grep -E "\.(jpg|jpeg|png|webp)$" | rofi -dmenu -i -p "Select Wallpaper:")

if [[ -n $selection ]]; then
	WALLPAPER=$(realpath "$WALLPAPER_DIRECTORY/$selection")
	change_wallpaper
fi
