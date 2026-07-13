# Claude Scheduled Task: GitHub Backlog Pickup

Use this for a high-autonomy nightly task that claims and implements one eligible issue.

## Prompt


Operate fully autonomously. Never pause to ask the user anything. Make reasonable decisions and document them in the issue or PR. If genuinely blocked, comment the blocker and stop.

Repository policy:

- Workspace: `[REPO_PATH]`.
- GitHub repository: `[GITHUB_REPO]`.
- Base branch: `[TRUNK]`.
- Read repo instructions and memory before coding.
- Use the repo's package manager and conventions.
- Do not deploy, run live migrations, or touch production data.

Objective:

Pick exactly one eligible backlog issue from GitHub and implement it end-to-end using multi-agent orchestration when available.

Issue selection:

- List open issues and inspect assignees, labels, title, URL, and status.
- Eligible issues must be unassigned or assigned to the automation owner.
- Never pick an issue assigned to someone else.
- Skip issues already in progress.
- Check open PRs, local/remote branches, and worktrees for the issue number or slug.
- Skip human-review, production-ops, manual-secret, live-migration, deploy, or external-account work.
- Prioritize highest priority, then smaller well-scoped issues.
- Never pick an epic issue itself; pick child tickets.
- If no eligible issue exists, say so and stop.

Claim:

- Assign the issue to the automation owner when appropriate.
- Comment that an automated session picked it up with start time.
- Run `git fetch --all --prune` before creating the worktree/branch.
- Create a worktree/branch off `origin/[TRUNK]` named `issue-<number>-<short-slug>`.

Implement:

- Map relevant code with search, graph tools, or subagents.
- Use TDD where practical.
- Follow existing codebase patterns.
- Keep every changed line traceable to the issue.
- No gratuitous refactoring.
- Keep secrets out of git.
- Cap expensive validation locally; use `[REMOTE_WORKER]` for heavier checks.

Ship:

- Commit with a conventional message referencing the issue.
- Push the branch and open a PR against `[TRUNK]`.
- Link the issue with a closing keyword only when fully implemented.
- Comment on the issue with the PR link.
- Do not merge the PR.

Success criteria:

- One issue claimed.
- Implementation complete or clearly blocked.
- PR opened or draft PR opened with blocker.
- Verification listed with commands executed and pass/fail outcome.
