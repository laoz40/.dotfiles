---
name: step-by-step-plan
description: Creates concise, token-efficient implementation plans broken into reviewable steps with clear checks after each step. Use when the user asks to write a step by step implementation plan, or wants work split into steps they can review/test incrementally.
---

# Step By Step Plan

## Purpose

Write short, practical plans for another agent or developer to follow. Optimize for clear implementation order, checkpoints, and low token use.

## Style Rules

- Be concise. Remove background unless needed for decisions.
- Use direct instructions, not long explanations.
- Break work into numbered steps.
- Each step should be independently reviewable/testable when possible.
- Add a short `Check after step` list for each step.
- Preserve important behaviour rules and decisions.
- Use stable helper/function names that explain what they return or do.

## Plan Structure

```md
# [Plan Title]

## Goal

[1-3 sentences or bullets]

## Rules

- [Important behaviour/security/UX constraints]

## Implementation Steps

### Step 1: [Name]

[What to change]

Check after step:

- [How to verify]
- [What should not break]

### Step 2: [Name]

[What to change]

Check after step:

- [How to verify]

## Final Checks

- [End-to-end tests]
```

## Workflow

1. Identify the goal and final user-facing behaviour.
2. List non-negotiable rules and resolved decisions.
3. Find existing files/helpers to reuse if available.
4. Split implementation into small ordered steps.
5. For each step, add checks the user can run or inspect before continuing.
6. End with final checks.

## Helper Naming Guidance

Use names that describe the exact output:

- Good: `getValidRescheduleLinkAndBooking`
- Good: `createFreshRescheduleLink`
- Good: `saveClientBookingReschedule`
- Avoid vague names: `resolveRequest`, `handleFlow`, `processData`

## Ask vs Infer

Ask the user when the answer changes behaviour, UX, architecture, data shape, security, cost, or rollback risk.

Ask about:

- user-facing behaviour
- security/privacy choices
- data model or migration choices that are hard to reverse
- integration side effects, e.g. payment, email, external APIs
- destructive or risky actions, e.g. delete, overwrite, rollback, auto-send
- unclear scope, e.g. whether to include frontend, backend, tests, docs

Infer safely when the choice is low-risk, conventional, easy to change, or can be written as a plan step.

Infer/default on:

- file organization when an obvious nearby location exists
- helper names
- implementation order
- minor UI copy that can be edited later
- validation details already implied by existing rules
- tests/checks that naturally follow the feature

If a decision is small and easy to change, do not stop to ask. Make a clear assumption and add a checkpoint where the user can correct it.

Use this pattern:

```md
Assumption: [small decision chosen].
Check after step: confirm [decision] before continuing if it matters.
```

