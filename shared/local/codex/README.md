# Shared Codex Automation Templates

These shared templates are sanitized from local Codex app automations and normalized
against the public examples in `../../../codex/upstream/`.

`github-issue-implementation.prompt.md` is the canonical authored prompt for the implementation loop. The app-ready TOML is generated from it with `python3 scripts/sync-codex-implementation-template.py`.

They are prompt templates, not live automation files. Create live automations
through the Codex app or Codex automation tools, then paste the relevant prompt.

Model and reasoning effort are set in the app UI when the automation is created;
templates carry `<app-owned>` placeholders and never name a model.

## Templates

| Template | Use when | Recommended environment |
| --- | --- | --- |
| `board-hygiene.md` | Audit weekly board readiness and repair metadata | `local` |
| `github-issue-implementation.md` | Ship exactly one ready GitHub issue | `worktree` |
| `recent-commit-review.md` | Review recent trunk commits and fix high-confidence issues | `worktree` |
| `sentry-hotfix.md` | Fix unresolved production errors safely | `worktree` |
| `pr-review.md` | Review one open PR with comments and markers only | `worktree` |
| `tool-fix-pass.md` | Run one configured scanner/tool and PR safe fixes | `worktree` |
| `dry-repo.md` | Make one behavior-preserving simplification | `worktree` |
| `local-validation.md` | Run read-only validation in the local checkout | `local` |
| `docs-verification.md` | Verify docs against source and PR corrections | `worktree` |
| `bundle-size-watchdog.md` | Report dependency and artifact size drift | `local` |
| `nightly-e2e-expansion.md` | Add exactly one focused nightly e2e spec | `worktree` |
| `worktree-prune.md` | Remove only clean, provably merged local worktrees when enabled | `local` |
| `content-factory-maintenance.md` | Improve a prompt, skill, template, docs, or evaluation pipeline | `worktree` |
| `memory-review.md` | Refresh repo memory against current source truth | `worktree` |
| `loop-discovery.md` | Find evidence-backed loop candidates in a target codebase | `local` |
| `agent-configuration-audit.md` | Audit effective global and per-repository agent configuration | `local` |
| `github-next-24h-planning.md` | Prepare an integration-aware Backlog queue for the next 24 hours | `local` |

## Support Files

| File | Use when |
| --- | --- |
| `memory.md` | Keep run state short and dedupe-aware between recurring automation runs. This is not a runnable automation. |

## Common Guardrails

- Scope each automation to exactly one repository or workspace.
- Name unrelated projects explicitly as out of scope.
- Use metadata-only mode for board hygiene; do not create branches or PRs.
- Use worktree mode for code changes.
- Choose exactly one unit of work per run unless the task is read-only.
- Search for duplicate issues, branches, worktrees, and PRs before creating anything.
- Stop cleanly when no safe work exists.
- Report what changed, what was skipped, validation run, and residual risk.

## Placeholder Key

- `[PROJECT]` - human-readable project name.
- `[REPO_PATH]` - absolute local path selected in the Codex automation.
- `[GITHUB_REPO]` - `owner/repo`.
- `[PROJECT_BOARD]` - GitHub project or board name/URL.
- `[TRUNK]` - `main` or `master`.
- `[BRANCH_PREFIX]` - short safe branch prefix, such as `codex/feature`.
- `[STATE_FILE]` - file or automation memory location for durable loop state.
- `[OUT_OF_SCOPE_PROJECTS]` - comma-separated project names the run must not inspect.
- `[SENTRY_ORG]` - Sentry organization slug used by sentry-hotfix and similar templates.
- `[SENTRY_PROJECTS]` - comma-separated Sentry project slugs to query for unresolved issues.
- `[SENTRY_OBSERVATION_RULE]` - post-deployment window or event-sample rule required before resolving a Sentry issue.
- `[AUTOMATION_ID]` - stable identifier for this automation (used in deduplication markers and state files).
- `[AUTOMATION_ASSIGNEE]` - issue assignee that marks an issue as owned by this automation.
- `[REVIEW_MARKER]` - stable marker label written inside a hidden comment with `[AUTOMATION_ID]` and the reviewed head SHA.
- `[TOOL_COMMAND]` - command this automation runs, such as `bun run lint`.
- `[TOOL_BASELINE_COMMAND]` - optional read-only baseline command for tools that compare before/after output.
- `[TOOL_VERIFY_COMMAND]` - optional final scan command that must pass or show verified improvement.
- `[TOOL_FOCUS]` - configured scanner/fix focus, such as security, React, lint, dead code, dependencies, or accessibility.
- `[VALIDATION_COMMANDS]` - explicit local validation commands to run sequentially.
- `[ALLOW_SAFE_DELETES]` - boolean gate for local worktree/branch deletion.
- `[DOC_SCOPE]`, `[DOC_FILE_1]`, `[DOC_FILE_2]`, `[DOC_FILE_3]` - documentation verification scope and files.
- `[SOURCE_PATH_1]`, `[SOURCE_PATH_2]`, `[SOURCE_PATH_3]` - source files checked by docs verification.
- `[DEPENDENCY_DIR]`, `[ARTIFACT_PATH_1]`, `[ARTIFACT_PATH_2]` - size watchdog targets.
- `[MAX_DEPENDENCY_SIZE]`, `[MAX_PACKAGE_COUNT]`, `[MAX_ARTIFACT_SIZE]` - size watchdog thresholds.
- `[ALLOW_LOCAL_E2E]` - boolean opt-in; unresolved or false keeps E2E execution in CI/nightly.
- `[LOCAL_E2E_RESOURCE_CONTRACT]` - project-defined local E2E command scope, services, resource/time limits, timeout, and cleanup.
- `[MEMORY_SCOPE]` - repo memory files or globs memory-review may edit, such as `AGENTS.md`, `CLAUDE.md`, or `.agents/memory/`.
- `[LOOP_LIBRARY_PATH]` - absolute path to the loops library used by loop-discovery for duplicate checks and candidate fit.
- `[LOOP_LIBRARY_REPO]` - `owner/repo` for the loops library used by loop-discovery.
- `[REPOSITORY_ROOT]`, `[PRIORITY_REPOSITORIES]`, `[PREVIOUS_AUDIT_PATH]` - multi-repo audit scope and baseline.
- `[GLOBAL_AGENTS_DIR]`, `[GLOBAL_CLAUDE_DIR]`, `[GLOBAL_CODEX_DIR]` - global configuration roots for agent-configuration-audit.
- `[MODEL_ROUTING_POLICY]` - explicit allowlisted model/effort/routing tuples, written positively rather than as a denylist.
- `[LOCAL_VERIFICATION_POLICY]`, `[EXCLUDED_PATH_PATTERNS]` - verification and discovery policy inputs for agent-configuration-audit.
- `[PLANNING_TARGETS]`, `[IMPLEMENTATION_SCHEDULES]` - exact fleet scope and per-repository next-24h implementation capacity.
- `[PLANNER_DRY_RUN]`, `[PER_REPO_CREATION_CAP]`, `[FLEET_CREATION_CAP]` - planner write and issue-creation gates.

## Tool Fix Presets

React Doctor:

- `[TOOL_FOCUS]` = `React Doctor`
- `[TOOL_BASELINE_COMMAND]` = `pnpm exec react-doctor . --verbose --yes --offline --fail-on none`
- `[TOOL_COMMAND]` = `pnpm exec react-doctor . --verbose --yes --offline --fail-on error`
- `[TOOL_VERIFY_COMMAND]` = `pnpm exec react-doctor . --verbose --yes --offline --fail-on error`
