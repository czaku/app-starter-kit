#!/usr/bin/env bash
# Stop hook — quality gate before Claude finishes a turn.
# Checks: no TODOs in source files, backend lint if changed.

input=$(cat)

# Prevent infinite loop: if this hook itself caused the Stop, exit cleanly.
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active // false')
[[ "$stop_hook_active" == "true" ]] && exit 0

REPO_ROOT=$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$REPO_ROOT" || exit 0

ISSUES=()

# ── 1. No TODO/TBD/placeholder in modified source files ─────────────────────
modified=$(git diff --name-only HEAD 2>/dev/null | grep -vE '\.(md|json|yaml|yml|txt|lock)$' | grep -vE '^docs/')

for f in $modified; do
  [[ ! -f "$f" ]] && continue
  hits=$(grep -n "TODO\|TBD\|placeholder" "$f" 2>/dev/null | grep -v "//.*INTENTIONAL" | head -3)
  if [[ -n "$hits" ]]; then
    ISSUES+=("TODO/TBD/placeholder found in $f:\n$hits")
  fi
done

# ── 2. Backend lint (if backend files changed) ───────────────────────────────
backend_changed=$(git diff --name-only HEAD 2>/dev/null | grep -c '^backend/')
if [[ "$backend_changed" -gt 0 ]] && [[ -f "backend/package.json" ]]; then
  if ! (cd backend && npm run lint --silent 2>/dev/null); then
    ISSUES+=("Backend lint failed — run: cd backend && npm run lint")
  fi
  cd "$REPO_ROOT"
fi

# ── Report ────────────────────────────────────────────────────────────────────
if [[ ${#ISSUES[@]} -gt 0 ]]; then
  echo "Quality gate failed — fix before finishing:" >&2
  for issue in "${ISSUES[@]}"; do
    echo -e "  x $issue" >&2
  done
  exit 2
fi

exit 0
