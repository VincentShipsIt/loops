# Loops

Clean templates and prompts for Codex Automations, Claude Routines, and recurring AI-agent loops.

This repo is agent-friendly first. Give it to Codex, Claude, or another coding agent and have the agent install clean routine drafts into your project.

This repo is not an installed automation pack. Use it as a source of prompt bodies, schedules, guardrails, and setup patterns, then create the live loop inside Codex or Claude.

Codex templates target `gpt-5.6-sol`. Implementation, review, and validation automations use `high` reasoning effort. The GitHub issue implementation workflow is authored once in `shared/local/codex/github-issue-implementation.prompt.md` and generated into the app-ready TOML.

## Copy-Paste Install Prompt

Paste this into an agent with your target project open:

```text
Install the VincentShipsIt loops library into this project as agent-friendly docs and project-specific routine drafts.

Source library: https://github.com/VincentShipsIt/loops

Create clean drafts for Codex Automations, Claude local routines, and Claude remote Routines where useful. Do not create live schedules or app automations unless explicitly asked.

Use the same intent contract for Codex and Claude. The prompt intent, safety boundary, state/dedupe, cadence recommendation, and stopping conditions should match; only the final artifact format should differ.

Read this project's AGENTS.md, CLAUDE.md, README, package scripts, existing automation docs, and issue/PR conventions. Then create .agents/loops/ with:
- README.md
- shared/local/
- shared/remote/
- codex/automations/local/
- codex/automations/remote/
- claude/routines/local/
- claude/routines/remote/

Install a small useful starter set: GitHub issue implementation, board hygiene, validation, PR review, and worktree pruning.

Create matching Codex and Claude drafts when the intent has both surfaces. If an intent is only safe on one surface, document why instead of forcing symmetry.

For each draft include: surface, trigger, connectors/tools, state/dedupe, safe writes, forbidden actions, prompt, output, failure mode, and manual test before enabling.

Replace placeholders only with verified repo facts. Keep unknowns as [PLACEHOLDER]. Do not include secrets, .env contents, private host details, local usernames, raw run logs, or unrelated project details.
```

More copy-paste prompts live in `prompts/`.

## Shared Intent Catalog

Use `shared/loop-intents.md` to compare Codex and Claude loops by intent.
The platform-specific files may differ in format and app settings, but matching
intents should select the same kind of work, enforce the same safety boundary,
and stop for the same reasons.

For install/adapt/audit work, use one shared agent prompt across Codex and
Claude: `prompts/install-in-agent.md`. Keep separate one-off creation prompts
only because the final artifact shape differs.

## Pick The Right Surface

Use Codex Automations when the task should run against a repo in the Codex app, especially worktree-based implementation, issue hygiene, Sentry fixes, local validation, and recurring codebase maintenance.

Use Claude Desktop scheduled tasks when the task needs local files, local tools, private repos, or Claude Code style `SKILL.md` prompts.

Use Claude remote Routines when the task is mostly connector/API driven: GitHub triage, board updates, meeting briefs, reading digests, sentiment summaries, or webhook/API-triggered workflows. Keep remote routines read-only or metadata-only by default.

This repo is organized by platform and execution surface:

- `codex/automations/local/` - Codex app automations that run against local/worktree repo state.
- `codex/automations/remote/` - reserved for future Codex remote/connector-safe templates.
- `claude/routines/local/` - Claude Desktop scheduled tasks and local `/loop` prompts.
- `claude/routines/remote/` - Claude remote Routine prompts for connector/API workflows.
- `shared/local/` and `shared/remote/` - source prompt bodies split by execution surface.

## Fast Start

1. If an agent is doing the work, start with `prompts/install-in-agent.md`.

2. Choose one template:
   - Codex GitHub issue work: `codex/automations/local/github-issue-implementation/automation.toml`
   - Codex recent commit review/fix: `codex/automations/local/recent-commit-review/automation.toml`
   - Codex board cleanup: `codex/automations/local/board-hygiene/automation.toml`
   - Codex Sentry fix loop: `codex/automations/local/sentry-hotfix/automation.toml`
   - Codex PR review: `codex/automations/local/pr-review/automation.toml`
   - Codex tool fix pass: `codex/automations/local/tool-fix-pass/automation.toml`
   - Codex local validation: `codex/automations/local/local-validation/automation.toml`
   - Codex weekly memory review: `codex/automations/local/memory-review/automation.toml`
   - Codex loop discovery: `codex/automations/local/loop-discovery/automation.toml`
   - Claude local GitHub issue work: `claude/routines/local/github-issue-implementation/SKILL.md`
   - Claude recent commit review/fix: `claude/routines/local/recent-commit-review/SKILL.md`
   - Claude Sentry fix loop: `claude/routines/local/sentry-hotfix/SKILL.md`
   - Claude local validation: `claude/routines/local/local-validation/SKILL.md`
   - Claude PR review: `claude/routines/local/pr-review/SKILL.md`
   - Claude weekly memory review: `claude/routines/local/memory-review/SKILL.md`
   - Claude remote board hygiene: `claude/routines/remote/board-hygiene.md`

