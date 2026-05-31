#!/usr/bin/env bash
set -euo pipefail

# Start a JS project's dev server (bun/pnpm/yarn/npm).
# In Herdr: starts Convex in a right split when present, then starts dev in current pane.
# In tmux: same behavior using a horizontal split.

usage() {
  cat <<'EOF'
Usage: start-dev-server.sh

Detects the project root from the current working directory, then:
  - starts Convex in a new right-side pane if a convex/ directory exists
  - starts `bun dev` if bun.lock or bun.lockb exists at the root
  - otherwise starts `pnpm dev` if pnpm-lock.yaml exists at the root
  - otherwise starts `yarn dev` if yarn.lock exists at the root
  - otherwise starts `npm run dev` if package-lock.json exists at the root

Works inside Herdr or tmux. Outside a multiplexer, it just runs the main dev command.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi


find_project_root() {
  local dir="$PWD"

  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/bun.lock" || -f "$dir/bun.lockb" || -f "$dir/pnpm-lock.yaml" || -f "$dir/yarn.lock" || -f "$dir/package-lock.json" || -d "$dir/.git" ]]; then
      printf '%s\n' "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done

  printf '%s\n' "$PWD"
}

root="$(find_project_root)"
project="$(basename "$root")"

pm=""
dev_cmd=""
convex_cmd=""

if [[ -f "$root/bun.lock" || -f "$root/bun.lockb" ]]; then
  pm="bun"
  dev_cmd="bun dev"
  convex_cmd="bunx convex dev"
elif [[ -f "$root/pnpm-lock.yaml" ]]; then
  pm="pnpm"
  dev_cmd="pnpm dev"
  convex_cmd="pnpm convex dev"
elif [[ -f "$root/yarn.lock" ]]; then
  pm="yarn"
  dev_cmd="yarn dev"
  convex_cmd="yarn convex dev"
elif [[ -f "$root/package-lock.json" ]]; then
  pm="npm"
  dev_cmd="npm run dev"
  convex_cmd="npx convex dev"
else
  echo "error: no supported lock file found at project root: $root" >&2
  echo "looked for: bun.lock, bun.lockb, pnpm-lock.yaml, yarn.lock, package-lock.json" >&2
  exit 1
fi

current_herdr_pane() {
  if [[ -n "${HERDR_ACTIVE_PANE_ID:-}" ]]; then
    printf '%s\n' "$HERDR_ACTIVE_PANE_ID"
    return 0
  fi

  if [[ -n "${HERDR_PANE_ID:-}" ]]; then
    printf '%s\n' "$HERDR_PANE_ID"
    return 0
  fi

  herdr pane list | python -c '
import json, sys
data = json.load(sys.stdin)
for pane in data.get("result", {}).get("panes", []):
    if pane.get("focused"):
        print(pane["pane_id"])
        raise SystemExit(0)
raise SystemExit(1)
'
}

json_field() {
  local field="$1"
  python -c '
import json, sys
field = sys.argv[1]
data = json.load(sys.stdin)
result = data.get("result", {})
pane = result.get("pane") or result.get("created") or result.get("new_pane") or result.get("target") or result
print(pane.get(field, ""))
' "$field"
}

new_side_pane() {
  local name="$1"
  local cmd="$2"

  if [[ -n "${HERDR_ENV:-}" ]] && command -v herdr >/dev/null 2>&1; then
    local pane_id new_pane_id
    pane_id="$(current_herdr_pane)"
    new_pane_id="$(herdr pane split "$pane_id" --direction right --cwd "$root" --no-focus | json_field pane_id)"
    if [[ -z "$new_pane_id" ]]; then
      echo "error: could not create Herdr pane" >&2
      exit 1
    fi
    herdr pane run "$new_pane_id" "$cmd" >/dev/null
    echo "started: $name pane -> $cmd"
    return 0
  fi

  if [[ -n "${TMUX:-}" ]] && command -v tmux >/dev/null 2>&1; then
    tmux split-window -h -c "$root" "$cmd"
    echo "started: $name pane -> $cmd"
    return 0
  fi

  echo "warning: not inside Herdr or tmux; run separately: cd '$root' && $cmd" >&2
}

echo "project: $project"
echo "root:    $root"
echo "pm:      $pm"

if [[ -n "${TMUX:-}" ]] && command -v tmux >/dev/null 2>&1; then
  tmux rename-window "dev"
fi
if [[ -d "$root/convex" ]]; then
  new_side_pane "convex" "$convex_cmd"
else
  echo "skip: no convex/ directory found"
fi

echo "starting dev server in current pane -> $dev_cmd"
cd "$root"
exec bash -lc "$dev_cmd"
