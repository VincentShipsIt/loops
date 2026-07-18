# Daily Loop Report

Surface: Codex local Automation running against the configured loop workspace.

Trigger: Once daily after the fleet's scheduled loops have had their reporting window.

Connectors/tools: Codex automation state and memories, GitHub Projects v2 REST API version 2026-03-10 through `gh api`, GitHub PR/check REST endpoints, MeterBar, connected Claude CLI profiles, and local filesystem access to `reports/`.

State/dedupe:

- Use the UTC date as the report key: `reports/YYYY-MM-DD.md`.
- Read the existing report for that date before writing; preserve prior evidence and replace only the current run section when rerun.
- Read each configured automation's memory and current state. Do not infer a successful run from a missing memory file.
- Count each loop at most once per observed run ID/timestamp.

Safe writes:

- Write only the date-keyed report under `reports/`.
- Use a temporary sibling file and atomic rename so an interrupted run cannot leave a partial report.
- Do not edit source code, automation schedules, project status, issues, PRs, branches, or worktrees.

Forbidden actions:

- Never expose secrets, tokens, `.env` contents, private payloads, or raw CLI authentication output.
- Never treat missing evidence as success.
- Never run heavy local tests, typechecks, builds, coverage, or E2E.
- Never mutate GitHub state or change a loop's enabled/paused state.

Required report sections:

1. Reporting date and collection timestamp.
2. Loop inventory with runs observed, completed, no-op, blocked, failed, and unknown counts.
3. Per-loop performance: duration when available, work units processed, PR/issue outcomes, verification evidence, and exact blockers.
4. Fleet outcomes: Projects v2 counts, PR review/repair/merge counts, current-head verdict coverage, and human actions.
5. Tool health: GitHub, MeterBar, Claude profiles, quota freshness, and filesystem/tool failures.
6. Trend versus the prior report: regressions, improvements, and unchanged risks.
7. Three or fewer prioritized flow improvements, each with evidence, owner loop, and measurable success signal.

Failure mode: If a source is unavailable, record `unknown` with the exact source and failure class. Do not fabricate counts or rewrite the report as healthy. If atomic publication fails, leave the prior report intact and report the blocker.

Output: Return the report path, collection window, source coverage, key metrics, improvement actions, and unresolved blockers.

Manual test before enabling: Run once while the automation is paused, confirm the report is created or updated atomically, verify ignored status with `git status --short --ignored reports/`, and inspect that secrets and raw credentials are absent.
