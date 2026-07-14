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
- Run `git fetch --all --prune` before creating any branch/worktree.
- Use `origin/[TRUNK]` as the base branch.
- Create a fresh timestamped branch/worktree based directly on `origin/[TRUNK]`, formatted like `[BRANCH_PREFIX]-YYYYMMDD-HHMMSS`.
- Before editing, inspect local branches/worktrees and open PRs for similar `[TOOL_COMMAND]` or `[TOOL_FOCUS]` work.
- If equivalent active work exists, update it only when it is clearly this automation's branch and safe to continue. Otherwise skip and report.
- Verify the work branch is based directly on `origin/[TRUNK]` before editing.
- If `[TOOL_COMMAND]` is still a placeholder or not configured, report required setup and stop.
- If `[TOOL_BASELINE_COMMAND]` is configured, run it first and record the baseline output.
- Run `[TOOL_COMMAND]`.
- Fix only clear, actionable findings with small, reviewable changes tied to `[TOOL_FOCUS]`.
- Prefer existing codebase patterns.
- If `[TOOL_VERIFY_COMMAND]` is configured, run it after fixes and keep only improvements that verify against the final scan.
- Run focused checks/tests for touched areas.
- Commit changes and open a pull request against `[TRUNK]`.
- If there are no actionable findings, report the result without creating noisy changes.

Output:

- Tool run summary, focus, baseline command if used, and verification command if used.
- Findings fixed/skipped.
- Branch/commit/PR.
- Validation.
- Residual risk.
