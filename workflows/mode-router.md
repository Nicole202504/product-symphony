# Mode Router

Use this file to choose the correct workflow for a Linear issue.

## Inputs

Read from Linear:

- Issue identifier.
- Title.
- Description.
- Labels.
- Current state.
- Comments.
- Linked design, PR, or attachment references.

## Routing

Choose exactly one:

- Label `mode: explore` -> `workflows/explore.md`
- Label `mode: prototype` -> `workflows/prototype.md`
- Label `mode: build` -> `workflows/build.md`
- Label `mode: park` -> do not execute, summarize if asked.
- Label `mode: discard` -> do not execute, preserve the decision record.

If multiple `mode:*` labels exist, stop and ask for clarification in Linear.

If no `mode:*` label exists, stop and ask for a mode.

## Branch Naming

Use:

```text
<branch-prefix>/<issue-id>-<short-slug>
```

Examples:

```text
experiment/ABC-123-homepage-navigation
prototype/ABC-124-billing-demo
feature/ABC-125-settings-permissions
```

## Linear Comment Requirement

Every execution path must end with a Linear result comment or a prepared result comment.