3. Replace every placeholder:
   - `[PROJECT]`
   - `[REPO_PATH]`
   - `[GITHUB_REPO]`
   - `[PROJECT_BOARD]`
   - `[TRUNK]`
   - `[BRANCH_PREFIX]`
   - `[STATE_FILE]`
   - `[VALIDATION_COMMANDS]` if used
   - `[WEEKLY_MILESTONE_PATTERN]` if used
   - `[OUT_OF_SCOPE_PROJECTS]`
   - `[REMOTE_WORKER]` if used

   Full placeholder reference: `claude/routines/local/README.md` and `shared/local/claude/README.md` Placeholder Keys.

4. Decide the trigger:
   - Schedule for hygiene, validation, summaries, cleanup, and drift detection.
   - Webhook/API trigger for CI failures, new Sentry issues, PR opened, issue labeled ready, or release events.
   - Manual run first for every new routine.

5. Create the live loop:
   - Codex: create a new Automation in the Codex app, copy the prompt/settings from the `automation.toml`, start paused, run once, then enable.
   - Claude Desktop: create a scheduled task and use the matching `SKILL.md` as the prompt body. Configure schedule, model, folder, and permissions in the app.
   - Claude remote Routine: use `claude/routines/remote/` or `shared/remote/claude/`, configure only the connectors the routine actually needs, and paste the prompt into the Routine UI.

6. Run it once manually and inspect the output before enabling the schedule.

## Agent Prompts

- `prompts/install-in-agent.md` - canonical shared install prompt for Codex, Claude, or another coding agent.
- `prompts/create-codex-automation.md` - create one Codex automation draft.
- `prompts/create-claude-routine.md` - create one Claude routine or scheduled task draft.
- `prompts/audit-existing-routines.md` - clean up existing routines and extract reusable patterns.
- `prompts/agent-memory-snippet.md` - paste into `AGENTS.md` or `CLAUDE.md` so future agents use this library.
- `skills/loop-writer/` - repo-local skill for drafting or auditing loop templates.

## Safety Checklist

Before enabling any recurring routine:

- Scope it to one repo, board, project, or connector set.
- Name out-of-scope projects explicitly.
- Add duplicate checks for issues, branches, worktrees, PRs, and prior run state.
- Define the write surface: read-only, issue metadata, branch + PR, or external API writes.
- Put destructive actions behind explicit approval.
- Keep secrets, tokens, `.env` files, request bodies, and private host details out of output.
- Define the final report format.
- Define what "no safe work" means, and make the routine stop cleanly.

## Recommended Stack

For autonomous engineering work, start with these:

- `codex/automations/local/github-issue-implementation/automation.toml`
- `codex/automations/local/recent-commit-review/automation.toml`
- `codex/automations/local/board-hygiene/automation.toml`
- `codex/automations/local/sentry-hotfix/automation.toml`
- `codex/automations/local/pr-review/automation.toml`
- `codex/automations/local/tool-fix-pass/automation.toml`
- `codex/automations/local/dry-repo/automation.toml`
- `codex/automations/local/local-validation/automation.toml`
- `codex/automations/local/worktree-prune/automation.toml`
- `claude/routines/local/github-issue-implementation/SKILL.md`
- `claude/routines/local/recent-commit-review/SKILL.md`
- `claude/routines/local/sentry-hotfix/SKILL.md`
- `claude/routines/local/local-validation/SKILL.md`
- `claude/routines/local/pr-review/SKILL.md`
- `claude/routines/local/worktree-prune/SKILL.md`

For product and operations routines, borrow the structure from:

- `claude/upstream/routine-templates/templates/04-github-pr-triage.md`
- `claude/upstream/routine-templates/templates/05-focus-block-handoff.md`
- `claude/linked-examples/aakashg-claude-routines-pm-pack.md`

Forward Future's Loop Library is useful for loop design patterns, especially explicit verification, authority limits, stopping conditions, and evidence-backed output:

- https://signals.forwardfuture.ai/loop-library/
- `shared/forward-future-loop-library.md`

## Template Rule

Every strong routine should answer these questions:

```text
Surface:
Trigger:
Connectors/tools:
State/dedupe:
Safe writes:
Forbidden actions:
Prompt:
Output:
Failure mode:
Manual test before enabling:
```

## References And Licensing

Copied upstream repositories with explicit MIT licenses keep their license files under `upstream/`.

Repositories without an explicit license are summarized and linked instead of republished under `linked-examples/`.

Forward Future's Loop Library is MIT-licensed and referenced as design input in `shared/forward-future-loop-library.md`.
