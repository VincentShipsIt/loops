---
name: agent-configuration-audit
description: Read-only audit of global and per-repository agent configuration
---

Audit agent configuration across active Git repositories under `[REPOSITORY_ROOT]` and the global configuration that affects them.

Execution profile:
- Model and effort are app-owned settings and are intentionally not pinned in this reusable prompt.
- Complete the audit in the current Claude session.
- This is a read-only audit. Do not modify repositories or global configuration.

Configured policy:
- Priority repositories: `[PRIORITY_REPOSITORIES]`.
- Previous audit: `[PREVIOUS_AUDIT_PATH]`.
- Global agent directory: `[GLOBAL_AGENTS_DIR]`.
- Global Claude directory: `[GLOBAL_CLAUDE_DIR]`.
- Global Codex directory: `[GLOBAL_CODEX_DIR]`.
- Model-routing policy: `[MODEL_ROUTING_POLICY]`.
- Local-verification policy: `[LOCAL_VERIFICATION_POLICY]`.
- Excluded path patterns: `[EXCLUDED_PATH_PATTERNS]`.

Repository discovery:
- Discover and deduplicate Git repository roots by canonical path.
- Do not traverse Git worktrees, `.git` internals, dependencies, generated output, `dist`, `build`, coverage, caches, temporary directories, archived directories, or deprecated/standby projects.
- Treat a repository as archived, deprecated, or standby only when its path, metadata, or documentation explicitly says so. Do not infer this solely from commit age.
- Do not follow directory symlinks during discovery.
- Report every excluded repository and the evidence-backed reason.
- Deep-review every repository listed in `[PRIORITY_REPOSITORIES]`.

Baseline and dedupe:
- Compare with `[PREVIOUS_AUDIT_PATH]` when it exists and is readable.
- Otherwise compare with prior scheduled-task memory when the platform supplies it.
- Store only non-sensitive counts, finding fingerprints, source versions, and the audit date in scheduled-task memory after a successful run.
- Do not create or update a filesystem state file.
- Never store file contents, environment values, credentials, private hostnames, or raw logs in task memory.
- If no baseline exists, label deltas and regression status as `baseline unknown`. Do not invent a baseline.

Configuration scope:
- Inspect effective global configuration under `[GLOBAL_AGENTS_DIR]`, `[GLOBAL_CLAUDE_DIR]`, and `[GLOBAL_CODEX_DIR]`, including intentional account-specific directories reached through documented symlinks or account switching.
- Exclude authentication stores, session histories, transcripts, logs, caches, telemetry, backups, temporary files, SQLite state, downloaded artifacts, and file-history stores unless a specific entry demonstrably changes effective configuration.
- In each repository inspect root and nested `AGENTS.md`, `AGENTS.override.md`, `CLAUDE.md`, `CLAUDE.local.md`, `.claude/CLAUDE.md`, and `CODEX.md` only when present or configured as a Codex fallback filename.
- Inspect relevant `.agents`, `.claude`, and `.codex` content: memory, rules, agents, skills, settings, hooks, plugins, MCP configuration, permission rules, profiles, imports, instruction overrides, fallback filenames, environment-variable names, symlinks, and source-of-truth synchronization scripts.

Instruction discovery and precedence:
- Reconstruct the effective instruction chain from representative launch directories, including nested monorepo packages where applicable.
- For Codex, verify `CODEX_HOME`, `AGENTS.override.md`, `AGENTS.md`, configured fallback filenames, `project_doc_max_bytes`, `model_instructions_file`, nested precedence, and truncation risk.
- Treat `AGENTS.md` as the normal canonical shared Codex instruction surface.
- Do not require `CODEX.md`. Flag it when it is inert, redundant, conflicting, drifting, or unnecessarily duplicates `AGENTS.md`.
- For Claude Code, verify global, root, `.claude/CLAUDE.md`, nested `CLAUDE.md`, `CLAUDE.local.md`, `@imports`, rules, `claudeMdExcludes`, managed settings, and local/shared/user precedence.
- Claude Code does not natively load `AGENTS.md`. Treat a `CLAUDE.md` import of `AGENTS.md` or an intentional valid symlink as a correct bridge when no separate Claude-specific instructions are required.
- Distinguish behavioral instructions from mechanically enforced settings, permission rules, and hooks.

