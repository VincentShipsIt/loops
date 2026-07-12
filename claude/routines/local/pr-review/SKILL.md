---
name: pr-review
description: Strict quality review of one open pull request
---

Review one open pull request in `[GITHUB_REPO]`.

Scope:
- Work only in `[REPO_PATH]` and `[GITHUB_REPO]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]`.
- Do not merge PRs.
- Never deploy, run live migrations, or write production data.
- Never print tokens, secrets, or environment file contents.

Selection:
- List open PRs.
- Skip drafts unless the task explicitly allows draft review.
- Skip PRs already reviewed by this routine using marker `[REVIEW_MARKER]`.
- If there are no unreviewed open PRs, report that and stop.
- Pick the highest-risk unreviewed PR based on touched surface, failing checks, security/auth/persistence impact, or size.

Review workflow:
- Fetch the diff and inspect relevant code.
- Prioritize correctness, security, data loss, migrations, auth/tenancy, concurrency, user-visible regressions, and missing tests.
- Verify every finding against the code.
- Do not comment on style unless it causes real risk.
- Post one concise review comment with findings ordered by severity.

Output:
- Report PR reviewed, findings posted, validation performed, skipped PRs, and residual risk.
