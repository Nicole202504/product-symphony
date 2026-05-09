# Product Symphony

Product Symphony is a product-aware fork layer on top of OpenAI Symphony.

OpenAI Symphony already solves the engineering orchestration problem:

```text
Linear issue -> isolated workspace -> Codex agent -> Linear/PR handoff
```

Product Symphony keeps that structure and adds a product layer:

```text
Product brief -> Linear project/issues -> mode router -> isolated workspace
  -> explore/prototype/build workflow -> product review
```

The goal is to let a product owner work from Linear without manually creating worktrees, copying
context between conversations, or treating every idea as production implementation.

## What Is Different From Upstream Symphony

Product Symphony adds:

- Product bootstrap guidance for creating the initial Linear project and issue set.
- `mode:*` labels that route issues into product workflows.
- Product-specific Linear templates and review decisions.
- A product-oriented Symphony workflow at `elixir/WORKFLOW.product.md`.

It preserves the upstream Symphony shape:

- `SPEC.md` is the upstream service specification.
- `elixir/` contains the upstream Elixir/OTP reference implementation.
- Per-issue workspace allocation is handled by Symphony's existing workspace manager.
- Codex agent execution is handled by Symphony's existing agent runner.

## Product Modes

Use exactly one mode label on each Linear issue:

- `mode: bootstrap` - create or refine the project's Linear task map.
- `mode: explore` - clarify a product question; code is optional and not merge-bound.
- `mode: prototype` - build a demo or spike; not production by default.
- `mode: build` - implement production-ready code and prepare for review.
- `mode: park` - keep the idea but do not execute.
- `mode: discard` - intentionally abandon.

The core rule:

```text
explore/prototype do not merge by default.
build is the only mode that targets production merge by default.
```

## How The Automated Worktree Assignment Works

Use the Elixir Symphony runner with the product workflow:

```bash
cd elixir
./bin/symphony ./WORKFLOW.product.md
```

The runner polls the configured Linear project. For every eligible issue, it:

1. Reads the issue and labels from Linear.
2. Creates an isolated workspace under `workspace.root`.
3. Runs `hooks.after_create` to clone/bootstrap the target repo.
4. Starts Codex in that workspace.
5. Sends the product-aware workflow prompt.
6. Lets the agent update Linear according to the mode.

That means Product Symphony does not need a separate manual worktree step. The issue itself is the
unit of allocation.

## Recommended Linear Flow

1. Product owner creates a `mode: bootstrap` issue with the project brief.
2. Agent turns the brief into a Linear project task map:
   - issues
   - mode labels
   - deliverables
   - acceptance criteria
3. Symphony runs against that Linear project.
4. `mode: build` issues can be handled autonomously by coding agents.
5. `mode: explore` and `mode: prototype` issues create isolated workspaces for product discussion,
   demo work, and product review.
6. Product owner decides whether to continue, convert to build, park, discard, or merge.

## Important Files

```text
PRODUCT_SPEC.md                 Product-specific architecture and behavior.
PRODUCT_WORKFLOW.md             Human-readable product workflow.
LINEAR_SETUP.md                 Linear labels/states to create.
LINEAR_ACCESS.md                Agent access rules for Linear.
LINEAR_AGENT_PROMPT.md          Manual fallback prompt for Codex/Claude.
linear/templates/               Issue and result comment templates.
workflows/                      Mode-specific workflow docs.
elixir/WORKFLOW.product.md      Product-aware Symphony runtime workflow.
elixir/                         Upstream Symphony Elixir implementation.
```

## License And Attribution

The Symphony implementation is based on OpenAI's Apache-2.0 licensed Symphony project. See
`LICENSE`, `NOTICE`, and `SPEC.md`.