Current behavior and routing:
- Verify changeable behavior using current official Anthropic and OpenAI documentation and record the audit date and exact source pages.
- Inspect installed CLI/app versions and locally available model catalogs when public documentation does not cover a product-specific label.
- Do not assume product labels map directly to public API model IDs or configuration values.
- Compare effective routing with `[MODEL_ROUTING_POLICY]`.
- Flag obsolete models, stale aliases, conflicting routing tables, deprecated environment variables, inaccurate subscription/API assumptions, and provider-specific guidance presented as universal.
- Distinguish subscriptions from API, Bedrock, Agent Platform, Foundry, gateway, and other configured providers.
- Treat `[MODEL_ROUTING_POLICY]` as an allowlist. Flag any model, effort, routing, or orchestration setting outside that policy.

Safety and correctness checks:
- Compare instructions that permit or require local tests, typechecks, lint gates, builds, or project hooks with `[LOCAL_VERIFICATION_POLICY]`. Flag conflicts with exact evidence.
- Validate relevant JSON and TOML with non-mutating parsers.
- Find broken symlinks. Treat external symlinks as findings only when the target is missing, unsafe, unintentionally account-specific, or causes cross-project leakage.
- Check hook references, existence, executability, matcher scope, ignore state, and permission boundaries without executing hooks.
- Find hardcoded checkout, username, home-directory, account, organization, repository, branch, and hostname assumptions.
- Find cross-project permissions, overly broad filesystem/network access, destructive commands, secret-bearing command arguments, bypass flags, duplicate or conflicting rules, and references to nonexistent `.agent` paths.
- Call memory stale only when contradicted by current repository evidence, official documentation, or a newer authoritative memory entry.
- Verify architecture counts against current filesystem evidence.
- Measure instruction size. Flag Claude instruction files above the current documented recommendation and Codex chains near or above the configured byte limit.
- Identify active repositories missing a useful root `AGENTS.md`.
- Identify missing Claude configuration only when no valid `CLAUDE.md`, `.claude/CLAUDE.md`, import, or symlink supplies it.

Secret handling:
- Never print tokens, cookies, private keys, authentication material, `.env` values, credential-helper output, or complete secret-bearing commands.
- Inspect sensitive files only as needed to verify structure, permissions, key names, references, and unsafe placement.
- Redact sensitive values as `<redacted>`. Report the path, safe line number, key name, and risk, never the value.

Forbidden actions:
- Do not modify, regenerate, format, stage, commit, push, open pull requests, create branches, install packages, update tools, authenticate accounts, or change repository state.
- Do not run tests, typechecks, linters, builds, package-manager lifecycle commands, project scripts, configuration generators, or hooks.
- Preserve every working-tree change.
- Use only read-only discovery, git inspection, file reading, official documentation lookup, and non-mutating syntax parsing.

Output:
1. Audit date, tool/CLI versions, baseline used, and limitations.
2. Repository inventory: discovered, included, excluded with reasons, and deep-reviewed.
3. Coverage counts by configuration surface and baseline deltas when available.
4. New regressions first, followed by existing findings, ranked critical, high, medium, and low.
5. Deep-review findings for `[PRIORITY_REPOSITORIES]`.
6. Active repositories missing useful configuration.
7. Effective precedence summary for each priority repository.
8. Prioritized remediation plan ordered by risk and dependency.
9. Official documentation sources used.
10. Explicit no-actionable-drift statements for clean repositories or surfaces.

For every actionable finding include severity, repository/scope, effective impact, evidence, exact absolute clickable file path and line number, interacting precedence source, concrete remediation, and whether it is new, existing, or baseline unknown. Do not report generic best practices without repository-specific evidence.

Manual test before enabling:
- Run once with scheduling disabled.
- Confirm no repository/global files or git state changed.
- Confirm sensitive values are redacted and every actionable finding has an absolute path and line number.
- Confirm a missing previous audit is reported as baseline unknown rather than treated as a regression-free baseline.
