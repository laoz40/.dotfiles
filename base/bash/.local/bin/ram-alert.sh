#!/usr/bin/env bash

set -euo pipefail

THRESHOLD="${RAM_ALERT_THRESHOLD:-87}"
INTERVAL="${RAM_ALERT_INTERVAL:-30}"
COOLDOWN="${RAM_ALERT_COOLDOWN:-300}"
APP_NAME="ram-alert"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
STATE_FILE="$STATE_DIR/ram-alert-last-alert"

usage_percent() {
  awk '
    /MemTotal:/ { total = $2 }
    /MemAvailable:/ { available = $2 }
    END {
      if (total <= 0) exit 1
      printf "%.0f", ((total - available) / total) * 100
    }
  ' /proc/meminfo
}

send_alert() {
  local usage="$1"
  local message="RAM usage is at ${usage}% (threshold: ${THRESHOLD}%)."

  if command -v notify-send >/dev/null 2>&1; then
    notify-send --app-name="$APP_NAME" --urgency=critical "High RAM usage" "$message"
  else
    printf '%s\n' "High RAM usage: $message" >&2
  fi
}

last_alert() {
  [[ -r "$STATE_FILE" ]] && cat "$STATE_FILE" || printf '0'
}

remember_alert() {
  mkdir -p "$STATE_DIR"
  date +%s >"$STATE_FILE"
}

check_once() {
  local usage now last
  usage="$(usage_percent)"
  now="$(date +%s)"
  last="$(last_alert)"

  if (( usage >= THRESHOLD && now - last >= COOLDOWN )); then
    send_alert "$usage"
    remember_alert
  fi

  printf '%s\n' "$usage"
}

waybar() {
  local usage class tooltip
  usage="$(check_once)"
  class="normal"
  (( usage >= THRESHOLD )) && class="critical"
  tooltip="RAM usage: ${usage}%"

  printf '{"text":"<span color='\''#dfb46a'\''></span> %s%%","tooltip":"%s","class":"%s"}\n' \
    "$usage" "$tooltip" "$class"
}

case "${1:-loop}" in
  waybar)
    waybar
    ;;
  once)
    check_once >/dev/null
    ;;
  loop)
    while true; do
      check_once >/dev/null
      sleep "$INTERVAL"
    done
    ;;
  *)
    echo "Usage: $0 [loop|once|waybar]" >&2
    exit 2
    ;;
esac
