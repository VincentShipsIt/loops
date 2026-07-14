# Codex Automation: Local Validation

Recommended settings:

- Kind: cron
- Execution environment: local
- Write surface: read-only validation report

## Prompt

Run local validation for `[PROJECT]`.

Scope:

- Local workspace: `[REPO_PATH]`.
- Validation commands: `[VALIDATION_COMMANDS]`.
- Do not inspect, validate, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.
- Read-only by default: do not create branches, commits, PRs, issue comments, source edits, env files, dependency installs, production writes, deploys, live migrations, or destructive cleanup.
- Never print tokens, secrets, request bodies with sensitive data, or `.env` file contents.

Workflow:

- Verify `[REPO_PATH]` exists and is a git worktree.
- Stop if it has staged, unstaged, or untracked local changes.
- Use a per-repo non-overlap lock under `/tmp`; if another validation run is active, exit cleanly. If the lock is older than 30 minutes or its owning process is no longer present, treat it as stale, clear it, and proceed.
- Do not fetch, switch branches, pull, or mutate git state. Validate the current checkout only.
- Record the current branch and commit before running commands.
- Inspect package scripts and project docs to understand the configured validation surface.
- If `[VALIDATION_COMMANDS]` is configured, run only those commands.
- If `[VALIDATION_COMMANDS]` is empty or still a placeholder, infer safe read-only commands only when package scripts or docs make them obvious: lint/check, type-check, and focused tests.
- If validation commands are unclear, report blocked: validation commands not configured.
- If a command requires missing env vars, `.env` files, browsers, Docker, databases, services, or dependencies that are not already available, report blocked: local validation environment incomplete.
- Run commands sequentially.
- Do not install dependencies, start persistent services, create env files, run dependency updates, deploy, migrate, or perform destructive cleanup.
- If a configured command writes normal caches or build/test artifacts, report the generated paths. Do not edit source files to clean them up.

Output:

- Report branch, commit, clean/dirty status, commands run, pass/fail status, first actionable failure block, skipped commands, blockers, and the next concrete action.
