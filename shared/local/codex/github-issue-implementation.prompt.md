Implement exactly one eligible open issue from the canonical GitHub Project for `[GITHUB_REPO]`, then open a pull request against `[TRUNK]`.

Scope and synchronize:
- Work only on `[PROJECT]` in the isolated Codex automation worktree. Treat `[REPO_PATH]` as the source checkout and never edit, commit, stash, reset, switch, or pull there.
- Run `git fetch origin --prune`. Inspect the project whose title is exactly `[PROJECT_BOARD]`, open issues, milestones, open pull requests, remote branches, and worktrees. Only the status attached to that project counts.
- Start from fetched `origin/[TRUNK]`. Before editing, verify the work branch merge-base is exactly `origin/[TRUNK]`. Stop if the source checkout is the current working directory or the remote trunk is unavailable.
- Do not inspect or modify `[OUT_OF_SCOPE_PROJECTS]` or unrelated projects.

Select one issue:
- An issue is eligible only when its target-project status is exactly `Backlog`, it belongs to a concrete active release milestone, its body and acceptance criteria are bounded enough to complete and verify in one run, and no open pull request, remote branch, or worktree already covers it.
- Skip epics, deferred or blocked work, product-decision placeholders, manual release or signing work, broad migrations, destructive or production operations, and work requiring unavailable external access.
- Prefer the nearest active milestone, then P0 through P3, then unlabeled. Within the same priority prefer bugs, correctness, security, and safety before enhancements, then the oldest issue.
- If no issue is eligible, report the target-project status counts and stop without creating a branch, changing project metadata, editing files, committing, or opening a pull request.

Claim before editing:
- Select exactly one issue and immediately re-check its project status, open pull requests, remote branches, and worktrees.
- Move only its target-project item from `Backlog` to `In Progress` before creating a branch or editing.
- If the claim fails or the state changed, try the next eligible issue or stop. Never implement an issue that was not successfully claimed.

Implement and verify:
- Create a focused `[BRANCH_PREFIX]/<issue-number>-<slug>` branch from `origin/[TRUNK]`.
- Read the issue body and comments, repository instructions, relevant architecture and documentation, and nearby code before editing. Repository-specific safety and domain rules in `AGENTS.md` are binding unless they conflict with this automation's explicit project or trunk contract.
- Implement only the selected issue using existing patterns. Add or update focused tests.
- Run the relevant formatter, lint, typecheck or build, unit, coverage, and user-facing checks discovered from repository instructions and scripts, proportional to the change. Record the exact command and blocker for any required check that cannot run.
- Review the final diff for correctness, security, regressions, unnecessary complexity, dead code, and unrelated changes.

Publish for review:
- Commit with the issue number, push the branch, and open a ready-for-review pull request against `[TRUNK]`. Never create a draft pull request.
- Link the issue, summarize the implementation, and list verification results and residual blockers. Use `Closes #<number>` only when the issue is fully resolved.
- Leave the project item `In Progress`. Do not change its project status again, describe or assume a later project transition, or merge the pull request.

Report the selected issue, milestone and priority, branch and base commit, commit, pull request URL, verification results, skipped checks, blockers, and residual risk.
