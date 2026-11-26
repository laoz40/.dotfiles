---
name: code-review
description: Review a branch, PR, or working-tree diff. Confirm intent from conversation and PR context.
---

## Confirm scope and intent

Resolve the comparison from the request and repository state. Honor explicit refs or PRs; otherwise infer the scope and ask only if materially ambiguous. Include staged and unstaged changes for working-tree reviews. Validate refs, check for a non-empty diff, and record the comparison. Use merge-base comparison for branches unless requested otherwise.

Infer intent from available conversation, PR description, linked issues, and user-supplied documents. Prioritize the user's latest instructions and corrections. Read applicable `AGENTS.md` files and relevant repository guidance. Surface material conflicts or missing context. Do not treat the implementation as evidence of intended behavior.

Summarize the intended outcome, constraints, and review scope in a few sentences or short bullets. Ask for confirmation and wait before substantive review. If corrected, confirm the revised understanding.

### Intent

Find missing or partial requirements, behavior that contradicts the agreed outcome, and changes outside scope. Tie findings to the confirmed intent or an explicit source.

### Code

Check correctness, regressions, broken callers, edge cases, and repository instruction violations. Assess test coverage for meaningful risks in the changed behavior. Skip issues caught by configured tooling.

Assess maintainability and design using these smells as investigation prompts:

- Mysterious names, duplicated logic, feature envy, data clumps, and primitive obsession.
- Repeated switches, shotgun surgery, divergent change, and speculative generality.
- Message chains, middle men, and refused bequest.

Report a smell when you can explain its cost to understanding, maintenance, extension, or reliability. A runtime bug is not required. Account for repository conventions and existing boundaries; suggest proportionate improvements rather than prescribing a code shape.

## Report

Keep **Intent findings** and **Code findings** in separate lists, ordered by severity within each. State briefly when a list is empty. Report each issue once.

For each finding, give a precise file location, the problem, the condition or context in which it matters, and its consequence. Cite the relevant requirement or repository rule. Distinguish defects from design judgments and support findings with evidence.

Keep the report concise and actionable. End with checks performed and material verification gaps.
