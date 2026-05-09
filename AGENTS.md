# Agent Operating Rules

This project uses Product Symphony. Linear is the source of truth for task intent, status, and review.

## Before Starting

1. Read the target Linear issue.
2. Read `PRODUCT_WORKFLOW.md`.
3. Read `workflows/mode-router.md`.
4. Read `LINEAR_ACCESS.md` if you need to fetch or update Linear.
5. Select exactly one mode workflow:
   - `workflows/explore.md`
   - `workflows/prototype.md`
   - `workflows/build.md`
6. Confirm scope, non-goals, and merge policy from the issue.

If the issue has no `mode:*` label, stop and ask for product clarification in Linear.

## Workspace Rule

Each Linear issue must be worked on in an isolated branch or worktree.

Recommended branch prefixes:

- `experiment/<issue-id>-<slug>` for `mode: explore`
- `prototype/<issue-id>-<slug>` for `mode: prototype`
- `feature/<issue-id>-<slug>` for `mode: build`

Do not mix unrelated Linear issues in one branch.

## Linear Reporting Rule

At the end of every work session, post or prepare a Linear comment using `linear/templates/result-comment.md`.

The comment must include:

- What changed.
- Files changed.
- Verification performed.
- Product notes.
- Recommendation.
- Whether the result should merge, continue, convert to build, park, or discard.

## Product Safety

- `mode: explore` and `mode: prototype` are not production merge modes.
- Do not turn exploratory code into production code unless the issue is converted to `mode: build`.
- If the product direction changes during the session, update the Linear comment instead of silently changing goals.
- Keep all unresolved product questions visible in Linear.

## Code Safety

- Preserve unrelated user changes.
- Keep edits within the issue scope.
- Prefer existing project patterns over new abstractions.
- Run the project's normal checks when the mode requires production readiness.
