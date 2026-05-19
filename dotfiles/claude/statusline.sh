#!/usr/bin/env bash
# Reads JSON from stdin provided by Claude Code.
# Outputs: <repo-name> | ctx: <pct>%  (colour-coded by usage)

input=$(cat)

# Extract current working directory — handle multiple possible key names
cwd=$(echo "$input" | jq -r '
  .cwd //
  .session.cwd //
  .workspace.cwd //
  ""
')
repo=$([ -n "$cwd" ] && basename "$cwd" || echo "claude")

# Extract token counts — handle multiple possible key shapes
used=$(echo "$input" | jq -r '
  .contextWindow.usedTokens //
  .context_window.used_tokens //
  .tokens.used //
  0
')
total=$(echo "$input" | jq -r '
  .contextWindow.maxTokens //
  .context_window.max_tokens //
  .tokens.max //
  200000
')

if [ "$total" -gt 0 ]; then
  pct=$((used * 100 / total))
else
  pct=0
fi

# Colour thresholds: green < 40%, yellow < 60%, red >= 60%
if [ "$pct" -lt 40 ]; then
  color="\033[32m"
elif [ "$pct" -lt 60 ]; then
  color="\033[33m"
else
  color="\033[31m"
fi
reset="\033[0m"

printf "%s | ctx: ${color}%d%%${reset}\n" "$repo" "$pct"
