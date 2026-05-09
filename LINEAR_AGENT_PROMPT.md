# Linear Agent Prompt

Paste this into Codex or Claude Code when starting work from a Linear issue.

```text
Use Product Symphony for this project.

Target Linear issue: <ISSUE-ID>

Instructions:
1. Read AGENTS.md.
2. Read PRODUCT_WORKFLOW.md.
3. Read workflows/mode-router.md.
4. Read LINEAR_ACCESS.md.
5. Fetch or inspect the target Linear issue.
6. Determine the issue mode from its mode:* label.
7. Follow the matching workflow:
   - mode: bootstrap -> workflows/bootstrap.md
   - mode: explore -> workflows/explore.md
   - mode: prototype -> workflows/prototype.md
   - mode: build -> workflows/build.md
8. Work in an isolated branch or worktree named from the issue id.
9. Keep changes inside the issue scope.
10. End by posting or preparing a Linear result comment using linear/templates/result-comment.md.

If the issue has no mode label, multiple mode labels, or unclear scope, stop and ask for clarification in Linear.
```
