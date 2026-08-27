---
name: review-pr-issues
description: Inspects the current pull request and walks through the latest code review feedback one issue at a time. Use when the user asks to review, address, fix, or triage PR review comments, including CodeRabbit feedback.
disable-model-invocation: true
---

# Review PR Issues

## Workflow

1. Confirm the current directory belongs to the pull request's branch.
2. Use `gh` to inspect the current PR and fetch its reviews, inline review comments, and conversation comments.
3. Identify the comments belonging to the latest review round. Prefer unresolved feedback and exclude summaries, praise, duplicates, and already-resolved issues.
4. Inspect the referenced code, surrounding context, call sites, and relevant types or existing tests.
5. Verify each comment rather than trusting the reviewer by default. Trace the actual behavior and, only when useful, run an existing focused check such as a test, typecheck, or linter. Do not create tests solely to triage a comment. Classify it as **Confirmed issue**, **False positive**, or **Unclear**.
6. Present exactly **one comment per message**, then stop and wait for the user. Include false positives so the user can explicitly ignore them.

For a **Confirmed issue** or **Unclear** comment, include:

- **Context:** The file and line range, relevant behavior, and a concise fenced code excerpt that makes the concern easy to visualize. Include only enough surrounding code to understand it.
- **Issue:** A plain-English explanation of the reviewer’s concern.
- **Verification:** The classification and concise evidence from the code or a focused check.
- **Suggested fix:** For a confirmed issue, propose the smallest appropriate change. For an unclear result, state the next check needed.

For a **False positive**, keep the response brief: identify the comment, label it **False positive**, and give one concise reason why the current code is correct. Do not include the full context, code excerpt, or suggested fix unless the user asks.

Do not apply a fix until the user asks. If the user chooses to:

- **Fix it:** Make the smallest appropriate change, run focused validation when practical, briefly report the result, then present the next issue in the same message.
- **Ignore it:** Briefly acknowledge the decision, then present the next issue in the same message.
- **Discuss it:** Answer questions about only the current issue; do not advance until the user fixes or ignores it.

Never present multiple review issues in one message. Preserve the review order when practical, prioritizing correctness and security before maintainability or style. When no actionable issues remain, say so clearly.
