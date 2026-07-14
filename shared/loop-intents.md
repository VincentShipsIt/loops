# Shared Loop Intents

This catalog is the source of truth for loop intent. Platform files may differ in
format, schedule storage, model settings, and execution environment, but matching
rows below should do the same kind of work.

Use GitHub-prefixed names when the current loop depends on GitHub issues, pull
requests, or project boards. Keep a generic name only when the same prompt can
reasonably work across trackers.

## Cadence Rule

Codex app automations store cadence in `automation.toml` as `rrule`.
Claude Desktop scheduled tasks store cadence in the app, not in `SKILL.md`.
Use the suggested cadence here when creating the live Claude schedule.

## Surface Rule

Use local or worktree execution for loops that read source files, run tests, edit
code, create branches, or open PRs. That includes implementation, hotfix,
review-fix, tool-fix, docs-fix, e2e expansion, cleanup, and validation loops.

Use remote connector routines for read-only or metadata/API workflows by default:
GitHub board hygiene, issue triage, PR routing, digests, and notifications.
Remote routines can update GitHub metadata when the prompt explicitly defines
the allowed fields and duplicate checks.

Do not make remote-worker validation a default template. It only works safely
when a project defines the worker host, repo path, env/bootstrap contract,
available services, secrets policy, lock behavior, and cleanup policy. Until
that exists, use `local-validation` and report missing environment as blocked.

## Canonical Intents

| Intent | Purpose | Suggested cadence | Current surfaces |
| --- | --- | --- | --- |
| `github-issue-implementation` | Claim exactly one `Backlog` issue, implement it, verify it, open a PR, and leave the item `In Progress`. | Every two hours for active repos, or nightly for conservative repos. | Codex `github-issue-implementation`; Claude `github-issue-implementation`; Claude `github-backlog-pickup` as the higher-autonomy variant. |
| `recent-commit-review` | Review new trunk commits since a durable baseline and open a fix PR only for high-confidence issues. | Daily after the trunk branch is usually quiet. | Codex `recent-commit-review`; Claude `recent-commit-review`. |
| `board-hygiene` | Audit GitHub board readiness for weekly execution and repair issue/board/milestone/priority metadata without creating duplicate issue/card work; answer Ready: yes/no. | Weekly, at the start of the work week. | Codex local `board-hygiene`; Claude local `board-hygiene`; Claude remote `board-hygiene`. |
| `sentry-hotfix` | Inspect unresolved Sentry issues, avoid duplicate fix PRs, and open one safe verified fix PR. | Every 6 business hours, or event-triggered after new unresolved production errors. | Codex `sentry-hotfix`; Claude `sentry-hotfix`. |
| `pr-review` | Review one open PR strictly and publish comments/markers without changing repository branches. | Hourly during work hours, or event-triggered when a PR opens/updates. | Codex `pr-review`; Claude `pr-review`. |
| `tool-fix-pass` | Run one configured quality/security/frontend scanner and open a small safe fix PR. | Nightly or weekly, depending on tool noise. | Codex `tool-fix-pass`; Claude `tool-fix-pass`. Use `[TOOL_FOCUS]` for security, React, lint, dead code, dependencies, accessibility, or similar variants. |
| `dry-repo` | Make one behavior-preserving cleanup/refactor that reduces duplication or unnecessary complexity. | Weekly at most. | Codex `dry-repo`; Claude `dry-repo`. |
| `local-validation` | Run scheduled read-only validation in the local checkout and report blockers when the environment is incomplete. | Hourly to daily, depending on command cost and local environment stability. | Codex `local-validation`; Claude `local-validation`. |
| `worktree-prune` | Remove only clean, provably merged local worktrees and branches. | Daily or weekly. | Codex `worktree-prune`; Claude `worktree-prune`; Claude `repo-hygiene-cleanup` for multi-repo reporting. |
| `docs-verification` | Verify documentation claims against source code and open documentation corrections. | Weekly or after large API/schema changes. | Codex `docs-verification`; Claude `docs-verification`. |
| `bundle-size-watchdog` | Read dependency/build artifact sizes and report threshold violations without modifying files. | Daily or weekly. | Codex `bundle-size-watchdog`; Claude `bundle-size-watchdog`. |
| `nightly-e2e-expansion` | Add exactly one high-value nightly e2e spec and update runner lists. | Nightly or weekly. | Codex `nightly-e2e-expansion`; Claude `nightly-e2e-expansion`. |
| `agent-content-maintenance` | Improve a repo whose product is prompts, skills, templates, docs, rubrics, or evaluation fixtures. This is not a general app-maintenance loop. | Weekly or monthly, and only for content/template-heavy repos. | Codex `content-factory-maintenance`. |
| `agent-configuration-audit` | Audit effective global and per-repository Claude/Codex instructions, routing, permissions, hooks, symlinks, and drift without modifying configuration. | Monthly, and manually after major agent-tool or routing changes. | Codex local `agent-configuration-audit`; Claude local `agent-configuration-audit`. |

