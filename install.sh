#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing claude-config from $REPO_DIR..."

# Ensure ~/.claude/teams/ exists (required by Agent Teams)
mkdir -p ~/.claude/teams

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
echo "To update: cd $REPO_DIR && git pull"
