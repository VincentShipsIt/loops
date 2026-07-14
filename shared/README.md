# Shared Loop Templates

Shared templates are sanitized source prompts for recurring app-level work. They are distilled from local Codex Automations, local Claude scheduled tasks, and public routine examples.

Use these files as the durable source of truth before pasting into Codex Automations, Claude Routines, Claude Desktop scheduled tasks, or `/loop` prompts.

## Layout

```text
shared/
  loop-intents.md
  forward-future-loop-library.md
  local/
    README.md
    codex/
      README.md
      *.md
    claude/
      README.md
      *.md
  remote/
    README.md
    codex/
      README.md
    claude/
      README.md
      board-hygiene.md
```

## Common Guardrails

- Scope each routine or automation to one repository, project, or workspace.
- Explicitly name out-of-scope projects when nearby repos share the same account.
- Search for duplicate issues, branches, worktrees, PRs, and existing automation output before creating anything.
- Use read-only mode for triage and board hygiene unless the prompt says otherwise.
- Use a dedicated worktree or isolated checkout for code-writing runs.
- Pick exactly one writable unit of work per run unless the task is purely read-only.
- Stop cleanly when no safe work exists.
- Report changes made, validation run, skipped work, and residual risk.

## Platform Split

- `loop-intents.md` defines the canonical intent, suggested cadence, and current Codex/Claude surfaces.
- `local/codex/` templates are shaped for Codex app Automations, including `automation.toml` plus optional `memory.md` live storage.
- `local/claude/` templates are shaped for Claude Desktop scheduled tasks and local `/loop` prompts.
- `remote/claude/` templates are shaped for Claude remote Routines and must stay connector/API scoped.
- `remote/codex/` is reserved until Codex has portable remote templates with explicit connector/write boundaries.

Keep implementation-specific setup in the platform folders. Keep reusable prompt bodies here.

Execution configuration belongs to the platform/app artifact: model, effort, schedule, enabled state, folder, execution mode, permissions, and connectors. Shared prompt bodies own outcome, scope, authority, base branch, state/dedupe, verification, stop/failure behavior, and output. Runtime safety assertions remain in the prompt even when the app duplicates the underlying protection.
