---
name: sentry-hotfix
description: Inspect unresolved Sentry errors and open safe fix PRs
---

Check unresolved Sentry errors for `[PROJECT]` and implement safe code fixes when the evidence is clear.

CPU-heavy validation policy:
- Do not run CPU-intensive tests or heavy validation locally.
- Run CPU-heavy checks on `[REMOTE_WORKER]` when available.
- Lightweight local checks are allowed only when clearly quick/static.

Scope:
- Work only in `[REPO_PATH]` and `[GITHUB_REPO]`.
- Check only `[SENTRY_ORG]` and `[SENTRY_PROJECTS]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.
- Never print tokens, secrets, request bodies with sensitive data, or environment file contents.

Workflow:
- Read local agent instructions and project memory before changing code.
- Run `git fetch --all --prune`.
- Inspect unresolved Sentry issues, latest event, stacktrace, route, environment, release, tags, breadcrumbs, and suspect code.
- Check open PRs and recent branches for issue short ID, title, route, and stack signature before creating duplicate work.
- If no unresolved issues are actionable, report the count and stop without creating a branch.
- If an issue is already clearly fixed by an open PR against `[TRUNK]`, report the PR and do not duplicate it.
- For one actionable new issue, create a fresh branch/worktree from `origin/[TRUNK]` formatted like `[BRANCH_PREFIX]-sentry-YYYYMMDD-HHMMSS`.
- Find at least three relevant local examples before changing patterns.
- Apply the smallest safe fix that converts the failure into handled behavior.
- Add or update focused tests when behavior, shared helpers, auth, validation, persistence, or user-facing flows change.
- Run focused validation for touched areas.
- If validation cannot run or fails, report the blocker and do not push a fix PR.
- Commit, push, and open a PR against `[TRUNK]` with issue IDs, route/signature, root cause, and validation.
- Do not resolve a Sentry issue unless a clear existing PR or newly opened PR covers it.
- Do not merge the PR, deploy, run live migrations, or write production data.

Output:
- Report unresolved count, handled issue IDs, branch, base commit, commit, PR URL, validation run, issues resolved or left open, blockers, and residual risk.
