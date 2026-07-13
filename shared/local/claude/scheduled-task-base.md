# Claude Desktop Scheduled Task: Base Wrapper

Use this as the starting shape for `~/.claude/scheduled-tasks/<task-name>/SKILL.md`.

```markdown
---
name: [task-name]
description: [short task summary]
---

Run this scheduled task autonomously.

Scope:
- Workspace: `[REPO_PATH]`
- Repository: `[GITHUB_REPO]`
- Base branch: `[TRUNK]`
- This task is scoped only to `[PROJECT]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.

Safety policy:
- Read local agent instructions before editing.
- Preserve unrelated user changes.
- Do not run destructive commands, production writes, deploys, live migrations, or credential-changing operations.
- If local policy prohibits required validation or it is too heavy for the configured environment, skip it, report the exact blocker, and do not publish unverified changes.
- If unsure whether a command is heavy or destructive, skip it and report why.

Workflow:
- Inspect current repo state, relevant issues/PRs, branches, and worktrees before selecting work.
- Choose at most one unit of work unless this is read-only or metadata-only.
- Skip work already covered by an open PR, active branch, active worktree, or existing issue.
- Create isolated work from `[TRUNK]` before editing when code changes are required.
- Keep changes tightly scoped.
- Run focused verification for touched behavior.
- Commit and open a pull request only when the task explicitly calls for implementation.
- If no safe work exists, report why and stop.

Output:
- Selected work or skip reason.
- Branch/worktree/PR when applicable.
- Files, issues, or project fields changed.
- Validation performed.
- Remaining risks or follow-up needed.
```
