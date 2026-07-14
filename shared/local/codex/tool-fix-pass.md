# Codex Automation: Tool Fix Pass

Recommended settings:

- Kind: cron
- Execution environment: worktree
- Reasoning effort: high
- Write surface: repo branch plus pull request

## Prompt

Run one configured scanner or quality tool for `[PROJECT]` and open a safe fix PR only for clear findings.

Scope:

- Work only in `[REPO_PATH]` and `[GITHUB_REPO]`.
- Tool command: `[TOOL_COMMAND]`.
- Optional baseline command: `[TOOL_BASELINE_COMMAND]`.
- Optional verification command: `[TOOL_VERIFY_COMMAND]`.
- Tool focus: `[TOOL_FOCUS]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.
- Never print tokens, secrets, request bodies with sensitive data, or environment file contents.
- Never deploy, run live migrations, or write production data.

Workflow:

- Read local agent instructions before editing.
- Run in the Codex worktree execution environment.
- Treat `[REPO_PATH]` as the source checkout only; do not edit, commit, or stash there.
- Stop if pwd resolves to `[REPO_PATH]`.
- Discover the default branch directly from `origin` with `git ls-remote --symref origin HEAD`; accept only one symbolic `ref: refs/heads/<default-branch> HEAD` result and record it as `default_branch`.
- Fetch only that branch into its remote-tracking ref with `git fetch --prune origin "+refs/heads/${default_branch}:refs/remotes/origin/${default_branch}"`, then record `default_commit` with `git rev-parse "refs/remotes/origin/${default_branch}^{commit}"`. Stop if discovery or resolution is missing or ambiguous.
- Treat `default_commit` as the sole fix base. Never use or mutate a local default branch.
- Search open PRs, branches, and worktrees for active `[TOOL_COMMAND]` or `[TOOL_FOCUS]` work before creating a branch.
- If equivalent active work exists, skip and report it.
- If `[TOOL_COMMAND]` is still a placeholder or not configured, report required setup and stop.
- Create `[BRANCH_PREFIX]-tool-fix-YYYYMMDD-HHMMSS` with no upstream directly from `default_commit` in the isolated worktree.
- Before any command that may edit files, require `git rev-parse HEAD` to equal `default_commit` exactly and `git status --porcelain=v1 --untracked-files=all` to produce no output; stop and report without editing if either check fails.
- If `[TOOL_BASELINE_COMMAND]` is configured, run it first and record the baseline output.
- Run `[TOOL_COMMAND]`.
- If the tool is missing, misconfigured, fails for environment reasons, or returns no actionable findings, report the result and stop without opening a PR.
- Classify findings into safe automated fixes, risky fixes, and false positives.
- Apply only clear, local, reversible fixes tied to `[TOOL_FOCUS]`.
- Prefer existing codebase patterns and find at least three examples before changing shared patterns.
- Add or update focused tests when behavior changes.
- If `[TOOL_VERIFY_COMMAND]` is configured, run it after fixes and keep only improvements that verify against the final scan.
- Run scoped validation for touched areas.
- Commit, push, and open one PR against `default_branch`.
- Do not merge the PR.

Output:

- Report `default_branch`, `default_commit`, tool command, baseline command if used, verification command if used, focus, findings fixed/skipped, branch, commit, PR URL, validation, blockers, and residual risk.
