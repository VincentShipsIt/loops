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

- Read repository instructions. Discover the default branch directly from `origin` with `git ls-remote --symref origin HEAD`; accept only one symbolic `ref: refs/heads/<default-branch> HEAD` result and record it as `default_branch`.
- Fetch only that branch into its remote-tracking ref with `git fetch --prune origin "+refs/heads/${default_branch}:refs/remotes/origin/${default_branch}"`, then record `default_commit` with `git rev-parse "refs/remotes/origin/${default_branch}^{commit}"`. Stop if discovery or resolution is missing or ambiguous.
- Compare configured docs with source, configs, scripts, commands, APIs, or schemas at `default_commit`. Never use or mutate a local default branch.
- Check signatures, fields, constants, values, flows, paths, interfaces, setup commands, examples, and deleted features. Update verified dates only for claims actually checked.
- If all claims are current, report evidence and stop without creating a branch/worktree.
- Before writing, search open PRs, remote branches, and worktrees for docs-verification work covering the same files. If equivalent work exists, report it and stop.

Correction workflow:

- Only when a correction is needed, create a fresh isolated `[BRANCH_PREFIX]-docs-YYYYMMDD-HHMMSS` branch/worktree with no upstream directly from `default_commit`.
- Before editing, require `git rev-parse HEAD` to equal `default_commit` exactly and `git status --porcelain=v1 --untracked-files=all` to produce no output; stop and report without editing if either check fails.
- Edit only the configured documentation files. Keep changes minimal and source-backed; never invent product behavior.
- Run lightweight docs formatting, lint, or link checks when available. If required validation fails or cannot run, report the blocker and do not commit, push, or open a PR.
- Commit, push, and open one PR against `default_branch`. Never merge it.

Output:

- Report `default_branch`, `default_commit`, docs/source files checked, claims corrected, source evidence, branch/commit/PR if created, validation, uncertain claims, skipped work, blockers, and residual risk.
