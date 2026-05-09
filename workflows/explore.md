# Explore Workflow

Use this for `mode: explore`.

## Goal

Help the product owner clarify the idea. Code is allowed, but the primary output is product learning.

## Steps

1. Restate the product question from the Linear issue.
2. Identify unknowns, assumptions, and constraints.
3. If useful, create a lightweight branch using `experiment/<issue-id>-<slug>`.
4. Explore options through notes, sketches in code, or small UI changes.
5. Avoid production refactors.
6. Prepare a Linear result comment.

## Output

The result comment should recommend one:

- Continue exploring.
- Convert to `mode: prototype`.
- Convert to `mode: build`.
- Park.
- Discard.

## Verification

Verification is lightweight:

- Confirm the idea is understandable.
- If code was touched, confirm it runs enough to support the exploration.
- Capture screenshots when visual changes matter.

## Merge Policy

Do not merge by default.

