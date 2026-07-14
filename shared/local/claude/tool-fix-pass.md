# Claude Scheduled Task: Tool Fix Pass

Use this for recurring scanner tools such as security scanners, React doctors,
safe auto-patch tools, dead-code detectors, or lint/code-quality agents.

## Prompt


Run `[TOOL_COMMAND]` in this repository and apply fixes for `[TOOL_FOCUS]`.

CPU-heavy validation policy:

- Do not run CPU-intensive tests or heavy validation locally.
- Lightweight local checks are allowed only when quick/static.
- If required validation is prohibited or too heavy for the configured environment, skip it with a clear blocker and do not publish changes.

Repository policy:

- This task is scoped only to `[PROJECT]`: `[REPO_PATH]`.
- Tool focus: `[TOOL_FOCUS]` (for example security, React, lint, dead code, dependencies, or accessibility).
- Optional baseline command: `[TOOL_BASELINE_COMMAND]`.
- Optional verification command: `[TOOL_VERIFY_COMMAND]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.
- Never merge PRs, deploy, run live migrations, or write production data.
- Never print tokens, secrets, `.env` contents, or environment file contents.

Workflow:

- Read local agent instructions before editing.
- Discover the default branch directly from `origin` with `git ls-remote --symref origin HEAD`; accept only one symbolic `ref: refs/heads/<default-branch> HEAD` result and record it as `default_branch`.
- Fetch only that branch into its remote-tracking ref with `git fetch --prune origin "+refs/heads/${default_branch}:refs/remotes/origin/${default_branch}"`, then record `default_commit` with `git rev-parse "refs/remotes/origin/${default_branch}^{commit}"`. Stop if discovery or resolution is missing or ambiguous.
- Treat `[REPO_PATH]` as the source checkout and require a separate registered worktree for edits. Treat `default_commit` as the sole fix base and never use or mutate a local default branch.
- Before editing, inspect local branches/worktrees and open PRs for similar `[TOOL_COMMAND]` or `[TOOL_FOCUS]` work.
- If equivalent active work exists, skip and report it; never continue a pre-existing branch.
- If `[TOOL_COMMAND]` is still a placeholder or not configured, report required setup and stop.
- Create `[BRANCH_PREFIX]-tool-fix-YYYYMMDD-HHMMSS` with no upstream directly from `default_commit` in the isolated worktree.
- Before any command that may edit files, require `git rev-parse HEAD` to equal `default_commit` exactly and `git status --porcelain=v1 --untracked-files=all` to produce no output; stop and report without editing if either check fails.
- If `[TOOL_BASELINE_COMMAND]` is configured, run it first and record the baseline output.
- Run `[TOOL_COMMAND]`.
- Fix only clear, actionable findings with small, reviewable changes tied to `[TOOL_FOCUS]`.
- Prefer existing codebase patterns.
- If `[TOOL_VERIFY_COMMAND]` is configured, run it after fixes and keep only improvements that verify against the final scan.
- Run focused checks/tests for touched areas.
- Commit changes and open a pull request against `default_branch`.
- If there are no actionable findings, report the result without creating noisy changes.

Output:

- Tool run summary, focus, baseline command if used, and verification command if used.
- Findings fixed/skipped.
- Discovered default branch, recorded base commit, branch/commit/PR.
- Validation.
- Residual risk.
