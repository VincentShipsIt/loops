# Codex Automation: Worktree Prune

Recommended settings:

- Kind: cron
- Execution environment: local
- Write surface: local worktree and local branch cleanup only

## Prompt

Clean up local worktrees and local branches in `[PROJECT]` that are already merged into `[TRUNK]`.

Scope:

- Work only in `[REPO_PATH]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.
- Clean local git worktrees and local branches only.
- Do not delete remote branches, push anything, deploy, run live migrations, or write production data.
- Only delete candidates when `[ALLOW_SAFE_DELETES]` is true. Otherwise report candidates only.

Workflow:

- Run in the local execution environment, not a disposable worktree.
- Run `git fetch --all --prune`.
- Verify local `[TRUNK]` exists.
- Record `git worktree list --porcelain`, local branches, remote branches, and current branch for each worktree before changing anything.
- For every worktree, run `git status --porcelain=v1 --untracked-files=all`.
- Never remove dirty worktrees or delete their branches.
- Never use `git clean`, `git reset`, `git checkout --`, `git branch -D`, or `git worktree remove --force`.
- A branch/worktree is eligible only when it is not `[TRUNK]`, has no dirty worktree attached, is merged into local `[TRUNK]`, is merged into `origin/[TRUNK]` when it exists, and file-level verification shows it contributes no file content absent from trunk.
- If `[ALLOW_SAFE_DELETES]` is true, remove eligible clean worktrees with `git worktree remove` without force and delete eligible local branches with `git branch -d`.
- Run `git worktree prune` after successful removals.

Output:

- Report removed branches/worktrees, cleanup candidates, skipped branches/worktrees, exact reason for each skip, dirty worktrees, and whether safe deletes were enabled.
