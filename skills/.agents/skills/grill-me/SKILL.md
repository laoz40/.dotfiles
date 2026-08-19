---
name: grill-me
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
disable-model-invocation: true
---

Interview the user relentlessly until you reach a shared understanding. Map this as a design tree: every decision branches into the decisions that hang off it.

Work the tree in rounds. The frontier is every decision whose prerequisites are already settled: the questions you can ask now without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Each question should be formatted like so:

❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a later round, not this one.

Finding facts is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The decisions are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.

## Progress indication

End each round with a rough progress indicator based on the design tree currently visible:

`Progress: ~<percentage>% | Estimated rounds remaining: ~<count>`

Treat both values as estimates, not targets or limits. Recalculate them whenever answers, research, or newly exposed branches change the tree. Progress may move backward and the estimated round count may increase when new questions or decisions appear.

## Scope

If a decision is a small, self-contained change that can reasonably be implemented in a single pass without introducing important tradeoffs or follow-on decisions, move on to something else.

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
