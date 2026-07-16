# AGENTS.md

## Interaction preference

Guidelines:
- Ask user (with ask user tool) before making assumptions that change behavior, UX, architecture
- If multiple valid options exist, ask user to choose instead of silently deciding

## Picking the right models for subagents

Rankings out of 10, higher = better. Higher cost efficiency = less token usage. My token usage is finite. Taste covers UI/UX, code quality, API design, and copy.

| Model | Thinking Level | Intelligence | Cost Efficiency | Taste |
| --- | --- | --- | --- | --- |
| gpt-5.6-sol | Medium |  8.5 | 2 | 8 |
| gpt-5.6-sol | Low |  7 | 5 | 7 |
| gpt-5.6-terra | High |  7.5 | 4.5 | 5 |
| gpt-5.6-terra | Medium |  4.5 | 8.5 | 4 |
| gpt-5.6-terra | Low |  2.5 | 9 | 4 |

- These are defaults, not limits. You have permission to override them: if a chosen model's output doesn't meet the bar, rerun or redo the work with a smarter model without asking. Judge the output, not the price tag. Escalating costs less than shipping mediocr
work.
- Don't let cost prevent you from using the right model for the job. Instead, take advantage of cheaper options to get more information and try things before moving the work to a more expensive option.
- Anything user-facing (UI, API design) needs taste at least 7.

- background subagents only for concurrent independent tasks.
