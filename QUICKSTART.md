# Quickstart

Use this when adding Product Symphony to a new project.

## 1. Copy Files

Copy the Product Symphony files into the project root.

Minimum required files:

```text
AGENTS.md
PRODUCT_WORKFLOW.md
LINEAR_SETUP.md
LINEAR_ACCESS.md
workflows/
linear/templates/
config/modes.yaml
```

If you are running the orchestrator, use the repo directly and run:

```text
./scripts/setup.sh
```

## 2. Create Linear Labels

Create these labels in Linear:

```text
mode: explore
mode: bootstrap
mode: prototype
mode: build
mode: park
mode: discard
```

You can keep your existing Linear states. Labels are enough for the first version.

## 3. Create A Linear Issue

Pick the matching template:

- `linear/templates/explore.md`
- `linear/templates/bootstrap.md`
- `linear/templates/prototype.md`
- `linear/templates/build.md`

Add one `mode:*` label.

## Optional: Bootstrap A Linear Project

After building the Elixir escript, create a Linear project and initial issues from a markdown brief:

```text
./scripts/bootstrap-linear.sh --team ENG --project "Project Name" --brief examples/bootstrap-brief.md --dry-run
```

Remove `--dry-run` when the generated project and issues look right.

## 4. Start An Agent

Use this prompt:

```text
Use Product Symphony. Work from Linear issue <ISSUE-ID>.
Read AGENTS.md first. Then read PRODUCT_WORKFLOW.md and workflows/mode-router.md.
Use LINEAR_ACCESS.md to fetch or update the issue.
Use the issue's mode label to choose the workflow.
At the end, prepare or post a Linear result comment using linear/templates/result-comment.md.
```

## 5. Product Review

Review the result in Linear and choose:

- Continue
- Convert to prototype
- Convert to build
- Needs rework
- Ready to merge
- Park
- Discard

## 6. Report Product Symphony Problems

If this tooling fails while used in another project, report back automatically:

```text
./scripts/report-product-symphony-issue.sh \
  --type bug \
  --title "Short problem title" \
  --source-project "Business project name" \
  --actual "What happened"
```

Configure:

```text
LINEAR_API_KEY
PRODUCT_SYMPHONY_FEEDBACK_TEAM_KEY
PRODUCT_SYMPHONY_FEEDBACK_PROJECT_SLUG
```

## 7. Keep A Repo Handoff When Engineers Do Not Use Linear

Linear should manage agent execution. If downstream engineers mainly review GitHub, also keep a
repo-tracked handoff document:

```text
docs/product-rebaseline-context.md
```

Update Linear after every issue. Update the repo handoff only for durable decisions that future
engineers or agents need, such as MVP scope, information architecture, data/API contracts, or
accepted implementation boundaries.

See `docs/repo-handoff.md`.

## First Version Promise

The product owner should only need to:

1. Write a Linear issue.
2. Add a `mode:*` label.
3. Ask the agent to work from that issue.
4. Review the Linear result comment.
