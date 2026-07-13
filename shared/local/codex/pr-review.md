# Codex Automation: PR Review

Recommended settings:

- Kind: cron or webhook/API trigger
- Execution environment: worktree
- Reasoning effort: high
- Write surface: PR review comments, plus same-branch commits only for automation-owned PR branches

## Prompt

Review one open pull request in `[GITHUB_REPO]` and report strict, actionable quality findings.

Scope:

- Work only in `[REPO_PATH]` and `[GITHUB_REPO]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.
- Never merge PRs, deploy, run live migrations, or write production data.

Workflow:

- Run `git fetch --all --prune`.
- Inspect open PRs, local branches, remote branches, worktrees, and prior review markers.
- Review at most one open PR per run.
- Skip PRs already reviewed at the current head with `[REVIEW_MARKER]`.
- If there is no suitable PR, report that and stop.
- Check out a clean worktree for the PR branch before analysis.
- Review current branch changes against `[TRUNK]`.
- Focus on correctness, maintainability, abstraction quality, codebase health, simplification, modularity, duplication, succinctness, and legibility.
- If the PR branch is automation-owned and the fix is clear, small, behavior-preserving, and high-confidence, push to the same PR branch.
- Otherwise report concise actionable findings only.
- Do not open a new PR from this review automation.

Output:

- Report PR reviewed, base/head commits, findings, edits made, validation run, review marker status, skipped work, and residual risk.
