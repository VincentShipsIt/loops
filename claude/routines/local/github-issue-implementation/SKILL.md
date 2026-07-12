---
name: github-issue-implementation
description: Ship one ready GitHub issue to a pull request
---

Implement one ready, high-value GitHub issue in `[PROJECT]`.

CPU-heavy validation policy:
- Do not run CPU-intensive tests or heavy validation locally.
- Run CPU-heavy checks on `[REMOTE_WORKER]` when available.
- Lightweight local checks are allowed only when clearly quick/static.
- If unsure whether a command is CPU-heavy, run it remotely or skip it with a clear note.

Repository policy:
- Work only in `[REPO_PATH]`.
- GitHub repository: `[GITHUB_REPO]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.

Workflow:
- Read local agent instructions and project memory before editing.
- Inspect open issues, open PRs, branches, and worktrees before choosing work.
- Use `[TRUNK]` as the base branch.
- Choose exactly one ready issue not covered by active work.
- Prefer small, shippable tasks with clear acceptance criteria.
- Run `git fetch --all --prune`.
- Create a fresh timestamped branch `[BRANCH_PREFIX]-YYYYMMDD-HHMMSS` from `origin/[TRUNK]`.
- Follow existing codebase patterns; find at least three examples before introducing a new pattern.
- Add focused tests or validation for changed behavior.
- Run the smallest relevant checks/tests for touched areas; if the right verification command cannot run, report the blocker and do not push a PR.
- Do not run destructive commands, production writes, deploys, or live migrations.
- Commit and open a pull request against `[TRUNK]`.
- Do not merge the PR.

If no safe ready issue is available, report why and stop.

Output:
- Selected issue (number and title).
- Branch name and base commit.
- Commit SHA.
- PR URL.
- Validation run (commands executed, pass/fail).
- Skipped work (issues considered but not chosen, and why).
- Residual risk (anything that could not be verified locally).
