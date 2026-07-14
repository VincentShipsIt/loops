# Codex Automation: Nightly E2E Expansion

Recommended settings:

- Kind: cron
- Execution environment: worktree
- Write surface: one test branch plus pull request

## Prompt

Add exactly one focused, high-value E2E coverage unit for `[PROJECT]` and hand execution evidence to CI/nightly infrastructure.

Scope and local resource policy:

- Work only in `[REPO_PATH]` and `[GITHUB_REPO]`; do not inspect `[OUT_OF_SCOPE_PROJECTS]`.
- Do not run E2E tests, dev servers, Docker, watch mode, or full builds locally by default.
- Local E2E execution is permitted only when `[ALLOW_LOCAL_E2E]` is exactly true and `[LOCAL_E2E_RESOURCE_CONTRACT]` is fully resolved with command scope, required services, resource/time limits, timeout, and cleanup. Otherwise CI/nightly is the execution surface.
- Local static formatting/linting and non-executing test discovery checks remain allowed.
- Never deploy, touch production, run live migrations, stage secrets, or merge the PR.

Discovery and dedupe:

- Run in an isolated Codex worktree, treat `[REPO_PATH]` as the source checkout, and read repository instructions.
- Discover the default branch directly from `origin` with `git ls-remote --symref origin HEAD`; accept only one symbolic `ref: refs/heads/<default-branch> HEAD` result and record it as `default_branch`.
- Fetch only that branch into its remote-tracking ref with `git fetch --prune origin "+refs/heads/${default_branch}:refs/remotes/origin/${default_branch}"`, then record `default_commit` with `git rev-parse "refs/remotes/origin/${default_branch}^{commit}"`. Stop if discovery or resolution is missing or ambiguous.
- Treat `default_commit` as the sole work base. Never use or mutate a local default branch.
- Discover the repo's E2E locations, file naming, language/framework, runner lists, package manager, fixtures/seeds, routes, auth/tenant gates, serializers, and expected statuses. Do not assume a path or extension.
- Find at least three nearby E2E examples, then choose one important uncovered user path with bounded fixture risk, or deepen one thin existing coverage unit.
- Search open PRs, remote branches, and worktrees for the same area before writing. If equivalent work exists or no net-new value exists, report and stop without a branch.

Write and verify:

- Create `[BRANCH_PREFIX]-e2e-YYYYMMDD-HHMMSS` with no upstream directly from `default_commit` in the isolated worktree.
- Before editing, require `git rev-parse HEAD` to equal `default_commit` exactly and `git status --porcelain=v1 --untracked-files=all` to produce no output; stop and report without editing if either check fails.
- Add exactly one focused coverage unit matching discovered conventions. Keep fixtures deterministic/idempotent and update every discovered runner/scheduler list.
- Verify assertions against source and run allowed static lint/format/discovery checks.
- When local E2E opt-in is not valid, do not execute the test locally; record the CI/nightly command or workflow expected to exercise it.
- Commit, push, and open one PR against `default_branch`.

Output:

- Report `default_branch`, `default_commit`, area/path covered, discovered test convention, files/runner lists changed, local static checks, local E2E execution (not run or opt-in evidence), CI/nightly execution evidence or pending workflow, branch/PR, blockers, and residual risk.
