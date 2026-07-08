#!/usr/bin/env bash
set -euo pipefail

confirm() {
  local prompt="$1"
  read -r -p "$prompt [y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

show_size() {
  local path="$1"
  if [[ -e "$path" ]]; then
    du -sh "$path" 2>/dev/null || true
  fi
}

remove_contents() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  find "$dir" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
}

echo "Arch cleanup"
echo "This script asks before deleting anything."
echo

# XDG trash
trash_base="${XDG_DATA_HOME:-$HOME/.local/share}/Trash"
echo "Trash:"
show_size "$trash_base"
if confirm "Empty user trash?"; then
  remove_contents "$trash_base/files"
  remove_contents "$trash_base/info"
  echo "Trash emptied."
else
  echo "Skipped trash."
fi
echo

# Pacman cache, more aggressive: keep 1 version.
echo "Pacman package cache:"
show_size "/var/cache/pacman/pkg"
if command -v paccache >/dev/null 2>&1; then
  echo "Policy: keep 1 cached version of each package."
  if confirm "Clean pacman cache with: sudo paccache -rk1?"; then
    sudo paccache -rk1
  else
    echo "Skipped pacman cache."
  fi
else
  echo "paccache not found. Install it with: sudo pacman -S pacman-contrib"
  echo "Skipped pacman cache."
fi
echo

# Paru AUR cache only. Avoid paru -Sc because it can also prompt for pacman cache/db cleanup.
paru_cache="$HOME/.cache/paru"
paru_clone="$paru_cache/clone"
paru_diff="$paru_cache/diff"
if [[ -d "$paru_cache" ]]; then
  echo "Paru cache:"
  show_size "$paru_cache"

  if [[ -d "$paru_clone" ]]; then
    show_size "$paru_clone"
    if confirm "Remove paru AUR clone/build cache only?"; then
      remove_contents "$paru_clone"
      echo "Paru clone/build cache cleaned."
    else
      echo "Skipped paru clone/build cache."
    fi
  fi

  if [[ -d "$paru_diff" ]]; then
    show_size "$paru_diff"
    if confirm "Remove paru saved diffs?"; then
      remove_contents "$paru_diff"
      echo "Paru diffs cleaned."
    else
      echo "Skipped paru diffs."
    fi
  fi
else
  echo "No paru cache found at $paru_cache."
fi
echo

# Journal logs, conservative.
echo "Systemd journal:"
if command -v journalctl >/dev/null 2>&1; then
  journalctl --disk-usage || true
  if confirm "Vacuum journal logs older than 2 weeks?"; then
    sudo journalctl --vacuum-time=2weeks
  else
    echo "Skipped journal cleanup."
  fi
fi
echo

echo "Done."
