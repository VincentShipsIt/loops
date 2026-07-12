# Codex Automation: Sentry Hotfix

Recommended settings:

- Kind: cron
- Execution environment: worktree
- Reasoning effort: high
- Write surface: repo branch, pull request, Sentry issue status

## Prompt

Check unresolved Sentry errors for `[PROJECT]` and implement safe code fixes when there is enough evidence.

Repository policy:

- This automation is scoped only to `[PROJECT]`: `[REPO_PATH]`.
- GitHub repository: `[GITHUB_REPO]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]` or any unrelated project.
- Read `AGENTS.md`, `CLAUDE.md`, and relevant memory files before changing code.
- Use the repo's package manager and existing commands.
- Never run production deploys, production migrations, destructive cleanup, or live data writes outside Sentry issue status updates described below.
- Use `[TRUNK]` as the sole trunk/base branch. Open pull requests against `[TRUNK]` only.

Sentry policy:

- Check unresolved Sentry issues for `[SENTRY_ORG]` and `[SENTRY_PROJECTS]`.
- Use available Sentry tools, CLI, or API credentials.
- Never print tokens or secrets.
- For each unresolved issue, inspect the latest event, stacktrace, route, environment/release, tags, and suspect code before deciding whether a code change is needed.
- Check open PRs and recent branches for the issue short ID, title, route, and stack signature to avoid duplicate fix PRs.

Worktree hard gate:

- This automation must run in the Codex worktree execution environment.
- Treat `[REPO_PATH]` as the source checkout only; do not edit, commit, stash, reset, switch, or pull there.
- If `pwd` resolves to the source checkout, stop and report blocked.
- Base fixes from local `[TRUNK]` in the source checkout.
- Run `git fetch --all --prune` in the worktree before creating any branch or commit.
- Verify the work branch merge-base is exactly local `[TRUNK]` before editing.
- Use or create a fresh timestamped branch based directly on `[TRUNK]`, formatted like `[BRANCH_PREFIX]-sentry-YYYYMMDD-HHMMSS`.

Fix workflow:

- If there are no unresolved Sentry issues, report the count and stop without creating a branch or PR.
- If unresolved issues are already clearly fixed by an open PR against `[TRUNK]`, do not duplicate the fix.
- Resolve Sentry issues only when there is a clear existing fix PR or newly opened fix PR.
- For actionable new issues, find at least three relevant local examples before changing patterns.
- Apply the smallest code fix that turns bad input, auth, race, missing data, or edge behavior into the correct handled response.
- Add or update focused tests when behavior, shared helpers, auth, validation, persistence, or user-facing flows change.
- Run focused validation for touched areas.
- If validation cannot run or fails, report the blocker and do not push a fix PR.
- Commit, push, and open a PR against `[TRUNK]` with Sentry short IDs, routes, root cause, and validation commands.
- Do not resolve issues that have neither a clear existing fix PR nor a newly opened fix PR.
- Do not merge the PR.

Output expectations:

- Report unresolved issue count, issue short IDs handled, branch, base commit, commit, PR URLs created or reused, Sentry issues resolved, validation run, and blockers.

