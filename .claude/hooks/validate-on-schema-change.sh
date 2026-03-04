#!/usr/bin/env bash
# PostToolUse — Edit|Write  (async)
# Re-runs schema:validate whenever a sentinel schema file is saved.

input=$(cat)
file=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[[ -z "$file" ]] && exit 0
[[ "$file" != *"sentinel/schemas/"* ]] && exit 0

REPO_ROOT=$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$REPO_ROOT" || exit 0
echo "[sentinel] Schema edited — validating..."
npm run schema:validate 2>&1
