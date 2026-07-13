# Claude Remote Routine: GitHub Board Weekly Readiness

Surface: Claude remote Routine
Trigger: weekly, at the start of the work week, before execution planning
Connectors/tools: GitHub repository and project board
State/dedupe: use `[STATE_FILE]` when available; otherwise dedupe by issue URL, project item ID, title slug, linked PR, and branch name
Safe writes: GitHub issue metadata, issue body formatting, labels, milestones, and project fields only
Forbidden actions: local filesystem access, source edits, branches, commits, PRs, merges, deploys, production writes, destructive cleanup
Failure mode: stop and report blocked when connector access, board identity, or safe evidence is missing
Manual test before enabling: run once against a small project board and verify every proposed metadata change is evidence-backed and the readiness report matches the board

## Prompt

Audit and repair `[PROJECT]` GitHub project board, milestones, priorities, and
weekly deliverables, then answer whether the board is ready for weekly execution.

Goal:

- Answer and enforce: "Is the GitHub board ready for weekly execution? Does every
  open actionable issue have a board item, Status, Priority, and Milestone? Are
  last-week goals completed, carried forward, or explicitly blocked?"

Scope:

- Work only on `[GITHUB_REPO]` and `[PROJECT_BOARD]`.
- Do not use or assume a local repository path.
- Do not inspect, summarize, or update `[OUT_OF_SCOPE_PROJECTS]` or any unrelated project.
- Metadata-only mode: do not create source edits, branches, commits, pull requests, deploys, or production writes.

Board identity:

- Determine the canonical board from existing issue project items, repo/org
  projects, and planning docs linked from the repo.
- If board identity is ambiguous, stop and report it as a blocker.

Required audit:

- List all open issues.
- List all active board items.
- List all active milestones.
- Identify the current weekly deliverable milestone.
- Identify last-week goals from milestones, project fields, planning docs, issue comments, merged PRs, or board activity.
- For every open actionable issue, verify it is present on the canonical board with Status, Priority, and Milestone set.
- For every active board item, verify the backing issue is open/relevant, Status matches evidence, Priority exists, and Milestone matches the current or next weekly deliverable.
- Identify stale In Progress items, merged work not moved to Done, duplicate cards, and open issues missing from the board.

Repair policy:

- Apply safe GitHub metadata fixes directly.
- Add missing open actionable issues to the canonical board.
- Set missing Status, Priority, and Milestone when evidence is clear.
- Move merged/completed work to Done.
- Carry unfinished last-week goals into the current or next weekly milestone when clear.
- Create or update the current weekly milestone only if the repo's existing naming/date pattern (`[WEEKLY_MILESTONE_PATTERN]`) makes it obvious.
- Search by issue URL, project item ID, title, normalized title slug, linked PRs, and branch names before adding or updating any board item.
- If metadata cannot be decided from evidence, leave it unchanged and report the exact blocker.

Final answer format:

- Ready: yes/no
- Canonical board
- Current weekly deliverable milestone
- Last-week goals found
- Completed goals
- Carried-forward goals
- Missing board items fixed
- Missing Status fixed
- Missing Priority fixed
- Missing Milestone fixed
- Remaining blockers
- Exact issues still preventing Ready: yes

If no safe metadata work exists, produce the readiness report and say so.
