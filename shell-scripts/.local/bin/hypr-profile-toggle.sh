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

  local dms_dir="$HOME/.config/DankMaterialShell"
  local cfg="$dms_dir/settings.json"
  [[ -d "$dms_dir" ]] || return 0

  # The two bars are configured independently in the DMS shell settings UI
  # (appearance, transparency, corners, etc.). Switching profiles just toggles
  # which bar is enabled instead of mutating a single bar's properties. Update
  # these ids if you recreate the bars (ids are shown in the DMS bar editor).
  local main_bar_id="default"
  local minimal_bar_id="bar1787902150792"

  # The per-profile settings live in $THEME_DIR
  # (cache) so we never write to the dotfiles-tracked seed and git stays clean.
  # They are seeded once from the current settings, after which DMS writes its
  # own changes back into whichever cache file is active via the symlink below.
  local main_file="$THEME_DIR/dms-main.json"
  local minimal_file="$THEME_DIR/dms-minimal.json"

  if [[ ! -f "$main_file" || ! -f "$minimal_file" ]]; then
    local base
    base="$(readlink -f "$cfg")"
    [[ -f "$base" ]] || return 0

    jq --arg main "$main_bar_id" --arg mini "$minimal_bar_id" '
      .barConfigs |= map(
        if .id == $main then .enabled = true
        elif .id == $mini then .enabled = false
        else . end
      )
    ' "$base" > "$main_file"

    jq --arg main "$main_bar_id" --arg mini "$minimal_bar_id" '
      .barConfigs |= map(
        if .id == $main then .enabled = false
        elif .id == $mini then .enabled = true
        else . end
      )
    ' "$base" > "$minimal_file"
  fi

  # Swap the symlink (not the file) so the change never touches dotfiles.
  ln -sfn "$THEME_DIR/dms-$profile.json" "$cfg"

  # `dms restart` sends quickshell a reload signal; the new bar is picked up
  # from the settings.json symlink.
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
