# Codex Automation: Nightly E2E Expansion

Recommended settings:

- Kind: cron
- Execution environment: worktree
- Reasoning effort: high
- Write surface: test branch plus pull request

## Prompt

Extend the nightly e2e coverage footprint for `[PROJECT]` by exactly one focused product-area spec.

Scope:

- Work only in `[REPO_PATH]` and `[GITHUB_REPO]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.
- Open pull requests against `[TRUNK]` only.
- Do not deploy, touch production, run live migrations, stage secrets, or edit environment files.

Resource limits:

- Do not run e2e specs locally.
- Do not start Docker, dev servers, watch mode, or full builds locally.
- Allowed local gates are static formatting/linting and test discovery or compile-only commands when available.
- The new spec is exercised by CI or nightly infrastructure after the PR is opened.

Workflow:

- Run in the Codex worktree execution environment.
- Run `git fetch --all --prune`.
- Read current nightly spec lists, existing e2e tests, routes, controllers, services, serializers, guards, DTOs, seed data, and expected statuses.
- Pick one high-value uncovered area, or deepen one thin existing spec with a missing edge case.
- If there is no net-new value, report that and stop without creating a branch.
- Add exactly one focused e2e spec matching existing style.
- Add seed data only when necessary, idempotent, and deterministic.
- Add the spec to every scheduler/list that controls nightly execution and keep runner lists in sync.
- Verify every assertion against actual source.
- Run allowed static checks and compile/discovery gates when available.
- Search open PRs and branches for an existing nightly e2e spec for the same area; if one exists, report it and stop.
- Commit, push, and open one PR against `[TRUNK]`.
- Do not merge the PR.

Output:

- Report area added or skip reason, spec filename, test count, runner lists updated, verification verdict, validation performed, branch, PR URL, blockers, and residual risk.
