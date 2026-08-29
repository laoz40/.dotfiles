---
name: create-pr
description: Drafts clear pull request descriptions from repository changes and creates GitHub pull requests with gh. Use when asked to write, revise, or create a PR description or pull request.
---

# Create PR

Draft a reviewable PR description, then create the PR only after the user explicitly approves the final body.

## Gather context

1. Determine the source branch, base branch, title, draft status, and whether a PR already exists. Ask for any unknown details in one grouped question.
2. Inspect the change before writing:
   - `git status --short`
   - `git log --oneline <base>..HEAD`
   - `git diff --stat <base>...HEAD`
   - targeted diffs and relevant tests when needed
3. Find and read the repository PR template before drafting. Check, in order:
   - `.github/pull_request_template.md`
   - `.github/PULL_REQUEST_TEMPLATE.md`
   - `.github/PULL_REQUEST_TEMPLATE/`
   - `docs/pull_request_template.md`
   - contribution documentation
4. If a template exists, preserve its headings and order. Do not add sections unless the template or user requests them.

## Write the draft

- Use ASD-STE100 Simplified Technical English for text that you write.
- Use short sentences, active voice, consistent terms, and simple sentence structures.
- Make the description easy to scan without removing meaningful technical detail.
- Write for a reader who has no prior context about the project or change.
- Prefer short, specific bullet points. Each bullet must state what changed, why it matters, or a relevant constraint.
- Describe behavior and boundaries, not file churn or vague claims such as “improves code quality.”
- Include important constraints, compatibility details, error handling, migrations, risks, and intentionally deferred work under the correct template heading.
- Follow each template heading's purpose. Keep scope sections concrete, rationale sections causal, implementation sections specific, constraint sections relevant to review, and testing sections limited to commands that ran and their results.
- Do not claim that tests passed, a migration occurred, or behavior changed unless without checking for evidence
- Do not mention internal planning artifacts, temporary status, or future work unless the user requests them.

### Write the scope section

- Make the `What` section clear to a person who does not know the codebase.
- Start with a short statement that identifies the system area and the purpose of the change.
- Explain the affected workflows in simple terms.
- Keep important implementation and behavior details, but group related details so the section stays readable.

### Write the rationale section

- Make the `Why` section a direct justification for the change.
- Explain the concrete problem in the old code before you explain the solution.
- For refactors: Explain how the change improves code clarity, reduces repetition, or makes behavior easier to test.

Present the draft for review. Ask whether to revise it or create the PR. Do not invoke `gh pr create` yet.

## Create or update the PR

After explicit approval:

1. Verify GitHub CLI authentication with `gh auth status`.
2. If a PR already exists for the branch, update it with `gh pr edit` rather than creating another. Preserve bot-managed or auto-generated sections unchanged unless the user asks you to edit them. Do not use those sections as the source of truth for the human-written description.
3. Otherwise run `gh pr create` with the approved title, base, head, draft status, and body.
4. Return the PR URL and briefly note whether it was created or updated.

Use a quoted or file-backed body so Markdown is preserved exactly. Do not push commits, change branches, or modify repository files.
