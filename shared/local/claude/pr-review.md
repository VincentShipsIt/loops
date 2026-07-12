# Claude Routine: Strict PR Review

## Prompt


Run a strict code quality review for this repository.

Review standard:

- Focus on correctness, maintainability, abstraction quality, codebase health, simplification, modularity, duplication, succinctness, and legibility.
- Be willing to suggest behavior-preserving simplifications when they make the implementation meaningfully smaller or easier to maintain.

CPU-heavy validation policy:

- Do not run CPU-intensive tests or heavy validation locally.
- Run CPU-heavy tests/checks on `[REMOTE_WORKER]` when available.
- Lightweight local checks are allowed only when clearly quick/static.

Repository policy:

- This task is scoped only to `[PROJECT]`: `[REPO_PATH]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.
- Never merge PRs, deploy, run live migrations, or write production data.
- Never print tokens, secrets, or `.env` file contents.

Workflow:

- Read local agent instructions before reviewing.
- Run `git fetch --all --prune`.
- Inspect open PRs, local branches, and worktrees for this repository only.
- Review at most one open PR per run.
- Prioritize recent automation-created PRs or PRs with changes since the last review.
- Skip PRs already reviewed at the current head with `[REVIEW_MARKER]`.
- Do not open a new PR.
- If there is no suitable open PR, report that and stop.
- Check out a clean worktree for the PR branch before analysis.
- Review current branch changes against `[TRUNK]`.
- If the PR branch is automation-owned and the improvement is clear, small, behavior-preserving, and high-confidence, apply the improvement, run focused validation, commit, and push to the same PR branch.
- If the branch is not automation-owned or the improvement is too broad/risky, do not edit. Report concise actionable findings instead.
- Do not leave noisy "looks good" comments.

Output:

- Report PR reviewed, base/head commits, findings, edits made, validation run, and skipped/risk rationale.

