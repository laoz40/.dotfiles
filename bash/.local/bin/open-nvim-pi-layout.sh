#!/usr/bin/env bash
set -euo pipefail

# Open a 2-pane layout in the current tmux window:
# - left pane runs nvim
# - right pane runs pi and stays smaller

LEFT_CMD="${LEFT_CMD:-nvim}"
RIGHT_CMD="${RIGHT_CMD:-pi}"
RIGHT_WIDTH="${RIGHT_WIDTH:-60}"

if ! command -v tmux >/dev/null 2>&1; then
  echo "error: tmux is not installed or not in PATH" >&2
  exit 1
fi

if ! command -v pi >/dev/null 2>&1; then
  echo "error: pi is not installed or not in PATH" >&2
  exit 1
fi

if ! command -v nvim >/dev/null 2>&1; then
  echo "error: nvim is not installed or not in PATH" >&2
  exit 1
fi

if [[ -z "${TMUX:-}" ]]; then
  echo "error: run this inside tmux" >&2
  exit 1
fi

current_pane="$(tmux display-message -p '#{pane_id}')"
current_path="$(tmux display-message -p '#{pane_current_path}')"
current_window="$(tmux display-message -p '#{window_id}')"

if [[ "$(tmux display-message -p '#{window_panes}')" -eq 1 ]]; then
  tmux split-window -h -l "$RIGHT_WIDTH" -t "$current_pane" -c "$current_path" "$RIGHT_CMD"
fi

right_pane="$(tmux list-panes -t "$current_window" -F '#{pane_id}' | grep -v "^$current_pane$" | head -n 1)"

tmux respawn-pane -k -t "$current_pane" -c "$current_path" "$LEFT_CMD"
tmux respawn-pane -k -t "$right_pane" -c "$current_path" "$RIGHT_CMD"

tmux resize-pane -t "$right_pane" -x "$RIGHT_WIDTH"
tmux select-pane -t "$current_pane"
