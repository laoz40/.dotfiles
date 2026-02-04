#!/usr/bin/env bash

WALLPAPER_DIRECTORY=$HOME/Pictures/Wallpapers

find_wallpapers() {
    find -L "$WALLPAPER_DIRECTORY" -type f \( \
        -iname "*.jpg"  -o \
        -iname "*.jpeg" -o \
        -iname "*.png"  -o \
        -iname "*.webp" \
    \) "$@"
}

find_wallpapers | read -r _ || { notify-send "No wallpapers found in $WALLPAPER_DIRECTORY" -u critical; exit 1; }

set_wallpaper() {
	local wallpaper="$1"
	hyprctl hyprpaper wallpaper ",$wallpaper"
	notify-send -r 2000 "Wallpaper changed to $(basename "$wallpaper")" -u low
}

if [[ $1 == "get_random" ]]; then
	wallpaper=$(find_wallpapers -printf "%f\n" | shuf -n 1)
	set_wallpaper "$(realpath "$WALLPAPER_DIRECTORY/$wallpaper")"
	exit 0
fi

selection=$(find_wallpapers -printf "%f\n" \
	| sort \
	| rofi -dmenu -i -p "Select Wallpaper:"
)

[[ -n "$selection" ]] || exit 0
set_wallpaper "$(realpath "$WALLPAPER_DIRECTORY/$selection")"
