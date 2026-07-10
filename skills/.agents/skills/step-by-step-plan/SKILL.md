---
name: step-by-step-plan
description: Creates concise, token-efficient implementation plans broken into reviewable steps with clear checks after each step. Use when the user asks to write a step by step implementation plan, or wants work split into steps they can review/test incrementally.
disable-model-invocation: true
---

# Step By Step Plan

## Purpose

- Create clear implementation order with thin vertical slices, so that each step is easy to review and test.

## Style Rules

- Prefer simplest sulution possible. Don't over-engineer.
- Be concise. Remove background unless needed for decisions.
- Use direct instructions, not long explanations.
- Each step should be independently reviewable/testable when possible.
- Find existing files/helpers to reuse if available.
- Make the plan token-efficient

## Plan Structure

```md
# [Plan Title]

## Goal

## Non-negotiable Rules and Resolved Decisions

- [Important behaviour/security/UX constraints]

## Implementation Steps

### Step 1: [Name]

[What to change]

### Step 2: [Name]

[What to change]
```

## Helper Naming Guidance

Use names that describe the exact output:

- Good: `getValidRescheduleLinkAndBooking`
- Good: `createFreshRescheduleLink`
- Good: `saveClientBookingReschedule`
- Avoid vague names: `resolveRequest`, `handleFlow`, `processData`

## Ask vs Infer

If unclear, ask the user about decisions that change behaviour, UX, architecture, data shape, security, cost, or rollback risk.

Ask about:

- user-facing behaviour
- security/privacy choices
- data model or migration choices that are hard to reverse
- integration side effects, e.g. payment, email, external APIs
- destructive or risky actions, e.g. delete, overwrite, rollback, auto-send
- unclear scope, e.g. whether to include frontend, backend, tests, docs

Infer safely when the choice is low-risk, conventional, easy to change.

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

