---
name: docs-verification
description: Verify docs against source and open a correction PR
---

Verify documentation for `[PROJECT]` against the current source of truth.

Scope:
- Work only in `[REPO_PATH]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.
- Never merge PRs, deploy, run production migrations, or write to production data.

Workflow:
- Run `git fetch --all --prune` and base work from latest `origin/[TRUNK]`.
- Create a fresh timestamped branch formatted like `[BRANCH_PREFIX]-docs-YYYYMMDD-HHMMSS` only when docs need changes.
- Read local agent instructions and docs contribution rules.
- Pick one docs area with clear source-backed verification.
- Compare docs against code, configs, scripts, commands, APIs, or schemas.
- Fix stale, misleading, or missing instructions.
- Do not invent product behavior.
- Keep edits minimal and source-backed.
- Run docs formatting or link checks when available.
- If all claims are current, report checked files and stop without creating a branch.
- Before committing, search open PRs and recent branches for existing docs-verification work on the same files; if one exists, report it and do not create a duplicate.
- Commit and open a PR against `[TRUNK]`.

Output:
- Report docs verified, source evidence, changes made, branch, PR URL, validation, and uncertain items.
