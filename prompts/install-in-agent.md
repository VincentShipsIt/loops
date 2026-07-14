# Install Loops Into This Project

Use this prompt in a coding agent while the target project is open.

```text
Install the VincentShipsIt loops library into this project as agent-friendly docs and project-specific routine drafts.

Source library:
- GitHub: https://github.com/VincentShipsIt/loops
- If the library already exists locally, read the local copy instead of fetching.

Goal:
- Create clean, project-specific loop drafts that can later be pasted into Codex Automations, Claude local routines, or Claude remote Routines.
- Use the same intent contract for Codex and Claude. The prompt intent, safety boundary, state/dedupe, cadence recommendation, and stopping conditions should match; only the final artifact format should differ.
- Do not create live schedules, webhooks, recurring jobs, or app automations unless explicitly asked after the drafts are reviewed.
- Separate app settings from prompt semantics. App settings own model, reasoning effort, schedule/enabled state, folder/cwds, local versus worktree execution, permissions, and connector grants. Prompt bodies own outcome, semantic scope, authority, base branch, state/dedupe, verification, stop/failure behavior, and output.
- Keep safety assertions in the prompt even when the app also configures the workspace, worktree, permissions, or connectors.

First inspect this project:
- Read AGENTS.md, CLAUDE.md, README, package scripts, existing docs, and existing automation/routine files if present.
- Identify the repo path, GitHub repo, trunk branch, package manager, test commands, CI system, issue tracker, project board, and out-of-scope sibling projects.
- Find any existing branch/worktree/PR conventions.

Choose surfaces:
- Use `codex/automations/local/` for repo work that should run in the Codex app, especially GitHub issue implementation, issue hygiene, Sentry fixes, local validation, and codebase maintenance.
- Use `codex/automations/remote/` only for future connector-safe Codex remote templates.
- Use `claude/routines/local/` for local files, private repos, local tools, and Claude Code `SKILL.md` prompts.
- Use `claude/routines/remote/` for read-only or metadata/API workflows such as GitHub board updates, triage, meeting briefs, reading digests, and webhook/API-triggered workflows.
- Use `shared/local/` and `shared/remote/` as source prompt bodies before creating platform-specific artifacts.

Create or update:
- .agents/loops/README.md
- .agents/loops/shared/local/
- .agents/loops/shared/remote/
- .agents/loops/codex/automations/local/
- .agents/loops/codex/automations/remote/
- .agents/loops/claude/routines/local/
- .agents/loops/claude/routines/remote/

Install a small useful starter set:
- GitHub issue implementation
- Recent commit review
- Board hygiene
- Local validation
- PR review
- Worktree prune

Create matching Codex and Claude drafts when the intent has both surfaces. If an
intent is only safe on one surface, document why instead of forcing symmetry.

For each installed draft, include:
- Surface
- Trigger
- Connectors/tools
- State/dedupe strategy
- Safe writes
- Forbidden actions
- Prompt body
- Output format
- Failure mode
- Manual test before enabling

Rules:
- Replace placeholders only with facts verified from this repo.
- Keep unknowns as [PLACEHOLDER] and list them under Required Setup.
- Do not include secrets, .env contents, private host details, local usernames, or unrelated project names.
- Do not copy raw run history from existing routines.
- Add duplicate checks for issues, branches, worktrees, PRs, and previous run state.
- Put destructive actions behind explicit approval.
- Make every routine stop cleanly when no safe work exists.
- Do not put model names, effort directives, cadence prose, enabled state, hardcoded `cd` commands, or app-selected folder/execution settings in reusable prompt bodies.
- Add remote validation only when the repo documents transport/tool, worker repo path, revision/bootstrap, dependency state, services, environment-variable names, secret policy, concurrency lock, timeout, cleanup, and result return. Otherwise report heavy/prohibited validation as blocked or skipped.

Finish with:
- Files created or changed.
- Which drafts are ready to paste into Codex or Claude.
- Any intentional Codex/Claude gaps and why.
- Required setup values still missing.
- Separate App settings and Prompt body sections for each draft.
- Recommended first manual test.
```
