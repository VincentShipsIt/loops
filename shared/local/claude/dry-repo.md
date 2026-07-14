# Claude Scheduled Task: DRY Repo

## Prompt


Make one small behavior-preserving simplification in `[PROJECT]` without deleting features.

CPU-heavy validation policy:

- Do not run CPU-intensive tests or heavy validation locally.
- Lightweight local checks are allowed only when clearly quick/static.
- If required validation is prohibited or too heavy for the configured environment, report blocked and do not publish changes.

Scope:

- Work only in `[REPO_PATH]`.
- GitHub repository: `[GITHUB_REPO]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.
- Do not deploy, run live migrations, delete production data, or remove product behavior.
- Do not merge the PR.

Workflow:

- Read `[STATE_FILE]` if present; skip any simplification target recorded as attempted since the last merged PR.
- Read local agent instructions.
- Treat `[REPO_PATH]` as the source checkout and require a separate registered worktree for edits.
- Discover the default branch directly from `origin` with `git ls-remote --symref origin HEAD`; accept only one symbolic `ref: refs/heads/<default-branch> HEAD` result and record it as `default_branch`.
- Fetch only that branch into its remote-tracking ref with `git fetch --prune origin "+refs/heads/${default_branch}:refs/remotes/origin/${default_branch}"`, then record `default_commit` with `git rev-parse "refs/remotes/origin/${default_branch}^{commit}"`. Stop if discovery or resolution is missing or ambiguous.
- Treat `default_commit` as the sole work base. Never use or mutate a local default branch.
- Search for one clear low-risk simplification target: duplicated logic, redundant branches, unnecessary indirection, stale comments, duplicate config, or obvious unreachable code.
- Search open PRs, branches, and active worktrees; skip if equivalent cleanup/refactor work is already active.
- If no clear low-risk simplification target is found, stop and report no-op without opening a PR.
- Create `[BRANCH_PREFIX]-simplify-YYYYMMDD-HHMMSS` with no upstream directly from `default_commit` in the isolated worktree.
- Before editing, require `git rev-parse HEAD` to equal `default_commit` exactly and `git status --porcelain=v1 --untracked-files=all` to produce no output; stop and report without editing if either check fails.
- Prefer targets with focused tests or cheap validation.
- Preserve behavior exactly.
- Do not remove features, public APIs, migrations, compatibility code, or uncertain behavior.
- Find at least three local examples before introducing or changing an abstraction.
- Run focused validation for touched areas.
- Commit and open a PR against `default_branch`.

Output:

- Report `default_branch`, `default_commit`, simplification target, evidence it was safe, files changed, branch, PR URL, validation, skipped candidates, and residual risk.
