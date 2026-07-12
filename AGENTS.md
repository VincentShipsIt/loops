# AGENTS.md

This repository is an agent-facing library of clean templates for Codex Automations, Claude Routines, and recurring AI-agent loops.

## Primary Goal

Help an agent install or adapt recurring loop prompts into a user's project without copying project-specific details from this repo.

## How To Use This Repo

- Start with `README.md`.
- Use `prompts/install-in-agent.md` when the user wants the library installed into another project.
- Use `prompts/create-codex-automation.md` when creating a Codex app Automation.
- Use `prompts/create-claude-routine.md` when creating a Claude Routine or Claude Desktop scheduled task.
- Use `prompts/audit-existing-routines.md` when the user already has routines and wants them cleaned up.
- Use `prompts/agent-memory-snippet.md` when the user wants to add a durable instruction to `AGENTS.md`, `CLAUDE.md`, or another agent memory file.
- Use `skills/loop-writer/` when drafting, auditing, or adapting loop templates in this repo.

## Template Rules

- Keep templates project-agnostic.
- Use placeholders such as `[PROJECT]`, `[REPO_PATH]`, `[GITHUB_REPO]`, `[TRUNK]`, and `[OUT_OF_SCOPE_PROJECTS]`.
- Keep execution configuration out of prompt bodies. Codex templates use `gpt-5.6-sol`; code-writing, review, and validation templates use `high` reasoning effort.
- Treat `shared/local/codex/github-issue-implementation.prompt.md` as the canonical implementation prompt and regenerate its app-ready TOML instead of maintaining a second authored copy.
- Do not add real organization names, private repo names, local paths, tokens, hostnames, issue numbers, PR URLs, run logs, or personal details.
- Keep every routine explicit about surface, trigger, connectors/tools, state/dedupe, safe writes, forbidden actions, prompt, output, failure mode, and manual test.
- Prefer a small set of installable routines over a broad pile of vague ideas.

## Install Behavior

When adapting this repo for a user's project:

- Read the target repo's `AGENTS.md`, `CLAUDE.md`, README, package scripts, and existing automation docs first.
- Pick the correct surface before writing prompts: Codex Automation, Claude Desktop scheduled task, Claude remote Routine, or shared prompt only.
- Fill placeholders from verified repo facts. If a fact is unknown, keep a placeholder and mark it as required setup.
- Do not create live schedules, webhooks, or recurring jobs unless the user explicitly asks.
- Prefer starting disabled or paused.
- Include a manual test step before enabling any recurring run.
- Never request or expose secrets. Refer to environment variables by name only when the target repo already documents them.

## Review Checklist

Before finishing:

- No project-specific data leaked from another user's repo.
- No secrets, tokens, `.env` contents, private hostnames, or local usernames.
- Every routine has duplicate-work checks.
- Every routine has safe stop behavior when no work is available.
- Destructive actions require approval.
- Output format is explicit.
