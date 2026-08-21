#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE_FILE="$STATE_DIR/hyprland-profile"
THEME_DIR="$STATE_DIR/dotfiles-theme"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
mkdir -p "$STATE_DIR" "$THEME_DIR"

current="main"
if [[ -f "$STATE_FILE" ]]; then
  current="$(<"$STATE_FILE")"
fi

case "$current" in
  minimal) next="main" ;;
  *) next="minimal" ;;
esac

printf '%s\n' "$next" > "$STATE_FILE"

waybar_theme="$next"
if [[ "$next" == "main" ]]; then
  waybar_theme="transparent"
fi

ln -sfn "$DOTFILES_DIR/waybar/.config/waybar/themes/$waybar_theme.jsonc" "$THEME_DIR/waybar-config.jsonc"
ln -sfn "$DOTFILES_DIR/waybar/.config/waybar/themes/$waybar_theme.css" "$THEME_DIR/waybar-style.css"
ln -sfn "$DOTFILES_DIR/rofi/.config/rofi/themes/$next.rasi" "$THEME_DIR/rofi-config.rasi"
ln -sfn "$DOTFILES_DIR/ghostty/.config/ghostty/themes/$next.conf" "$THEME_DIR/ghostty-theme.conf"

hyprctl reload

pkill waybar 2>/dev/null || true
nohup waybar >/dev/null 2>&1 &

pkill -USR2 -x ghostty 2>/dev/null || true

notify-send "Hyprland profile" "$next" -t 2500 2>/dev/null || true
