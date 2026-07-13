# Codex Automation: DRY Repo

Recommended settings:

- Kind: cron
- Execution environment: worktree
- Reasoning effort: high
- Write surface: repo branch plus pull request

## Prompt

Make one small behavior-preserving simplification in `[PROJECT]` without deleting features.

Scope:

- Work only in `[REPO_PATH]` and `[GITHUB_REPO]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.
- Open pull requests against `[TRUNK]` only.
- Do not deploy, run live migrations, delete production data, or remove product behavior.

Workflow:

- Read `[STATE_FILE]` if present; skip any simplification target recorded as attempted since the last merged PR.
- Run `git fetch --all --prune`.
- Base work from latest `origin/[TRUNK]`.
- Search for one clear low-risk simplification target: duplicated logic, redundant branches, unnecessary indirection, stale comments, duplicate config, or obvious unreachable code.
- Skip if equivalent cleanup/refactor work is already active.
- If no clear low-risk simplification target is found, stop and report no-op without opening a PR.
- Prefer targets with focused tests or cheap validation.
- Preserve behavior exactly.
- Do not remove features, public APIs, migrations, compatibility code, or uncertain behavior.
- Find at least three local examples before introducing or changing an abstraction.
- Run focused validation for touched areas.
- Commit, push, and open one PR against `[TRUNK]`.
- Do not merge the PR.

Output:

- Report simplification target, evidence it was safe, files changed, branch, commit, PR URL, validation, skipped candidates, and residual risk.
