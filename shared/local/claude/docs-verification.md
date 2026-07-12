# Claude Scheduled Task: Documentation Verification

## Prompt


Verify `[DOC_SCOPE]` documentation against the actual source code in `[REPO_PATH]`.

Authority:

- You may edit documentation files in scope.
- Do not ask for permission to fix stale documentation.
- Do not edit source code unless the task explicitly allows it.
- Never merge PRs, deploy, run production migrations, or write to production data.

Preflight:

- Switch to `[TRUNK]` and fast-forward from origin.
- Stop if the repo has uncommitted source changes unless the task is explicitly allowed to work with them.

Objective:

- Review and update the documentation files so every claim matches the actual source code.

Files to update:

- `[DOC_FILE_1]`
- `[DOC_FILE_2]`
- `[DOC_FILE_3]`

Source files to cross-reference:

- `[SOURCE_PATH_1]`
- `[SOURCE_PATH_2]`
- `[SOURCE_PATH_3]`

Verification checklist:

- Method signatures match.
- Schema fields are complete and accurate.
- Constants and values match.
- Flow descriptions match actual code paths.
- File paths still exist.
- Interface shapes match actual definitions.
- Deleted features are removed from docs.
- Last verified dates are updated only after verification.

Output:

- Files changed.
- Claims corrected.
- Source files checked.
- Anything left uncertain.

