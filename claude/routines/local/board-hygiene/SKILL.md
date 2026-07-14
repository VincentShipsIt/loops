---
name: board-hygiene
description: Weekly GitHub board readiness audit and metadata repair
---

Audit and repair `[PROJECT]` GitHub project board, milestones, priorities, and
weekly deliverables, then answer whether the board is ready for weekly execution.

Goal:
- Answer and enforce: "Is the board ready for weekly execution? Does every open
  actionable issue have a board item, Status, Priority, and Milestone? Are
  last-week goals completed, carried forward, or explicitly blocked?"

Scope:
- Work only on `[GITHUB_REPO]` and `[PROJECT_BOARD]`.
- Local repository path: `[REPO_PATH]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.
- Queue labels are `codex:automation` for Codex automation work and `claude:routine` for Claude routine work.
- `claude:routines` is a stale plural variant, not a canonical queue label. Use `claude:routine` unless a target repo explicitly documents the plural label.
- `shipcode:agent:codex` and `shipcode:agent:claude` are ShipCode routing only. Do not treat either as a generic intake signal outside ShipCode-specific logic.

Board identity:
- Read local agent instructions, project memory, and planning docs.
- Determine the canonical board from existing issue project items, repo/org projects, and linked planning docs.
- If board identity is ambiguous, stop and report it as a blocker instead of guessing.

Required audit:
- List all open issues, active board items, and active milestones.
- Identify the current weekly deliverable milestone.
- Identify last-week goals from milestones, project fields, planning docs, issue comments, merged PRs, branches, or board activity.
- For every open actionable issue, verify it is on the canonical board with Status, Priority, and Milestone set.
- For every active board item, verify the backing issue is open/relevant, Status matches evidence, Priority exists, and Milestone matches the current or next weekly deliverable.
- Identify stale In Progress items, merged work not moved to Done, duplicate cards, and open issues missing from the board.

Repair policy:
- Search by issue URL, title, normalized title slug, branch name, and PR references before adding or updating anything.
- Apply safe GitHub metadata fixes directly: add missing actionable issues to the board, set missing Status/Priority/Milestone when evidence is clear.
- Remove or archive duplicate board cards, keeping the canonical issue card.
- Move merged/completed work to Done.
- Carry unfinished last-week goals into the current or next weekly milestone when clear.
- Create or update the current weekly milestone only if the repo's existing naming/date pattern (`[WEEKLY_MILESTONE_PATTERN]`) makes it obvious.
- Repair existing linked open PRs: if an open PR closes or links an issue, ensure the PR has the issue's queue/review labels.
- Always copy queue labels (`codex:automation`, `claude:routine`) from linked issues to PRs, and copy existing classification/review labels such as `code-quality`, `security`, `product`, `bug`, `enhancement`, `backend`, `frontend`, `infra`, and `e2e`.
- Do not invent labels from project fields like Priority, Status, or Area unless those labels already exist on the issue.
- If a non-ShipCode issue or PR has stale `shipcode:agent:codex` or `shipcode:agent:claude`, or any issue or PR has stale plural `claude:routines`, remove it only when the correct queue label is present or can be added with clear evidence; otherwise report it as uncertain.
- Keep labels concise and avoid duplicating project fields with labels.
- Keep titles board-readable while preserving nuance in the body.
- If metadata cannot be decided from evidence, leave it unchanged and report the exact blocker.

Do not create branches, commits, or PRs. This audit is GitHub metadata only.

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
