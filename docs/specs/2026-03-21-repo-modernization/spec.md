# Spec: claude-config Repo Modernisation

**Status:** DRAFT (post 1.5 + arch/ux review fixes)
**Date:** 2026-03-21
**Feature slug:** repo-modernization

---

## What

Comprehensive update of the `claude-config` personal configuration repo to align with Claude Code best practices as of March 2026. Covers: README rewrite, agent frontmatter modernisation, skills format migration to directory structure, new repo-level CLAUDE.md, install.sh improvements, Agent Teams enablement documentation, UX agent bug fix, and new-project-bootstrap scaffold improvements.

## Why

The repo was designed when Claude Code was earlier in its lifecycle. Since then:
- Agent Teams launched (Feb 2026) — `execute-plan` references `spawnTeam` but nothing documents the required env flag
- Skills canonical format is now directory-based (`skills/*/SKILL.md`), not flat files
- Agent definitions support new frontmatter fields (`maxTurns`, `disallowedTools`, `isolation`) that improve safety and predictability
- `.claude/rules/*.md` is now the recommended pattern for modular project context
- 9 of 10 slash commands are undocumented in the README
- The UX agent has a formatting bug that breaks its Read/Write Contract instructions
- The repo has no `CLAUDE.md` of its own, so Claude lacks project context when working inside it

## Zones Touched

- `README.md`
- `CLAUDE.md` (new)
- `agents/orchestrator.md`
- `agents/architect.md`
- `agents/reviewer.md`
- `agents/ux.md`
- `skills/` — all 10 skill files; migrate to directory format (`skills/{name}/SKILL.md`)
- `commands/` — all 10 command files; keep flat format (backward-compat)
- `install.sh`
- `.claude/settings.local.json`
- `docs/mcp-catalog.md`

## Shared Packages

None — this repo has no `packages/*` directories.

---

## Acceptance Criteria

### README

**AC-1:** `README.md` contains a Commands table that lists all 10 slash commands (`plan-feature`, `execute-plan`, `what-next`, `correct-course`, `abandon-feature`, `parallel-session`, `improve`, `tdd-first`, `use-context7`, `bootstrap`) with description.

**AC-2:** `README.md` documents the Agent Teams requirement: a section or callout explains that `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=true` must be set for `execute-plan` / `spawnTeam` to function.

**AC-3:** `README.md` documents the `.claude/rules/` pattern and how it relates to this repo.

### CLAUDE.md

**AC-4:** `CLAUDE.md` exists at the repo root and contains: (a) one-line project purpose, (b) zone map (which directory does what), (c) list of global agents and their roles, (d) pointer to `docs/` for session/spec/plan state.

### Agent Files

**AC-5:** Each of the 4 agent files (`orchestrator.md`, `architect.md`, `reviewer.md`, `ux.md`) has a `maxTurns` field in its YAML frontmatter.

**AC-6:** `agents/ux.md` Read/Write Contract section is outside any fenced code block — specifically, the section headings `## Read/Write Contract`, `Reads:`, and `Writes:` appear as top-level markdown, not inside a triple-backtick fence. (The current bug: these lines are inside the output format code block.)

**AC-7:** `agents/architect.md` and `agents/reviewer.md` each have a `tools` frontmatter field that restricts them to their minimum required operations: the list contains `Read`, `Grep`, `Glob`, `WebSearch`, `WebFetch`, `Write` and does NOT include `Edit` or `Bash`. (`Write` is retained because both agents must write their output files — `arch-review.md`, `gateway.md`, `review.md`. This is a **breaking change** for any caller expecting the agents to inherit all parent tools; callers relying on `Edit` or `Bash` will need to be updated.)

### Skills Migration

**AC-8:** Each skill is in directory format: `skills/{name}/SKILL.md` exists for all 10 skills (e.g., `ls skills/plan-feature/SKILL.md` returns the file).

**AC-9:** Flat `skills/*.md` files no longer exist at the root of `skills/` (migration is complete, not duplicated).

**AC-10:** `install.sh` still produces a working symlink: `~/.claude/skills` → `~/claude-config/skills`. The symlink resolves to the skill files — verifiable by running `ls -la ~/.claude/skills/plan-feature/SKILL.md` and confirming the file is reachable (non-empty, exits 0).

### install.sh

**AC-11:** `install.sh` creates `~/.claude/rules` as a local directory (not a symlink — this is user-local project-context state, not versioned config) alongside the existing `~/.claude/teams` creation. The existing `ln -sfn` idempotency pattern already handles re-runs correctly for symlinks; `mkdir -p` handles idempotency for directories.

**AC-12:** `install.sh` prints a post-install Agent Teams reminder only when `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is not already set in the current environment: `if [ -z "$CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" ]; then echo "..."; fi`. The reminder message names both `.bashrc` and `.zshrc` as candidate files to add the export to.

### settings.local.json

**AC-13:** `settings.local.json` includes allow-rules for common workflow operations beyond just `git add` / `git commit`: at minimum `git status`, `git log`, `git diff`, `git worktree`, and `ls`.

### new-project-bootstrap

**AC-14:** The `new-project-bootstrap` skill's docs scaffold step (Step 3) creates `docs/sessions/retros/` as part of the `mkdir -p` command.

**AC-15:** The `new-project-bootstrap` skill contains a new step titled `### 6. Create rules directory (optional)` (inserted after the existing Step 5 "Verify" section) with a `mkdir -p .claude/rules` command and a one-line explanation: "Each `.md` file in `.claude/rules/` is auto-loaded by Claude — use these to split a large CLAUDE.md into focused, path-scoped rule files."

### Agent Teams / execute-plan

**AC-16:** `skills/execute-plan/SKILL.md` (post-migration) includes a Prerequisites section that lists `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=true` as required for Agent Teams mode, with fallback instructions for single-agent sequential execution (run T1, T2, T3 sequentially in the same session).

**AC-16b:** After migrating skills to directory format, a grep of the entire repo for references to old flat skill paths (e.g., `skills/plan-feature.md`) returns zero matches — confirming no stale hardcoded paths remain.

### Docs

**AC-17:** `docs/bmad-comparison.md` is committed to the repo. The file already exists with content (it is currently untracked per `git status`); no content changes are required — this AC is satisfied by `git add docs/bmad-comparison.md && git commit`.

**AC-18:** `docs/mcp-catalog.md` (which already exists — this is an append operation) contains an entry with the heading `## hytale-rag` that documents: its purpose (game-data RAG search for Hytale), the available tool names (search_hytale_code, search_hytale_docs, search_hytale_gamedata, search_hytale_client_code and their stats variants), and which agents use it.

---

## Out of Scope

- Adding new skills or agents beyond what is described above
- Migrating `commands/` to directory format (commands flat format is fully supported and intentionally kept for simplicity)
- Changing agent model assignments
- Adding hooks to `settings.local.json` (user has not specified desired automations)
- Modifying any project-specific `.claude/` directories (this spec only touches the global config repo)
