# Claude Routine: GitHub Board Weekly Readiness

## Prompt

Audit and repair `[PROJECT]` GitHub project board, milestones, priorities, and weekly deliverables, then answer whether the board is ready for weekly execution.

Scope and identity:

- Work only on `[GITHUB_REPO]`, `[PROJECT_BOARD]`, and read-only evidence in `[REPO_PATH]`; do not inspect `[OUT_OF_SCOPE_PROJECTS]`.
- Metadata-only mode: never create source edits, branches, commits, PRs, deploys, or production writes.
- Determine the canonical board from existing project items and linked planning docs. If identity is ambiguous, stop instead of guessing.
- Queue labels are `codex:automation` for Codex automation work and `claude:routine` for Claude routine work.
- `claude:routines` is a stale plural variant, not a canonical queue label. Use `claude:routine` unless a target repo explicitly documents the plural label.
- `shipcode:agent:codex` and `shipcode:agent:claude` are ShipCode routing only. Do not treat either as a generic intake signal outside ShipCode-specific logic.

Required audit:

- List open issues, active board items, and active milestones; identify the current weekly deliverable milestone and last-week goals.
- Verify every open actionable issue is represented once with Status, Priority, and Milestone.
- Verify every active card has an open/relevant issue, evidence-backed status/priority, and the current or next weekly milestone.
- Identify stale In Progress items, merged work not Done, duplicate cards, missing items, and goals that need completion, carry-forward, or an explicit blocker.

Repair policy:

- Search issue URL, project item id, title/slug, linked PR, and branch before any add/update.
- Apply only evidence-backed GitHub metadata fixes: add missing actionable issues, set fields, archive duplicate cards, move completed work to Done, and carry unfinished goals forward.
- Create/update the weekly milestone only when `[WEEKLY_MILESTONE_PATTERN]` makes the naming and dates unambiguous.
- Repair existing linked open PRs: if an open PR closes or links an issue, ensure the PR has the issue's queue/review labels.
- Always copy queue labels (`codex:automation`, `claude:routine`) from linked issues to PRs, and copy existing classification/review labels such as `code-quality`, `security`, `product`, `bug`, `enhancement`, `backend`, `frontend`, `infra`, and `e2e`.
- Do not invent labels from project fields like Priority, Status, or Area unless those labels already exist on the issue.
- If a non-ShipCode issue or PR has stale `shipcode:agent:codex` or `shipcode:agent:claude`, or any issue or PR has stale plural `claude:routines`, remove it only when the correct queue label is present or can be added with clear evidence; otherwise report it as uncertain.
- Leave uncertain metadata unchanged and report the exact blocker.

Final answer format:

- Ready: yes/no
- Canonical board
- Current weekly deliverable milestone
- Last-week goals found; completed; carried forward; blocked
- Missing board items, Status, Priority, and Milestone fixed
- Duplicate/stale items fixed
- Remaining blockers
- Exact issues still preventing Ready: yes

If no safe metadata work exists, produce the readiness report and say so.