## Canonical Artifact Map

The shared column is authored source material; the installable column is the artifact pasted or imported into an app. A dash is an intentional platform-only gap, not an untracked mirror.

| Intent | Shared artifacts | Installable artifacts |
| --- | --- | --- |
| `github-issue-implementation` | `shared/local/codex/github-issue-implementation.prompt.md`; `shared/local/codex/github-issue-implementation.md`; `shared/local/claude/github-issue-implementation.md`; Claude higher-autonomy source `shared/local/claude/github-backlog-pickup.md` | `codex/automations/local/github-issue-implementation/automation.toml`; `claude/routines/local/github-issue-implementation/SKILL.md`; higher-autonomy `claude/routines/local/github-backlog-pickup/SKILL.md` |
| `recent-commit-review` | `shared/local/codex/recent-commit-review.md`; `shared/local/claude/recent-commit-review.md` | `codex/automations/local/recent-commit-review/automation.toml`; `claude/routines/local/recent-commit-review/SKILL.md` |
| `board-hygiene` | `shared/local/codex/board-hygiene.md`; `shared/local/claude/board-hygiene.md`; `shared/remote/claude/board-hygiene.md` | `codex/automations/local/board-hygiene/automation.toml`; `claude/routines/local/board-hygiene/SKILL.md`; `claude/routines/remote/board-hygiene.md` |
| `sentry-hotfix` | `shared/local/codex/sentry-hotfix.md`; `shared/local/claude/sentry-hotfix.md` | `codex/automations/local/sentry-hotfix/automation.toml`; `claude/routines/local/sentry-hotfix/SKILL.md` |
| `pr-review` | `shared/local/codex/pr-review.md`; `shared/local/claude/pr-review.md` | `codex/automations/local/pr-review/automation.toml`; `claude/routines/local/pr-review/SKILL.md` |
| `tool-fix-pass` | `shared/local/codex/tool-fix-pass.md`; `shared/local/claude/tool-fix-pass.md` | `codex/automations/local/tool-fix-pass/automation.toml`; `claude/routines/local/tool-fix-pass/SKILL.md` |
| `dry-repo` | `shared/local/codex/dry-repo.md`; `shared/local/claude/dry-repo.md` | `codex/automations/local/dry-repo/automation.toml`; `claude/routines/local/dry-repo/SKILL.md` |
| `local-validation` | `shared/local/codex/local-validation.md`; `shared/local/claude/local-validation.md` | `codex/automations/local/local-validation/automation.toml`; `claude/routines/local/local-validation/SKILL.md` |
| `worktree-prune` | `shared/local/codex/worktree-prune.md`; `shared/local/claude/worktree-prune.md` | `codex/automations/local/worktree-prune/automation.toml`; `claude/routines/local/worktree-prune/SKILL.md` |
| `docs-verification` | `shared/local/codex/docs-verification.md`; `shared/local/claude/docs-verification.md` | `codex/automations/local/docs-verification/automation.toml`; `claude/routines/local/docs-verification/SKILL.md` |
| `bundle-size-watchdog` | `shared/local/codex/bundle-size-watchdog.md`; `shared/local/claude/bundle-size-watchdog.md` | `codex/automations/local/bundle-size-watchdog/automation.toml`; `claude/routines/local/bundle-size-watchdog/SKILL.md` |
| `nightly-e2e-expansion` | `shared/local/codex/nightly-e2e-expansion.md`; `shared/local/claude/nightly-e2e-expansion.md` | `codex/automations/local/nightly-e2e-expansion/automation.toml`; `claude/routines/local/nightly-e2e-expansion/SKILL.md` |
| `agent-content-maintenance` | `shared/local/codex/content-factory-maintenance.md` | `codex/automations/local/content-factory-maintenance/automation.toml`; intentionally Codex-only |

Runnable platform-only catalog entries are explicit: `memory-review` maps to `shared/local/{codex,claude}/memory-review.md` and both installable local artifacts; `loop-discovery` maps to `shared/local/codex/loop-discovery.md` and its Codex TOML only. `memory`, `memory-template`, and `scheduled-task-base` are support artifacts rather than runnable canonical intents.

## Safety-Critical Invariant Manifest

Platform syntax and app settings may differ. The following semantic fields may not drift without an explicit exception in this catalog.

