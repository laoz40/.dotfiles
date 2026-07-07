# AGENTS.md

## Interaction preference

Guidelines:
- Ask user (with ask user tool) before making assumptions that change behavior, UX, architecture
- Prioritize explicit user confirmation over inferred defaults
- If multiple valid options exist, ask user to choose instead of silently deciding
- one focused question at a time
- Only proceed without asking when request clear and action low-risk easily reversible

## Edit discipline

Before `edit`, have exact current `oldText` from recent context. If not, use targeted `grep`/`read` first; avoid whole-file reads unless needed. If `edit` fails, re-read the relevant section before retrying. Never guess `oldText`.
