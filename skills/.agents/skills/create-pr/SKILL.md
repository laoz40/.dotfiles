---
name: create-pr
description: Drafts clear pull request descriptions from repository changes and creates GitHub pull requests with gh. Use when asked to write, revise, or create a PR description or pull request.
disable-model-invocation: true
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

- Make the description easy for humans to scan without dropping meaningful technical detail.
- Prefer short, specific bullet points. Each bullet should state what changed, why it matters, or a relevant constraint.
- Use plain language first; include technical terms where they explain a real design decision.
- Describe behavior and boundaries, not file churn or vague claims such as “improves code quality.”
- Include important constraints, compatibility details, error handling, migrations, risks, or intentionally deferred work under the template’s appropriate heading.
- Follow each template heading’s purpose. Keep scope sections concrete, rationale sections causal, implementation sections specific, constraint sections review-relevant, and testing sections limited to commands actually run and their results.
- Do not claim tests passed, a migration happened, or a behavior changed unless verified from the repository or user-provided evidence.
- Do not mention internal planning artifacts, temporary status, or future work unless the user wants them in the PR.

Present the draft for review. Ask whether to revise it or create the PR. Do not invoke `gh pr create` yet.

## Create or update the PR

After explicit approval:

1. Verify GitHub CLI authentication with `gh auth status`.
2. If a PR already exists for the branch, update it with `gh pr edit` rather than creating another.
3. Otherwise run `gh pr create` with the approved title, base, head, draft status, and body.
4. Return the PR URL and briefly note whether it was created or updated.

Use a quoted or file-backed body so Markdown is preserved exactly. Do not push commits, change branches, or modify repository files.
