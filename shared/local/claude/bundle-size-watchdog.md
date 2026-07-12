# Claude Scheduled Task: Bundle Size Watchdog

## Prompt


Run a lightweight bundle/dependency size check for `[PROJECT]` at `[REPO_PATH]`.

Rules:

- Ensure the repo is on `[TRUNK]` and fast-forwarded before reading metrics.
- Do not run builds.
- Do not install dependencies.
- Do not modify files.
- Do not inspect unrelated projects.

Metrics:

- Check configured build artifact sizes:
  - `[ARTIFACT_PATH_1]`
  - `[ARTIFACT_PATH_2]`
- Check dependency directory size:
  - `[DEPENDENCY_DIR]`
- Count top-level dependency packages when useful.
- Inspect recent dependency lockfile/package manifest changes.

Thresholds:

- Flag if `[DEPENDENCY_DIR]` exceeds `[MAX_DEPENDENCY_SIZE]`.
- Flag if package count exceeds `[MAX_PACKAGE_COUNT]`.
- Flag if artifact size exceeds `[MAX_ARTIFACT_SIZE]`.

Output:

- Dependency directory size.
- Package count.
- Artifact sizes.
- Recent dependency changes.
- Threshold violations.
- Do not create a branch or PR.

