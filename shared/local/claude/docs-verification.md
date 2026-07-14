# Claude Scheduled Task: Documentation Verification

## Prompt

Verify `[DOC_SCOPE]` documentation against source truth in `[REPO_PATH]` and open one correction PR only when claims are stale.

Scope and source-checkout safety:

- Work only in `[REPO_PATH]` and `[GITHUB_REPO]`; do not inspect `[OUT_OF_SCOPE_PROJECTS]`.
- Documentation files in scope: `[DOC_FILE_1]`, `[DOC_FILE_2]`, `[DOC_FILE_3]`.
- Source paths to cross-reference: `[SOURCE_PATH_1]`, `[SOURCE_PATH_2]`, `[SOURCE_PATH_3]`.
- Treat `[REPO_PATH]` as read-only source checkout. Never switch, pull, edit, commit, stash, reset, or overwrite it.
- Never edit source code, merge, deploy, run live migrations, or write production data.

Verify and dedupe:

- Read repository instructions and fetch remote metadata without changing the source checkout.
- Compare configured docs with fetched `origin/[TRUNK]` source, configs, scripts, commands, APIs, or schemas.
- Check signatures, fields, constants, values, flows, paths, interfaces, setup commands, examples, and deleted features. Update verified dates only for claims actually checked.
- If all claims are current, report evidence and stop without creating a branch/worktree.
- Before writing, search open PRs, remote branches, and worktrees for docs-verification work covering the same files. If equivalent work exists, report it and stop.

Correction workflow:

- Only when a correction is needed, create a fresh isolated `[BRANCH_PREFIX]-docs-YYYYMMDD-HHMMSS` branch/worktree from fetched `origin/[TRUNK]` and verify the merge-base.
- Edit only the configured documentation files. Keep changes minimal and source-backed; never invent product behavior.
- Run lightweight docs formatting, lint, or link checks when available. If required validation fails or cannot run, report the blocker and do not commit, push, or open a PR.
- Commit, push, and open one PR against `[TRUNK]`. Never merge it.

Output:

- Report docs/source files checked, claims corrected, source evidence, branch/base/commit/PR if created, validation, uncertain claims, skipped work, blockers, and residual risk.
