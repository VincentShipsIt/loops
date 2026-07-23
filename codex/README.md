# Codex Automations

Examples and tooling for OpenAI Codex app Automations.

## Shared Templates

Use `../shared/local/codex/` for clean shared templates derived from working Codex automation patterns:

- `../shared/local/codex/board-hygiene.md`
- `../shared/local/codex/github-issue-implementation.md`
- `../shared/local/codex/recent-commit-review.md`
- `../shared/local/codex/sentry-hotfix.md`
- `../shared/local/codex/pr-review.md`
- `../shared/local/codex/tool-fix-pass.md`
- `../shared/local/codex/dry-repo.md`
- `../shared/local/codex/local-validation.md`
- `../shared/local/codex/docs-verification.md`
- `../shared/local/codex/bundle-size-watchdog.md`
- `../shared/local/codex/nightly-e2e-expansion.md`
- `../shared/local/codex/worktree-prune.md`
- `../shared/local/codex/content-factory-maintenance.md`
- `../shared/local/codex/memory-review.md`
- `../shared/local/codex/loop-discovery.md`
- `../shared/local/codex/figma-surface-orchestrator.md`
- `../shared/local/codex/memory.md`
- `../shared/local/codex/agent-configuration-audit.md`
- `../shared/local/codex/github-next-24h-planning.md`

## Surface Folders

- `automations/local/` - app-ready Codex automation templates for local/worktree execution.
- `automations/remote/` - reserved for future connector-safe Codex remote templates.

## Clean App Automation Templates

Use `automations/local/` for app-ready templates derived from local Codex automation patterns:

```text
~/.codex/automations/
```

The template set includes:

- GitHub issue implementation
- Recent commit review
- Board hygiene
- Sentry hotfix
- PR review
- Tool fix pass
- Dry repo
- Local validation
- Docs verification
- Bundle size watchdog
- Nightly e2e expansion
- Worktree pruning
- Content factory maintenance for prompt, skill, template, docs, or evaluation repos
- Memory template
- Read-only global and per-repository agent configuration audit
- Registry-driven Figma surface and flow orchestration with quota-aware probes
- Integration-aware GitHub next-24h queue planning

## Included Upstreams

### `upstream/awesome-codex-automations/`

Source: https://github.com/onurkanbakirci/awesome-codex-automations

MIT-licensed catalog of Codex automation ideas. The useful examples live under:

```text
upstream/awesome-codex-automations/automations/
```

Notable examples:

- `daily-bug-scan`
- `issue-triage`
- `ci-monitor`
- `test-gap-detection`
- `dependency-sweep`
- `release-notes-drafter`
- `secret-scanner`
- `performance-regression-watch`
- `weekly-engineering-summary`

Most examples are seed prompts, not full production automation configs.

### `upstream/codex-automations-cli/`

Source: https://github.com/vltansky/codex-automations

MIT-licensed CLI for sharing and installing Codex app automations:

```bash
npx -y codex-automations add <source>
npx -y codex-automations share
npx -y codex-automations list
npx -y codex-automations remove
```

Use this if we want to publish a reusable Codex automation pack.

## Codex Automation Shape

Local Codex app automations live under:

```text
~/.codex/automations/<automation-id>/
  automation.toml
  memory.md
```

Create and update live automations through the Codex app or Codex automation tools. Treat this folder as examples and source material, not as the live automation registry.
