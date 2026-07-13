# Shared Loop Intents

This catalog is the source of truth for loop intent. Platform files may differ in
format, schedule storage, model settings, and execution environment, but matching
rows below should do the same kind of work.

Use GitHub-prefixed names when the current loop depends on GitHub issues, pull
requests, or project boards. Keep a generic name only when the same prompt can
reasonably work across trackers.

## Cadence Rule

Codex app automations store cadence in `automation.toml` as `rrule`.
Claude Desktop scheduled tasks store cadence in the app, not in `SKILL.md`.
Use the suggested cadence here when creating the live Claude schedule.

## Surface Rule

Use local or worktree execution for loops that read source files, run tests, edit
code, create branches, or open PRs. That includes implementation, hotfix,
review-fix, tool-fix, docs-fix, e2e expansion, cleanup, and validation loops.

Use remote connector routines for read-only or metadata/API workflows by default:
GitHub board hygiene, issue triage, PR routing, digests, and notifications.
Remote routines can update GitHub metadata when the prompt explicitly defines
the allowed fields and duplicate checks.

Do not make remote-worker validation a default template. It only works safely
when a project defines the worker host, repo path, env/bootstrap contract,
available services, secrets policy, lock behavior, and cleanup policy. Until
that exists, use `local-validation` and report missing environment as blocked.

## Canonical Intents

| Intent | Purpose | Suggested cadence | Current surfaces |
| --- | --- | --- | --- |
| `github-issue-implementation` | Claim exactly one `Backlog` issue, implement it, verify it, open a PR, and leave the item `In Progress`. | Every two hours for active repos, or nightly for conservative repos. | Codex `github-issue-implementation`; Claude `github-issue-implementation`; Claude `github-backlog-pickup` as the higher-autonomy variant. |
| `recent-commit-review` | Review new trunk commits since a durable baseline and open a fix PR only for high-confidence issues. | Daily after the trunk branch is usually quiet. | Codex `recent-commit-review`; Claude `recent-commit-review`. |
| `board-hygiene` | Audit GitHub board readiness for weekly execution and repair issue/board/milestone/priority metadata without creating duplicate issue/card work; answer Ready: yes/no. | Weekly, at the start of the work week. | Codex local `board-hygiene`; Claude local `board-hygiene`; Claude remote `board-hygiene`. |
| `sentry-hotfix` | Inspect unresolved Sentry issues, avoid duplicate fix PRs, and open one safe verified fix PR. | Every 6 business hours, or event-triggered after new unresolved production errors. | Codex `sentry-hotfix`; Claude `sentry-hotfix`. |
| `pr-review` | Review one open PR strictly and optionally improve automation-owned PR branches. | Hourly during work hours, or event-triggered when a PR opens/updates. | Codex `pr-review`; Claude `pr-review`. |
| `tool-fix-pass` | Run one configured quality/security/frontend scanner and open a small safe fix PR. | Nightly or weekly, depending on tool noise. | Codex `tool-fix-pass`; Claude `tool-fix-pass`. Use `[TOOL_FOCUS]` for security, React, lint, dead code, dependencies, accessibility, or similar variants. |
| `dry-repo` | Make one behavior-preserving cleanup/refactor that reduces duplication or unnecessary complexity. | Weekly at most. | Codex `dry-repo`; Claude `dry-repo`. |
| `local-validation` | Run scheduled read-only validation in the local checkout and report blockers when the environment is incomplete. | Hourly to daily, depending on command cost and local environment stability. | Codex `local-validation`; Claude `local-validation`. |
| `worktree-prune` | Remove only clean, provably merged local worktrees and branches. | Daily or weekly. | Codex `worktree-prune`; Claude `worktree-prune`; Claude `repo-hygiene-cleanup` for multi-repo reporting. |
| `docs-verification` | Verify documentation claims against source code and open documentation corrections. | Weekly or after large API/schema changes. | Codex `docs-verification`; Claude `docs-verification`. |
| `bundle-size-watchdog` | Read dependency/build artifact sizes and report threshold violations without modifying files. | Daily or weekly. | Codex `bundle-size-watchdog`; Claude `bundle-size-watchdog`. |
| `nightly-e2e-expansion` | Add exactly one high-value nightly e2e spec and update runner lists. | Nightly or weekly. | Codex `nightly-e2e-expansion`; Claude `nightly-e2e-expansion`. |
| `agent-content-maintenance` | Improve a repo whose product is prompts, skills, templates, docs, rubrics, or evaluation fixtures. This is not a general app-maintenance loop. | Weekly or monthly, and only for content/template-heavy repos. | Codex `content-factory-maintenance`. |

## Support Artifacts

`memory` is not an automation intent. It is a short state file used by recurring
Codex automations to remember baselines, active work, known skips, and duplicate
search keys between runs. Claude scheduled tasks can use `[STATE_FILE]` for the
same concept, but Claude does not have a portable local memory file format in
this repo.

`scheduled-task-base` is not an automation intent. It is a Claude prompt wrapper.

Claude has a few extra local wrappers because Claude Desktop scheduled tasks are
good at local and multi-repo maintenance. Do not mirror those into Codex unless
they can be scoped to one repository with an explicit Codex execution environment.

## Tool Fix Presets

`tool-fix-pass` is a wrapper. It is not ready to run until the installer fills
the tool placeholders from a real project command.

React Doctor example:

- `[TOOL_FOCUS]`: `React Doctor`
- `[TOOL_BASELINE_COMMAND]`: `pnpm exec react-doctor . --verbose --yes --offline --fail-on none`
- `[TOOL_COMMAND]`: `pnpm exec react-doctor . --verbose --yes --offline --fail-on error`
- `[TOOL_VERIFY_COMMAND]`: `pnpm exec react-doctor . --verbose --yes --offline --fail-on error`

If a project uses npm, yarn, bun, or a package script wrapper, replace the
commands with the project-native equivalent.
