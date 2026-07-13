---
name: github-backlog-pickup
description: Fully autonomous pickup of one eligible backlog issue
---

Do not pause for input. Make reasonable decisions, document them in the issue or PR, and stop cleanly if blocked.

Objective:
- Pick exactly one eligible backlog issue in `[GITHUB_REPO]`.
- Implement it end to end in `[REPO_PATH]`.
- Open a pull request against `[TRUNK]`.

Eligibility:
- Issue is unassigned or assigned to `[AUTOMATION_ASSIGNEE]`.
- Issue is not already represented by an open PR, active branch, worktree, or in-progress label/status.
- Issue does not require production deployment, live data migration, credentials, external account setup, or a human-only product decision.
- Issue is not an epic unless the task explicitly says to implement the epic itself.

Workflow:
- Read local agent instructions and memory.
- List open issues and open PRs.
- Check branches and worktrees for duplicate work.
- Claim the selected issue when supported.
- Run `git fetch --all --prune`.
- Create a fresh branch/worktree from `origin/[TRUNK]`.
- Implement with focused tests where practical.
- Use existing codebase patterns and at least three examples before introducing new structure.
- Run focused validation for touched areas (commands executed and pass/fail result required).
- Push, open a PR, and comment with the PR link when supported.
- Do not merge the PR.
- If no eligible issue exists after checking, report why and stop without opening a PR.

Resource limits:
- Do not run full test suites, full builds, dev servers, docker, or watch mode locally.
- Use `[REMOTE_WORKER]` for heavy validation when needed.
- Keep shell-executing subagents or parallel tasks bounded.

Output:
- Report selected issue, branch, PR URL, validation (commands executed, pass/fail), blockers, and residual risk.
