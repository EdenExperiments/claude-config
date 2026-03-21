#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing claude-config from $REPO_DIR..."

# Ensure local directories exist.
# ~/.claude/teams/ is required by Agent Teams.
# ~/.claude/rules/ holds global rule files (auto-loaded by Claude Code; not symlinked — user-local).
mkdir -p ~/.claude/teams
mkdir -p ~/.claude/rules

# Symlink global config directories.
# ln -sfn is required (not -sf): if the target already exists as a symlink to a directory,
# ln -sf creates a nested link *inside* that directory instead of replacing it.
# The -n flag forces replacement of the symlink itself (idempotent re-runs).
ln -sfn "$REPO_DIR/agents"    ~/.claude/agents
ln -sfn "$REPO_DIR/skills"    ~/.claude/skills
ln -sfn "$REPO_DIR/commands"  ~/.claude/commands
ln -sfn "$REPO_DIR/templates" ~/.claude/templates

echo "Done. Symlinks created:"
echo "  ~/.claude/agents    → $REPO_DIR/agents"
echo "  ~/.claude/skills    → $REPO_DIR/skills"
echo "  ~/.claude/commands  → $REPO_DIR/commands"
echo "  ~/.claude/templates → $REPO_DIR/templates"
echo ""
echo "Local directories ensured:"
echo "  ~/.claude/teams/    (Agent Teams coordination)"
echo "  ~/.claude/rules/    (global rule files — add .md files here for Claude to auto-load)"
echo ""
echo "To update: cd $REPO_DIR && git pull"
echo ""

# Agent Teams requires an env var. Remind the user if it is not already set.
if [ -z "${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-}" ]; then
  echo "Note: Agent Teams is not enabled in this shell."
  echo "To enable parallel agent execution via execute-plan, add this to ~/.bashrc or ~/.zshrc:"
  echo ""
  echo "  export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=true"
  echo ""
fi
