# claude-config

Personal Claude Code configuration — global agents, custom skills, agent templates, and an MCP catalog. Installs via symlinks so `git pull` updates all projects instantly.

## Install

```bash
git clone git@github.com:EdenExperiments/claude-config.git ~/claude-config
cd ~/claude-config && ./install.sh
```

This symlinks `agents/`, `skills/`, `commands/`, and `templates/` into `~/.claude/`.

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

| Command | What it does |
|---------|-------------|
| `/bootstrap` | Runs `new-project-bootstrap` to set up a new project |

### Agent templates (`templates/agents/`)

Starting-point templates for project-tuned agents. Copy to `.claude/agents/` and fill in the `<!-- TUNE: -->` markers:

```bash
cp ~/.claude/templates/agents/backend.md  .claude/agents/backend.md
cp ~/.claude/templates/agents/frontend.md .claude/agents/frontend.md
cp ~/.claude/templates/agents/tester.md   .claude/agents/tester.md
```

See `templates/agents/README.md` for details.

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
# Then clone your project repos — their .claude/ agents are already tuned
```
