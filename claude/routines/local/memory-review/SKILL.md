---
name: memory-review
description: Source-backed cleanup of stale repository memory
---

Review and refresh repository memory for `[PROJECT]` so future agents get current, source-backed instructions instead of stale migration-era guidance.

Repository policy:
- Work only in `[REPO_PATH]`.
- GitHub repository: `[GITHUB_REPO]`.
- Memory scope: `[MEMORY_SCOPE]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]` or any unrelated project.
- Never print tokens, secrets, `.env` contents, private payloads, or credentials.
- Never merge PRs, deploy, run production migrations, or write to production data.

State and baseline:
- Store `last_successful_memory_review_baseline_sha` in `[STATE_FILE]`.
- Discover the default branch directly from `origin` with `git ls-remote --symref origin HEAD`; accept only one symbolic `ref: refs/heads/<default-branch> HEAD` result and record it as `default_branch`.
- Fetch only that branch into its remote-tracking ref with `git fetch --prune origin "+refs/heads/${default_branch}:refs/remotes/origin/${default_branch}"`, then record `default_commit` with `git rev-parse "refs/remotes/origin/${default_branch}^{commit}"`. Stop if discovery or resolution is missing or ambiguous.
- If a valid baseline SHA exists and is an ancestor of `default_commit`, inspect repository changes in `baseline..default_commit` plus all files in `[MEMORY_SCOPE]`.
- If no valid baseline exists, inspect repository changes ending at `default_commit` from the last 7 days plus all files in `[MEMORY_SCOPE]`.
- If the baseline is not an ancestor of `default_commit`, stop and report the mismatch.
- Update the baseline only after a completed review cycle: no changes needed, findings reported with no safe fix, an equivalent existing PR found, or a verified memory-update PR is opened.
- Do not update the baseline when fetch, review, validation, push, or PR creation fails.

Workspace policy:
- Stop if `[REPO_PATH]` has uncommitted changes outside `[MEMORY_SCOPE]` unless they belong to this scheduled task's active branch.
- Treat `[REPO_PATH]` as the source checkout and require a separate registered worktree for edits. Treat `default_commit` as the sole review and edit base. Never use or mutate a local default branch.
- When edits are needed, create `[BRANCH_PREFIX]-memory-review-YYYYMMDD-HHMMSS` with no upstream directly from `default_commit` in the isolated worktree.
- Before editing, require `git rev-parse HEAD` to equal `default_commit` exactly and `git status --porcelain=v1 --untracked-files=all` to produce no output; stop and report without editing if either check fails.
- Do not commit, stash, reset, or overwrite user work.

Source-of-truth inventory:
- Read repo-level agent instructions such as `AGENTS.md`, `CLAUDE.md`, and files in `[MEMORY_SCOPE]`.
- Inspect current source truth before editing memory: README files, package scripts, dependency manifests, framework configs, database schema and migrations, ORM/client config, Docker or compose files, CI workflows, deploy scripts, and docs that define current workflows.
- Review recent trunk changes since the baseline for migrations, renamed commands, removed services, new tools, changed validation, changed package managers, changed branch policy, and deleted paths.
- Identify contradictions where memory says to use, avoid, always do, or never do something that current source truth no longer supports.

Memory cleanup workflow:
- Classify each relevant memory claim as current, stale, too broad, duplicated, contradictory, missing replacement context, or unverifiable.
- Fix only source-backed stale or contradictory guidance.
- When a migration has changed the operational truth, replace obsolete negative warnings with concise current guidance and evidence. Do not preserve stale warnings in a way that keeps old context dominant.
- If the repo still contains legacy references during a migration, describe the current rule and the limited legacy exception precisely.
- Remove duplicate or conflicting memory entries when one source-backed instruction is enough.
- Keep durable human/team preferences unless they conflict with repo-scoped technical facts.
- Update last-verified dates only for claims actually checked during this run.
- Do not invent future architecture, migration plans, project policy, or personal preferences.
- Do not edit source code, configs, migrations, or generated files to satisfy memory text.

Dedupe and PR behavior:
- Before editing, search open PRs, branches, worktrees, and recent commits for existing memory-review work touching `[MEMORY_SCOPE]`.
- If an existing open PR already covers the stale memory, report it and do not create a duplicate.
- If safe edits are needed, change the smallest coherent set of memory files.
- Run available formatting, markdown lint, link checks, or repository validation that covers the changed memory files.
- Commit, push, and open one PR against `default_branch` with source evidence, files changed, validation results, and unresolved uncertainty.
- Do not create a PR when there are no stale memory findings, only unverifiable questions, an equivalent PR exists, or validation is blocked.

Output:
- Report `default_branch`, `default_commit`, baseline SHA, reviewed head SHA, memory files reviewed, source-of-truth evidence checked, stale claims found, changes made, branch/PR if created, validation run, baseline update status, skipped work, blockers, and residual risk.

Manual test before enabling:
- Run once with scheduling disabled.
- Confirm the run either no-ops with source-backed evidence or opens at most one PR touching only `[MEMORY_SCOPE]`.
