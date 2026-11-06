#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE_FILE="$STATE_DIR/hyprland-profile"
THEME_DIR="$STATE_DIR/dotfiles-theme"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
mkdir -p "$STATE_DIR" "$THEME_DIR"

# Make sure `dms` and our scripts are reachable when invoked from a keybind.
export PATH="$HOME/.nix-profile/bin:$HOME/.local/bin:$PATH"

case "${1:-}" in
  main|minimal|sharp) next="$1" ;;
  *) printf 'Usage: %s {main|minimal|sharp}\n' "$0" >&2; exit 1 ;;
esac

printf '%s\n' "$next" > "$STATE_FILE"

# Shared appearance symlinks (apply on every machine).
app_theme="$next"
[[ "$next" != "sharp" ]] || app_theme="main"
ln -sfn "$DOTFILES_DIR/rofi/.config/rofi/themes/$app_theme.rasi" "$THEME_DIR/rofi-config.rasi"
ln -sfn "$DOTFILES_DIR/ghostty/.config/ghostty/themes/$app_theme.conf" "$THEME_DIR/ghostty-theme.conf"

# Machine detection: reuse hyprland.lua's rule. The laptop's built-in panel is
# eDP-1; the desktop's main output is DP-3 (no eDP-1).
is_laptop=false
if hyprctl monitors 2>/dev/null | grep -q "eDP-1"; then
  is_laptop=true
fi

apply_dms_appearance() {
  local profile="$1"

  local cfg="$HOME/.config/DankMaterialShell/settings.json"
  [[ -f "$cfg" ]] || return 0

  # settings.json is an out-of-store symlink into the dotfiles seed, and DMS
  # rewrites it through that symlink. The `cat >` redirect below writes
  # *through* the symlink, so the change lands in dotfiles (git will show it).

  # The bars are configured independently in the DMS shell settings UI
  # (appearance, transparency, corners, etc.). Switching profiles just toggles
  # which bar is enabled instead of mutating a single bar's properties. Update
  # these ids if you recreate the bars (ids are shown in the DMS bar editor).
  local main_bar_id="default"
  local minimal_bar_id="bar1787902150792"
  local sharp_bar_id="bar-sharp-profile"

  local selected_bar
  case "$profile" in
    main) selected_bar="$main_bar_id" ;;
    minimal) selected_bar="$minimal_bar_id" ;;
    sharp) selected_bar="$sharp_bar_id" ;;
  esac

  jq --arg main "$main_bar_id" \
     --arg mini "$minimal_bar_id" \
     --arg sharp "$sharp_bar_id" \
     --arg selected "$selected_bar" '
    .barConfigs |= map(
        if .id == $main or .id == $mini or .id == $sharp then .enabled = (.id == $selected)
        else . end
      )
  ' "$cfg" > /tmp/dms-settings.json \
    && cat /tmp/dms-settings.json > "$cfg" \
    && rm -f /tmp/dms-settings.json

  # Bar swaps need a full restart. `dms restart` (SIGUSR1 reload) kills quickshell
  # when switching between bar configs and does not bring it back.
  dms kill >/dev/null 2>&1 || true
  nohup dms run -d >/dev/null 2>&1 &
}

if $is_laptop; then
  # Waybar (laptop only).
  waybar_theme="$next"
  if [[ "$next" != "minimal" ]]; then
    waybar_theme="transparent"
  fi
  ln -sfn "$DOTFILES_DIR/waybar/.config/waybar/themes/$waybar_theme.jsonc" "$THEME_DIR/waybar-config.jsonc"
  ln -sfn "$DOTFILES_DIR/waybar/.config/waybar/themes/$waybar_theme.css" "$THEME_DIR/waybar-style.css"

  pkill -x 'waybar|\.waybar-wrapped' 2>/dev/null || true
  while pgrep -x 'waybar|\.waybar-wrapped' >/dev/null; do
    sleep 0.1
  done
  nohup waybar >/dev/null 2>&1 &
else
  # Desktop: waybar is not used here, DMS is the bar. Make sure no stray
  # waybar is running and retheme DMS instead.
  pkill -x 'waybar|\.waybar-wrapped' 2>/dev/null || true
  apply_dms_appearance "$next"
fi

hyprctl reload

pkill -USR2 -x ghostty 2>/dev/null || true

notify-send "Hyprland profile" "$next" -t 2500 2>/dev/null || true
