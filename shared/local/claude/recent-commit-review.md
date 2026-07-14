# Claude Routine: Recent Commit Review

## Prompt


Review new commits on the resolved remote default branch of `[GITHUB_REPO]` since the last successful review baseline SHA, or the last 24 hours when no baseline exists. Fix only high-confidence issues.

Surface:

- Use as a Claude Desktop scheduled task when the repository is local and code fixes may be needed.
- Do not use this template as a remote Routine by default. If a project needs remote commit review, create a separate project-specific routine with an explicit worker contract, test environment, GitHub write policy, and PR creation permission.

Scope:

- Work only in `[REPO_PATH]` and `[GITHUB_REPO]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]` or unrelated projects.
- Never merge PRs, deploy, run production migrations, or write to production data.
- Never print tokens, secrets, `.env` contents, private payloads, or credentials.

State and baseline:

- Store `last_successful_review_baseline_sha` in `[STATE_FILE]`.
- Discover the default branch directly from `origin` with `git ls-remote --symref origin HEAD`. Accept only one symbolic `ref: refs/heads/<default-branch> HEAD` result; record it as `default_branch`, and stop if it is missing, ambiguous, or not under `refs/heads/`.
- Fetch only that branch into its remote-tracking ref with `git fetch --prune origin "+refs/heads/${default_branch}:refs/remotes/origin/${default_branch}"`, then record `default_commit` with `git rev-parse "refs/remotes/origin/${default_branch}^{commit}"`.
- If a valid baseline SHA exists and is an ancestor of `default_commit`, review `baseline..default_commit`.
- If no valid baseline exists, review commits ending at `default_commit` from the last 24 hours.
- If the baseline is not an ancestor of `default_commit`, stop and report the mismatch.
- Update the baseline only after a successful review cycle:
  - no new commits,
  - no findings,
  - findings reported with no safe fix needed, or
  - a verified fix branch is pushed and a PR is opened.
- Do not update the baseline when fetch, review, validation, push, or PR creation fails.

Workflow:

- Read local agent instructions before acting.
- Treat `[REPO_PATH]` as the source checkout only and require a separate registered worktree before any fix.
- List each reviewed commit with short hash, author, date, message, and GitHub link.
- Summarize the change in one sentence per commit after reading the diff.
- Flag notable commits:
  - large diffs,
  - auth, billing, persistence, migrations, data loss, security, background jobs, build, deploy, environment, or dependency changes,
  - behavior changes without tests or docs,
  - unusual patterns compared with local examples.
- Review each commit and combined diff for correctness, security, data loss, tenancy/auth, concurrency, null/undefined handling, edge cases, performance, critical path risk, and missing tests.
- Verify every finding against `default_commit`, not only the old commit snapshot.
- Include severity, file/line when available, affected commit link, concern, and recommended fix.
- Do not report style preferences or speculative issues.

Fix workflow:

- Before fixing, search open PRs, branches, and recent commits for an existing fix covering the same files, commit range, or finding.
- If there are no new commits, no findings, low-confidence findings only, an existing PR already covers the issue, or verification is blocked, do not create a PR.
- Treat `default_commit` as the sole review and fix base. Never use or mutate a local default branch: do not check it out, create it, pull it, switch it, merge it, rebase it, reset it, or update it.
- For high-confidence fixable issues, create a fresh `[BRANCH_PREFIX]-commit-review-YYYYMMDD-HHMMSS` branch with no upstream directly from `default_commit` in the isolated worktree.
- Before editing, require `git rev-parse HEAD` to equal `default_commit` exactly and `git status --porcelain=v1 --untracked-files=all` to produce no output; stop and report without editing if either check fails.
- Find at least three relevant local examples before changing patterns.
- Apply the smallest safe fix. Add or update focused tests when behavior, shared helpers, auth, validation, persistence, concurrency, or user-facing flows change.
- Run focused verification for touched areas.
- Commit, push, and open one PR against `default_branch` with:
  - reviewed commit range,
  - findings fixed,
  - files changed,
  - verification results,
  - residual risk.

Output:

- Report `default_branch`, `default_commit`, baseline SHA, reviewed head SHA, commit count, commit inventory, findings, notable commits, branch/PR if created, validation run, baseline update status, skipped work, blockers, and residual risk.
