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
./scripts/run-product-symphony.sh
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

### Linear Scope

The default workflow targets one Linear project:

```yaml
tracker:
  kind: linear
  project_slug: "my-project"
```

For product rebaseline work that spans multiple projects, configure a project group:

```yaml
tracker:
  kind: linear
  project_slugs:
    - "a-personal-space-rebuild-1c478af653df"
    - "b-github-skill-ingestion-058deef57088"
    - "c-landing-page-usable-paths-7024e2fc19ab"
```

Or target every project attached to a Linear initiative:

```yaml
tracker:
  kind: linear
  initiative_id: "7a85d8a6-4c57-4259-84d5-e5c6a9ce2818"
```

If both `project_slug` / `project_slugs` and `initiative_id` are present, Product Symphony polls the
union and de-duplicates issues by Linear issue ID.

## Recommended Linear Flow

Default Linear hierarchy:

```text
Initiative: Product Symphony
  Project: Product Symphony Feedback
  Project: Product Symphony Core
  Project: <business project using Product Symphony>
```

For product-led work, Product Symphony should be treated as an Initiative-level platform, not as a
single feature project.

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

## Product Bootstrap CLI

Product Symphony includes a first bootstrap command for turning a markdown brief/task map into a
Linear project with labeled issues:

```bash
./scripts/bootstrap-linear.sh \
  --team ENG \
  --project "AI Onboarding Dashboard" \
  --brief examples/bootstrap-brief.md
```

Use `--dry-run` first to inspect the payload without creating anything:

```bash
./scripts/bootstrap-linear.sh --team ENG --brief examples/bootstrap-brief.md --dry-run
```

The brief format is intentionally explicit:

```md
# Project Name

### Explore: First-run user mental model
mode: explore
deliverable: Option memo
acceptance: Recommendation posted to Linear

### Build: Persist checklist progress
mode: build
deliverable: Production implementation
acceptance: Progress persists across refresh
```

The command creates:

- a Linear project;
- the `mode:*` labels if missing;
- one Linear issue per task;
- issue descriptions containing mode, deliverable, and acceptance criteria.

## Downstream Feedback Loop

When Product Symphony is used inside another project and the agent finds a Product Symphony problem,
it should report the issue back to the Product Symphony Linear project:

```bash
export LINEAR_API_KEY=...
export PRODUCT_SYMPHONY_FEEDBACK_TEAM_KEY=ENG
export PRODUCT_SYMPHONY_FEEDBACK_PROJECT_SLUG=product-symphony

./scripts/report-product-symphony-issue.sh \
  --type bug \
  --title "bootstrap-linear fails when label already exists" \
  --source-project "billing-console" \
  --actual "The command failed during label creation"
```

See `docs/feedback-loop.md`.

The scripts load `.env.local` from the repository root when present. Keep real secrets in
`.env.local`; commit only `.env.example`.

## Repository Handoff Ledger

Linear is still the source of truth for agent execution, but some downstream engineering teams review
work through GitHub rather than Linear. In those projects, keep a repo-tracked handoff document for
durable decisions and engineering context.

Recommended downstream path:

```text
docs/product-rebaseline-context.md
```

Use Linear for issue status and agent result comments. Use the repo handoff document for stable
context such as product decisions, MVP boundaries, information architecture, data/API contracts, and
engineering handoff notes.

See `docs/repo-handoff.md`.

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
examples/bootstrap-brief.md     Example bootstrap input.
docs/startup.md                 Runtime setup model and wrapper scripts.
docs/feedback-loop.md           Automatic issue reporting from downstream projects.
docs/repo-handoff.md            Linear plus repo-doc handoff model for downstream engineering.
scripts/                        Stable setup/run entrypoints for new agents.
elixir/                         Upstream Symphony Elixir implementation.
```

## License And Attribution

The Symphony implementation is based on OpenAI's Apache-2.0 licensed Symphony project. See
`LICENSE`, `NOTICE`, and `SPEC.md`.
