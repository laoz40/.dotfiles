#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE_FILE="$STATE_DIR/hyprland-profile"
mkdir -p "$STATE_DIR"

current="main"
if [[ -f "$STATE_FILE" ]]; then
  current="$(<"$STATE_FILE")"
fi

case "$current" in
  minimal) next="main" ;;
  *) next="minimal" ;;
esac

printf '%s\n' "$next" > "$STATE_FILE"

ln -sf "themes/$next.jsonc" "$HOME/.config/waybar/config.jsonc"
ln -sf "themes/$next.css" "$HOME/.config/waybar/style.css"
ln -sf "themes/$next.rasi" "$HOME/.config/rofi/config.rasi"
ln -sf "themes/$next.conf" "$HOME/.config/ghostty/theme.conf"

hyprctl reload

pkill waybar 2>/dev/null || true
nohup waybar >/dev/null 2>&1 &

pkill -USR2 -x ghostty 2>/dev/null || true

notify-send "Hyprland profile" "$next" -t 2500 2>/dev/null || true
