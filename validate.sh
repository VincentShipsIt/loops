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
codex/automations/local/loop-discovery/automation.toml'

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

# 5) Leaked-data scan (authored files only; upstream/linked-examples excluded by the path set)
leak=$(grep -rnE '/Users/|/home/[a-z]|ghp_[A-Za-z0-9]{20,}|gho_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{30,}|-----BEGIN [A-Z ]*PRIVATE KEY-----' \
  README.md AGENTS.md claude/routines shared codex/automations prompts skills 2>/dev/null || true)
if [ -n "$leak" ]; then
  while IFS= read -r line; do err "leaked absolute path or secret-shaped string: $line"; done <<< "$leak"
fi

if [ "$fail" -eq 0 ]; then echo "OK: all checks passed"; fi
exit $fail
