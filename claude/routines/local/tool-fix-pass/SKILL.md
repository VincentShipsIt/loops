---
name: tool-fix-pass
description: Run a project scanner or tool and open a safe fix PR
---

Run one safe automated fix pass for `[PROJECT]` using `[TOOL_COMMAND]`.

Scope:
- Work only in `[REPO_PATH]`.
- GitHub repository: `[GITHUB_REPO]`.
- Tool focus: `[TOOL_FOCUS]` (for example security, React, lint, dead code, dependencies, or accessibility).
- Optional baseline command: `[TOOL_BASELINE_COMMAND]`.
- Optional verification command: `[TOOL_VERIFY_COMMAND]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.
- Never merge PRs, deploy, run production migrations, or write to production data.
- Never print tokens, secrets, `.env` contents, private payloads, or credentials.

Validation policy:
- Run only checks allowed by local agent instructions and the configured environment.
- If required validation is prohibited or too heavy, report blocked and do not publish changes.

Workflow:
- Read local agent instructions.
- Inspect existing scripts and prior tool usage for `[TOOL_FOCUS]`.
- Search open PRs, branches, and worktrees for active `[TOOL_COMMAND]` or `[TOOL_FOCUS]` work before creating a branch. If equivalent active work exists on an automation-owned branch, skip and report it.
- If `[TOOL_COMMAND]` is still a placeholder or not configured, report required setup and stop.
- Discover the default branch directly from `origin` with `git ls-remote --symref origin HEAD`; accept only one symbolic `ref: refs/heads/<default-branch> HEAD` result and record it as `default_branch`.
- Fetch only that branch into its remote-tracking ref with `git fetch --prune origin "+refs/heads/${default_branch}:refs/remotes/origin/${default_branch}"`, then record `default_commit` with `git rev-parse "refs/remotes/origin/${default_branch}^{commit}"`. Stop if discovery or resolution is missing or ambiguous.
- Treat `[REPO_PATH]` as the source checkout and require a separate registered worktree for edits. Treat `default_commit` as the sole fix base and never use or mutate a local default branch.
- Create `[BRANCH_PREFIX]-tool-fix-YYYYMMDD-HHMMSS` with no upstream directly from `default_commit` in the isolated worktree.
- Before any command that may edit files, require `git rev-parse HEAD` to equal `default_commit` exactly and `git status --porcelain=v1 --untracked-files=all` to produce no output; stop and report without editing if either check fails.
- If `[TOOL_BASELINE_COMMAND]` is configured, run it first and record the baseline output.
- Run `[TOOL_COMMAND]` or the closest existing project script.
- If `[TOOL_COMMAND]` is not installed, exits non-zero for an environment or configuration reason, or produces empty output, report that result and stop without opening a PR.
- Classify findings into safe automated fixes, risky fixes, and false positives.
- Apply only safe, local, reversible changes tied to `[TOOL_FOCUS]`.
- Do not make broad rewrites or opportunistic refactors.
- Add or update focused tests when behavior changes.
- If `[TOOL_VERIFY_COMMAND]` is configured, run it after fixes and keep only improvements that verify against the final scan.
- Run scoped validation.
- Commit and open a PR against `default_branch`.

Output:
- Report `default_branch`, `default_commit`, tool command, baseline command if used, verification command if used, focus, findings fixed, findings skipped, branch, PR URL, validation, and residual risk.
