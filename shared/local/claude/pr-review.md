# Claude Routine: Strict PR Review

## Prompt

Review exactly one open pull request in `[GITHUB_REPO]`. The routine is comment-only by default and may repair the same branch only when every write gate below passes.

Scope and authority:

- Work only in `[REPO_PATH]` and `[GITHUB_REPO]`; do not inspect `[OUT_OF_SCOPE_PROJECTS]`.
- Never merge, deploy, run live migrations, write production data, expose secrets, or open a second PR.
- A branch edit is permitted only when the branch is automation-owned, an isolated clean checkout is available, the fix is small and high-confidence, and focused verification succeeds.

Selection and marker lifecycle:

- Run `git fetch --all --prune`, list open non-draft PRs, and review at most one.
- For each candidate, read its current head SHA and look for the exact successful marker `<!-- [REVIEW_MARKER] automation=[AUTOMATION_ID] head=<head-sha> -->`.
- Skip only when the marker's automation id and head SHA exactly match the current head. A changed head is eligible again.
- Missing, malformed, unreadable, or failed marker access is not successful dedupe; report it and continue conservatively.
- Pick the highest-risk eligible PR based on failing checks, touched surface, security/auth/persistence impact, or size. Stop cleanly if none exists.

Review and optional repair:

- Check out the selected PR in an isolated clean worktree and compare it with `[TRUNK]`.
- Prioritize verified correctness, security, data loss, migration, auth/tenancy, concurrency, user-visible regression, maintainability, and missing-test findings. Avoid speculative or style-only comments.
- If the branch is not automation-owned or any repair gate fails, do not edit; post one concise review with actionable findings ordered by severity.
- If every repair gate passes, apply only the clear behavior-preserving fix to the same PR branch, run focused verification, commit, push, confirm the new head SHA, and post one concise review/update. Never create another branch or PR.
- If there are no findings, do not post a noisy approval message; proceed to the marker step.

Marker write:

- Only after the review comment succeeds, or after a same-branch update is pushed, verified, and reported successfully, write the exact hidden marker for the final current head SHA and stable `[AUTOMATION_ID]`.
- If marker posting fails, report the failure and do not claim the head was deduped.

Output:

- Report PR, base and initial/final head SHAs, findings, comment URL, edits, validation, marker status, skipped work, blockers, and residual risk.
