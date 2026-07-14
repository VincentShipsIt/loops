# Claude Scheduled Task: GitHub Backlog Pickup

This is the higher-autonomy variant of `github-issue-implementation`. Eligibility, project claim, base, verification blocker, ready-PR handoff, issue linking, and final `In Progress` status are identical. The intentional differences are: never pause for input, claim the configured automation assignee when supported, leave a pickup comment, and use bounded orchestration for discovery and critique when available.

## Prompt

Operate autonomously and implement exactly one eligible open issue from the canonical GitHub Project for `[GITHUB_REPO]`. Never pause for input. If genuinely blocked, document the blocker on the claimed issue when safe and stop.

Scheduler lifecycle preflight:

- Before any repository synchronization or issue selection, query the exact target project and count items whose status on that project is exactly `Backlog`.
- If and only if that query succeeds and the exact `Backlog` count is zero, use `mcp__scheduled-tasks__list_scheduled_tasks` and `mcp__scheduled-tasks__update_scheduled_task` when both are available to identify and pause only the current Claude scheduled task while preserving every other setting. Then report the zero count and stop without repository or project writes.
- If the scheduled-task tools are unavailable or the current task cannot be identified unambiguously, report the inability and stop without claiming a pause or mutating another scheduler.
- If the `Backlog` count is greater than zero, continue normally. If the board query fails, is incomplete, or cannot identify the exact target project, report blocked and stop without pausing the task or synchronizing the repository.
- Never pause merely because `Backlog` is nonzero but no item passes milestone, scope, dedupe, access, or other eligibility gates.

Scope and synchronize:

- Work only on `[PROJECT]` in an isolated branch/worktree. Treat `[REPO_PATH]` as the source checkout and never edit, commit, stash, reset, switch, or pull there.
- Discover the default branch directly from `origin` with `git ls-remote --symref origin HEAD`. Accept only one symbolic `ref: refs/heads/<default-branch> HEAD` result; record `<default-branch>` as `default_branch`, and stop if it is missing, ambiguous, or not under `refs/heads/`.
- Fetch only that branch into its remote-tracking ref with `git fetch --prune origin "+refs/heads/${default_branch}:refs/remotes/origin/${default_branch}"`, then record `default_commit` with `git rev-parse "refs/remotes/origin/${default_branch}^{commit}"`. Inspect the project whose title is exactly `[PROJECT_BOARD]`, open issues, active release milestones, open pull requests, remote branches, and worktrees. Only that project's status counts.
- Treat `default_commit` as the sole implementation base. Never use or mutate a local default branch: do not check it out, create it, pull it, switch it, merge it, rebase it, reset it, or update it. Do not base work on the initial worktree `HEAD` or the source checkout branch. Stop if the source checkout is the current working directory, the current checkout is not an isolated registered worktree, or the fetched remote-tracking ref cannot be resolved to a commit.
- Do not inspect or modify `[OUT_OF_SCOPE_PROJECTS]` or unrelated projects.

Eligibility and claim:

- `claude:routine` is the Claude routine queue label.
- Prefer ready `claude:routine` issues before unlabeled/non-routine work.
- `claude:routines` is a stale plural variant, not a canonical queue label. Use `claude:routine` unless a target repo explicitly documents the plural label.
- `codex:automation` is the Codex queue label.
- `shipcode:agent:codex` and `shipcode:agent:claude` are ShipCode routing only. Do not treat either as a generic intake signal outside ShipCode-specific logic.
- Select exactly one issue whose target-project status is `Backlog`, which has a concrete active release milestone, bounded one-run acceptance criteria, and no covering open PR, remote branch, or worktree.
- Rank eligible issues in this order: queue label (`claude:routine`), milestone, target/release/start date, project Priority, then readiness (acceptance criteria, verification scope, and confidence).
- Skip epics, deferred/blocked work, product-decision placeholders, manual release/signing work, broad migrations, destructive/production operations, and unavailable external access.
- Repair existing linked open PRs: if an open PR closes or links a candidate issue, ensure the PR has the issue's queue/review labels before skipping it as already covered.
- Re-check all eligibility and duplicate signals immediately before claiming. Move only the target-project item from `Backlog` to `In Progress` before branching or editing.
- When supported, assign `[AUTOMATION_ASSIGNEE]` and leave one concise pickup comment with the start time. These are additional ownership signals, not substitutes for the project-status claim.
- If the claim fails or state changed, try the next eligible issue or stop. If none is eligible, report status counts and stop without writes.

Implement and publish:

- In the isolated worktree, create `[BRANCH_PREFIX]/<issue-number>-<slug>` with no upstream directly from the recorded `default_commit`. Before editing, require `git rev-parse HEAD` to equal `default_commit` exactly and `git status --porcelain=v1 --untracked-files=all` to produce no output; stop and report without editing if either condition fails.
- Read repository instructions and use bounded orchestration for discovery or critique when useful. Keep every changed line traceable to the issue.
- Add focused tests and run required proportional verification. If required verification is prohibited, unavailable, or too heavy for the configured environment, document the blocker and do not publish an unverified PR.
- Never deploy, run live migrations, write production data, or use destructive commands.
- Commit with the issue number, push, and open a ready-for-review PR against the recorded `default_branch`; never open a draft or merge it.
- Use `Closes #<number>` only when fully resolved. Comment with the PR link when supported.
- When opening a PR, mirror source issue labels onto the PR: always copy queue labels (`codex:automation`, `claude:routine`) and copy existing classification/review labels such as `code-quality`, `security`, `product`, `bug`, `enhancement`, `backend`, `frontend`, `infra`, and `e2e`.
- Do not invent labels from project fields like Priority, Status, or Area unless those labels already exist on the issue.
- If a non-ShipCode issue or PR has stale `shipcode:agent:codex` or `shipcode:agent:claude`, or any issue or PR has stale plural `claude:routines`, remove it only when the correct queue label is present or can be added with clear evidence; otherwise report it as uncertain.
- Leave the target-project item `In Progress` and perform no later project-status transition.

Output:

- Report selected issue, milestone/priority, ownership signals, discovered default branch and recorded base commit, issue branch, commit, ready PR URL, verification results, blockers, and residual risk.
