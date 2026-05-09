# Startup Model

Product Symphony inherits upstream Symphony's runtime model.

## How Upstream Symphony Handles Runtime Setup

Symphony does not vendor Erlang or Elixir into the repo. Instead, the Elixir implementation keeps a
`mise.toml` file in `elixir/` that pins the expected toolchain. A new machine runs:

```bash
cd elixir
mise trust
mise install
mise exec -- mix setup
mise exec -- mix build
```

That produces `elixir/bin/symphony`, the executable used to run the orchestrator.

## Product Symphony Wrapper Scripts

Product Symphony adds scripts so another Codex does not need to remember the raw Elixir commands.

Setup:

```bash
./scripts/setup.sh
```

Bootstrap a Linear project from a markdown task map:

```bash
./scripts/bootstrap-linear.sh --team ENG --brief examples/bootstrap-brief.md --dry-run
```

Run the product-aware Symphony daemon:

```bash
export LINEAR_API_KEY=...
export PRODUCT_SYMPHONY_TARGET_REPO=git@github.com:org/repo.git
./scripts/run-product-symphony.sh
```

The wrapper scripts also load `.env.local` from the repository root when it exists.

Before running the daemon, update `elixir/WORKFLOW.product.md`:

```yaml
tracker:
  project_slug: "your-linear-project-slug"
```

## Why This Solves The Codex Handoff Problem

A new Codex instance only needs to:

1. Clone the repo.
2. Run `./scripts/setup.sh`.
3. Set `LINEAR_API_KEY` and `PRODUCT_SYMPHONY_TARGET_REPO`.
4. Run either `./scripts/bootstrap-linear.sh` or `./scripts/run-product-symphony.sh`.

The pinned toolchain remains upstream-compatible, while the wrapper scripts provide a stable,
product-friendly entrypoint.