| Intent | Outcome | Authority/write surface | Required gates and state/dedupe | Verification blocker and stop conditions |
| --- | --- | --- | --- | --- |
| `github-issue-implementation` | Claim one eligible `Backlog` item, open a ready PR, leave it `In Progress`. | One project claim, one isolated branch, one PR. | Exact target board, active milestone, exact remote-default commit/worktree gate, PR/branch/worktree dedupe. | Required verification blocker prevents publish; no eligible/claim failure stops without code writes. |
| `recent-commit-review` | Review new trunk commits since a durable baseline; fix only verified defects. | State plus at most one isolated fix branch/PR. | Valid ancestor baseline, commit/PR dedupe, source-checkout guard. | Failed/blocked validation prevents PR and baseline advance; no actionable defect is a clean no-op. |
| `board-hygiene` | Produce weekly `Ready: yes/no` and repair evidence-backed metadata. | GitHub issue/project/milestone metadata only. | Canonical-board identity, item/card dedupe, `[WEEKLY_MILESTONE_PATTERN]`. | Ambiguous identity/metadata remains unchanged; always emit readiness blockers. |
| `sentry-hotfix` | Open/reuse one fix PR; resolve only after deployment plus no-recurrence evidence. | One isolated branch/PR, state, evidence-gated Sentry resolution. | Issue/signature state, PR/branch dedupe, fix commit/release/environment/event tracking. | Validation blocks PR; absent deployment/observation evidence leaves issue unresolved in handoff. |
| `pr-review` | Review one current PR head without repository writes. | Review comments and marker only. | Exact remote-default comparison commit, marker with automation id and head SHA. | Repository edits, commits, pushes, and second PRs are forbidden; failed marker write is reported and not deduped. |
| `tool-fix-pass` | Run one configured tool focus and PR only safe verified fixes. | One isolated branch/PR. | Configured command, baseline/final scan, PR/branch/worktree dedupe. | Missing tool or failed verification stops without PR; no actionable finding is a no-op. |
| `dry-repo` | Make one behavior-preserving simplification. | One isolated branch/PR. | Prior-attempt state, active-work dedupe, existing-pattern check. | Unclear behavior or blocked verification stops without PR; no safe target is a no-op. |
| `local-validation` | Execute configured read-only validation and report results. | Read-only checkout inspection and state/report only. | Explicit commands, dirty-checkout awareness, result dedupe/baseline. | Missing environment/command is reported blocked; never repairs code. |
| `worktree-prune` | Report candidates; delete only clean, provably merged local work when explicitly enabled. | Local worktrees/branches only. | `[ALLOW_SAFE_DELETES]`, dirty/unpushed guard, local+remote ancestry, file equivalence. | Missing/false gate is report-only; ambiguity always skips deletion. |
| `docs-verification` | Verify docs against source and PR one correction set. | Configured docs only, one isolated branch/PR. | Fresh remote base, source checkout read-only, same-file PR/branch dedupe. | Failed docs validation blocks publish; current docs stop without a branch. |
| `bundle-size-watchdog` | Report absolute thresholds and deltas from the last complete measurement. | Repo read-only; baseline state only. | Complete baseline fields keyed to source commit and configured targets. | Partial measurement retains prior baseline; no regression is a reported no-op. |
| `nightly-e2e-expansion` | Add one project-native E2E coverage unit for CI/nightly execution. | One isolated test branch/PR. | Discover repo conventions, active-work dedupe, local-execution opt-in/resource contract. | Static-check failure blocks publish; local E2E remains off unless explicitly contracted. |
| `agent-content-maintenance` | Improve one bounded agent-content artifact. | One isolated branch/PR. | Content-repo fit, active-work dedupe, project-specific evaluation rules. | Failed content validation blocks publish; no safe improvement is a no-op. |

Any exception must name the affected artifact, the broadened or narrowed invariant, and why the platform requires it. `validate.sh` enforces the currently safety-critical cross-surface invariants and the artifact inventory above.

## Support Artifacts

`memory` is not an automation intent. It is a short state file used by recurring
Codex automations to remember baselines, active work, known skips, and duplicate
search keys between runs. Claude scheduled tasks can use `[STATE_FILE]` for the
same concept, but Claude does not have a portable local memory file format in
this repo.

`scheduled-task-base` is not an automation intent. It is a Claude prompt wrapper.

Claude has a few extra local wrappers because Claude Desktop scheduled tasks are
good at local and multi-repo maintenance. Do not mirror those into Codex unless
they can be scoped to one repository with an explicit Codex execution environment.

## Tool Fix Presets

`tool-fix-pass` is a wrapper. It is not ready to run until the installer fills
the tool placeholders from a real project command.

React Doctor example:

- `[TOOL_FOCUS]`: `React Doctor`
- `[TOOL_BASELINE_COMMAND]`: `pnpm exec react-doctor . --verbose --yes --offline --fail-on none`
- `[TOOL_COMMAND]`: `pnpm exec react-doctor . --verbose --yes --offline --fail-on error`
- `[TOOL_VERIFY_COMMAND]`: `pnpm exec react-doctor . --verbose --yes --offline --fail-on error`

If a project uses npm, yarn, bun, or a package script wrapper, replace the
commands with the project-native equivalent.
