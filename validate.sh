#!/usr/bin/env bash
# validate.sh - lint the loops template library.
# Checks: SKILL.md frontmatter + name==dir, app-owned model/effort policy
# (templates carry "<app-owned>" placeholders and never name a concrete model),
# generated prompt synchronization, intent artifact/invariant parity,
# placeholder documentation coverage, and project/secret residue.
set -uo pipefail
cd "$(dirname "$0")"
fail=0
err(){ echo "FAIL: $*"; fail=1; }
contains(){ grep -qF -- "$2" "$1" || err "$1: missing required text: $2"; }

# 1) Claude scheduled-task SKILL.md
for f in claude/routines/local/*/SKILL.md; do
  [ -e "$f" ] || continue
  dir=$(basename "$(dirname "$f")")
  grep -q '^name:' "$f" || err "$f: missing 'name:' frontmatter"
  grep -q '^description:' "$f" || err "$f: missing 'description:' frontmatter"
  name=$(awk -F': ' '/^name:/{sub(/^name: */,""); print; exit}' "$f" | tr -d '\r')
  [ "$name" = "$dir" ] || err "$f: name '$name' != dir '$dir'"
done

# 1b) Skill SKILL.md frontmatter + name==dir
for f in skills/*/SKILL.md; do
  [ -e "$f" ] || continue
  dir=$(basename "$(dirname "$f")")
  grep -q '^name:' "$f" || err "$f: missing 'name:' frontmatter"
  grep -q '^description:' "$f" || err "$f: missing 'description:' frontmatter"
  name=$(awk -F': ' '/^name:/{sub(/^name: */,""); print; exit}' "$f" | tr -d '\r')
  [ "$name" = "$dir" ] || err "$f: name '$name' != dir '$dir'"
done

