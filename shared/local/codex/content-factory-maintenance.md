# Codex Automation: Content Factory Maintenance

Recommended settings:

- Kind: cron
- Execution environment: worktree
- Write surface: docs, prompts, skills, tests, or evaluation fixtures

## Prompt

Improve `[PROJECT]` when the repository itself produces prompts, skills, templates, docs, rubrics, or evaluation fixtures.

This is not a general product-app maintenance loop. Use it for agent-content repositories where recurring quality work means tightening prompts, templates, documentation, guardrails, or eval assets.

Repository policy:

- This automation is scoped only to `[REPO_PATH]`.
- Do not inspect, modify, summarize, or report on `[OUT_OF_SCOPE_PROJECTS]` or any unrelated project.
- Never print tokens, secrets, .env contents, private payloads, or credentials.
- Never merge PRs, deploy, run production migrations, or write to production data.

Worktree hard gate:

- This automation must run in the Codex worktree execution environment, not directly in the source checkout.
- Treat `[REPO_PATH]` as the source checkout only; do not edit, commit, stash, reset, switch, or pull there.
- If `pwd` resolves to the source checkout, stop and report blocked.
- Discover the default branch directly from origin with `git ls-remote --symref origin HEAD`; accept only one symbolic `ref: refs/heads/<default-branch> HEAD` result and record it as `default_branch`.
- Fetch only that branch into its remote-tracking ref with `git fetch --prune origin "+refs/heads/${default_branch}:refs/remotes/origin/${default_branch}"`, then record `default_commit` with `git rev-parse "refs/remotes/origin/${default_branch}^{commit}"`. Stop if discovery or resolution is missing or ambiguous.
- Treat `default_commit` as the sole work base. Never use or mutate a local default branch.

Workflow:

- Inspect existing skills, content workflows, prompts, templates, evaluation docs, and recent changes.
- Scan a small set of relevant public primary sources for fresh ideas in the target domain.
- Avoid copying proprietary or large verbatim text; summarize useful patterns and adapt only what fits this repo.
- Read `[STATE_FILE]` for previously addressed items; skip any candidate already listed there.
- Identify one small high-leverage improvement:
  - tighten an existing skill
  - add missing guardrails
  - improve QA rubrics
  - improve trend-to-brief workflows
  - add evaluation checks
  - improve metadata
  - remove stale instructions
  - document a clearer operating loop
  - incorporate a proven public pattern into existing repo conventions
- Prefer changes that improve output quality with less human intervention.
- Follow existing repository patterns and preserve unrelated changes.
- If code or docs are changed, run the most relevant lightweight validation available.
- If no improvement with clear positive impact is identified, report that and stop without creating a branch or PR.
- Before creating a branch, search open PRs and branches on the repository for any automation-owned content-factory PR; if one is open and not merged, skip the PR step and report the existing PR URL.
- Create `[BRANCH_PREFIX]-content-YYYYMMDD-HHMMSS` with no upstream directly from `default_commit` in the isolated worktree.
- Before editing, require `git rev-parse HEAD` to equal `default_commit` exactly and `git status --porcelain=v1 --untracked-files=all` to produce no output; stop and report without editing if either check fails.
- Update `[STATE_FILE]` with the chosen item only after the PR is opened and pushed.
- Commit and open a pull request against `default_branch`.

Output expectations:

- Report `default_branch`, `default_commit`, what changed, sources used, why it improves the factory, validation run, and next candidates.
