---
name: create-pr
description: Drafts clear pull request descriptions from repository changes. Use when asked to create a PR.
argument-hint: "Optional notes about what the PR description should emphasize"
---

# Create PR

## Gather context

1. Determine the source branch, base branch, title, draft status, and whether a PR already exists. Ask for any unknown details in one grouped question.
2. Inspect the change before writing:
   - `git status --short`
   - `git log --oneline <base>..HEAD`
   - `git diff --stat <base>...HEAD`
3. Find and read the repository PR template before drafting e.g.
   - `.github/pull_request_template.md`
   - contribution documentation
4. If a template exists, preserve its headings and order. Do not add sections unless the template or user requests them.

## Write the PR description

- Use `unslop` skill for text that you write.
- Prefer using `show-me` skill to communicate changes visually.
- Skip all preambles and keep prose brief.
- Describe behavior and boundaries, not file churn or vague claims such as “improves code quality.”
- Follow each template heading's purpose.
- Do not mention planning artifacts, temporary status, or future work unless the user requests them.
- Use simple conventional commit tag in the title e.g. feat:, fix:, refactor:
  - Don't make the title inventory lists, area labels without change, or vague polish. It should be a readable statement of what the PR does.

### Writing the scope

- Write for a reader who has no prior context about the change or why.
- Explain the affected workflows in simple terms.
- Should be easy to scan for humans

#### Show evidence if possible

Concrete evidence that the change works. Show a before and after.

- Screenshots are S-tier - when the environment is set up for it and the change is visual.
- Execution-based evidence is A-tier. Test results, console output. Show the exact test that now fails and passes, using pseudocode.

### Writing the rationale

- Make the section a direct justification for the change.
- Explain the concrete problem in the old code before you explain the solution.

### Writing additional notes

#### Merge Danger

Describe whether it's a one-way or two-way door. You can walk back through two-way doors, but not one-way doors. A PR that is cheap to roll back is lower risk. Changes that involve destructive actions or hard-to-reverse decisions are one-way doors.

The blast radius is the potential impact or scope of the changes introduced by this PR. Consider all possibilities. Examples are layout shift, breakages for consumers, mobile responsiveness, etc.

```md
**Door:** <one-way or two-way>

<optional: description>

**Blast Radius:** <one-word description>

<optional: potential ramifications of merge>
```

## Verify before creating

### Discover checks

Find what this repo runs before a PR is mergeable. Stop once you have a concrete command list:

1. `AGENTS.md`, or `CONTRIBUTING.md` for verify/check/test instructions
2. CI config (eg. `.github/workflows/*`) for the PR or push job steps

### Run checks

1. Make sure the branch is up to date. Prefer rebasing. Fix any conflicts.
1. Run every discovered check locally.
1. If any fail, fix, commit if needed, and re-run until all pass.
1. Do not push or create/update the PR until every check passes.

## Create or update the PR

1. Verify GitHub CLI authentication with `gh auth status`.
2. If a PR already exists for the branch, update it with `gh pr edit` rather than creating another. Preserve bot-managed or auto-generated sections unchanged unless the user asks you to edit them. Do not use those sections as the source of truth for the human-written description.
3. Return the PR URL
