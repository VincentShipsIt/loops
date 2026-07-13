# Create One Claude Routine Or Scheduled Task

Use this prompt in Claude when you want one concrete Claude Routine or Claude Desktop scheduled task draft.

```text
Create one Claude Routine or Claude Desktop scheduled task draft for this project using the VincentShipsIt loops library.

Source library:
- https://github.com/VincentShipsIt/loops
- Prefer local copy if available.

Routine requested:
- Purpose: [GITHUB_ISSUE_IMPLEMENTATION | RECENT_COMMIT_REVIEW | GITHUB_BACKLOG_PICKUP | BOARD_HYGIENE | SENTRY_HOTFIX | TOOL_FIX_PASS | DRY_REPO | LOCAL_VALIDATION | PR_REVIEW | WORKTREE_PRUNE | DOCS_VERIFICATION | BUNDLE_SIZE_WATCHDOG | NIGHTLY_E2E_EXPANSION | OTHER]
- Surface preference: [CLAUDE_DESKTOP_SCHEDULED_TASK | CLAUDE_REMOTE_ROUTINE | UNSURE]
- Project: [PROJECT]
- Repository: [GITHUB_REPO]
- Local path: [REPO_PATH]
- Trunk branch: [TRUNK]
- State file or memory location: [STATE_FILE]
- Out of scope: [OUT_OF_SCOPE_PROJECTS]
- Validation commands, if any: [VALIDATION_COMMANDS]

Steps:
1. Read this repo's AGENTS.md, CLAUDE.md, README, package scripts, and existing routine docs.
2. Decide the correct surface before writing the prompt. Prefer Desktop scheduled tasks for code/test execution and remote Routines for read-only or GitHub metadata/API workflows.
3. Choose the closest template from `claude/routines/local/`, `claude/routines/remote/`, `shared/local/claude/`, or `shared/remote/claude/`.
4. Keep the same intent contract as the matching Codex automation when one exists; only the Claude artifact shape should differ.
5. Fill placeholders from verified repo facts.
6. Keep unknowns as [PLACEHOLDER] and list them under Required Setup.
7. Include setup, connectors/tools, trigger, state/dedupe, safe writes, forbidden actions, prompt, output, failure mode, and manual test.
8. Keep destructive actions behind explicit approval.
9. Put model, effort, schedule/enabled state, selected folder, execution mode, permissions, and connector grants in app setup only. Keep outcome, semantic scope, authority, base branch, state/dedupe, verification, stop/failure behavior, and output in the prompt body.
10. Preserve prompt-level safety assertions even when the app also configures the folder, isolation, permissions, or connectors.
11. Add remote validation only if the target repo already documents its transport/tool, worker repo path, revision/bootstrap, dependency state, required services, environment-variable names, secret policy, concurrency lock, timeout, cleanup, and result return. Otherwise report heavy/prohibited validation as blocked or skipped.

Do not create or enable the live schedule unless explicitly asked. If live scheduled-task tools are available and the user asks to create it, start disabled or paused when possible.

Output:
- App settings, followed by the complete Routine or SKILL.md prompt body.
- Required setup values still missing.
- Manual test instructions.
- Recommended schedule and model.
```
