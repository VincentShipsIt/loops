# Claude Scheduled Task: Prune Merged Worktrees

## Prompt

Clean up local worktrees and local branches in this repository that are already merged into `[TRUNK]`.

Repository policy:

- This task is scoped only to `[PROJECT]`: `[REPO_PATH]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.
- Clean local git worktrees and local branches only.
- Do not delete remote branches, push anything, deploy, run live migrations, or write production data.
- Always preserve these branch names exactly: `[TRUNK]`.
- Also preserve the currently checked-out branch in every worktree, unless that worktree is safely removed.
- Missing, unresolved, or false `[ALLOW_SAFE_DELETES]` means report-only. Never infer permission from the schedule or a previous run.

Preflight:

- Read local agent instructions if present.
- Run `git fetch --all --prune`.
- Verify local `[TRUNK]` exists.
- If `origin/[TRUNK]` exists, use both local and remote trunk as safety references.
- Record `git worktree list --porcelain`, local branches, remote branches, and current branch for each worktree before changing anything.

Dirty-work guard:

- For every worktree, run `git status --porcelain=v1 --untracked-files=all`.
- If a worktree has staged, unstaged, untracked, conflicted, or ignored-required local work, do not remove that worktree and do not delete its branch.
- Never use `git clean`, `git reset`, `git checkout --`, `git branch -D`, or `git worktree remove --force`.

Merged-work verification:

- Do not trust commit ancestry alone.
- A branch/worktree is eligible only when all are true:
  - branch is not `[TRUNK]`
  - branch has no dirty worktree attached
  - branch tip is merged into local `[TRUNK]`
  - if `origin/[TRUNK]` exists, branch tip is also merged into it
  - file-level verification shows the branch contributes no file content absent from trunk
- Prefer false negatives over false positives.
- Verify the branch has no commits that are absent from every configured remote; unpushed work is never eligible.

Cleanup actions:

- If `[ALLOW_SAFE_DELETES]` is not exactly true, list all eligible candidates and stop without deleting anything.
- Only when `[ALLOW_SAFE_DELETES]` is exactly true, remove eligible clean worktrees with `git worktree remove` without force and delete eligible local branches with `git branch -d` only.
- Run `git worktree prune` only after successful removals.
- If no worktrees or branches are eligible, report no-op with the candidate count and stop.

Output:

- Report removed branches/worktrees, every candidate, skipped branches/worktrees, exact reason for each skip, and whether safe deletes were enabled.
- Explicitly call out dirty worktrees.

Manual test before enabling deletes:

- Run once with `[ALLOW_SAFE_DELETES]` false or unresolved and verify the report lists candidates without changing worktrees or branches.
