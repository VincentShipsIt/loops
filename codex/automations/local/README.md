# Clean Codex Automation Templates

Project-agnostic Codex app automation templates derived from working automation patterns.

These are clean templates, not raw exports. They intentionally do not include project names, organization names, issue numbers, pull request URLs, local usernames, machine paths, hostnames, tokens, run history, or repository-specific labels.

## Templates

- `github-issue-implementation/automation.toml` - implement exactly one ready GitHub issue in a worktree.
- `recent-commit-review/automation.toml` - review recent trunk commits and open safe fix PRs.
- `board-hygiene/automation.toml` - audit weekly board readiness and repair evidence-backed metadata.
- `sentry-hotfix/automation.toml` - inspect unresolved Sentry errors and open safe fix PRs.
- `pr-review/automation.toml` - review one open PR and improve only automation-owned branches.
- `tool-fix-pass/automation.toml` - run one configured scanner/tool and open safe fix PRs.
- `dry-repo/automation.toml` - make one behavior-preserving simplification.
- `local-validation/automation.toml` - run read-only validation in the local checkout.
- `docs-verification/automation.toml` - verify docs against source and open correction PRs.
- `bundle-size-watchdog/automation.toml` - report dependency and artifact size drift without writes.
- `nightly-e2e-expansion/automation.toml` - add exactly one focused nightly e2e spec.
- `worktree-prune/automation.toml` - remove only clean, provably merged local worktrees when enabled.
- `content-factory-maintenance/automation.toml` - improve a prompt, skill, template, docs, or evaluation pipeline.
- `memory-review/automation.toml` - review repo memory against current source truth and open safe correction PRs.
- `loop-discovery/automation.toml` - inspect a codebase for evidence-backed loop candidates without writing files.
- `agent-configuration-audit/automation.toml` - audit global and per-repository agent configuration without modifying files.
- `memory-template/memory.md` - support file for Codex automation state, not a runnable automation.

## Placeholder Key

The issue-implementation prompt is authored once in `../../../shared/local/codex/github-issue-implementation.prompt.md`; run `python3 scripts/sync-codex-implementation-template.py` from the repository root after editing it. Model and reasoning effort are set in the app UI when the automation is created; templates carry `<app-owned>` placeholders and never name a model.

- `[AUTOMATION_ID]` - stable slug for the automation.
- `[PROJECT]` - human-readable project name.
- `[REPO_PATH]` - absolute repo path on the machine where the automation runs.
- `[GITHUB_REPO]` - `owner/repo`.
- `[PROJECT_BOARD]` - board name, URL, or project identifier.
- `[TRUNK]` - trunk branch, usually `main` or `master`.
- `[BRANCH_PREFIX]` - safe branch prefix, such as `codex/feature`.
- `[STATE_FILE]` - file or automation memory location for durable loop state.
- `[OUT_OF_SCOPE_PROJECTS]` - projects this automation must not inspect.
- `[VALIDATION_COMMANDS]` - explicit local validation commands to run sequentially.
- `[REVIEW_MARKER]` - stable marker label written inside a hidden comment with `[AUTOMATION_ID]` and the reviewed head SHA.
- `[TOOL_COMMAND]` - command this automation runs, such as `bun run lint`.
- `[TOOL_BASELINE_COMMAND]` - optional read-only baseline command for tools that compare before/after output.
- `[TOOL_VERIFY_COMMAND]` - optional final scan command that must pass or show verified improvement.
- `[TOOL_FOCUS]` - configured scanner/fix focus, such as security, React, lint, dead code, dependencies, or accessibility.
- `[ALLOW_SAFE_DELETES]` - boolean gate; when true the automation may delete provably merged, clean local worktrees/branches.
- `[DOC_SCOPE]`, `[DOC_FILE_1]`, `[DOC_FILE_2]`, `[DOC_FILE_3]` - documentation verification scope and files.
- `[SOURCE_PATH_1]`, `[SOURCE_PATH_2]`, `[SOURCE_PATH_3]` - source files checked by docs verification.
- `[DEPENDENCY_DIR]` - dependency directory checked by bundle-size-watchdog.
- `[ARTIFACT_PATH_1]`, `[ARTIFACT_PATH_2]` - build artifacts checked by bundle-size-watchdog.
- `[MAX_DEPENDENCY_SIZE]`, `[MAX_PACKAGE_COUNT]`, `[MAX_ARTIFACT_SIZE]` - watchdog thresholds.
- `[REPOSITORY_ROOT]` - parent directory containing repositories for a multi-repo audit.
- `[PRIORITY_REPOSITORIES]` - repositories that receive a deep configuration review.
- `[PREVIOUS_AUDIT_PATH]` - prior audit report used for coverage deltas and regression classification.
- `[GLOBAL_AGENTS_DIR]`, `[GLOBAL_CLAUDE_DIR]`, `[GLOBAL_CODEX_DIR]` - effective global agent configuration roots.
- `[MODEL_ROUTING_POLICY]` - explicit allowlisted model/effort/routing tuples, written positively rather than as a denylist.
- `[LOCAL_VERIFICATION_POLICY]` - configured policy for local tests, typechecks, lint, builds, and hooks.
- `[EXCLUDED_PATH_PATTERNS]` - explicit discovery exclusions for the multi-repo audit.
- `[SENTRY_OBSERVATION_RULE]` - post-deployment window or event-sample rule required before resolving a Sentry issue.
- `[ALLOW_LOCAL_E2E]` - boolean opt-in; unresolved or false keeps E2E execution in CI/nightly.
- `[LOCAL_E2E_RESOURCE_CONTRACT]` - project-defined local E2E command scope, services, resource/time limits, timeout, and cleanup.

## Tool Fix Presets

React Doctor:

- `[TOOL_FOCUS]` = `React Doctor`
- `[TOOL_BASELINE_COMMAND]` = `pnpm exec react-doctor . --verbose --yes --offline --fail-on none`
- `[TOOL_COMMAND]` = `pnpm exec react-doctor . --verbose --yes --offline --fail-on error`
- `[TOOL_VERIFY_COMMAND]` = `pnpm exec react-doctor . --verbose --yes --offline --fail-on error`

## Safety Rules

- Scope each automation to one repository.
- Use worktree execution for code-writing automations.
- Use local execution for metadata-only hygiene.
- Search for duplicate issues, branches, worktrees, and PRs before creating anything.
- Stop cleanly when no safe work exists.
- Report changed work, skipped work, validation, and residual risk.
