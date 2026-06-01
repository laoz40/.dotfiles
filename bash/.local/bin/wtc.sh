#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  wtc <branch-name> [base-branch]

Examples:
  wtc feature/login
  wtc feature/login main

Creates a git worktree using this default path convention:
  ../<project>_<branch-name>

Example in repo "project" with branch "feature/login":
  ../project_feature-login
USAGE
}

copy_env_files() {
  local source_root="$1"
  local target_root="$2"

  shopt -s nullglob
  local env_files=("$source_root"/.env*)
  shopt -u nullglob

  if (( ${#env_files[@]} == 0 )); then
    echo "No .env* files found, skipping env copy"
    return
  fi

  for source in "${env_files[@]}"; do
    [[ -f "$source" ]] || continue

    local filename
    filename="$(basename "$source")"
    local target="$target_root/$filename"

    if [[ -e "$target" ]]; then
      echo "Skipping $filename; already exists in worktree"
    else
      cp "$source" "$target"
      echo "Copied $filename to new worktree"
    fi
  done
}

run_install() {
  local target_root="$1"

  if [[ -f "$target_root/package-lock.json" ]]; then
    echo "Installing dependencies: npm install"
    (cd "$target_root" && npm install)
  elif [[ -f "$target_root/pnpm-lock.yaml" ]]; then
    echo "Installing dependencies: pnpm install"
    (cd "$target_root" && pnpm install)
  elif [[ -f "$target_root/yarn.lock" ]]; then
    echo "Installing dependencies: yarn install"
    (cd "$target_root" && yarn install)
  elif [[ -f "$target_root/bun.lock" || -f "$target_root/bun.lockb" ]]; then
    echo "Installing dependencies: bun install"
    (cd "$target_root" && bun install)
  else
    echo "No lockfile found, skipping install"
  fi
}

branch="${1:-}"
base_branch="${2:-}"

if [[ -z "$branch" || "$branch" == "-h" || "$branch" == "--help" ]]; then
  usage
  exit 0
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "wtc: not inside a git repository" >&2
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
project="$(basename "$repo_root")"

# Match worktree-friendly naming: branch slashes become hyphens.
safe_branch="${branch//\//-}"
worktree_path="$(dirname "$repo_root")/${project}_${safe_branch}"

if [[ -e "$worktree_path" ]]; then
  echo "wtc: target path already exists: $worktree_path" >&2
  exit 1
fi

echo "Fetching origin..."
git fetch origin --prune >/dev/null 2>&1 || true

if git show-ref --verify --quiet "refs/heads/$branch"; then
  echo "Creating worktree from existing local branch: $branch"
  git worktree add "$worktree_path" "$branch"
elif git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
  echo "Creating worktree from existing remote branch: origin/$branch"
  git worktree add -b "$branch" "$worktree_path" "origin/$branch"
else
  if [[ -n "$base_branch" ]]; then
    echo "Creating new branch '$branch' from '$base_branch'"
    git worktree add -b "$branch" "$worktree_path" "$base_branch"
  else
    echo "Creating new branch '$branch' from current HEAD"
    git worktree add -b "$branch" "$worktree_path"
  fi
fi
copy_env_files "$repo_root" "$worktree_path"
run_install "$worktree_path"

echo
echo "Done."
echo "Branch: $branch"
echo "Path:   $worktree_path"
