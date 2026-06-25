#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 1 ]]; then
  selected="$1"
else
  selected=$(find ~/Documents/ ~/Downloads ~/Projects/ ~/ ~/.config ~/.dotfiles -mindepth 1 -maxdepth 1 -type d 2>/dev/null | fzf)
fi

if [[ -z "${selected:-}" ]]; then
  exit 0
fi

selected="$(realpath -m "$selected")"
selected_name="$(basename "$selected")"

if [[ "$selected" == "$HOME" ]]; then
  selected_name="~"
fi

if ! command -v herdr >/dev/null 2>&1; then
  echo "error: herdr is not installed or not in PATH" >&2
  exit 1
fi

workspace_id=$(
  herdr workspace list | python -c '
import json, os, sys
selected = os.path.realpath(sys.argv[1])
label = sys.argv[2]
data = json.load(sys.stdin)
for workspace in data.get("result", {}).get("workspaces", []):
    if workspace.get("label") == label:
        print(workspace["workspace_id"])
        raise SystemExit(0)
raise SystemExit(1)
' "$selected" "$selected_name" 2>/dev/null || true
)

if [[ -n "$workspace_id" ]]; then
  herdr workspace focus "$workspace_id" >/dev/null
  exit 0
fi

herdr workspace create --cwd "$selected" --label "$selected_name" --focus >/dev/null
