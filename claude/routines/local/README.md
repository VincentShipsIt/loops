# Clean Claude Local Routine Templates

Project-agnostic Claude local routine templates derived from working scheduled-task patterns.

These are clean templates, not raw exports. They intentionally do not include project names, organization names, issue numbers, pull request URLs, local usernames, machine paths, hostnames, tokens, run history, or repository-specific labels.

Each directory contains a `SKILL.md` prompt body. When installed as a Claude Desktop scheduled task, Claude Desktop manages schedule, enabled state, model, folder, and permissions in the app.

## Execution settings

Claude Desktop manages model and effort settings in the app. Keep those settings out of reusable prompt bodies.

The app also owns schedule/enabled state, selected folder, execution mode, permissions, and connectors. Prompt bodies own outcome, scope, authority, base branch, state/dedupe, verification, stop/failure behavior, and output. Keep runtime safety checks in the prompt as defense in depth.

## Templates

- `scheduled-task-base/`
- `github-issue-implementation/`
- `recent-commit-review/`
- `github-backlog-pickup/`
- `board-hygiene/`
- `sentry-hotfix/`
- `tool-fix-pass/`
- `dry-repo/`
- `local-validation/`
- `pr-review/`
- `worktree-prune/`
- `docs-verification/`
- `bundle-size-watchdog/`
- `nightly-e2e-expansion/`
- `repo-hygiene-cleanup/`
- `memory-review/`

## Suggested Cadence

Claude stores schedule settings in the app, not in these `SKILL.md` prompt files. Use
`../../../shared/loop-intents.md` as the source of truth when configuring live schedules.

| Task | Suggested cadence |
| --- | --- |
| `github-issue-implementation` | Every two hours for active repositories, or nightly for conservative repositories. |
| `github-backlog-pickup` | Nightly. |
| `recent-commit-review` | Daily after `[TRUNK]` is usually quiet. |
| `board-hygiene` | Weekly, at the start of the work week. |
| `sentry-hotfix` | Every 6 business hours, or event-triggered after new unresolved production errors. |
| `pr-review` | Hourly during work hours, or event-triggered when a PR opens/updates. |
| `tool-fix-pass` | Nightly or weekly, depending on tool noise. Configure `[TOOL_FOCUS]` for security, React, lint, dead code, dependencies, or accessibility. |
| `dry-repo` | Weekly at most. |
| `local-validation` | Hourly to daily, depending on command cost and local environment stability. |
| `worktree-prune`, `repo-hygiene-cleanup` | Daily or weekly. |
| `docs-verification`, `bundle-size-watchdog` | Weekly or after relevant large changes. |
| `nightly-e2e-expansion` | Nightly or weekly. |
| `memory-review` | Weekly, or after large source/schema changes. |

## Placeholder Key

- `[PROJECT]` - human-readable project name.
- `[REPO_PATH]` - local repository path.
- `[GITHUB_REPO]` - `owner/repo`.
- `[TRUNK]` - trunk branch, usually `main` or `master`.
- `[BRANCH_PREFIX]` - safe branch prefix.
- `[STATE_FILE]` - file or scheduled task memory location for durable loop state.
- `[OUT_OF_SCOPE_PROJECTS]` - projects this task must not inspect.
- `[VALIDATION_COMMANDS]` - explicit local validation commands to run sequentially.
- `[PROJECT_BOARD]` - canonical issue/project board (e.g. a GitHub Projects board).
- `[AUTOMATION_ID]` - stable routine identifier used in dedupe markers and state.
- `[WEEKLY_MILESTONE_PATTERN]` - the repo's existing milestone naming/date pattern used to identify or create the current weekly deliverable (e.g. `Week of YYYY-MM-DD` or `Sprint NN`).
- `[REVIEW_MARKER]` - stable marker label written inside a hidden comment with `[AUTOMATION_ID]` and the reviewed head SHA (for example `routine:pr-review`).
- `[TOOL_COMMAND]` - command this routine runs (linter/scanner/test script), e.g. `bun run lint`.
- `[TOOL_BASELINE_COMMAND]` - optional read-only baseline command for tools that compare before/after output.
- `[TOOL_VERIFY_COMMAND]` - optional final scan command that must pass or show verified improvement.
- `[TOOL_FOCUS]` - configured scanner/fix focus, such as security, React, lint, dead code, dependencies, or accessibility.
- `[AUTOMATION_ASSIGNEE]` - issue assignee that marks an issue as owned by this routine.
- `[ALLOW_SAFE_DELETES]` - boolean gate; when true the routine may delete provably-merged, clean
  targets, otherwise it only reports candidates.
- `[SENTRY_ORG]` - Sentry organization slug used by sentry-hotfix.
- `[SENTRY_PROJECTS]` - comma-separated Sentry project slugs to query for unresolved issues.
- `[SENTRY_OBSERVATION_RULE]` - configured post-deployment window or event-sample rule required before resolving a Sentry issue.
- `[ALLOW_LOCAL_E2E]` - boolean opt-in; unresolved or false keeps E2E execution in CI/nightly.
- `[LOCAL_E2E_RESOURCE_CONTRACT]` - project-defined local E2E command scope, services, resource/time limits, timeout, and cleanup.
- `[REPO_PATH_1]`, `[REPO_PATH_2]` - local repo paths for multi-repo routines (repo-hygiene-cleanup).
- `[GITHUB_REPO_1]`, `[GITHUB_REPO_2]` - `owner/repo` for multi-repo routines.

Remote validation is opt-in only. A project-specific routine may add it after the repo documents transport/tool, worker repo path, revision/bootstrap, dependency state, required services, environment-variable names, secret policy, concurrency lock, timeout, cleanup, and result return. Generic templates report prohibited or heavy validation as blocked/skipped instead.

## Tool Fix Presets

React Doctor:

- `[TOOL_FOCUS]` = `React Doctor`
- `[TOOL_BASELINE_COMMAND]` = `pnpm exec react-doctor . --verbose --yes --offline --fail-on none`
- `[TOOL_COMMAND]` = `pnpm exec react-doctor . --verbose --yes --offline --fail-on error`
- `[TOOL_VERIFY_COMMAND]` = `pnpm exec react-doctor . --verbose --yes --offline --fail-on error`
