---
name: create-pr
description: Drafts clear pull request descriptions from repository changes. Use when asked to create a PR.
argument-hint: "Optional notes about what the PR description should emphasize"
---

# Create PR

## Gather context

1. Determine the source branch, base branch, title, draft status, and whether a PR already exists. Ask for any unknown details in one grouped question.

### Determine the base branch

Do not assume the default branch (main) is the base. If the branch is part of a stack, its base is the parent branch.

- Check whether the branch was cut from another feature branch: `git reflog show <branch>` and `git merge-base` against candidate branches. The reflog entry where the branch was created names its starting commit.
- Check for an existing stack: `gh pr list --state open` and look for an open PR whose head is a plausible parent branch. If found, base this PR on that branch, not main.
- When still ambiguous, ask the user. Creating a PR based on main when it should sit on a parent branch pollutes the diff with the whole stack.

The head is always the current working branch. Verify with `git branch --show-current` before creating. 2. Inspect the change before writing:

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
- Use a simple conventional commit tag in the title e.g. feat:, fix:, refactor:
- Write the title as a readable statement of what the PR does, the way a colleague would describe it in a standup.
  - Lead with the change or outcome, not the area. "fix: stop session expiry from logging users out mid-edit", not "fix: session handling".
  - Bad titles are inventory lists ("feat: add config, refactor auth, update tests"), area labels with no change ("refactor: core module"), or vague polish ("improve UX").
  - Prefer verbs a human uses: add, fix, stop, drop, speed up, make. Avoid "leverage", "enhance", "streamline", "optimize" with no detail.

### Writing the scope

- Write for a reader who has no prior context about the change or why.
- Explain the affected workflows in simple terms.
- Should be easy to scan for humans

#### Show evidence if possible

Concrete evidence that the change works. Show a before and after.

- Screenshots are S-tier for any PR that changes user-visible UI.
  - **Attempt capture before `gh pr create`.** This is part of verification.
  - Confirm the environment before capturing anything:
      - Does the dev server need to be started first? What port?
      - Is the page behind login? `npx playwright screenshot` starts a fresh browser with no cookies, so it captures the login page, not the app. To get past auth, sign in once and persist the session: either save and reload a storage state (`--save-storage` / `--load-storage`) or reuse a `--user-data-dir`. A short script driving the sign-in form works
      - Does the changed UI need seeded data or navigation from the landing page?
  - If the environment can't reproduce the change after you tried (dev server, auth, navigation), skip screenshots and use execution-based evidence instead, and state what you ran and what broke.
  - Take screenshots with the Playwright CLI, no test suite needed:
    ```sh
    npx playwright screenshot --full-page --wait-for-timeout 3000 <url> before.png
    npx playwright screenshot --color-scheme dark <url> after.png
    ```
  - Useful flags: `--full-page` for the whole scrollable page, `--wait-for-selector '<selector>'` to wait for the changed UI to appear, `--wait-for-timeout` for animations or slow loads, `--color-scheme dark` and `--device 'iPhone 11'` for responsive/dark-mode changes.
  - Capture a matching pair, before and after, from the same view. A screenshot of the wrong page or a different viewport than its pair is worse than none.
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

### UI screenshot gate (when the diff is visual)

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
3. Pass images with the `--attach` flag. It accepts a file path with optional alt text after `#`, and can be repeated:
   ```sh
   gh pr create --attach './before.png#Before: broken layout' --attach './after.png#After' ...
   ```
   - Reference the files in the body where they belong so they land in context instead of dumped at the end.
4. Return the PR URL.
