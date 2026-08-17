# AGENTS.md

## Interaction preference

Guidelines:
- Ask user before making assumptions that change behavior, UX, architecture
- If multiple valid options exist, ask user to choose instead of silently deciding

## Picking the right models for subagents

Rankings out of 10, higher = better. Higher cost efficiency = less token usage. My token usage is finite. Taste covers UI/UX, code quality, API design, and copy.

| Model | Thinking Level | Intelligence | Cost Efficiency | Taste |
| --- | --- | --- | --- | --- |
| gpt-5.6-sol | Medium |  8.5 | 2 | 8 |
| gpt-5.6-sol | Low |  8 | 4 | 7 |
| gpt-5.6-terra | High |  7.5 | 6 | 5 |
| gpt-5.6-terra | Medium |  4.5 | 8 | 4 |
| gpt-5.6-luna | High | 6 | 10 | 2 |
| gpt-5.6-luna | Medium | 4 | 10 | 2 |

- Don't let cost prevent you from using the right model for the job. Instead, take advantage of cheaper options to get more information and try things before moving the work to a more expensive option.
- Anything user-facing (UI, API design) needs taste at least 7.

## Language

- Use simple 10th grade English when explaning or talking to me.
- Facts survive verbatim. Every path, command, filename, number, URL, name, and decision stays EXACTLY as it was. Simplify the explanation around the facts, never the facts themselves.
- Casual and direct ("basically", "pretty much", "ok so"). A touch of personality is welcome.
