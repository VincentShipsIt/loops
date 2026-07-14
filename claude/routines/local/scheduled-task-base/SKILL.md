---
name: scheduled-task-base
description: Base scheduled task wrapper for one scoped repository
---

Run the scheduled task for `[PROJECT]`.

Scope:
- Work only in `[REPO_PATH]`.
- GitHub repository: `[GITHUB_REPO]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]` or unrelated projects.

Safety:
- Read local agent instructions before acting.
- Check current git status before making changes.
- Search for duplicate branches, worktrees, issues, and PRs before creating anything.
- For code changes, discover the default branch directly from `origin` with `git ls-remote --symref origin HEAD`; accept only one symbolic `ref: refs/heads/<default-branch> HEAD` result and record it as `default_branch`.
- Fetch only that branch into its remote-tracking ref with `git fetch --prune origin "+refs/heads/${default_branch}:refs/remotes/origin/${default_branch}"`, then record `default_commit` with `git rev-parse "refs/remotes/origin/${default_branch}^{commit}"`. Stop if discovery or resolution is missing or ambiguous.
- Never use or mutate a local default branch. Create the work branch with no upstream directly from `default_commit` in a separate registered worktree.
- Before editing, require `git rev-parse HEAD` to equal `default_commit` exactly and `git status --porcelain=v1 --untracked-files=all` to produce no output; stop and report without editing if either check fails.
- Target `default_branch` when the task explicitly authorizes a pull request.
- Do not run production deploys, live migrations, destructive cleanup, or commands that write to external services unless this task explicitly allows it.
- Keep the run bounded. Stop cleanly if no safe action exists.

Output:
- Report actions taken, validation run, skipped work, blockers, and residual risk.
