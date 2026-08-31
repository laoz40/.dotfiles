---
name: commit
description: Draft one Conventional Commit message for the staged Git changes. Use only when user asks to commit a change.
argument-hint: "Optional notes about what the commit should emphasize"
---

# Commit draft

Draft a commit message for the changes in the diff. If there are staged changes, prioritise those.
Commit only when given permission.
A large mixed diff should become several small commits, one main change each. Staging the subset for the current commit is allowed.

## Inspect the change

Noise paths: lockfiles, minified assets, source maps, snapshots, build artifacts, and other generated files.

1. Run `git diff --cached --name-status`.
2. If the index is empty, inspect the working tree: `git diff --name-status` plus untracked files from `git status`. Split that into smaller commits instead of asking the user to stage first.
3. If you need how big each path is, run `--stat` on the same tree you are inspecting (`--cached` when the index has content). Keep `--name-status` as the inventory; `--stat` is size only.
4. Read the patch of every meaningful path. When name-status is already large, skip a full dump and diff by path. For noise paths, use `--stat` or `--compact-summary` instead of the patch, unless those files are the only changes.
5. Account for every meaningful change in the current commit before writing the draft. Treat skill arguments as focus notes, not as a substitute for the diff.

## Write the draft

Return only this Markdown structure:

```markdown
# Commit draft

## Title
`type: Clear, concise past-tense subject`

## Description
- One past-tense bullet for each meaningful staged change.
```

Use one of these Conventional Commit types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, or `revert`.

Make the title clear on its own and easy to read. Let the subject describe multiple areas when the staged change spans them. Keep the title under 72 characters when possible.

Combine bullets only when the edits form one meaningful change. Describe behavior rather than file churn. Do not invent changes.

Omit formatting and import-only edits from the description. Omit noise paths unless they are the only staged changes.
