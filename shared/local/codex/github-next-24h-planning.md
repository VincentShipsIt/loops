# GitHub Next 24h Planning

Surface: Codex local Automation running against a configured GitHub repository fleet.

Trigger: Once daily after roadmap hygiene and before the next overnight implementation window.

Connectors/tools: GitHub Projects v2 REST API version 2026-03-10 through `gh api`, GitHub issue/PR/check REST endpoints, local automation definitions and memories, and the current and prior Daily Loop Reports.

Outcome: Prepare a bounded, integration-aware Backlog queue for the next 24 hours without claiming implementation work.

State/dedupe:

- Store the run timestamp, per-repository input snapshot, queue calculation, `fleet:ready` issue set, integration directives, writes, skips, and stop conditions in automation memory or `[STATE_FILE]`.
- Read the prior successful planner memory before acting. A same-day rerun replaces only conclusions based on changed source evidence.
- Resolve each exact GitHub Project from `/orgs/{owner}/projectsV2` or `/users/{owner}/projectsV2`, then use the owner-scoped `/orgs|users/{owner}/projectsV2/{project-number}/fields` and `/items?fields=<numeric-ids>` routes. Never substitute the numeric project database id into `/projects/{id}`. Request the numeric field IDs required for Status, Priority, Milestone, Start date, Target date, and Work type. Missing or incomplete field projections are blockers, not empty values.
- Before creating or updating an issue, search issue URL, title and normalized slug, parent/subissue links, open and recently closed PRs, remote branches, worktrees, and prior planner fingerprints.
- Never count a PR, issue, merge, or implementation run more than once in the seven-day throughput window.

Planning model:

- For each repository, calculate `slots_24h` from the configured implementation schedule.
- Calculate `throughput_factor = min(1, merged_agent_prs_7d_daily_average / max(1, opened_agent_prs_7d_daily_average))`.
- Calculate `ready_target = clamp(min(ceil(slots_24h * throughput_factor), ceil(merged_agent_prs_7d / 7) + 1), 1, slots_24h)`.
- `ready_deficit = max(0, ready_target - existing_actionable_ready_backlog)`.
- Force issue creation to zero when open unmerged agent PRs are at least `min(10, ceil(1.5 * slots_24h))`, when at least three PRs conflict, when required project fields are unavailable, or when merge throughput is zero.
- Apply `[PER_REPO_CREATION_CAP]` and `[FLEET_CREATION_CAP]` after every repository gate. `[PLANNER_DRY_RUN]` forces every write count to zero.

Selection:

- Classify Backlog issues from current evidence as actionable-ready, broad, already covered, blocked, provider-dependent, research/decision work, manual-only, or duplicate.
- Exclude expired milestones unless repository evidence explicitly carries them forward. Treat an issue with incomplete subissues as an epic, not a ready implementation unit. Treat provider credentials, paid APIs, production data, asset generation, physical-device access, user interviews, and product decisions as unavailable unless current automation memory proves the required access exists.
- Prefer integration recovery, correctness, security, failing CI, conflicted PRs, unavailable review verdicts, and existing actionable issues before net-new feature decomposition.
- Rank actionable-ready issues by concrete active milestone, dependency satisfaction, Priority, target/start date, and bounded acceptance/verification criteria.
- Mark no more than `ready_target` issues per repository with the planner-owned `fleet:ready` label. Remove that label when an issue is no longer Backlog or no longer actionable-ready.
- The label is a preference signal only. It does not claim the issue, assign an agent, or change project Status.

Safe writes:

- Create the `fleet:ready` repository label when missing, with a consistent description explaining that the next-24h planner owns it.
- Add or remove `fleet:ready` only on exact-project Backlog issues with current evidence.
- Repair missing Backlog Priority, milestone, Start date, Target date, and Work type only when the repository's existing roadmap schema and evidence make the value unambiguous.
- Issue creation is disabled while `[PLANNER_DRY_RUN]` is true or either creation cap is zero.
- When creation is enabled, create at most one child residual from any parent per run, only when the parent contains an independently implementable residual with traceable acceptance criteria, satisfied dependencies, known project metadata, and no duplicate issue, PR, branch, worktree, or prior planner fingerprint.
- Add every created issue to the exact project in Backlog with complete required metadata. Never create a speculative standalone issue.

Forbidden actions:

- Never edit source code, branches, commits, pull requests, automation schedules, production data, or report files.
- Never move an item to `In Progress`, `Agent`, `Human Review`, `Done`, or `Deferred`; implementation loops retain exclusive claim authority.
- Never assign an implementation agent, merge or close work, edit an issue body the planner did not create, or change issue/PR state.
- Never create a new project field or alter the canonical project schema.
- Never retry writes after a partial GitHub or Projects API failure. Record the partial state and stop further writes for that repository.
- Never expose secrets, tokens, `.env` contents, private payloads, raw credentials, or unbounded logs.

Integration directives:

- Record conflicted PRs, failing current-head checks, unavailable review verdicts, exact-head PASS PRs awaiting merge, dependency ordering, and human-owned gates.
- Directives are report-ready telemetry for Fleet Review and Daily Loop Report. They do not grant either loop broader write authority.
- When integration pressure closes the creation gate, prefer a smaller ready queue and say which implementation slots should remain unused.
- Record `hold_new_implementation: true` for a repository when its open-PR or conflict WIP gate is closed. Implementation loops consume only a planner run less than 24 hours old and stop before claiming new work; the hold never pauses their schedule. Clear the hold explicitly when the gate reopens.

Output:

- Run timestamp and source coverage.
- Fleet and per-repository creation-cap usage.
- Per repository: `slots_24h`, opened/merged agent PR averages, open/conflicted PR counts, throughput factor, ready target, ready before/after, labels added/removed, metadata repaired, issues created, integration directives, skips, and stop conditions.
- Planned-versus-consumed baseline for the next Daily Loop Report.
- Explicit no-op when the existing actionable queue already meets the target or integration pressure makes additional preparation unsafe.

Failure mode: Missing exact-project identity, incomplete required fields, stale planner inputs, authentication failure, or partial writes stop further mutation for the affected repository. Preserve the previous successful memory baseline and report unknown values rather than fabricating a plan.

Manual test before enabling: Run with `[PLANNER_DRY_RUN]` true and both creation caps at zero. Confirm exact project identity, queue math, dedupe, stale-label detection, integration directives, no GitHub writes, no report writes, and useful no-op output. Enable label/metadata writes before enabling issue creation.
