# Codex Automation: Agent Configuration Audit

Recommended settings:

- Kind: cron or manual
- Execution environment: local
- Model: GPT-5.6 Sol
- Reasoning effort: high
- Write surface: read-only filesystem/repository inspection plus non-sensitive automation memory
- Explicitly disabled: Max, Ultra, workflows, and subagents
- Suggested schedule: monthly, and manually after major agent-tool or model-routing changes

## Loop Contract

Surface: Codex app Automation with read access to `[REPOSITORY_ROOT]` and the configured global agent directories.

Trigger: Monthly cron plus a manual run before enabling. It can also be run after a material Claude Code or Codex release.

Connectors/tools: Read-only local filesystem and git inspection, non-mutating JSON/TOML parsing, installed CLI version lookup, official Anthropic/OpenAI documentation lookup, and automation memory.

State/dedupe: Compare `[PREVIOUS_AUDIT_PATH]` or prior automation-memory fingerprints. Store only counts, finding fingerprints, source versions, and audit date after a successful run. If no baseline exists, report `baseline unknown`.

Safe writes: Non-sensitive Codex automation memory only. Do not write a report or state file into any repository or global configuration directory.

Forbidden actions: Do not modify files or git state; run hooks, tests, typechecks, linters, builds, project scripts, lifecycle commands, or generators; install/update tools; authenticate accounts; create branches; commit; push; open PRs; deploy; or disclose secrets.

Output: Repository inventory and coverage counts, baseline deltas, severity-ranked findings with absolute clickable paths and line numbers, priority-repository deep reviews, missing configuration, effective precedence, remediation plan, official sources, and explicit clean results.

Failure mode: Stop with a bounded partial report when repository discovery, a priority repository, official documentation, or syntax parsing is unavailable. Do not infer a clean result from missing access and do not update state after a failed run.

Manual test before enabling: Run once while paused and confirm no files/git state changed, secrets stayed redacted, missing baseline was explicit, and findings include exact evidence.

## Prompt

Use the prompt from `../../../codex/automations/local/agent-configuration-audit/automation.toml`. Replace every placeholder from the key below before creating the live Automation.

## Placeholder Key

- `[AUTOMATION_ID]` - stable slug for the live automation.
- `[REPOSITORY_ROOT]` - parent directory containing repositories to discover.
- `[PRIORITY_REPOSITORIES]` - comma-separated repository roots or names for deep review.
- `[PREVIOUS_AUDIT_PATH]` - readable prior report, or a documented missing path when no baseline exists.
- `[GLOBAL_AGENTS_DIR]`, `[GLOBAL_CLAUDE_DIR]`, `[GLOBAL_CODEX_DIR]` - effective global configuration roots.
- `[MODEL_ROUTING_POLICY]` - durable routing policy to compare with current configuration and official behavior.
- `[LOCAL_VERIFICATION_POLICY]` - policy governing local tests, typechecks, lint, builds, and hooks.
- `[EXCLUDED_PATH_PATTERNS]` - explicit archive, dependency, generated, cache, build, and worktree exclusions.
