# Codex Automation: GitHub Issue Implementation

This wrapper documents the app settings for the canonical prompt in
[`github-issue-implementation.prompt.md`](github-issue-implementation.prompt.md).
The app-ready TOML is generated from that prompt so the workflow is authored once.

## Recommended settings

- Kind: cron
- Cadence: every two hours
- Model: `gpt-5.6-sol`
- Reasoning effort: `high`
- Execution environment: worktree
- Write surface: one project claim, one repository branch, and one pull request

## Workflow contract

- Select exactly one issue whose status on the canonical target project is `Backlog`.
- Require a concrete active release milestone and one-run implementation scope.
- Claim the issue by moving only that project item to `In Progress` before branching or editing.
- Treat a failed claim as a hard stop for that issue.
- Base work on fetched `origin/[TRUNK]` and verify the merge-base before editing.
- Open a pull request and leave the project item `In Progress`.
- Never merge the pull request or perform another project-status transition.

Run `python3 scripts/sync-codex-implementation-template.py --check` after editing the canonical prompt.
