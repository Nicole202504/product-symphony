# Build Workflow

Use this for `mode: build`.

## Goal

Implement production-ready changes based on a clear product decision.

## Required Issue Fields

The Linear issue should include:

- Goal.
- Scope.
- Non-goals.
- Acceptance criteria.
- Verification expectations.
- Links to prototype or design references, if any.

If these are missing, ask for clarification before making broad changes.

## Steps

1. Read the Linear issue and all relevant comments.
2. Create an isolated branch using `feature/<issue-id>-<slug>`.
3. Implement within the stated scope.
4. Run relevant tests, build checks, lint checks, or manual verification.
5. Prepare a review-ready summary.
6. Post or prepare a Linear result comment.

## Output

The result comment should include:

- Implementation summary.
- Files changed.
- Verification results.
- Known risks.
- Review notes.
- PR link if one exists.

## Merge Policy

Prepare for review and merge.

