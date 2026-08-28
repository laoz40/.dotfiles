#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
STATE_FILE="$STATE_DIR/hyprland-profile"
THEME_DIR="$STATE_DIR/dotfiles-theme"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
mkdir -p "$STATE_DIR" "$THEME_DIR"

# Make sure `dms` and our scripts are reachable when invoked from a keybind.
export PATH="$HOME/.nix-profile/bin:$HOME/.local/bin:$PATH"

current="main"
if [[ -f "$STATE_FILE" ]]; then
  current="$(<"$STATE_FILE")"
fi

case "$current" in
  minimal) next="main" ;;
  *) next="minimal" ;;
esac

printf '%s\n' "$next" > "$STATE_FILE"

# Shared appearance symlinks (apply on every machine).
ln -sfn "$DOTFILES_DIR/rofi/.config/rofi/themes/$next.rasi" "$THEME_DIR/rofi-config.rasi"
ln -sfn "$DOTFILES_DIR/ghostty/.config/ghostty/themes/$next.conf" "$THEME_DIR/ghostty-theme.conf"

# Machine detection: reuse hyprland.lua's rule. The laptop's built-in panel is
# eDP-1; the desktop's main output is DP-3 (no eDP-1).
is_laptop=false
if hyprctl monitors 2>/dev/null | grep -q "eDP-1"; then
  is_laptop=true
fi

apply_dms_appearance() {
  local profile="$1"
  pgrep -f 'bin/quickshell' >/dev/null 2>&1 || return 0

  local cfg="$HOME/.config/DankMaterialShell/settings.json"
  [[ -f "$cfg" ]] || return 0

  # settings.json is an out-of-store symlink into the dotfiles seed, and DMS
  # rewrites it through that symlink. The `cat >` redirect below writes
  # *through* the symlink, so the change lands in dotfiles (git will show it).

  # The two bars are configured independently in the DMS shell settings UI
  # (appearance, transparency, corners, etc.). Switching profiles just toggles
  # which bar is enabled instead of mutating a single bar's properties. Update
  # these ids if you recreate the bars (ids are shown in the DMS bar editor).
  local main_bar_id="default"
  local minimal_bar_id="bar1787902150792"

  local main_on=true
  [[ "$profile" == "main" ]] || main_on=false

  jq --arg main "$main_bar_id" \
     --arg mini "$minimal_bar_id" \
     --argjson main_on "$main_on" '
    .barConfigs |= map(
        if .id == $main then .enabled = $main_on
        elif .id == $mini then .enabled = (if $main_on then false else true end)
        else . end
      )
  ' "$cfg" > /tmp/dms-settings.json \
    && cat /tmp/dms-settings.json > "$cfg" \
    && rm -f /tmp/dms-settings.json

  # `dms restart` sends quickshell a reload signal; the new bar is picked up
  # from the rewritten settings.json.
  dms restart >/dev/null 2>&1 &
}

if $is_laptop; then
  # Waybar (laptop only).
  waybar_theme="$next"
  if [[ "$next" == "main" ]]; then
    waybar_theme="transparent"
  fi
  ln -sfn "$DOTFILES_DIR/waybar/.config/waybar/themes/$waybar_theme.jsonc" "$THEME_DIR/waybar-config.jsonc"
  ln -sfn "$DOTFILES_DIR/waybar/.config/waybar/themes/$waybar_theme.css" "$THEME_DIR/waybar-style.css"

  pkill -x waybar 2>/dev/null || true
  nohup waybar >/dev/null 2>&1 &
else
  # Desktop: waybar is not used here, DMS is the bar. Make sure no stray
  # waybar is running and retheme DMS instead.
  pkill -x waybar 2>/dev/null || true
  apply_dms_appearance "$next"
fi

hyprctl reload

pkill -USR2 -x ghostty 2>/dev/null || true

notify-send "Hyprland profile" "$next" -t 2500 2>/dev/null || true
