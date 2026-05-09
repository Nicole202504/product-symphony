# Linear Access

Product Symphony assumes Linear is the source of truth. Agents should fetch the issue directly when they have Linear access.

## Preferred: Linear MCP

If the environment provides Linear MCP tools, use them in this order:

1. `get_issue` for the target issue.
2. `list_comments` for discussion history.
3. `save_comment` to post the result comment.
4. `save_issue` only when explicitly asked to update labels, assignee, status, or relations.

Do not change issue state or labels unless the product owner asked for it or the workflow explicitly requires it.

## Fallback: User-Pasted Issue

If Linear access is unavailable, ask the product owner to paste:

- Issue identifier.
- Title.
- Description.
- Labels.
- Current state.
- Relevant comments.
- Linked design or PR references.

Then proceed using the same mode routing.

## Minimum Issue Data

An agent needs:

- One `mode:*` label.
- Goal or question.
- Scope.
- Non-goals, if any.
- Expected output.
- Merge policy.

If any of these are missing, ask a short clarification in Linear or prepare a clarification comment.

## Result Comments

Use `linear/templates/result-comment.md`.

Result comments should be concise enough for a product owner to review from Linear without reopening the whole chat.

