---
name: worktree-prune
description: Report or remove only clean provably merged local worktrees
---

Prune merged local worktrees and branches for `[PROJECT]`.

Scope:
- Work only in `[REPO_PATH]`.
- GitHub repository: `[GITHUB_REPO]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.
- Clean local git worktrees and local branches only. Never delete remote branches or push.
- Missing, unresolved, or false `[ALLOW_SAFE_DELETES]` means report-only.

Safety preflight:
- Run in the local execution environment, not a disposable worktree.
- Read local agent instructions and run `git fetch --all --prune`.
- Verify local `[TRUNK]`; use both local and `origin/[TRUNK]` as safety references when the remote exists.
- Record `git worktree list --porcelain`, all local/remote branches, and the current branch for every worktree.
- Preserve the main/source checkout, `[TRUNK]`, and every currently checked-out branch unless its eligible worktree is safely removed.
- For each worktree, run `git status --porcelain=v1 --untracked-files=all`. Any staged, unstaged, untracked, conflicted, or required ignored work makes the worktree and branch ineligible.
- Never use `git clean`, `git reset`, `git checkout --`, `git branch -D`, `git worktree remove --force`, or any destructive equivalent.

Eligibility:
- Do not trust PR state or ancestry alone.
- A candidate is eligible only when it is not `[TRUNK]`, has no dirty worktree, is merged into local `[TRUNK]`, is merged into `origin/[TRUNK]` when present, has no unpushed commits, and file-level verification shows no content absent from trunk.
- Prefer false negatives over false positives.

Actions:
- Always report every eligible candidate and every skipped target with its exact reason.
- If `[ALLOW_SAFE_DELETES]` is not exactly true, stop after the report without changing anything.
- Only when it is exactly true, remove eligible worktrees with non-force `git worktree remove`, delete eligible local branches with `git branch -d`, then run `git worktree prune`.
- Never deploy, run live migrations, write production data, or remove remote work.

Output:
- Report removed worktrees/branches, all candidates, skipped dirty/unmerged/unpushed targets, exact blockers, and whether safe deletes were enabled.

Manual test before enabling deletes:
- Run once with `[ALLOW_SAFE_DELETES]` false or unresolved and confirm the report lists candidates while git worktree and branch state remain unchanged.
