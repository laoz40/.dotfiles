#!/usr/bin/env bash
set -euo pipefail

# Start a JS project's dev server (bun/pnpm) and, when present, Convex dev
# in separate tmux windows from anywhere inside the project.

usage() {
  cat <<'EOF'
Usage: project-dev.sh

Detects the project root from the current working directory, then:
  - starts `bun dev` if bun.lock or bun.lockb exists at the root
  - otherwise starts `pnpm dev` if pnpm-lock.yaml exists at the root
  - otherwise starts `yarn dev` if yarn.lock exists at the root
  - otherwise starts `npm run dev` if package-lock.json exists at the root
  - starts Convex in another tmux window if a convex/ directory exists

Requires tmux and an active tmux session.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if ! command -v tmux >/dev/null 2>&1; then
  echo "error: tmux is not installed or not in PATH" >&2
  exit 1
fi

if [[ -z "${TMUX:-}" ]]; then
  echo "error: run this from inside an existing tmux session" >&2
  exit 1
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
  convex_cmd="pnpm exec convex dev"
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

window_exists() {
  local name="$1"
  tmux list-windows -F '#W' | grep -Fxq "$name"
}

new_window() {
  local name="$1"
  local cmd="$2"

  if window_exists "$name"; then
    echo "skip: tmux window '$name' already exists"
    return 0
  fi

  tmux new-window -n "$name" -c "$root" "$cmd"
  echo "started: $name -> $cmd"
}

echo "project: $project"
echo "root:    $root"
echo "pm:      $pm"

new_window "dev" "$dev_cmd"

if [[ -d "$root/convex" ]]; then
  new_window "convex" "$convex_cmd"
else
  echo "skip: no convex/ directory found"
fi
