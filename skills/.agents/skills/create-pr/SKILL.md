---
name: create-pr
description: Drafts clear pull request descriptions from repository changes. Use when asked to create a PR.
argument-hint: "Optional notes about what the PR description should emphasize"
---

# Create PR

Draft a reviewable PR description, then create the PR with the user's approval.

## Gather context

1. Determine the source branch, base branch, title, draft status, and whether a PR already exists. Ask for any unknown details in one grouped question.
2. Inspect the change before writing:
   - `git status --short`
   - `git log --oneline <base>..HEAD`
   - `git diff --stat <base>...HEAD`
   - targeted diffs and relevant tests when needed
3. Find and read the repository PR template before drafting e.g.
   - `.github/pull_request_template.md`
   - contribution documentation
4. If a template exists, preserve its headings and order. Do not add sections unless the template or user requests them.

## Write the draft

- Use the `unslop` skill for text that you write.
- Make the description easy to scan for humans without removing meaningful technical detail.
- Write for a reader who has no prior context about the project or change.
- Describe behavior and boundaries, not file churn or vague claims such as “improves code quality.”
- Include important constraints, compatibility details, error handling, migrations, risks, and intentionally deferred work under the correct template heading.
- Follow each template heading's purpose. Keep scope sections concrete, rationale sections causal, implementation sections specific, constraint sections relevant to review, and testing sections limited to commands that ran and their results.
- Do not claim that tests passed, a migration occurred, or behavior changed unless without checking for evidence.
- You may run tests yourself, such as lint, typecheck, format, tests, and build. Do not run tests in parallel, CPU and RAM are limited.
- Do not mention internal planning artifacts, temporary status, or future work unless the user requests them.

### Write the scope section

- Make the section clear to a person who does not know the codebase.
- Start with a short statement that identifies the system area and the purpose of the change.
- Explain the affected workflows in simple terms.
- Keep important implementation and behavior details, but group related details so the section stays readable.

### Write the rationale section

- Make the section a direct justification for the change.
- Explain the concrete problem in the old code before you explain the solution.

Present the draft for review. Ask whether to revise it or create the PR. Do not invoke `gh pr create` yet.

## Create or update the PR

After explicit approval:

1. Verify GitHub CLI authentication with `gh auth status`.
2. If a PR already exists for the branch, update it with `gh pr edit` rather than creating another. Preserve bot-managed or auto-generated sections unchanged unless the user asks you to edit them. Do not use those sections as the source of truth for the human-written description.
3. Otherwise run `gh pr create` with the approved title, base, head, draft status, and body.
4. Return the PR URL and briefly note whether it was created or updated.

Use a quoted or file-backed body so Markdown is preserved exactly.
