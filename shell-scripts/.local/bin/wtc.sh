#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: wtc <branch-name> [base-branch]

Creates a worktree at ../<project>_<branch-name>.
USAGE
}

copy_env_files() {
  local source filename
  local found=false

  shopt -s nullglob
  for source in "$1"/.env*; do
    [[ -f "$source" ]] || continue
    found=true
    filename="${source##*/}"

    if [[ -e "$2/$filename" ]]; then
      echo "Skipping $filename; already exists in worktree"
    else
      cp "$source" "$2/"
      echo "Copied $filename to new worktree"
    fi
  done
  shopt -u nullglob

  if [[ "$found" == false ]]; then
    echo "No .env* files found, skipping env copy"
  fi
}

run_install() {
  local manager=""

  if [[ -f "$1/package-lock.json" ]]; then
    manager=npm
  elif [[ -f "$1/pnpm-lock.yaml" ]]; then
    manager=pnpm
  elif [[ -f "$1/yarn.lock" ]]; then
    manager=yarn
  elif [[ -f "$1/bun.lock" || -f "$1/bun.lockb" ]]; then
    manager=bun
  fi

  if [[ -z "$manager" ]]; then
    echo "No lockfile found, skipping install"
    return
  fi

  echo "Installing dependencies: $manager install"
  (cd "$1" && "$manager" install)
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

herdr-sessionizer.sh "$worktree_path"
