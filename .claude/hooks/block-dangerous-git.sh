#!/usr/bin/env bash
# PreToolUse — Bash
# Blocks --no-verify commits and force-pushes to main/master.

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')

[[ -z "$cmd" ]] && exit 0

# Block --no-verify
if echo "$cmd" | grep -qE 'git\s+commit.*--no-verify'; then
  echo "BLOCKED: --no-verify skips pre-commit hooks. Fix the underlying issue instead." >&2
  exit 2
fi

# Block force push to main or master
if echo "$cmd" | grep -qE 'git\s+push.*(--force|-f)\s.*(main|master)' || \
   echo "$cmd" | grep -qE 'git\s+push.*(main|master).*(--force|-f)'; then
  echo "BLOCKED: Force-pushing to main/master is not allowed." >&2
  exit 2
fi

exit 0
