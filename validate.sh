#!/usr/bin/env bash
# validate.sh - lint the loops template library.
# Checks: SKILL.md frontmatter + name==dir, Codex model/effort policy,
# generated prompt synchronization, and placeholder documentation coverage.
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

# 2) Codex automation.toml required keys + current model policy
for f in codex/automations/local/*/automation.toml; do
  [ -e "$f" ] || continue
  for k in version id kind name prompt status rrule; do
    grep -qE "^$k[[:space:]]*=" "$f" || err "$f: missing required key '$k'"
  done
  grep -qE '^model[[:space:]]*=[[:space:]]*"gpt-5\.6-sol"' "$f" || err "$f: model must be gpt-5.6-sol"
  grep -qE '^reasoning_effort[[:space:]]*=[[:space:]]*"(low|medium|high)"' "$f" || err "$f: unsupported or missing reasoning_effort"
done

python3 scripts/sync-codex-implementation-template.py --check || fail=1

# 3) Placeholder documentation coverage (authored files only; upstream excluded)
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

# 4) Leaked-data scan (authored files only; upstream/linked-examples excluded by the path set)
leak=$(grep -rnE '/Users/|/home/[a-z]|ghp_[A-Za-z0-9]{20,}|gho_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{30,}|-----BEGIN [A-Z ]*PRIVATE KEY-----' \
  README.md AGENTS.md claude/routines shared codex/automations prompts skills 2>/dev/null || true)
if [ -n "$leak" ]; then
  while IFS= read -r line; do err "leaked absolute path or secret-shaped string: $line"; done <<< "$leak"
fi

if [ "$fail" -eq 0 ]; then echo "OK: all checks passed"; fi
exit $fail
