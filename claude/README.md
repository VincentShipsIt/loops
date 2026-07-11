# Claude Routines

Examples for:

- Claude Code remote Routines
- Claude Desktop local scheduled tasks
- Claude `/loop` style scheduled prompts

## Shared Templates

Use `../shared/local/claude/` for sanitized shared templates derived from local scheduled tasks:

- `../shared/local/claude/scheduled-task-base.md`
- `../shared/local/claude/github-issue-implementation.md`
- `../shared/local/claude/recent-commit-review.md`
- `../shared/local/claude/github-backlog-pickup.md`
- `../shared/local/claude/board-hygiene.md`
- `../shared/local/claude/sentry-hotfix.md`
- `../shared/local/claude/tool-fix-pass.md`
- `../shared/local/claude/dry-repo.md`
- `../shared/local/claude/local-validation.md`
- `../shared/local/claude/pr-review.md`
- `../shared/local/claude/worktree-prune.md`
- `../shared/local/claude/docs-verification.md`
- `../shared/local/claude/bundle-size-watchdog.md`
- `../shared/local/claude/nightly-e2e-expansion.md`
- `../shared/local/claude/memory-review.md`
- `../shared/local/claude/agent-configuration-audit.md`

Use `../shared/remote/claude/` for connector-safe remote Routine source prompts.

## Surface Folders

- `routines/local/` - Claude local routine templates for local files, local tools, and code execution.
- `routines/remote/` - Claude remote Routine templates for connector/API workflows.

## Clean Desktop Scheduled Task Templates

Use `routines/local/` for app-ready templates derived from local Claude Desktop scheduled task patterns:

```text
~/.claude/scheduled-tasks/
```

The template set includes GitHub issue implementation, recent commit review, backlog pickup, board hygiene, Sentry hotfixes, configurable tool fix passes, dry repo, local validation, PR review, worktree pruning, docs verification, bundle checks, e2e expansion, repo hygiene, and a read-only global/per-repository agent configuration audit. Schedule, enabled state, model, folder, and permission settings are app-managed and are not represented in `SKILL.md` files.

Use `../shared/loop-intents.md` for the canonical intent names and suggested cadence when creating the live Claude schedule.

Ultracode-class templates (code review/build/validation) emit a bare `ultracode` token as the first prompt-body line to run at Claude Opus 4.8 effort; the app model should be set to Opus 4.8.

## Included Upstreams

### `upstream/routine-templates/`

Source: https://github.com/Fisher521/routine-templates

MIT-licensed Claude Code Routine prompt templates. Useful files:

```text
upstream/routine-templates/templates/
  01-daily-reading-triage.md
  02-weekly-vault-harvest.md
  03-morning-flame-brief.md
  04-github-pr-triage.md
  05-focus-block-handoff.md
```

Best pattern to copy: `Schedule / Connectors / Delivery / Prompt / Rules / Setup`.

### `upstream/paperclip-devops-watchdog/`

Source: https://github.com/MichaelZelbel/paperclip-devops-watchdog

MIT-licensed DevOps watchdog examples. Useful files:

```text
upstream/paperclip-devops-watchdog/templates/desktop-scheduled-task-skill.example.md
upstream/paperclip-devops-watchdog/prompts/hourly-quick-repair.md
upstream/paperclip-devops-watchdog/prompts/six-hour-deep-check.md
upstream/paperclip-devops-watchdog/paperclip-devops-runbook.md
```

Best pattern to copy: scheduled task prompt delegates to a runbook and specific task prompt, with hard safety boundaries.

## Linked Examples

The linked examples are strong references but do not have explicit licenses, so they are summarized rather than copied:

- `linked-examples/aakashg-claude-routines-pm-pack.md`
- `linked-examples/ziptax-claude.md`

## Claude Storage Shapes

Remote Routines are configured in Claude's web/Desktop UI and have no portable local file format. Store their prompts and setup docs as Markdown.

Claude Desktop local scheduled task prompts live at:

```text
~/.claude/scheduled-tasks/<task-name>/SKILL.md
```

Schedule, model, folder, enabled state, and permissions are app-managed; the `SKILL.md` stores the prompt body.
