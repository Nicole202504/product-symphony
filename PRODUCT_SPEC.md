# Product Symphony Specification

Status: Draft v0

Purpose: Extend Symphony from engineering task execution into product-led AI development.

## 1. Problem

Product work often starts before a task is ready for engineering. A product owner may need to:

- Discuss an idea with an agent.
- Turn a vague brief into Linear tasks.
- Try a UI or feature prototype.
- Decide which experiments become production work.
- Let coding agents execute clear build tasks.

Plain Symphony is excellent once issues are ready to execute. Product Symphony adds the missing
front half: project bootstrap, mode routing, and product review.

## 2. Architecture

```text
Product owner
  -> Product brief
  -> Linear bootstrap issue
  -> Product task map in Linear
  -> Symphony orchestrator
  -> mode-aware agent workflow
  -> product review decision
```

## 3. Components

### 3.1 Product Bootstrap

Input:

- Product brief.
- Target Linear team/project.
- Optional repo or design links.

Output:

- Linear project or project task map.
- Initial issues.
- Exactly one `mode:*` label per issue.
- Deliverable and merge policy per issue.

Bootstrap can be run by a product agent before the main Symphony daemon is started, or represented
as a `mode: bootstrap` issue in an intake Linear project.

### 3.2 Mode Router

The mode router reads Linear labels and routes the issue:

- `mode: bootstrap` -> create/refine task map.
- `mode: explore` -> clarify direction; code optional; no merge by default.
- `mode: prototype` -> demo/spike; no merge by default.
- `mode: build` -> production implementation; review/merge path.
- `mode: park` -> no execution.
- `mode: discard` -> no execution.

### 3.3 Workspace Allocation

Workspace allocation is inherited from Symphony:

```text
one Linear issue -> one isolated workspace
```

Recommended branch prefixes:

- `product-bootstrap/<issue-id>-<slug>`
- `experiment/<issue-id>-<slug>`
- `prototype/<issue-id>-<slug>`
- `feature/<issue-id>-<slug>`

### 3.4 Agent Workflows

The same Codex runner can execute all modes. The workflow prompt defines behavior:

- Explore agents are allowed to ask product questions in Linear and produce notes or light code.
- Prototype agents create demos and mark shortcuts clearly.
- Build agents implement production-ready code and prepare PR/review output.

### 3.5 Product Review

The product owner chooses one decision after every result:

- Continue.
- Convert to prototype.
- Convert to build.
- Needs rework.
- Ready to merge.
- Park.
- Discard.

## 4. Linear Requirements

Default hierarchy:

```text
Initiative: Product Symphony
  Project: Product Symphony Feedback
  Project: Product Symphony Core
  Project: <business project using Product Symphony>
```

Product Symphony itself should be modeled as an Initiative because it is a long-lived shared tool.
Feedback, roadmap, and business delivery can then live in separate Projects under that Initiative.

Required labels:

- `mode: bootstrap`
- `mode: explore`
- `mode: prototype`
- `mode: build`
- `mode: park`
- `mode: discard`

Recommended states:

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

## 5. Product Bootstrap CLI

The first bootstrap implementation accepts an explicit markdown task map and creates Linear
resources.

Command:

```bash
symphony product.bootstrap --team <TEAM_KEY> --brief <brief.md> [--project <NAME>] [--dry-run]
```

Input:

- H1 project name.
- Task sections using `### Explore: ...`, `### Prototype: ...`, `### Build: ...`, or an explicit
  `mode:` field.
- `deliverable:` and `acceptance:` fields per task.

Output:

- Linear project.
- `mode:*` labels.
- Initial Linear issues with mode, deliverable, and acceptance criteria.

This version does not yet ask an AI to infer the issue breakdown from a loose conversation. The
product owner or agent first turns the conversation into a markdown brief, then the CLI creates the
Linear project structure.

## 6. First Runtime Version

The first runnable version is upstream Symphony plus `elixir/WORKFLOW.product.md`.

It uses the existing Symphony mechanisms for:

- polling Linear;
- creating workspaces;
- launching Codex;
- injecting issue context;
- preserving logs and dashboard state.

The product behavior lives in:

- Linear labels;
- issue templates;
- the product workflow prompt;
- product review comments.

Future versions may add first-class Elixir modules for automatic Linear project creation and label
setup.
