# Downstream Feedback Loop

Product Symphony is a shared tool. When a downstream business project finds a Product Symphony
problem, report it back to the Product Symphony Linear project instead of leaving it inside the
business project chat.

## Agent Rule

If you are an agent working in another project and you discover a Product Symphony bug, missing
workflow, unclear instruction, or useful feature request, create a Product Symphony feedback issue.

Use:

```bash
./scripts/report-product-symphony-issue.sh \
  --type bug \
  --title "bootstrap-linear fails when label already exists" \
  --source-project "billing-console" \
  --command "./scripts/bootstrap-linear.sh --team ENG --brief brief.md" \
  --expected "Existing mode labels are reused" \
  --actual "Label creation failed" \
  --details /tmp/product-symphony-error.md
```

## Required Environment

```bash
export LINEAR_API_KEY=...
export PRODUCT_SYMPHONY_FEEDBACK_TEAM_KEY=ENG
export PRODUCT_SYMPHONY_FEEDBACK_PROJECT_SLUG=product-symphony
```

`PRODUCT_SYMPHONY_FEEDBACK_PROJECT_SLUG` is optional. If it is omitted, the issue is created in the
team without attaching it to a project.

## Issue Types

- `bug` -> `tool-bug`
- `feature` -> `tool-feature`
- `question` -> `tool-question`

The script creates the label if it does not exist.

## Dry Run

Use `--dry-run` to inspect the issue payload without creating anything:

```bash
./scripts/report-product-symphony-issue.sh \
  --type question \
  --title "How should prototype branches be cleaned up?" \
  --source-project "growth-dashboard" \
  --actual "The workflow does not say when to remove prototype worktrees" \
  --dry-run
```

## What To Include

Good feedback issues include:

- downstream project name;
- Product Symphony commit, if known;
- command or situation;
- expected behavior;
- actual behavior;
- logs, stack traces, or screenshots when available;
- whether the downstream project is blocked.

## Repair Flow

1. Downstream agent creates a feedback issue.
2. Product owner returns to the Product Symphony repo.
3. Product Symphony issue is triaged and fixed.
4. Fix is pushed to GitHub.
5. Downstream project updates its Product Symphony clone or submodule.

