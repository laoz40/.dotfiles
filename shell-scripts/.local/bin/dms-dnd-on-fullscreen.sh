#!/usr/bin/env bash
# Toggle DMS do-not-disturb while any fullscreen window is active.
# Prevents notification popups on the other monitor from stealing
# mouse/keyboard focus away from a fullscreen game.

set -u

dnd_enabled_by_us=0

get_fullscreen() {
  hyprctl -j activewindow 2>/dev/null | jq -r '.fullscreen // 0'
}

set_dnd() {
  if [ "$1" = "on" ]; then
    dms ipc call notifications enableDoNotDisturbIndefinitely >/dev/null 2>&1
    dnd_enabled_by_us=1
  else
    dms ipc call notifications disableDoNotDisturb >/dev/null 2>&1
    dnd_enabled_by_us=0
  fi
}

cleanup() {
  if [ "$dnd_enabled_by_us" = "1" ]; then
    set_dnd off
  fi
  exit 0
}
trap cleanup INT TERM

while true; do
  sleep 2
  fs="$(get_fullscreen)"

  # 1 = true fullscreen, 2 = maximized-fullscreen, 0 = none
  if [ "$fs" != "0" ]; then
    if [ "$dnd_enabled_by_us" = "0" ]; then
      # Don't clobber a DND the user turned on manually.
      existing="$(dms ipc call notifications getDoNotDisturb 2>/dev/null | tr -d '[:space:]')"
      if [ "$existing" = "true" ]; then
        continue
      fi
      set_dnd on
    fi
  elif [ "$dnd_enabled_by_us" = "1" ]; then
    set_dnd off
  fi
done