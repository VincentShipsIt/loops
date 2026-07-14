Implement exactly one eligible open issue from the canonical GitHub Project for `[GITHUB_REPO]`, then open a pull request against the remote repository's discovered default branch.

Scheduler lifecycle preflight:
- Use GitHub's versioned Projects v2 REST API through `gh api` for exact-board discovery, fields, status counts, candidate filtering, and status mutation. Send `X-GitHub-Api-Version: 2026-03-10`, use server-side `q` filters, request only required field IDs, and paginate REST responses. Do not use GraphQL or `gh project item-list` for work supported by these endpoints.
- Before any repository synchronization or issue selection, query the exact target project and count items whose status on that project is exactly `Backlog`.
- If and only if that query succeeds and the exact `Backlog` count is zero, use the Codex app automation-management capability to change only the current automation's status to paused, preserving its prompt, schedule, model, reasoning effort, execution environment, working directories, and every other setting. Then report the zero count and stop without repository or project writes.
- If the `Backlog` count is greater than zero, continue normally. If the board query fails, is incomplete, or cannot identify the exact target project, report blocked and stop without pausing the automation or synchronizing the repository.
- Never pause merely because `Backlog` is nonzero but no item passes milestone, scope, dedupe, access, or other eligibility gates.

Scope and synchronize:
- Work only on `[PROJECT]` in the isolated Codex automation worktree. Treat `[REPO_PATH]` as the source checkout and never edit, commit, stash, reset, switch, or pull there.
- Discover the default branch directly from `origin` with `git ls-remote --symref origin HEAD`. Accept only one symbolic `ref: refs/heads/<default-branch> HEAD` result; record `<default-branch>` as `default_branch`, and stop if it is missing, ambiguous, or not under `refs/heads/`.
- Fetch only that branch into its remote-tracking ref with `git fetch --prune origin "+refs/heads/${default_branch}:refs/remotes/origin/${default_branch}"`, then record `default_commit` with `git rev-parse "refs/remotes/origin/${default_branch}^{commit}"`. Inspect the project whose title is exactly `[PROJECT_BOARD]`, open issues, milestones, open pull requests, remote branches, and worktrees. Only the status attached to that project counts.
- Treat `default_commit` as the sole implementation base. Never use or mutate a local default branch: do not check it out, create it, pull it, switch it, merge it, rebase it, reset it, or update it. Do not base work on the initial worktree `HEAD` or the source checkout branch. Stop if the source checkout is the current working directory, the current checkout is not an isolated registered worktree, or the fetched remote-tracking ref cannot be resolved to a commit.
- Do not inspect or modify `[OUT_OF_SCOPE_PROJECTS]` or unrelated projects.

Select one issue:
- Consider the current dated weekly or release milestone first. If it has no eligible `Backlog` issue, advance to the nearest future dated milestone and continue milestone by milestone. A full or empty current milestone is not a reason to stop while later eligible `Backlog` work exists.
- `codex:automation` is the Codex queue label; `claude:routine` is the Claude routine queue label.
- `claude:routines` is a stale plural variant, not a canonical queue label. Use `claude:routine` unless a target repo explicitly documents the plural label.
- `shipcode:agent:codex` and `shipcode:agent:claude` are ShipCode routing only. Do not treat either as a generic intake signal outside ShipCode-specific logic.
- An issue is eligible only when its target-project status is exactly `Backlog`, it belongs to a concrete dated current or future weekly/release milestone, its body and acceptance criteria are bounded enough to complete and verify in one run, and no open pull request, remote branch, or worktree already covers it.
- Rank eligible issues in this order: queue label (`codex:automation`), milestone, target/release/start date, project Priority, then readiness (acceptance criteria, verification scope, and confidence).
- Prefer ready `codex:automation` issues before unlabeled/non-automation work.
- Do not give `shipcode:agent:codex` or `shipcode:agent:claude` any selection weight unless this run is explicitly scoped to ShipCode.
- Do not give stale `claude:routines` any selection weight unless target repo policy explicitly documents that plural label.
- Skip epics, deferred or blocked work, product-decision placeholders, manual release or signing work, broad migrations, destructive or production operations, and work requiring unavailable external access.
- Prefer the nearest active milestone, then P0 through P3, then unlabeled. Within the same priority prefer bugs, correctness, security, and safety before enhancements, then the oldest issue.
- Repair existing linked open PRs: if an open PR closes or links a candidate issue, ensure the PR has the issue's queue/review labels before skipping it as already covered.
- If a candidate is too large for one coherent PR, decompose it before claiming into bounded child or follow-up issues, inherit its milestone and priority, add those issues to this exact project as `Backlog`, and link the decomposition from the parent. Then select at most one eligible child for this run. Never claim a broad parent merely to leave it stranded `In Progress`.
- If no issue is eligible, report the target-project status counts and stop without creating a branch, changing project metadata, editing files, committing, or opening a pull request.

Claim before editing:
- Select exactly one issue and immediately re-check its project status, open pull requests, remote branches, and worktrees.
- Move only its target-project item from `Backlog` to `In Progress` before creating a branch or editing.
- If the claim fails or the state changed, try the next eligible issue or stop. Never implement an issue that was not successfully claimed.

Implement and verify:
- In the isolated worktree, create a focused `[BRANCH_PREFIX]/<issue-number>-<slug>` branch with no upstream directly from the recorded `default_commit`. Before editing, require `git rev-parse HEAD` to equal `default_commit` exactly and `git status --porcelain=v1 --untracked-files=all` to produce no output; stop and report without editing if either condition fails.
- Read the issue body and comments, repository instructions, relevant architecture and documentation, and nearby code before editing. Repository-specific safety and domain rules in `AGENTS.md` are binding unless they conflict with this automation's explicit project or trunk contract.
- Implement only the selected issue using existing patterns. Add or update focused tests.
- Run the relevant formatter, lint, typecheck or build, unit, coverage, and user-facing checks discovered from repository instructions and scripts, proportional to the change. Record the exact command and blocker for any required check that cannot run.
- Review the final diff for correctness, security, regressions, unnecessary complexity, dead code, and unrelated changes.

Publish for review:
- Commit with the issue number, push the branch, and open a ready-for-review pull request against the recorded `default_branch`. Never create a draft pull request.
- When opening a PR, mirror source issue labels onto the PR: always copy queue labels (`codex:automation`, `claude:routine`) and copy existing classification/review labels such as `code-quality`, `security`, `product`, `bug`, `enhancement`, `backend`, `frontend`, `infra`, and `e2e`.
- Do not invent labels from project fields like Priority, Status, or Area unless those labels already exist on the issue.
- If a non-ShipCode issue or PR has stale `shipcode:agent:codex` or `shipcode:agent:claude`, or any issue or PR has stale plural `claude:routines`, remove it only when the correct queue label is present or can be added with clear evidence; otherwise report it as uncertain.
- Link the issue, summarize the implementation, and list verification results and residual blockers. Use `Closes #<number>` only when the issue is fully resolved.
- Leave the project item `In Progress`. Do not change its project status again, describe or assume a later project transition, or merge the pull request.

Report the selected issue, milestone and priority, discovered default branch and recorded base commit, issue branch, commit, pull request URL, verification results, skipped checks, blockers, and residual risk.
