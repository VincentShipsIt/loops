# Claude Scheduled Task: GitHub Issue Implementation

## Prompt


Implement one ready, high-value GitHub issue in this repository, conservatively and without creating duplicate work.

CPU-heavy validation policy:

- Do not run CPU-intensive tests or heavy validation on the local laptop.
- Run CPU-heavy tests/checks on `[REMOTE_WORKER]` when available.
- Lightweight local checks are allowed only when clearly quick/static.
- If unsure whether a test command is CPU-heavy, treat it as CPU-heavy and run it remotely or skip it with a clear note.

Repository policy:

- This task is scoped only to `[PROJECT]`: `[REPO_PATH]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]` or any unrelated project.

Workflow:

- Read local agent instructions before editing.
- Inspect open issues/PRs, local branches, and git worktrees before choosing work.
- Use `[TRUNK]` as the base branch.
- Choose one ready issue that is not already covered by active work.
- Prefer small, shippable implementation tasks with clear acceptance criteria.
- Run `git fetch --all --prune`.
- Create a fresh timestamped branch/worktree based directly on `origin/[TRUNK]`.
- Verify the base before editing.
- Follow existing codebase patterns and find at least three examples before introducing a new pattern.
- Add focused tests/validation for changed behavior.
- Run the smallest relevant checks/tests for touched areas; if the right verification command cannot run, report the blocker and do not push a PR.
- Do not run destructive commands, production writes, deploys, or live migrations.
- Commit and open a pull request against `[TRUNK]`.
- Do not merge the PR.

If no safe ready issue is available, report the reason and skip without creating noisy changes.
