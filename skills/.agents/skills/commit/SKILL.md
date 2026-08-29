---
name: commit
description: Draft one Conventional Commit message for the staged Git changes. Use only when user asks to commit a change.
argument-hint: "Optional notes about what the commit should emphasize"
---

# Commit draft

Draft a commit message for the staged changes. Leave the working tree and index unchanged, and stop after presenting the draft.

## Inspect the staged change

1. Run `git diff --cached --name-status`.
2. If nothing is staged, tell the user to stage files first and stop. (You may stage files if the user asks for it.)
3. Read `git diff --cached`. Use targeted commands when the full diff is too large.
4. Account for every meaningful staged change before writing the draft. Treat arguments passed to the skill as focus notes, not as a substitute for the diff.

## Write the draft

Return only this Markdown structure:

```markdown
# Commit draft

## Title
`type: clear, concise past-tense subject`

## Description
- One past-tense bullet for each meaningful staged change.
```

Use one of these Conventional Commit types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, or `revert`.

Make the title clear on its own and easy to read. Let the subject describe multiple areas when the staged change spans them. Keep the title under 72 characters when possible.

Combine bullets only when the edits form one meaningful change. Describe behavior rather than file churn. Do not invent changes.

Omit formatting, import ordering, generated files, lockfiles, minified assets, source maps, snapshots, and build artifacts unless they are the only staged changes.
