#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
HOME_DIR="$HOME"
BASE="base"
PROFILES=("main" "minimal")

PROFILE="${1:-}"

if [[ -z "$PROFILE" ]]; then
  echo "Usage: profile [main|minimal]"
  exit 1
fi

if [[ ! " ${PROFILES[*]} " =~ [[:space:]]${PROFILE}[[:space:]] ]]; then
  echo "Invalid profile: $PROFILE"
  echo "Available: ${PROFILES[*]}"
  exit 1
fi

stow_packages_in_dir() {
  local package_root="$1"
  shift

  [[ -d "$package_root" ]] || return 0

  local package
  shopt -s nullglob
  for package in "$package_root"/*; do
    [[ -d "$package" ]] || continue
    stow -d "$package_root" -t "$HOME_DIR" "$@" "$(basename "$package")"
  done
  shopt -u nullglob
}

echo "Switching to profile: $PROFILE"

# Remove all switchable profile packages.
for profile in "${PROFILES[@]}"; do
  stow_packages_in_dir "$DOTFILES_DIR/$profile" -D 2>/dev/null || true
done

# Always ensure base packages are present.
stow_packages_in_dir "$DOTFILES_DIR/$BASE"

# Apply the selected profile packages.
stow_packages_in_dir "$DOTFILES_DIR/$PROFILE"

# Reload hyprland and kill profile-dependent services.
pkill waybar 2>/dev/null || true
pkill hyprpaper 2>/dev/null || true
pkill hyprsunset 2>/dev/null || true
hyprctl reload 2>/dev/null || true
# Wait for the reload to complete, then start the services.
sleep 1
pkill -USR2 -x ghostty 2>/dev/null || true
nohup waybar >/dev/null 2>&1 &
nohup hyprpaper >/dev/null 2>&1 &
nohup hyprsunset >/dev/null 2>&1 &
nohup bash -lc 'sleep 1 && killall -SIGUSR1 waybar' >/dev/null 2>&1 &
# note need to manually reload ghostty to fix lag from shader

echo "Active profile: $PROFILE"
