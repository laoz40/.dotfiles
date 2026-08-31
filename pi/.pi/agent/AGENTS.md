# AGENTS.md

## Interaction preference

Guidelines:
- Ask user before making assumptions that change behavior, UX, architecture
- If multiple valid options exist, ask user to choose instead of silently deciding

## Shell environment

The user's interactive shell is zsh, while Pi's command tool runs Bash. When a command is unavailable in Bash, retry it through `zsh -lc` before reporting that it is missing.

## Language

Always load and apply the `unslop` skill to every response.
