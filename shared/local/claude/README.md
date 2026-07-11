# Shared Claude Routine Templates

These shared templates are sanitized from local Claude Desktop scheduled tasks and
normalized against the public Claude routine examples in `../../../claude/upstream/`.

Use them as copy-paste starting points for:

- Claude Desktop local scheduled tasks
- Claude `/loop` maintenance prompts

Claude code review, code-building, and validation templates that need Claude Opus 4.8-level effort carry a bare `ultracode` token as the first body line immediately after the YAML frontmatter's closing `---`. Keep template names focused on intent; do not encode execution effort in the name.

## Templates

| Template | Best surface | Use when | Suggested cadence |
| --- | --- | --- | --- |
| `scheduled-task-base.md` | Desktop scheduled task | You need a safe local task wrapper | n/a |
| `github-issue-implementation.md` | Desktop scheduled task | Ship one ready GitHub issue to PR | Every 4-6 business hours or nightly |
| `recent-commit-review.md` | Desktop scheduled task | Review recent trunk commits and PR high-confidence fixes | Daily after trunk is quiet |
| `github-backlog-pickup.md` | Desktop scheduled task | Fully autonomous issue pickup | Nightly |
| `board-hygiene.md` | Desktop scheduled task | Keep GitHub boards clean | Daily or twice daily |
| `sentry-hotfix.md` | Desktop scheduled task | Fix unresolved Sentry production errors safely | Every 6 business hours or event-triggered |
| `tool-fix-pass.md` | Desktop scheduled task | Run a configured scanner/tool and PR safe fixes | Nightly or weekly |
| `dry-repo.md` | Desktop scheduled task | Reduce duplication or complexity without behavior changes | Weekly at most |
| `local-validation.md` | Desktop scheduled task | Run periodic validation in the local checkout | Hourly to daily |
| `pr-review.md` | Desktop scheduled task | Review one open PR strictly | Hourly or PR-triggered |
| `worktree-prune.md` | Desktop scheduled task | Remove only merged clean worktrees | Daily or weekly |
| `docs-verification.md` | Desktop scheduled task | Verify docs against source | Weekly or after large API/schema changes |
| `bundle-size-watchdog.md` | Desktop scheduled task | Monitor dependency/build artifact size | Daily or weekly |
| `nightly-e2e-expansion.md` | Desktop scheduled task | Add exactly one nightly e2e spec | Nightly or weekly |
| `repo-hygiene-cleanup.md` | Desktop scheduled task | Safe multi-repo hygiene check with no code changes by default | Weekly |
| `memory-review.md` | Desktop scheduled task | Refresh repo memory against current source truth and PR corrections | Weekly |
| `agent-configuration-audit.md` | Desktop scheduled task | Audit effective global and per-repository agent configuration without writes | Monthly or after major agent-tool/routing changes |

## Common Claude Prompt Rules

- Define the surface: Desktop scheduled task or local `/loop`.
- Include setup, connectors/tools, prompt, hard rules, output, and failure modes.
- Run manually once before scheduling.
- For Desktop tasks, keep prompt in `~/.claude/scheduled-tasks/<task>/SKILL.md`.
- Use `../../remote/claude/` for Claude remote Routine source prompts.

## Placeholder Key

Universal:
- `[PROJECT]`, `[REPO_PATH]`, `[GITHUB_REPO]`, `[TRUNK]`, `[BRANCH_PREFIX]`, `[STATE_FILE]`, `[OUT_OF_SCOPE_PROJECTS]`.

Local validation:
- `[VALIDATION_COMMANDS]` - explicit local validation commands to run sequentially.

Remote worker:
- `[REMOTE_WORKER]` - optional remote worker for local Desktop tasks that explicitly support offloading heavy checks.

Routine-specific:
- `[PROJECT_BOARD]`, `[REVIEW_MARKER]`, `[TOOL_COMMAND]`, `[TOOL_BASELINE_COMMAND]`, `[TOOL_VERIFY_COMMAND]`, `[TOOL_FOCUS]`, `[AUTOMATION_ASSIGNEE]`, `[ALLOW_SAFE_DELETES]`.
- `[SENTRY_ORG]`, `[SENTRY_PROJECTS]` (Sentry hotfix scope).
- `[REPO_PATH_1]`/`[REPO_PATH_2]`, `[GITHUB_REPO_1]`/`[GITHUB_REPO_2]` (multi-repo).
- bundle-size-watchdog: `[DEPENDENCY_DIR]`, `[ARTIFACT_PATH_1]`, `[ARTIFACT_PATH_2]`, `[MAX_DEPENDENCY_SIZE]`, `[MAX_PACKAGE_COUNT]`, `[MAX_ARTIFACT_SIZE]`.
- docs-verification: `[DOC_SCOPE]`, `[DOC_FILE_1]`, `[DOC_FILE_2]`, `[DOC_FILE_3]`, `[SOURCE_PATH_1]`, `[SOURCE_PATH_2]`, `[SOURCE_PATH_3]`.
- memory-review: `[MEMORY_SCOPE]` - repo memory files or globs memory-review may edit, such as `AGENTS.md`, `CLAUDE.md`, or `.agents/memory/`.
- agent-configuration-audit: `[REPOSITORY_ROOT]`, `[PRIORITY_REPOSITORIES]`, `[PREVIOUS_AUDIT_PATH]`, `[GLOBAL_AGENTS_DIR]`, `[GLOBAL_CLAUDE_DIR]`, `[GLOBAL_CODEX_DIR]`, `[MODEL_ROUTING_POLICY]`, `[LOCAL_VERIFICATION_POLICY]`, `[EXCLUDED_PATH_PATTERNS]`.

The canonical local-repo-path token is `[REPO_PATH]` (not `[LOCAL_REPO_PATH]` or `[ABSOLUTE_REPO_PATH]`).
The canonical tool-invocation token is `[TOOL_COMMAND]` (not `[TOOL_NAME]`).

## Tool Fix Presets

React Doctor:

- `[TOOL_FOCUS]` = `React Doctor`
- `[TOOL_BASELINE_COMMAND]` = `pnpm exec react-doctor . --verbose --yes --offline --fail-on none`
- `[TOOL_COMMAND]` = `pnpm exec react-doctor . --verbose --yes --offline --fail-on error`
- `[TOOL_VERIFY_COMMAND]` = `pnpm exec react-doctor . --verbose --yes --offline --fail-on error`
