---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
disable-model-invocation: true
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.

If the request is a small, self-contained change that can reasonably be implemented in a single pass without introducing important tradeoffs or follow-on decisions, skip the grilling process and implement it directly.

Examples include:

- Changing copy or wording.
- Tweaking styling, spacing, colors, or typography.
- Renaming variables, functions, or files.
- Fixing a straightforward bug with an obvious cause.
- Adding a small UI interaction (e.g. autofocus an input, add a loading spinner, disable a button while submitting).
- Adjusting validation messages or error text.

In contrast, use the grilling process for changes like:

- Adding a new feature or workflow.
- Redesigning a user experience.
- Choosing between multiple architectural approaches.
- Changing data models, APIs, or database schemas.
- Introducing new dependencies or infrastructure.
- Changes that affect multiple parts of the codebase or require several coordinated decisions.
- Any request where the implementation depends on unresolved product or technical decisions.
