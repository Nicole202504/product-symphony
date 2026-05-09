# Prototype Workflow

Use this for `mode: prototype`.

## Goal

Create a concrete demo or spike that helps the product owner make a decision.

## Steps

1. Read the Linear issue and confirm the prototype scope.
2. Create an isolated branch using `prototype/<issue-id>-<slug>`.
3. Build only enough to evaluate the product direction.
4. Prefer visible, reviewable output: a local demo, screenshot, or recording.
5. Mark any shortcut or throwaway code clearly in the Linear result comment.
6. Recommend whether to continue, convert to build, park, or discard.

## Output

The result comment should include:

- Demo summary.
- What is real versus mocked.
- Files changed.
- Reuse notes.
- Product tradeoffs.
- Recommendation.

## Verification

Run enough checks to prove the demo works. Full production checks are optional unless the issue asks for them.

## Merge Policy

Do not merge unless the product owner converts the issue to `mode: build`.

