# Create One Codex Automation

Use this prompt in Codex when you want one concrete Codex app Automation draft.

```text
Create one Codex app Automation draft for this repository using the VincentShipsIt loops library.

Source library:
- https://github.com/VincentShipsIt/loops
- Prefer local copy if available.

Automation requested:
- Purpose: [GITHUB_ISSUE_IMPLEMENTATION | RECENT_COMMIT_REVIEW | BOARD_HYGIENE | SENTRY_HOTFIX | PR_REVIEW | TOOL_FIX_PASS | DRY_REPO | LOCAL_VALIDATION | WORKTREE_PRUNE | DOCS_VERIFICATION | BUNDLE_SIZE_WATCHDOG | NIGHTLY_E2E_EXPANSION | CONTENT_FACTORY_MAINTENANCE | OTHER]
- Project: [PROJECT]
- Repository: [GITHUB_REPO]
- Local path: [REPO_PATH]
- Trunk branch: [TRUNK]
- Project board: [PROJECT_BOARD]
- State file or memory location: [STATE_FILE]
- Validation commands, if any: [VALIDATION_COMMANDS]
- Out of scope: [OUT_OF_SCOPE_PROJECTS]

Steps:
1. Read this repo's AGENTS.md, CLAUDE.md, README, package scripts, and existing automation docs.
2. Choose the closest template from `codex/automations/local/`.
   For GitHub issue implementation, render from `shared/local/codex/github-issue-implementation.prompt.md`; do not maintain a separate prompt variant.
3. Fill every placeholder from verified repo facts.
4. Keep the same intent contract as the matching Claude routine when one exists; only the Codex artifact shape should differ.
5. Keep unknowns as [PLACEHOLDER] and list them under Required Setup.
6. Preserve safety rules: one repo scope, duplicate checks, worktree gate for code-writing, no destructive actions, no secrets in output.
7. Use `gpt-5.6-sol`. Use `high` reasoning effort for implementation, review, and validation; keep lower effort only for bounded metadata or reporting routines.
8. Produce a complete automation.toml draft.

Do not create or enable the live Codex automation unless explicitly asked. If Codex automation tools are available and the user asks to create it, start it PAUSED.

Output:
- The automation.toml draft.
- Required setup values still missing.
- Manual test instructions.
- Recommended schedule and reasoning effort.
```
