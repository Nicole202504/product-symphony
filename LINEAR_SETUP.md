# Linear Setup

This template assumes Linear is the task source and review surface.

## Default Product Hierarchy

Product Symphony is an Initiative-level platform, not a single project.

Recommended structure:

```text
Initiative: Product Symphony
  Project: Product Symphony Feedback
  Project: Product Symphony Core
  Project: <business project using Product Symphony>
```

Use `Product Symphony Feedback` for downstream bug reports, feature requests, and questions.
Use separate business projects for actual product work.

## Required Labels

Create these labels:

- `mode: explore`
- `mode: bootstrap`
- `mode: prototype`
- `mode: build`
- `mode: park`
- `mode: discard`

Recommended optional labels:

- `agent: codex`
- `agent: claude`
- `needs: product-decision`
- `needs: design-review`
- `needs: eng-review`
- `merge: blocked`
- `merge: ready`

## Recommended States

Map these to your existing Linear workflow, or create them if your team wants a dedicated product-agent flow:

- `Idea`
- `Bootstrap`
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

## State Guidelines

- `Idea` - raw issue, not ready for agent execution.
- `Bootstrap` - product brief is being turned into a task map.
- `Exploring` - active product thinking.
- `Prototype` - active demo or spike.
- `Spec Ready` - product has decided what should be built.
- `Ready for Dev` - ready for an AI or human engineer.
- `In Build` - production implementation in progress.
- `Review` - waiting for product or engineering review.
- `Ready to Merge` - accepted and merge-ready.
- `Done` - shipped or otherwise completed.
- `Parked` - useful but inactive.
- `Discarded` - intentionally abandoned.

## Minimal First Version

If changing Linear states is too heavy, only create the `mode:*` labels first. Agents can still work correctly from labels plus issue templates.

## Agent Instruction

When starting work, tell the agent:

```text
Use Product Symphony. Work from Linear issue <ISSUE-ID>. Read AGENTS.md first, then follow the mode workflow from the issue label.
```
