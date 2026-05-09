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
cd elixir
./bin/symphony product.bootstrap --team ENG --project "Project Name" --brief ../examples/bootstrap-brief.md --dry-run
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

## First Version Promise

The product owner should only need to:

1. Write a Linear issue.
2. Add a `mode:*` label.
3. Ask the agent to work from that issue.
4. Review the Linear result comment.
