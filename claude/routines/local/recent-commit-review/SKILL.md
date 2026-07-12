---
name: recent-commit-review
description: Review recent trunk commits and open a fix PR for high-confidence issues
---

Review new commits on `[GITHUB_REPO]` `[TRUNK]` since the last successful review baseline SHA, or the last 24 hours when no baseline exists. Fix only high-confidence issues.

Scope:
- Work only in `[REPO_PATH]` and `[GITHUB_REPO]`.
- Trunk branch: `[TRUNK]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]` or unrelated projects.
- Never merge PRs, deploy, run production migrations, or write to production data.
- Never print tokens, secrets, `.env` contents, private payloads, or credentials.

State and baseline:
- Store `last_successful_review_baseline_sha` in `[STATE_FILE]`.
- Fetch the latest remote state before reading or writing the baseline.
- If a valid baseline SHA exists and is an ancestor of `origin/[TRUNK]`, review `baseline..origin/[TRUNK]`.
- If no valid baseline exists, review commits on `origin/[TRUNK]` from the last 24 hours.
- If the baseline is not an ancestor of `origin/[TRUNK]`, stop and report the mismatch.
- Update the baseline only after a successful review cycle: no new commits, no findings, findings reported with no safe fix needed, or a verified fix branch is pushed and a PR is opened.
- Do not update the baseline when fetch, review, validation, push, or PR creation fails.

Workflow:
- Read local agent instructions before acting.
- Run `git fetch --all --prune`.
- List each reviewed commit with short hash, author, date, message, and GitHub link.
- Summarize the change in one sentence per commit after reading the diff.
- Flag notable commits: large diffs; auth, billing, persistence, migrations, data loss, security, background jobs, build, deploy, environment, or dependency changes; behavior changes without tests or docs; unusual patterns compared with local examples.
- Review each commit and combined diff for correctness, security, data loss, tenancy/auth, concurrency, null/undefined handling, edge cases, performance, critical path risk, and missing tests.
- Verify every finding against current `origin/[TRUNK]`, not only the old commit snapshot.
- Include severity, file/line when available, affected commit link, concern, and recommended fix.
- Do not report style preferences or speculative issues.

Fix workflow:
- Before fixing, search open PRs, branches, and recent commits for an existing fix covering the same files, commit range, or finding.
- If there are no new commits, no findings, low-confidence findings only, an existing PR already covers the issue, or verification is blocked, do not create a PR.
- For high-confidence fixable issues, create a fresh branch from latest `origin/[TRUNK]` formatted like `[BRANCH_PREFIX]-commit-review-YYYYMMDD-HHMMSS`.
- Find at least three relevant local examples before changing patterns.
- Apply the smallest safe fix. Add or update focused tests when behavior, shared helpers, auth, validation, persistence, concurrency, or user-facing flows change.
- Run focused verification for touched areas.
- Commit, push, and open one PR against `[TRUNK]` with reviewed commit range, findings fixed, files changed, verification results, and residual risk.

Output:
- Report baseline SHA, reviewed head SHA, commit count, commit inventory, findings, notable commits, branch/PR if created, validation run, baseline update status, skipped work, blockers, and residual risk.
