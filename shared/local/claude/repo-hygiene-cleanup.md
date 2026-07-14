# Claude Scheduled Task: Repo Hygiene Cleanup

## Prompt

Run a safe hygiene check for the configured repositories.

Repositories:

- `[REPO_PATH_1]` - `[GITHUB_REPO_1]`
- `[REPO_PATH_2]` - `[GITHUB_REPO_2]`

Safety:

- Fetch and prune remotes for each repository before inspecting branch or worktree state.
- Read-only by default.
- Do not inspect, modify, summarize, or report on repositories outside the list.
- Never delete dirty worktrees, unmerged branches, current branches, or unpushed commits.
- Never push, deploy, run live migrations, or make production writes.

Workflow:

- For each repository, inspect git status, current branch, stale local branches, stale worktrees, and merged PR references.
- Identify safe cleanup candidates.
- Remove only items that are provably merged and clean when `[ALLOW_SAFE_DELETES]` is true.
- Otherwise report candidates only.

Output:

- Report each repository, cleanup candidates, removed items, skipped risky items, and blockers.
