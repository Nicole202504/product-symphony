# Repository Handoff Ledger

Product Symphony uses Linear as the agent execution source of truth. Some downstream teams,
however, do not work from Linear. They review GitHub commits, pull requests, and repository docs.

For those teams, use a repository handoff ledger alongside Linear.

## Two Ledgers

### Linear: agent execution ledger

Use Linear for:

- issue intent, owner, status, and mode
- agent work session results
- changed files and verification
- product or design review outcome
- recommendation: continue, convert, merge, park, or discard

Every Product Symphony issue must end with a Linear result comment or a prepared result comment.

### Repository docs: engineering handoff ledger

Use a repo-tracked document for stable context that engineers and future agents need outside
Linear.

Recommended path:

```text
docs/product-rebaseline-context.md
```

Use the repository handoff ledger for:

- product background and current initiative structure
- confirmed product decisions
- information architecture or workflow decisions
- data model and API contracts
- implementation boundaries
- engineering handoff notes
- known repo state that affects future work

Do not use the repository handoff ledger as a replacement for Linear issue status.

## When To Update Both

Always update Linear at the end of an issue.

Also update the repository handoff ledger when the issue changes something that future engineers or
future agents must know without opening Linear:

- product direction changed
- MVP scope was decided
- a page structure or information architecture was accepted
- a data model, parser contract, or API contract was accepted
- an old approach was explicitly abandoned
- a cross-project dependency or handoff was created
- a non-code exploration produced a durable decision

## When Linear Alone Is Enough

Do not update the repository handoff ledger for ordinary issue execution details:

- small bug fixes
- copy tweaks
- lint or test fixes
- routine verification notes
- temporary exploration that did not change direction
- local failures that were fully resolved inside the issue

Those belong in the Linear result comment.

## Recommended Handoff Document Shape

```md
# Product Rebaseline Context

## Why This Exists

Short background for engineers and future agents.

## Linear Control Plane

Initiative:
- ...

Projects:
- ...

Current issue map:
- ...

## Product Decisions

- ...

## Engineering Contracts

- Data model:
- API contract:
- UI state model:

## Repo State Notes

- ...

## Agent Operating Rules

- One agent owns one issue.
- Fetch Linear issue before acting.
- Write a Linear result comment at the end.
- Update this document only for durable decisions and engineering handoff context.

## Open Questions

- ...
```

## Practical Rule

Linear answers: what did this agent do on this issue?

The repository handoff ledger answers: what should a future engineer or future agent know after the
issue is forgotten?
