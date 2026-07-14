---
name: sentry-hotfix
description: Open one safe Sentry fix PR and resolve only after deployment evidence
---

Inspect unresolved Sentry errors for `[PROJECT]`, open at most one safe fix PR, and resolve an issue only after deployment and observation evidence.

Scope and state:
- Work only in `[REPO_PATH]`, `[GITHUB_REPO]`, `[SENTRY_ORG]`, and `[SENTRY_PROJECTS]`; do not inspect `[OUT_OF_SCOPE_PROJECTS]`.
- Never expose secrets, merge, deploy, run live migrations, or write production data.
- In `[STATE_FILE]`, dedupe by Sentry issue id and stack signature. Record fix PR, fix commit, target release/environment, last checked event id/time, deployment evidence, observation status, and resolution status.

Triage and dedupe:
- Read repository instructions and run `git fetch --all --prune`.
- Inspect each unresolved issue's latest event, stacktrace, route, environment, release, tags, breadcrumbs, and suspect code.
- Check state, open PRs, and recent branches for issue id, title, route, and stack signature before creating work.
- A matching open/new PR is a fix handoff only. Opening or finding a PR never resolves the Sentry issue.
- If no issue needs a new code fix or lifecycle check, report the unresolved count and stop.

Fix workflow:
- For one actionable issue without a covering PR, create an isolated `[BRANCH_PREFIX]-sentry-YYYYMMDD-HHMMSS` branch/worktree from fetched `origin/[TRUNK]`. Never edit, switch, pull, stash, or reset the source checkout.
- Find relevant local examples, apply the smallest safe fix, and add focused tests when behavior changes.
- Run required proportional validation. If a required check is prohibited, unavailable, or too heavy, report the blocker and do not publish an unverified PR.
- Commit, push, and open one PR against `[TRUNK]` with issue id, route/signature, root cause, fix commit, and validation. Do not resolve the Sentry issue.

Deployment-aware resolution:
- Check tracked fix commits for explicit evidence that the commit is included in a deployed release for the affected environment.
- If evidence is unavailable or ambiguous, leave unresolved and report `handoff: awaiting deployment evidence`.
- After deployment, apply `[SENTRY_OBSERVATION_RULE]` to post-deployment Sentry events. Resolve only when the configured window/sample is complete and the stack signature has not recurred.
- If the signature recurs, keep unresolved and update the last checked event.
- Never infer deployment from merge state, a PR label, or elapsed time alone.

Output:
- Report unresolved count and, per handled issue: PR opened/reused, fix commit, deployed yes/no/unknown, observation complete/pending/recurred, resolved yes/no, release/environment, last checked event, validation, blockers, and residual risk.
