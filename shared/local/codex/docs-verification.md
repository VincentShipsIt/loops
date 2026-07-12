# Codex Automation: Docs Verification

Recommended settings:

- Kind: cron
- Execution environment: worktree
- Reasoning effort: high
- Write surface: documentation branch plus pull request

## Prompt

Verify `[DOC_SCOPE]` documentation against actual source code in `[REPO_PATH]` and open a correction PR when claims are stale.

Scope:

- Work only in `[REPO_PATH]` and `[GITHUB_REPO]`.
- Documentation files in scope: `[DOC_FILE_1]`, `[DOC_FILE_2]`, `[DOC_FILE_3]`.
- Source files to cross-reference: `[SOURCE_PATH_1]`, `[SOURCE_PATH_2]`, `[SOURCE_PATH_3]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.
- Do not edit source code unless explicitly reconfigured.

Workflow:

- Run `git fetch --all --prune`.
- Base work from latest `origin/[TRUNK]`.
- Verify documentation claims against source, not assumptions.
- Check method signatures, schema fields, constants, values, flow descriptions, file paths, interface shapes, deleted features, setup commands, and examples.
- Update last verified dates only after checking the relevant source.
- If all claims are current, report checked files and stop without creating a branch.
- If changes are needed, edit only documentation files in scope.
- Run relevant lightweight docs validation when available.
- Before committing, search open PRs and recent branches for existing docs-verification work on the same files; if one exists, report it and do not open a duplicate PR.
- Commit, push, and open one PR against `[TRUNK]`.
- Do not merge the PR.

Output:

- Report files checked, source files checked, claims corrected, branch, commit, PR URL, validation, uncertain claims, skipped work, and residual risk.
