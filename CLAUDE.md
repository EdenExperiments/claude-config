# claude-config

Personal Claude Code global configuration repo — agents, skills, commands, and templates that install into `~/.claude/` via symlinks.

## Purpose

This repo provides a global agentic development system. Every project benefits from it automatically. Skills and agents in this repo are available in all Claude Code sessions on this machine.

## Zone map

| Directory | What it contains |
|-----------|-----------------|
| `agents/` | Global agent definitions (orchestrator, architect, reviewer, ux) — symlinked to `~/.claude/agents/` |
| `skills/` | Skill files in `{name}/SKILL.md` format — symlinked to `~/.claude/skills/` |
| `commands/` | Slash command definitions — symlinked to `~/.claude/commands/` |
| `templates/agents/` | Project-tuned agent templates (backend, frontend, tester) — symlinked to `~/.claude/templates/` |
| `docs/specs/` | Specs produced by `plan-feature` pipeline |
| `docs/plans/` | Implementation plans produced by `plan-feature` Phase 5 |
| `docs/sessions/` | Active session files (written by `parallel-session`); retros in `docs/sessions/retros/` |
| `.claude/` | Repo-local settings (`settings.local.json`) |

## Global agents

| Agent | File | Role |
|-------|------|------|
| `orchestrator` | `agents/orchestrator.md` | Planning, dispatch, coordination — runs `plan-feature` and `execute-plan` |
| `architect` | `agents/architect.md` | Phase 2 spec review — schema, service boundaries, Parallelisation Map |
| `reviewer` | `agents/reviewer.md` | Phase 1.5 spec-draft, Phase 4 spec gateway, Phase 5.5 plan review, **code gate (logic) OR visual review (UI)** |
| `ux` | `agents/ux.md` | Phase 3 UX review — flows, mobile viability, edge cases. **Does NOT review visual design** |

## Pipeline Split (D-036)

Work is classified during Phase 0 of `plan-feature`:
- **`type: logic`** — TDD gate applies. Tester writes failing tests, reviewer runs Code Gate.
- **`type: visual`** — No TDD. Reviewer runs Visual Review (token compliance, theme compatibility, accessibility).
- **`type: mixed`** — TDD for behavioural ACs only. Both Code Gate and Visual Review must pass.

## Skills

All skills are in `skills/{name}/SKILL.md`. The full pipeline: `plan-feature` → `parallel-session` → `execute-plan`. Use `what-next` to resume after interruption. Use `correct-course` if a spec AC or approach turns out wrong mid-implementation.

## Session state

Active feature sessions live in `docs/sessions/{feature-slug}-active.md`. Before starting any feature work, read all `docs/sessions/*-active.md` files to check for zone conflicts.

## Install

```bash
./install.sh
```

Re-runnable (idempotent). Creates symlinks and local directories. See `README.md` for full setup instructions.
