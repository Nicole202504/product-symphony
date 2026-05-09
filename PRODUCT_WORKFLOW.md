# Product Workflow

Product Symphony separates product maturity from implementation effort. A Linear issue can start as a vague idea, become a prototype, turn into a spec, and then become production work.

## Mode Definitions

### `mode: explore`

Use this when the product question is still open.

Good for:

- Discussing a new idea.
- Comparing directions.
- Small UI experiments.
- Understanding user flows.
- Producing a product memo.

Allowed outputs:

- Notes.
- Options.
- Lightweight code.
- Screenshots.
- A recommendation.

Default merge policy:

```text
Do not merge.
```

### `mode: prototype`

Use this when the direction is plausible and needs a concrete demo.

Good for:

- A clickable frontend demo.
- A page variant.
- A feature spike.
- A throwaway implementation to learn from.

Allowed outputs:

- Working demo.
- Prototype branch.
- Screenshots or recording.
- Reuse notes.
- Conversion recommendation.

Default merge policy:

```text
Do not merge unless converted to mode: build.
```

### `mode: build`

Use this when the desired behavior is clear enough to implement.

Good for:

- Production UI changes.
- Feature implementation.
- Bug fixes.
- Refactors attached to a clear acceptance criterion.

Required outputs:

- Production-ready code.
- Verification.
- Review summary.
- PR or merge-ready diff, depending on the team workflow.

Default merge policy:

```text
Prepare for review and merge.
```

## Review Decisions

After reviewing agent output, choose one:

- `continue` - keep exploring the same issue.
- `convert to prototype` - the idea needs a demo.
- `convert to build` - the direction is decided and should become production work.
- `merge` - build work is accepted.
- `park` - useful, but not now.
- `discard` - intentionally abandon the branch and record why.

## Product Owner Role

The product owner decides:

- Which mode the issue is in.
- Whether a prototype becomes a build task.
- Whether exploratory code can be reused.
- Whether the final result matches the product intent.

AI can suggest, summarize, and implement, but the product owner owns the mode change and final decision.

