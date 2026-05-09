# Product Symphony

Product Symphony is a reusable coordination template for product-led AI development with Linear, Codex, Claude Code, and human review.

It is inspired by OpenAI Symphony, but tuned for product work where some Linear issues are still ideas, some are prototypes, and some are ready for implementation.

## What This Solves

- Multiple AI conversations working on different pages or ideas without stepping on each other.
- Product context living in Linear instead of scattered chat history.
- Experimental work that can be explored, reviewed, continued, converted, or discarded without polluting the main codebase.
- A repeatable path from vague idea to demo to spec to build.

## Core Model

```text
Linear issue
  -> mode router
  -> isolated workspace
  -> agent workflow
  -> Linear result comment
  -> product review
  -> continue / convert / build / merge / discard
```

Linear is the control plane. The repo documents define how agents should behave. Git branches or worktrees isolate each issue.

## Modes

Use one of these labels on every Linear issue:

- `mode: explore` - unclear idea, discussion and discovery allowed, code optional.
- `mode: prototype` - product direction is plausible, create a demo or spike, not production by default.
- `mode: build` - spec is clear, implement production-ready changes and prepare for review.
- `mode: park` - recorded but not active.
- `mode: discard` - intentionally abandoned.

The most important rule:

```text
explore/prototype do not merge by default.
build is the only mode that targets production merge by default.
```

## Daily Usage

1. Create or update a Linear issue.
2. Add one `mode:*` label.
3. Fill the matching template from `linear/templates/`.
4. Start Codex or Claude Code in the project.
5. Tell the agent: "Work from Linear issue ABC-123 using Product Symphony."
6. The agent reads `AGENTS.md`, `PRODUCT_WORKFLOW.md`, and the mode workflow.
7. The agent works in an isolated branch/worktree and posts a Linear result comment.
8. You review in Linear and decide the next state.

## Recommended Linear States

- `Idea`
- `Exploring`
- `Prototype`
- `Spec Ready`
- `Ready for Dev`
- `In Build`
- `Review`
- `Ready to Merge`
- `Done`
- `Parked`
- `Discarded`

If your Linear team already has states, map these concepts onto existing names instead of renaming everything on day one.

## Repository Layout

```text
AGENTS.md
PRODUCT_WORKFLOW.md
LINEAR_SETUP.md
LINEAR_ACCESS.md
linear/
  templates/
    explore.md
    prototype.md
    build.md
    result-comment.md
workflows/
  mode-router.md
  explore.md
  prototype.md
  build.md
  review.md
config/
  modes.yaml
```

## First Project Setup

Copy these files into a project repo. Then create the Linear labels listed in `LINEAR_SETUP.md`. After that, new agents should be able to read the repo and understand how to use Linear as the task source.

For agent access patterns, read `LINEAR_ACCESS.md`.
