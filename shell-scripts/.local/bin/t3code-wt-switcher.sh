#!/usr/bin/env bash

# Select and go to a t3 code worktree for the current git project.
t3code_wt_switcher() {
  local project_name t3_dir selected branch wt_path

  project_name=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)") || return
  t3_dir="$HOME/.t3/worktrees/$project_name"

  [ -d "$t3_dir" ] || { echo "No worktrees for $project_name"; return; }

  # Get path and branch name for each worktree.
  selected=$(
    find "$t3_dir" -mindepth 1 -maxdepth 1 -type d | while read -r wt_path; do
      branch=$(git -C "$wt_path" branch --show-current 2>/dev/null)
      [ -z "$branch" ] && branch="DETACHED"

      printf '%s\t%s\t%s\n' "$project_name" "$branch" "$wt_path"
    done | fzf --with-nth=1,2
  ) || return

  cd "$(printf '%s' "$selected" | cut -f3)" || return
}

t3code_wt_switcher "$@"
