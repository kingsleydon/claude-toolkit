#!/bin/sh
# Claude Code custom statusline — shows cwd, git branch, model, and context usage
# with color-coded context percentage (green < 50%, yellow 50-80%, red > 80%)
#
# Installation:
#   1. Copy this file to ~/.claude/statusline-command.sh
#   2. Add to your Claude Code settings (~/.claude/settings.json):
#      {
#        "statusLine": {
#          "type": "command",
#          "command": "bash ~/.claude/statusline-command.sh"
#        }
#      }

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "?"')
model=$(echo "$input" | jq -r '.model.display_name // "?"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten home directory to ~
home="$HOME"
short_cwd=$(echo "$cwd" | sed "s|^$home|~|")

# Git branch (if in a git repo)
git_branch=""
if command -v git >/dev/null 2>&1; then
  git_branch=$(cd "$cwd" 2>/dev/null && git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
fi

# Build output
out="\033[34m \033[0m\033[34m${short_cwd}\033[0m"

# Git branch
if [ -n "$git_branch" ]; then
  out="${out}  \033[35m\033[0m \033[35m${git_branch}\033[0m"
fi

# Model
out="${out}  \033[33m${model}\033[0m"

# Context usage with color coding
if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")
  if [ "$used_int" -ge 80 ]; then
    cc="31"  # red
  elif [ "$used_int" -ge 50 ]; then
    cc="33"  # yellow
  else
    cc="32"  # green
  fi
  out="${out}  \033[${cc}m${used}%\033[0m"
fi

printf '%b' "$out"
