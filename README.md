# claude-config

Personal Claude Code configuration — global agents, custom skills, slash commands, agent templates, and an MCP catalog. Installs via symlinks so `git pull` updates all projects instantly.

## Install

```bash
git clone git@github.com:EdenExperiments/claude-config.git ~/claude-config
cd ~/claude-config && ./install.sh
```

This symlinks `agents/`, `skills/`, `commands/`, and `templates/` into `~/.claude/` and creates `~/.claude/teams/` and `~/.claude/rules/`.

## Update

```bash
cd ~/claude-config && git pull
```

Changes take effect immediately — no reinstall needed.

## What's included

### Global agents (`agents/`)

Available in every project via `~/.claude/agents/`:

| Agent | Model | Role |
|-------|-------|------|
| `orchestrator` | Opus 4.6 | Feature planning, specialist dispatch, merge coordination |
| `architect` | Sonnet 4.6 | Spec review — schema impact, service boundaries, Parallelisation Map |
| `reviewer` | Sonnet 4.6 | Spec gateway (Phase 4) and code quality gate |
| `ux` | Sonnet 4.6 | UX review — flows, mobile viability, edge cases |

### Skills (`skills/`)

Skills live in `skills/{name}/SKILL.md` (directory format). Available in every project via `~/.claude/skills/`.

| Skill | When to use |
|-------|------------|
| `plan-feature` | New feature request → Phase 0 scale check, then quick path or full 5-phase pipeline |
| `execute-plan` | Approved plan → Agent Teams execution with TDD gate |
| `tdd-first` | T1 task → write failing tests from spec ACs before any implementation |
| `use-context7` | Before writing any third-party library API call |
| `parallel-session` | Before starting a feature session → register zone, create worktree |
| `abandon-feature` | Feature cancelled/interrupted → archive and clean up |
| `new-project-bootstrap` | New project → copy templates, scaffold docs/, update CLAUDE.md |
| `what-next` | After interruption or context loss → read session state and get exact next action |
| `correct-course` | Mid-implementation when spec AC, plan structure, or approach turns out to be wrong |
| `improve` | After 3–5 merged features → synthesise retro patterns, propose targeted skill/agent edits for approval |

### Commands (`commands/`)

Slash commands available in every project. Each delegates to the corresponding skill.

| Command | What it does |
|---------|-------------|
| `/plan-feature` | Runs `plan-feature` — full 5-phase planning pipeline |
| `/execute-plan` | Runs `execute-plan` — executes an approved plan |
| `/what-next` | Runs `what-next` — get bearings after an interruption |
| `/correct-course` | Runs `correct-course` — mid-implementation course correction |
| `/abandon-feature` | Runs `abandon-feature` — archive and clean up a cancelled feature |
| `/parallel-session` | Runs `parallel-session` — register zone and create worktree |
| `/improve` | Runs `improve` — synthesise retro notes into skill improvements |
| `/tdd-first` | Runs `tdd-first` — TDD discipline for the T1 tester task |
| `/use-context7` | Runs `use-context7` — load up-to-date library docs before coding |
| `/bootstrap` | Runs `new-project-bootstrap` — set up a new project |

### Agent templates (`templates/agents/`)

Starting-point templates for project-tuned agents. Copy to `.claude/agents/` and fill in the `<!-- TUNE: -->` markers:

```bash
cp ~/.claude/templates/agents/backend.md  .claude/agents/backend.md
cp ~/.claude/templates/agents/frontend.md .claude/agents/frontend.md
cp ~/.claude/templates/agents/tester.md   .claude/agents/tester.md
```

See `templates/agents/README.md` for details.

## Agent Teams

`execute-plan` uses Agent Teams for parallel T1/T2/T3 execution. Agent Teams is experimental and requires an env var:

```bash
# Add to ~/.bashrc or ~/.zshrc
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=true
```

Without this flag, `execute-plan` falls back to sequential single-session execution — the same tasks run in order rather than in parallel.

## Modular project context with `.claude/rules/`

Claude Code auto-loads every `.md` file in `.claude/rules/`. Use this to split a large `CLAUDE.md` into focused, path-scoped rule files:

```
.claude/rules/
  backend-conventions.md
  test-patterns.md
  api-contracts.md
```

`install.sh` creates `~/.claude/rules/` for global rules. Per-project rules live in the project's own `.claude/rules/`.

## Bootstrap a new project

```bash
# In any project directory:
/bootstrap
```

Or manually: copy templates, fill in `<!-- TUNE: -->` markers, run `new-project-bootstrap` skill.

## New machine setup

```bash
git clone git@github.com:EdenExperiments/claude-config.git ~/claude-config
cd ~/claude-config && ./install.sh
# Add CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=true to ~/.bashrc or ~/.zshrc
# Then clone your project repos — their .claude/ agents are already tuned
```
