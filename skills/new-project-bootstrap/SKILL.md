---
name: new-project-bootstrap
description: Bootstrap a new project with the agentic team system. Run once per project to set up tuned agents, docs scaffolding, and CLAUDE.md. Triggered by /bootstrap slash command.
---

# new-project-bootstrap Skill

Run this skill once when starting a new project. By the end, the project has tuned agent definitions, docs scaffolding, and a CLAUDE.md that tells agents where to start.

## Steps

### 1. Copy and tune agent templates

```bash
mkdir -p .claude/agents
cp ~/.claude/templates/agents/backend.md  .claude/agents/backend.md
cp ~/.claude/templates/agents/frontend.md .claude/agents/frontend.md
cp ~/.claude/templates/agents/tester.md   .claude/agents/tester.md
```

Open each file. Fill in every `<!-- TUNE: -->` marker:

**backend.md:**
- Stack: language, framework, ORM/DB client, auth library
- File locations: handler directory, repository directory, test directory
- Context7 libraries: all third-party libs this agent will use

**frontend.md:**
- Framework + version (Next.js 15, Remix 2, etc.)
- Component library path (if any)
- Context7 libraries: all third-party libs this agent will use

**tester.md:**
- Test runner + assertion library (Vitest, Go testing, pytest, etc.)
- Two or three specific existing test files to read for conventions
- Known mock patterns and wrappers specific to this project

### 2. Write project CLAUDE.md

Add or update `CLAUDE.md` with:
- **Start here:** which files to read first (key entry points)
- **Zones:** which directory paths belong to which product area
- **Shared packages:** list all `packages/*` or shared directories explicitly
- **Implementation agents:** backend, frontend, tester (brief purpose of each)
- **Planning agents:** orchestrator, architect, reviewer, ux (brief purpose of each)

### 3. Create docs/ structure

```bash
mkdir -p docs/specs/archived docs/plans/archived docs/sessions/retros
printf "# Abandoned Features\n\n" > docs/sessions/abandoned.md
```

### 4. Commit

```bash
git add .claude/agents/ docs/ CLAUDE.md
git commit -m "chore: bootstrap agentic team system"
```

### 5. Verify

Open a new Claude Code session and run the orchestrator agent. Confirm it can:
- Read `docs/sessions/*-active.md` without error (directory exists, no conflict)
- Dispatch the architect agent
- Dispatch the ux agent

If any agent fails to load, check that `~/.claude/agents/` symlink points to `~/claude-config/agents/`.

### 6. Create rules directory (optional)

```bash
mkdir -p .claude/rules
```

Each `.md` file in `.claude/rules/` is auto-loaded by Claude — use these to split a large `CLAUDE.md` into focused, path-scoped rule files (e.g., `backend-conventions.md`, `test-patterns.md`).
