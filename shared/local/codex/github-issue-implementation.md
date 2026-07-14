# Codex Automation: GitHub Issue Implementation

This wrapper documents the app settings for the canonical prompt in
[`github-issue-implementation.prompt.md`](github-issue-implementation.prompt.md).
The app-ready TOML is generated from that prompt so the workflow is authored once.

## Recommended settings

- Kind: cron
- Cadence: every two hours
- Execution environment: worktree
- Write surface: one project claim, one repository branch, and one pull request

## Workflow contract

- Select exactly one issue whose status on the canonical target project is `Backlog`.
- Pause only the current Codex automation, preserving every other setting, when a successful exact-target query proves the `Backlog` count is zero; never pause on query failure or eligibility exhaustion with a nonzero backlog.
- Require a concrete active release milestone and one-run implementation scope.
- Claim the issue by moving only that project item to `In Progress` before branching or editing.
- Treat a failed claim as a hard stop for that issue.
- Discover the default branch from `origin`, fetch its remote-tracking ref explicitly, and record its exact commit.
- Create isolated issue work directly from that commit; require exact `HEAD` equality and a clean worktree before editing, without using or mutating a local default branch.
- Open a ready-for-review pull request against the discovered default branch and leave the project item `In Progress`.
- Never merge the pull request or perform another project-status transition.

After editing the canonical prompt, run `python3 scripts/sync-codex-implementation-template.py` to regenerate the TOML, then run `python3 scripts/sync-codex-implementation-template.py --check` to verify synchronization.
