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
- When code changes are required, discover the default branch directly from `origin` with `git ls-remote --symref origin HEAD`; accept only one symbolic `ref: refs/heads/<default-branch> HEAD` result and record it as `default_branch`.
- Fetch only that branch into its remote-tracking ref with `git fetch --prune origin "+refs/heads/${default_branch}:refs/remotes/origin/${default_branch}"`, then record `default_commit` with `git rev-parse "refs/remotes/origin/${default_branch}^{commit}"`. Stop if discovery or resolution is missing or ambiguous.
- Never use or mutate a local default branch. Create the work branch with no upstream directly from `default_commit` in a separate registered worktree.
- Before editing, require `git rev-parse HEAD` to equal `default_commit` exactly and `git status --porcelain=v1 --untracked-files=all` to produce no output; stop and report without editing if either check fails.
- Keep changes tightly scoped.
- Run focused verification for touched behavior.
- Commit and open a pull request against `default_branch` only when the task explicitly calls for implementation.
- If no safe work exists, report why and stop.

Output:
- Selected work or skip reason.
- Branch/worktree/PR when applicable.
- Files, issues, or project fields changed.
- Validation performed.
- Remaining risks or follow-up needed.
```
