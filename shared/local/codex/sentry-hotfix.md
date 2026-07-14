# Codex Automation: Sentry Hotfix

Recommended settings:

- Kind: cron
- Execution environment: worktree
- Reasoning effort: high
- Write surface: one repo branch/PR, state, and evidence-gated Sentry resolution

## Prompt

Inspect unresolved Sentry errors for `[PROJECT]`, open at most one safe fix PR, and resolve an issue only after deployment and observation evidence.

Scope and state:

- Work only in `[REPO_PATH]`, `[GITHUB_REPO]`, `[SENTRY_ORG]`, and `[SENTRY_PROJECTS]`; do not inspect `[OUT_OF_SCOPE_PROJECTS]`.
- Never expose secrets, merge, deploy, run live migrations, or write production data.
- In automation memory or `[STATE_FILE]`, dedupe by issue id and stack signature. Record fix PR, fix commit, target release/environment, last checked event id/time, deployment evidence, observation status, and resolution status.

Triage and dedupe:

- Read repository instructions. Discover the default branch directly from `origin` with `git ls-remote --symref origin HEAD`; accept only one symbolic `ref: refs/heads/<default-branch> HEAD` result and record it as `default_branch`.
- Fetch only that branch into its remote-tracking ref with `git fetch --prune origin "+refs/heads/${default_branch}:refs/remotes/origin/${default_branch}"`, then record `default_commit` with `git rev-parse "refs/remotes/origin/${default_branch}^{commit}"`. Stop if discovery or resolution is missing or ambiguous.
- Inspect each unresolved issue's latest event, stacktrace, route, environment, release, tags, breadcrumbs, and suspect code.
- Check state, open PRs, and recent branches for issue id, title, route, and stack signature before creating work.
- A matching open/new PR is a fix handoff only. Opening or finding a PR never resolves the Sentry issue.
- If no issue needs a new code fix or lifecycle check, report the unresolved count and stop.

Fix workflow:

- Run in an isolated Codex worktree. Treat `[REPO_PATH]` as the source checkout; never edit, switch, pull, stash, or reset it, and stop if it is the current working directory.
- Treat `default_commit` as the sole fix base. Never use or mutate a local default branch: do not check it out, create it, pull it, switch it, merge it, rebase it, reset it, or update it.
- For one actionable issue without a covering PR, create `[BRANCH_PREFIX]-sentry-YYYYMMDD-HHMMSS` with no upstream directly from `default_commit` in the isolated worktree.
- Before editing, require `git rev-parse HEAD` to equal `default_commit` exactly and `git status --porcelain=v1 --untracked-files=all` to produce no output; stop and report without editing if either check fails.
- Find relevant local examples, apply the smallest safe fix, add focused tests, and run required proportional validation.
- If required validation cannot run or fails, report the blocker and do not publish an unverified PR.
- Commit, push, and open one PR against `default_branch` with issue id, route/signature, root cause, fix commit, and validation. Do not resolve the Sentry issue.

Deployment-aware resolution:

- Check tracked fix commits for explicit evidence that the commit is included in a deployed release for the affected environment.
- If evidence is unavailable or ambiguous, leave unresolved and report `handoff: awaiting deployment evidence`.
- After deployment, apply `[SENTRY_OBSERVATION_RULE]` to post-deployment events. Resolve only when the configured window/sample is complete and the stack signature has not recurred.
- If the signature recurs, keep unresolved and update the last checked event.
- Never infer deployment from merge state, a PR label, or elapsed time alone.

Output:

- Report `default_branch`, `default_commit`, unresolved count and, per handled issue: PR opened/reused, fix commit, deployed yes/no/unknown, observation complete/pending/recurred, resolved yes/no, release/environment, last checked event, validation, blockers, and residual risk.
