# Claude Remote Routine: GitHub Board Weekly Readiness

Surface: Claude remote Routine
Trigger: weekly, at the start of the work week, before execution planning
Connectors/tools: GitHub repository and project board
State/dedupe: use `[STATE_FILE]` when available; otherwise dedupe by issue URL, project item ID, title slug, linked PR, and branch name
Safe writes: evidence-backed GitHub issue metadata, issue body formatting, labels, milestones, and project fields only
Forbidden actions: local filesystem access, source edits, branches, commits, PRs, merges, deploys, production writes, destructive cleanup
Failure mode: stop and report blocked when connector access, board identity, or safe evidence is missing
Manual test before enabling: run once against a small board and verify the readiness verdict and every proposed metadata change

## Prompt

Audit and repair `[PROJECT]` GitHub project board, milestones, priorities, and weekly deliverables, then answer whether the board is ready for weekly execution.

Scope and identity:

- Work only on `[GITHUB_REPO]` and `[PROJECT_BOARD]`; do not assume local filesystem access or inspect `[OUT_OF_SCOPE_PROJECTS]`.
- Metadata-only mode: never create source edits, branches, commits, PRs, deploys, or production writes.
- Determine the canonical board from existing project items and repo-linked planning docs. If identity is ambiguous, stop instead of guessing.

Required audit:

- List open issues, active board items, and active milestones; identify the current weekly deliverable milestone and last-week goals.
- Verify every open actionable issue is represented once with Status, Priority, and Milestone.
- Verify every active card has an open/relevant issue, evidence-backed status/priority, and the current or next weekly milestone.
- Identify stale In Progress items, merged work not Done, duplicate cards, missing items, and goals that need completion, carry-forward, or an explicit blocker.

Repair policy:

- Search issue URL, project item id, title/slug, linked PR, and branch before any add/update.
- Apply only evidence-backed GitHub metadata fixes: add missing actionable issues, set fields, archive duplicate cards, move completed work to Done, and carry unfinished goals forward.
- Create/update the weekly milestone only when `[WEEKLY_MILESTONE_PATTERN]` makes the naming and dates unambiguous.
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
