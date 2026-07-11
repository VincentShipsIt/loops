# Clean Claude Local Routine Templates

Project-agnostic Claude local routine templates derived from working scheduled-task patterns.

These are clean templates, not raw exports. They intentionally do not include project names, organization names, issue numbers, pull request URLs, local usernames, machine paths, hostnames, tokens, run history, or repository-specific labels.

Each directory contains a `SKILL.md` prompt body. When installed as a Claude Desktop scheduled task, Claude Desktop manages schedule, enabled state, model, folder, and permissions in the app.

## Ultracode Trigger

`ultracode` requests Claude Opus 4.8-level effort. The trigger is a **bare `ultracode` token on the first
line of the prompt body**, immediately after the frontmatter — NOT the task name. Keep task names
focused on the automation intent, not the execution effort.

Correct shape:

```text
---
name: recent-commit-review
description: Review recent trunk commits and open a fix PR
---

ultracode

Review new commits on `[GITHUB_REPO]` ...
```

Also set the task's model to **Claude Opus 4.8** in the app. The app model selection and the body token
work together: the token drives the high-effort run.

Templates that carry the trigger (code review + code building + validation):
github-issue-implementation, github-backlog-pickup, recent-commit-review, sentry-hotfix,
pr-review, tool-fix-pass, dry-repo, nightly-e2e-expansion,
docs-verification, bundle-size-watchdog, local-validation, memory-review.
Pure hygiene tasks (board-hygiene, worktree-prune, repo-hygiene-cleanup) intentionally omit it.
The read-only `agent-configuration-audit` task also omits it: configure Opus 4.8 at high effort in the app and do not use Max, Ultracode, workflows, agent teams, or subagents.

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
- `agent-configuration-audit/`

## Suggested Cadence

Claude stores schedule settings in the app, not in these `SKILL.md` prompt files. Use
`../../../shared/loop-intents.md` as the source of truth when configuring live schedules.

| Task | Suggested cadence |
| --- | --- |
| `github-issue-implementation` | Every 4-6 business hours for active repos, or nightly for conservative repos. |
| `github-backlog-pickup` | Nightly. |
| `recent-commit-review` | Daily after `[TRUNK]` is usually quiet. |
| `board-hygiene` | Daily or twice daily on active boards. |
| `sentry-hotfix` | Every 6 business hours, or event-triggered after new unresolved production errors. |
| `pr-review` | Hourly during work hours, or event-triggered when a PR opens/updates. |
| `tool-fix-pass` | Nightly or weekly, depending on tool noise. Configure `[TOOL_FOCUS]` for security, React, lint, dead code, dependencies, or accessibility. |
| `dry-repo` | Weekly at most. |
| `local-validation` | Hourly to daily, depending on command cost and local environment stability. |
| `worktree-prune`, `repo-hygiene-cleanup` | Daily or weekly. |
| `docs-verification`, `bundle-size-watchdog` | Weekly or after relevant large changes. |
| `nightly-e2e-expansion` | Nightly or weekly. |
| `memory-review` | Weekly, or after large source/schema changes. |
| `agent-configuration-audit` | Monthly, or after major Claude Code/Codex or routing changes. |

## Placeholder Key

- `[PROJECT]` - human-readable project name.
- `[REPO_PATH]` - local repository path.
- `[GITHUB_REPO]` - `owner/repo`.
- `[TRUNK]` - trunk branch, usually `main` or `master`.
- `[BRANCH_PREFIX]` - safe branch prefix.
- `[STATE_FILE]` - file or scheduled task memory location for durable loop state.
- `[OUT_OF_SCOPE_PROJECTS]` - projects this task must not inspect.
- `[VALIDATION_COMMANDS]` - explicit local validation commands to run sequentially.
- `[REMOTE_WORKER]` - optional remote worker name for code-writing tasks that explicitly support offloading heavy checks.
- `[PROJECT_BOARD]` - canonical issue/project board (e.g. a GitHub Projects board).
- `[WEEKLY_MILESTONE_PATTERN]` - the repo's existing milestone naming/date pattern used to identify or create the current weekly deliverable (e.g. `Week of YYYY-MM-DD` or `Sprint NN`).
- `[REVIEW_MARKER]` - hidden marker string this routine writes into its own review comments so it can
  detect already-reviewed PRs (e.g. an HTML comment like `<!-- routine:pr-review -->`).
- `[TOOL_COMMAND]` - command this routine runs (linter/scanner/test script), e.g. `bun run lint`.
- `[TOOL_BASELINE_COMMAND]` - optional read-only baseline command for tools that compare before/after output.
- `[TOOL_VERIFY_COMMAND]` - optional final scan command that must pass or show verified improvement.
- `[TOOL_FOCUS]` - configured scanner/fix focus, such as security, React, lint, dead code, dependencies, or accessibility.
- `[AUTOMATION_ASSIGNEE]` - issue assignee that marks an issue as owned by this routine.
- `[ALLOW_SAFE_DELETES]` - boolean gate; when true the routine may delete provably-merged, clean
  targets, otherwise it only reports candidates.
- `[SENTRY_ORG]` - Sentry organization slug used by sentry-hotfix.
- `[SENTRY_PROJECTS]` - comma-separated Sentry project slugs to query for unresolved issues.
- `[REPO_PATH_1]`, `[REPO_PATH_2]` - local repo paths for multi-repo routines (repo-hygiene-cleanup).
- `[GITHUB_REPO_1]`, `[GITHUB_REPO_2]` - `owner/repo` for multi-repo routines.
- `[REPOSITORY_ROOT]`, `[PRIORITY_REPOSITORIES]`, `[PREVIOUS_AUDIT_PATH]` - multi-repo audit scope and baseline.
- `[GLOBAL_AGENTS_DIR]`, `[GLOBAL_CLAUDE_DIR]`, `[GLOBAL_CODEX_DIR]` - global configuration roots.
- `[MODEL_ROUTING_POLICY]`, `[LOCAL_VERIFICATION_POLICY]`, `[EXCLUDED_PATH_PATTERNS]` - policy inputs for agent-configuration-audit.

## Tool Fix Presets

React Doctor:

- `[TOOL_FOCUS]` = `React Doctor`
- `[TOOL_BASELINE_COMMAND]` = `pnpm exec react-doctor . --verbose --yes --offline --fail-on none`
- `[TOOL_COMMAND]` = `pnpm exec react-doctor . --verbose --yes --offline --fail-on error`
- `[TOOL_VERIFY_COMMAND]` = `pnpm exec react-doctor . --verbose --yes --offline --fail-on error`