# 2) Codex automation.toml required keys + app-owned model policy
for f in codex/automations/local/*/automation.toml; do
  [ -e "$f" ] || continue
  for k in version id kind name prompt status rrule; do
    grep -qE "^$k[[:space:]]*=" "$f" || err "$f: missing required key '$k'"
  done
  grep -qE '^model[[:space:]]*=[[:space:]]*"<app-owned>"' "$f" || err "$f: model must be the \"<app-owned>\" placeholder (model is chosen in the app UI)"
  grep -qE '^reasoning_effort[[:space:]]*=[[:space:]]*"<app-owned>"' "$f" || err "$f: reasoning_effort must be the \"<app-owned>\" placeholder (effort is chosen in the app UI)"
done

# 2b) No concrete model identifiers anywhere in authored content.
# Model and reasoning effort are app-owned settings; reintroducing a pinned
# model in templates, drafts, or guidance must fail here. Word boundaries keep
# ordinary words (solution, terraform, console) from matching the variant names.
model_residue=$(grep -rniE 'gpt-[0-9]|claude-[0-9]|claude-(opus|sonnet|haiku|fable)|\b(sol|terra|luna)\b' \
  --exclude-dir=.git --exclude-dir=upstream --exclude-dir=linked-examples \
  --exclude=validate.sh . 2>/dev/null || true)
if [ -n "$model_residue" ]; then
  while IFS= read -r line; do err "concrete model identifier in authored content (models are app-owned): $line"; done <<< "$model_residue"
fi

python3 scripts/sync-codex-implementation-template.py --check || fail=1

# 3) Canonical artifact inventory + safety-critical semantic invariants.
# Platform syntax may differ, so these checks intentionally target contract
# phrases rather than byte-for-byte prompt equality.
require_all() {
  needle=$1
  shift
  for f in "$@"; do
    grep -Fq -- "$needle" "$f" || err "$f: missing invariant '$needle'"
  done
}

mapped_artifacts='shared/local/codex/github-issue-implementation.prompt.md
shared/local/codex/github-issue-implementation.md
shared/local/claude/github-issue-implementation.md
shared/local/claude/github-backlog-pickup.md
codex/automations/local/github-issue-implementation/automation.toml
claude/routines/local/github-issue-implementation/SKILL.md
claude/routines/local/github-backlog-pickup/SKILL.md
shared/local/codex/recent-commit-review.md
shared/local/claude/recent-commit-review.md
codex/automations/local/recent-commit-review/automation.toml
claude/routines/local/recent-commit-review/SKILL.md
shared/local/codex/board-hygiene.md
shared/local/claude/board-hygiene.md
shared/remote/claude/board-hygiene.md
codex/automations/local/board-hygiene/automation.toml
claude/routines/local/board-hygiene/SKILL.md
claude/routines/remote/board-hygiene.md
shared/local/codex/sentry-hotfix.md
shared/local/claude/sentry-hotfix.md
codex/automations/local/sentry-hotfix/automation.toml
claude/routines/local/sentry-hotfix/SKILL.md
shared/local/codex/pr-review.md
shared/local/claude/pr-review.md
codex/automations/local/pr-review/automation.toml
claude/routines/local/pr-review/SKILL.md
shared/local/codex/tool-fix-pass.md
shared/local/claude/tool-fix-pass.md
codex/automations/local/tool-fix-pass/automation.toml
claude/routines/local/tool-fix-pass/SKILL.md
shared/local/codex/dry-repo.md
shared/local/claude/dry-repo.md
codex/automations/local/dry-repo/automation.toml
claude/routines/local/dry-repo/SKILL.md
shared/local/codex/local-validation.md
shared/local/claude/local-validation.md
codex/automations/local/local-validation/automation.toml
claude/routines/local/local-validation/SKILL.md
shared/local/codex/worktree-prune.md
shared/local/claude/worktree-prune.md
codex/automations/local/worktree-prune/automation.toml
claude/routines/local/worktree-prune/SKILL.md
shared/local/codex/docs-verification.md
shared/local/claude/docs-verification.md
codex/automations/local/docs-verification/automation.toml
claude/routines/local/docs-verification/SKILL.md
shared/local/codex/bundle-size-watchdog.md
shared/local/claude/bundle-size-watchdog.md
codex/automations/local/bundle-size-watchdog/automation.toml
claude/routines/local/bundle-size-watchdog/SKILL.md
shared/local/codex/nightly-e2e-expansion.md
shared/local/claude/nightly-e2e-expansion.md
codex/automations/local/nightly-e2e-expansion/automation.toml
claude/routines/local/nightly-e2e-expansion/SKILL.md
shared/local/codex/content-factory-maintenance.md
codex/automations/local/content-factory-maintenance/automation.toml
shared/local/codex/memory-review.md
shared/local/claude/memory-review.md
codex/automations/local/memory-review/automation.toml
claude/routines/local/memory-review/SKILL.md
shared/local/codex/loop-discovery.md
codex/automations/local/loop-discovery/automation.toml
shared/local/codex/figma-surface-orchestrator.md
codex/automations/local/figma-surface-orchestrator/automation.toml
codex/automations/local/figma-surface-orchestrator/registry.example.json'

for f in $mapped_artifacts; do
  [ -f "$f" ] || err "canonical artifact map references missing file: $f"
done

require_all 'Ready: yes/no' \
  shared/local/codex/board-hygiene.md \
  shared/local/claude/board-hygiene.md \
  shared/remote/claude/board-hygiene.md \
  codex/automations/local/board-hygiene/automation.toml \
  claude/routines/local/board-hygiene/SKILL.md \
  claude/routines/remote/board-hygiene.md

require_all 'Do not build, install dependencies, switch or pull branches, edit repo files, create branches, commit, push, open PRs' \
  shared/local/codex/bundle-size-watchdog.md \
  shared/local/claude/bundle-size-watchdog.md \
  codex/automations/local/bundle-size-watchdog/automation.toml \
  claude/routines/local/bundle-size-watchdog/SKILL.md
require_all 'On a complete successful measurement only' \
  shared/local/codex/bundle-size-watchdog.md \
  shared/local/claude/bundle-size-watchdog.md \
  codex/automations/local/bundle-size-watchdog/automation.toml \
  claude/routines/local/bundle-size-watchdog/SKILL.md

require_all '[ALLOW_SAFE_DELETES]' \
  shared/local/codex/worktree-prune.md \
  shared/local/claude/worktree-prune.md \
  codex/automations/local/worktree-prune/automation.toml \
  claude/routines/local/worktree-prune/SKILL.md
require_all 'file-level verification' \
  shared/local/codex/worktree-prune.md \
  shared/local/claude/worktree-prune.md \
  codex/automations/local/worktree-prune/automation.toml \
  claude/routines/local/worktree-prune/SKILL.md

require_all '<!-- [REVIEW_MARKER] automation=[AUTOMATION_ID] head=<head-sha> -->' \
  shared/local/codex/pr-review.md \
  shared/local/claude/pr-review.md \
  codex/automations/local/pr-review/automation.toml \
  claude/routines/local/pr-review/SKILL.md

require_all 'Opening or finding a PR never resolves the Sentry issue.' \
  shared/local/codex/sentry-hotfix.md \
  shared/local/claude/sentry-hotfix.md \
  codex/automations/local/sentry-hotfix/automation.toml \
  claude/routines/local/sentry-hotfix/SKILL.md
require_all '[SENTRY_OBSERVATION_RULE]' \
  shared/local/codex/sentry-hotfix.md \
  shared/local/claude/sentry-hotfix.md \
  codex/automations/local/sentry-hotfix/automation.toml \
  claude/routines/local/sentry-hotfix/SKILL.md

require_all 'Treat `[REPO_PATH]` as read-only source checkout.' \
  shared/local/claude/docs-verification.md \
  claude/routines/local/docs-verification/SKILL.md

require_all 'Do not run E2E tests, dev servers, Docker, watch mode, or full builds locally by default.' \
  shared/local/codex/nightly-e2e-expansion.md \
  shared/local/claude/nightly-e2e-expansion.md \
  codex/automations/local/nightly-e2e-expansion/automation.toml \
  claude/routines/local/nightly-e2e-expansion/SKILL.md
require_all '[ALLOW_LOCAL_E2E]' \
  shared/local/codex/nightly-e2e-expansion.md \
  shared/local/claude/nightly-e2e-expansion.md \
  codex/automations/local/nightly-e2e-expansion/automation.toml \
  claude/routines/local/nightly-e2e-expansion/SKILL.md

require_all 'target-project status is exactly `Backlog`' \
  shared/local/codex/github-issue-implementation.prompt.md \
  codex/automations/local/github-issue-implementation/automation.toml \
  shared/local/claude/github-issue-implementation.md \
  claude/routines/local/github-issue-implementation/SKILL.md

require_all 'Never infer quota reset from local midnight' \
  shared/local/codex/figma-surface-orchestrator.md \
  codex/automations/local/figma-surface-orchestrator/automation.toml
require_all 'Stop on the first Figma quota, tool, mutation, or validation error' \
  shared/local/codex/figma-surface-orchestrator.md \
  codex/automations/local/figma-surface-orchestrator/automation.toml
require_all 'Route labels and generic family templates are not implemented surfaces.' \
  shared/local/codex/figma-surface-orchestrator.md \
  codex/automations/local/figma-surface-orchestrator/automation.toml
require_all 'Pages inside one Figma file do not satisfy independent file-role coverage.' \
  shared/local/codex/figma-surface-orchestrator.md \
  codex/automations/local/figma-surface-orchestrator/automation.toml
require_all 'Every required file role must be a distinct file co-located in the declared Figma project.' \
  shared/local/codex/figma-surface-orchestrator.md \
  codex/automations/local/figma-surface-orchestrator/automation.toml
require_all '#2B2B2B' \
  shared/local/codex/figma-surface-orchestrator.md \
  codex/automations/local/figma-surface-orchestrator/automation.toml
require_all '"allowWrites": false' \
  codex/automations/local/figma-surface-orchestrator/registry.example.json
require_all '"validationReserve": 2' \
  codex/automations/local/figma-surface-orchestrator/registry.example.json
require_all '"singleFileExceptionApproved": false' \
  codex/automations/local/figma-surface-orchestrator/registry.example.json
require_all '"requireDistinctRequiredRoleFiles": true' \
  codex/automations/local/figma-surface-orchestrator/registry.example.json

write_capable_prompts='shared/local/codex/github-issue-implementation.prompt.md
codex/automations/local/github-issue-implementation/automation.toml
shared/local/claude/github-issue-implementation.md
claude/routines/local/github-issue-implementation/SKILL.md
shared/local/claude/github-backlog-pickup.md
claude/routines/local/github-backlog-pickup/SKILL.md
shared/local/codex/recent-commit-review.md
codex/automations/local/recent-commit-review/automation.toml
shared/local/claude/recent-commit-review.md
claude/routines/local/recent-commit-review/SKILL.md
shared/local/codex/sentry-hotfix.md
codex/automations/local/sentry-hotfix/automation.toml
shared/local/claude/sentry-hotfix.md
claude/routines/local/sentry-hotfix/SKILL.md
shared/local/codex/tool-fix-pass.md
codex/automations/local/tool-fix-pass/automation.toml
shared/local/claude/tool-fix-pass.md
claude/routines/local/tool-fix-pass/SKILL.md
shared/local/codex/dry-repo.md
codex/automations/local/dry-repo/automation.toml
shared/local/claude/dry-repo.md
claude/routines/local/dry-repo/SKILL.md
shared/local/codex/docs-verification.md
codex/automations/local/docs-verification/automation.toml
shared/local/claude/docs-verification.md
claude/routines/local/docs-verification/SKILL.md
shared/local/codex/nightly-e2e-expansion.md
codex/automations/local/nightly-e2e-expansion/automation.toml
shared/local/claude/nightly-e2e-expansion.md
claude/routines/local/nightly-e2e-expansion/SKILL.md
shared/local/codex/memory-review.md
codex/automations/local/memory-review/automation.toml
shared/local/claude/memory-review.md
claude/routines/local/memory-review/SKILL.md
shared/local/codex/content-factory-maintenance.md
codex/automations/local/content-factory-maintenance/automation.toml
shared/local/claude/scheduled-task-base.md
claude/routines/local/scheduled-task-base/SKILL.md'

for f in $write_capable_prompts; do
  grep -Fq 'git ls-remote --symref origin HEAD' "$f" || err "$f: default branch must be discovered directly from origin"
  grep -Fq 'refs/remotes/origin/${default_branch}' "$f" || err "$f: discovered default branch must be fetched into its remote-tracking ref"
  grep -Fq 'default_commit' "$f" || err "$f: exact remote default commit must be recorded"
  grep -Fiq 'no upstream' "$f" || err "$f: work branch must be created without upstream tracking"
  grep -Fq 'git rev-parse HEAD' "$f" || err "$f: work branch HEAD must equal the recorded default commit before editing"
  grep -Fq 'git status --porcelain=v1 --untracked-files=all' "$f" || err "$f: isolated worktree must be clean before editing"
  grep -Eiq 'isolated .*worktree|separate registered worktree|registered worktree.*isolated' "$f" || err "$f: edits must run in an isolated registered worktree"
  grep -Fiq 'never use or mutate a local default branch' "$f" || err "$f: local default branch mutation must be forbidden"
  grep -Eq 'against .*default_branch|[Tt]arget .*default_branch' "$f" || err "$f: pull requests must target the resolved default branch"
  if grep -Fq '[TRUNK]' "$f"; then err "$f: canonical code-writing prompt must discover the default branch instead of using [TRUNK]"; fi
  if grep -Fiq 'merge-base' "$f"; then err "$f: merge-base-only gates are forbidden in canonical code-writing prompts"; fi
  if LC_ALL=C grep -Eqi '(^|[^[:alnum:]_])(main|master)([^[:alnum:]_]|$)' "$f"; then err "$f: hard-coded main/master branch name is forbidden"; fi
done

is_write_capable_prompt() {
  printf '%s\n' "$write_capable_prompts" | grep -Fxq "$1"
}

for f in $mapped_artifacts; do
  if grep -Eqi '^[[:space:]]*-[[:space:]]*(create|commit|push|open).*(branch|commit|pull request|PR)' "$f"; then
    if ! is_write_capable_prompt "$f" && [ "$f" != 'shared/local/codex/github-issue-implementation.md' ]; then
      err "$f: apparent canonical code-writing prompt is missing from write_capable_prompts"
    fi
  fi
done

pr_review_prompts='shared/local/codex/pr-review.md
codex/automations/local/pr-review/automation.toml
shared/local/claude/pr-review.md
claude/routines/local/pr-review/SKILL.md'
for f in $pr_review_prompts; do
  grep -Fq 'git ls-remote --symref origin HEAD' "$f" || err "$f: PR review must discover the default branch directly from origin"
  grep -Fq 'refs/remotes/origin/${default_branch}' "$f" || err "$f: PR review must fetch the default remote-tracking ref explicitly"
  grep -Fq 'default_commit' "$f" || err "$f: PR review must compare against the exact remote default commit"
  grep -Fiq 'strictly comment-only' "$f" || err "$f: PR review must remain repository-read-only"
  grep -Fq 'Never edit repository files, create or switch branches, commit, push' "$f" || err "$f: PR review repository-write prohibition is missing"
  if grep -Fq '[TRUNK]' "$f"; then err "$f: PR review must discover the default branch instead of using [TRUNK]"; fi
done

codex_issue_prompts='shared/local/codex/github-issue-implementation.prompt.md
codex/automations/local/github-issue-implementation/automation.toml'
for f in $codex_issue_prompts; do
  grep -Fq 'Scheduler lifecycle preflight:' "$f" || err "$f: scheduler lifecycle preflight section is missing"
  grep -Fq 'Before any repository synchronization or issue selection' "$f" || err "$f: backlog count must precede repository synchronization"
  grep -Fq 'If and only if that query succeeds and the exact `Backlog` count is zero' "$f" || err "$f: zero-backlog-only pause gate is missing"
  grep -Fq "change only the current automation's status to paused" "$f" || err "$f: current-automation-only pause action is missing"
  grep -Fq 'preserving its prompt, schedule, model, reasoning effort, execution environment, working directories, and every other setting' "$f" || err "$f: pause must preserve every other automation setting"
  grep -Fq 'Never pause merely because `Backlog` is nonzero but no item passes' "$f" || err "$f: eligibility exhaustion must not pause the automation"
  grep -Fq 'board query fails' "$f" || err "$f: board-query failure must not pause the automation"
  preflight_line=$(grep -nF 'Scheduler lifecycle preflight:' "$f" | head -n1 | cut -d: -f1)
  fetch_line=$(grep -nF 'git fetch --prune origin' "$f" | head -n1 | cut -d: -f1)
  if [ -z "$preflight_line" ] || [ -z "$fetch_line" ] || [ "$preflight_line" -ge "$fetch_line" ]; then
    err "$f: scheduler lifecycle preflight must run before repository fetch"
  fi
done

claude_issue_prompts='shared/local/claude/github-issue-implementation.md
claude/routines/local/github-issue-implementation/SKILL.md
shared/local/claude/github-backlog-pickup.md
claude/routines/local/github-backlog-pickup/SKILL.md'
for f in $claude_issue_prompts; do
  grep -Fq 'Scheduler lifecycle preflight:' "$f" || err "$f: scheduler lifecycle preflight section is missing"
  grep -Fq 'Before any repository synchronization or issue selection' "$f" || err "$f: backlog count must precede repository synchronization"
  grep -Fq 'mcp__scheduled-tasks__list_scheduled_tasks' "$f" || err "$f: Claude scheduled-task discovery tool is missing"
  grep -Fq 'mcp__scheduled-tasks__update_scheduled_task' "$f" || err "$f: Claude scheduled-task update tool is missing"
  grep -Fq 'If and only if that query succeeds and the exact `Backlog` count is zero' "$f" || err "$f: zero-backlog-only pause gate is missing"
  grep -Fq 'pause only the current Claude scheduled task while preserving every other setting' "$f" || err "$f: Claude self-pause scope is missing"
  grep -Fq 'tools are unavailable or the current task cannot be identified unambiguously' "$f" || err "$f: unavailable/ambiguous scheduler fallback is missing"
  grep -Fq 'without claiming a pause or mutating another scheduler' "$f" || err "$f: Claude scheduler fallback must remain report-only"
  grep -Fq 'Never pause merely because `Backlog` is nonzero but no item passes' "$f" || err "$f: eligibility exhaustion must not pause the Claude task"
  grep -Fq 'board query fails' "$f" || err "$f: board-query failure must not pause the Claude task"
  preflight_line=$(grep -nF 'Scheduler lifecycle preflight:' "$f" | head -n1 | cut -d: -f1)
  fetch_line=$(grep -nF 'git fetch --prune origin' "$f" | head -n1 | cut -d: -f1)
  if [ -z "$preflight_line" ] || [ -z "$fetch_line" ] || [ "$preflight_line" -ge "$fetch_line" ]; then
    err "$f: scheduler lifecycle preflight must run before repository fetch"
  fi
done

remote_worker_residue=$(grep -rnF '[REMOTE_WORKER]' shared/local/claude claude/routines/local prompts/create-claude-routine.md 2>/dev/null || true)
if [ -n "$remote_worker_residue" ]; then
  while IFS= read -r line; do err "generic Claude template assumes REMOTE_WORKER: $line"; done <<< "$remote_worker_residue"
fi

# 4) Placeholder documentation coverage (authored files only; upstream excluded)
tmp_used=$(mktemp); tmp_doc=$(mktemp); tmp_used_files=$(mktemp); tmp_doc_files=$(mktemp)
printf '%s\n' README.md AGENTS.md prompts/*.md skills/loop-writer/SKILL.md > "$tmp_used_files"
find codex/automations claude/routines shared -path '*/upstream/*' -prune -o -type f \( -name '*.md' -o -name '*.toml' \) -print >> "$tmp_used_files" 2>/dev/null
grep -rhoE '\[[A-Z0-9_]+\]' $(cat "$tmp_used_files") 2>/dev/null \
  | grep -vE '\[(PLACEHOLDER|[A-Z])\]$' | sort -u > "$tmp_used"

printf '%s\n' README.md AGENTS.md skills/loop-writer/SKILL.md > "$tmp_doc_files"
find codex claude shared prompts -path '*/upstream/*' -prune -o -name README.md -type f -print >> "$tmp_doc_files" 2>/dev/null
grep -rhoE '\[[A-Z0-9_]+\]' $(cat "$tmp_doc_files") 2>/dev/null \
  | sort -u > "$tmp_doc"
while read -r tok; do
  [ -z "$tok" ] && continue
  grep -qxF "$tok" "$tmp_doc" || err "placeholder $tok is used but not documented in any README/key"
done < "$tmp_used"
rm -f "$tmp_used" "$tmp_doc" "$tmp_used_files" "$tmp_doc_files"

# 5) GitHub queue label policy checks
codex_issue_files="codex/automations/local/github-issue-implementation/automation.toml shared/local/codex/github-issue-implementation.prompt.md"
for f in $codex_issue_files; do
  contains "$f" "Rank eligible issues in this order: queue label (\`codex:automation\`), milestone, target/release/start date, project Priority, then readiness (acceptance criteria, verification scope, and confidence)."
  contains "$f" "Prefer ready \`codex:automation\` issues before unlabeled/non-automation work."
done

claude_issue_files="claude/routines/local/github-issue-implementation/SKILL.md shared/local/claude/github-issue-implementation.md claude/routines/local/github-backlog-pickup/SKILL.md shared/local/claude/github-backlog-pickup.md"
for f in $claude_issue_files; do
  contains "$f" "Rank eligible issues in this order: queue label (\`claude:routine\`), milestone, target/release/start date, project Priority, then readiness (acceptance criteria, verification scope, and confidence)."
  contains "$f" "Prefer ready \`claude:routine\` issues before unlabeled/non-routine work."
  contains "$f" "\`claude:routines\` is a stale plural variant, not a canonical queue label."
done

pr_label_files="$codex_issue_files $claude_issue_files"
for f in $pr_label_files; do
  contains "$f" "When opening a PR, mirror source issue labels onto the PR: always copy queue labels (\`codex:automation\`, \`claude:routine\`)"
  contains "$f" "Do not invent labels from project fields like Priority, Status, or Area unless those labels already exist on the issue."
  contains "$f" "stale plural \`claude:routines\`"
done

repair_files="codex/automations/local/board-hygiene/automation.toml shared/local/codex/board-hygiene.md claude/routines/local/board-hygiene/SKILL.md shared/local/claude/board-hygiene.md claude/routines/remote/board-hygiene.md shared/remote/claude/board-hygiene.md"
for f in $repair_files; do
  contains "$f" "Repair existing linked open PRs: if an open PR closes or links an issue, ensure the PR has the issue's queue/review labels."
  contains "$f" "Always copy queue labels (\`codex:automation\`, \`claude:routine\`) from linked issues to PRs"
  contains "$f" "Do not invent labels from project fields like Priority, Status, or Area unless those labels already exist on the issue."
  contains "$f" "\`claude:routines\` is a stale plural variant, not a canonical queue label."
  contains "$f" "stale plural \`claude:routines\`"
done

shipcode_lines=$(grep -rnE "shipcode:agent:(codex|claude)" README.md AGENTS.md claude/routines shared codex/automations prompts skills 2>/dev/null || true)
if [ -n "$shipcode_lines" ]; then
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    case "$line" in
      *ShipCode*) ;;
      *) err "shipcode:agent:* labels must only appear in ShipCode-specific guidance: $line" ;;
    esac
  done <<< "$shipcode_lines"
fi

claude_plural_lines=$(grep -rn "claude:routines" README.md AGENTS.md claude/routines shared codex/automations prompts skills 2>/dev/null || true)
if [ -n "$claude_plural_lines" ]; then
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    case "$line" in
      *stale*|*plural*|*legacy*) ;;
      *) err "claude:routines must only appear as stale/plural/legacy guidance: $line" ;;
    esac
  done <<< "$claude_plural_lines"
fi

# 6) Leaked-data scan (authored files only; upstream/linked-examples excluded by the path set)
leak=$(grep -rnE '/Users/|/home/[a-z]|ghp_[A-Za-z0-9]{20,}|gho_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{30,}|-----BEGIN [A-Z ]*PRIVATE KEY-----' \
  README.md AGENTS.md claude/routines shared codex/automations prompts skills 2>/dev/null || true)
if [ -n "$leak" ]; then
  while IFS= read -r line; do err "leaked absolute path or secret-shaped string: $line"; done <<< "$leak"
fi

if [ "$fail" -eq 0 ]; then echo "OK: all checks passed"; fi
exit $fail
