# Agentic Development Setup: Custom Pipeline vs BMAD Method

This document compares the custom agentic development setup in this repo with the [BMAD Method](https://docs.bmad-method.org) (Build More Architect Dreams), an open-source AI-driven agile development framework.

---

## Overview

| | Custom Setup | BMAD Method |
|---|---|---|
| **Install** | `git clone && ./install.sh` (bash, symlinks) | `npx bmad-method install` (Node.js package) |
| **Platform** | Claude Code native | Claude Code, Cursor, GitHub Copilot |
| **Agents** | 7 (lean, pipeline-focused) | 12+ (full agile SDLC) |
| **Skills/workflows** | 9 focused skills | 34+ named workflows |
| **Community** | Private | Open source, Discord, YouTube |
| **License** | Yours to own | MIT |
| **TDD** | Hard gate (tests before implementation) | Advisory (QA agent, not enforced) |
| **Parallel sessions** | First-class (zone conflict protocol) | Not supported |

---

## Philosophy

**BMAD** positions AI as an *expert advisor* — agents guide you through a structured agile process, but the human drives each phase interactively. It's modelled on agile ceremonies: sprint planning, retrospectives, story creation, velocity tracking. The goal is to bring rigour to AI-assisted development without replacing human judgement.

**This setup** is optimised for *autonomous parallel feature development* with hard quality gates. Once a feature is kicked off, the orchestrator drives it end-to-end — spec through tests through implementation through code review — surfacing only blockers. Human input happens at the start (requirements) and the end (review/merge), not at every phase.

Both approaches believe in structured AI development. The difference is where the human sits: BMAD keeps you in the loop at every phase; this setup automates the loop and pulls you in only when something goes wrong.

---

## Agent Architecture

### BMAD Agents (12+)

| Agent | Role |
|---|---|
| PM (Product Manager) | PRD creation, feature scoping, agile backlog |
| Architect | Technical design, ADRs, system architecture |
| UX Designer | UX flows, wireframes, interaction design |
| Developer | Implementation, code reviews |
| QA | Test strategy, e2e test generation |
| Scrum Master | Sprint planning, retrospectives, velocity |
| Analyst | Requirements elicitation, research |
| Tech Writer | Documentation |
| + more | Party mode allows combining personas |

BMAD covers the full SDLC including agile ceremonies. If you work in sprints or need to involve non-technical stakeholders, this breadth matters.

### This Setup (7 agents)

| Agent | Model | Role |
|---|---|---|
| `orchestrator` | Opus 4.6 | Plans features, dispatches team, merges work |
| `architect` | Sonnet 4.6 | Spec review — schema, service boundaries, parallelisation |
| `reviewer` | Sonnet 4.6 | Spec gateway (Phase 4) + code quality gate |
| `ux` | Sonnet 4.6 | UX review — flows, mobile viability, edge cases |
| `backend` | Sonnet 4.6 | Implementation specialist (project-tuned) |
| `frontend` | Sonnet 4.6 | Implementation specialist (project-tuned) |
| `tester` | Sonnet 4.6 | Writes failing tests from spec ACs — never writes implementation |

The lean agent roster is intentional. No PM agent because the orchestrator handles planning. No Scrum Master because there are no sprints — features flow continuously. No Tech Writer because documentation emerges from the spec pipeline itself.

---

## Workflow

### BMAD: 4 Phases + 34 Workflows

```
1. Analysis      → product brief, market research, requirements elicitation
2. Plan          → PRD, UX design, validation
3. Solutioning   → architecture, epics and stories, implementation readiness check
4. Implementation→ development, QA, sprint planning, retrospective, course correction
```

BMAD provides named workflows for each step and optional entry points (e.g. `bmad-quick-dev` for small solo tasks, `bmad-party-mode` for multi-persona sessions). The depth of each phase adapts to project complexity.

### This Setup: Phase 0 + 5-Phase Pipeline

```
Phase 0 — Scale Check
  ↓ (small task: bug fix, ≤3 files, no new API/schema)
  Quick Path → mini-spec → implement → verify ACs → done

  ↓ (everything else)
Phase 1 — Spec Draft       (orchestrator writes spec.md)
Phase 2 — Architecture Review  (architect produces arch-review.md)
Phase 3 — UX Review        (ux agent produces ux-review.md)
Phase 4 — Spec Gateway     (reviewer: GO or NO-GO)
  ↓ GO
Phase 5 — Implementation Plan  (orchestrator writes plan.md)
  ↓
execute-plan:
  T1 — tester writes failing tests (verified red)
  T2/T3 — backend + frontend implement in parallel
  Code Gate — reviewer reads all changed files
  ↓ GO
  Merge
```

Every phase has a hard gate. Nothing proceeds without the previous output. The code gate specifically requires the reviewer to read every changed file — not just the summary.

---

## Quality Gates

This is the most significant difference between the two systems.

### BMAD
- QA agent can generate e2e tests
- Code review workflow exists
- `bmad-check-implementation-readiness` validates readiness before building
- Reviews are structured but **advisory** — you can proceed without them

### This Setup
- **TDD is mandatory**: tester commits failing tests before any implementation agent is dispatched. If tests pass before implementation, something is wrong — the pipeline stops.
- **Spec gateway**: reviewer must issue GO before plan.md is written. NO-GO routes back through arch/UX reviews.
- **Code gate**: reviewer reads all changed source files and produces review.md. NO-GO re-dispatches specific agents with targeted fix instructions.
- There is no way to skip any gate in the full pipeline. The Quick Path (small tasks) bypasses arch/UX/gateway reviews but still requires AC verification.

---

## Parallel Development

### BMAD
BMAD's "Party Mode" allows multiple agent *personas* within a single session — useful for getting a PM and Architect to debate a decision. It is not parallel execution; it is a single session with multiple viewpoints.

### This Setup
Multiple independent Opus orchestrator sessions can run simultaneously on different features:
- Each session writes a unique `docs/sessions/{feature-slug}-active.md` file
- Zone conflict detection uses a prefix-containment algorithm: if session A's paths are a prefix of session B's paths (or vice versa), they conflict
- TOCTOU prevention: write session file → wait 2 seconds → read all session files → check overlap → abort if conflict
- Each session gets its own git worktree (`plan-{feature-slug}`) on a separate branch
- Shared `packages/*` changes are isolated via `plan-{feature-slug}--shared` sub-branches, merged to main before parallel T2/T3 dispatch

This enables working on a new feature while a bugfix is being reviewed in a separate terminal, without risk of file conflicts.

---

## Customisation

| | Custom Setup | BMAD |
|---|---|---|
| **Format** | Plain Markdown files you own | NPM package with release cycle |
| **Updating** | Edit files directly, `git push` | `npx bmad-method install` (upgrade) |
| **Extending** | Add a new `.md` file to `skills/` or `agents/` | BMad Builder module |
| **Project tuning** | Copy templates, fill `TUNE:` markers | Configure agent personas per project |
| **Versioning** | Your git history | Semantic versioning, changelog |

The tradeoff: BMAD's package approach means you get community improvements automatically. This setup means you fully own the system and can tune anything — but you maintain it yourself.

---

## When to Choose Which

### Choose BMAD when:
- Working in a team with agile ceremonies (sprints, retrospectives, standups)
- You want cross-platform support (Cursor, GitHub Copilot, not just Claude Code)
- You need PM-level artefacts (PRDs, roadmaps, stakeholder-facing docs)
- You want an off-the-shelf system with community support and ongoing updates
- The project spans multiple complexity levels (from bug fixes to enterprise systems) and you want automatic depth scaling

### Choose this setup when:
- Solo or small team, continuous delivery (no sprint cadence needed)
- Hard TDD discipline is non-negotiable
- Multiple parallel feature sessions running simultaneously
- Full ownership and editability of every agent and skill is important
- Deep Claude Code integration (Agent Teams, subagents, native tool use)
- You want a lean system you can fully understand and reason about

### They are not mutually exclusive:
BMAD's planning phases (analyst, PM, PRD) pair well with this setup's implementation pipeline. You could use BMAD to produce the spec and architecture artefacts, then hand off to this system's orchestrator + `execute-plan` for the TDD-gated implementation cycle.

---

## Feature Comparison Table

| Feature | Custom | BMAD |
|---|---|---|
| Scale-adaptive depth | Phase 0 quick path (conservative) | Fully adaptive |
| Sprint / agile ceremonies | No | Yes (Scrum Master agent) |
| TDD gate | Hard (mandatory) | Soft (advisory QA) |
| Parallel sessions | Yes (zone conflict protocol) | No |
| Multi-persona discussion | No | Yes (Party Mode) |
| Context7 MCP integration | First-class skill | Not built-in |
| Session resume (`what-next`) | Yes | `bmad-help` equivalent |
| Mid-implementation correction | `correct-course` skill | `bmad-correct-course` workflow |
| Cross-platform | Claude Code only | Claude Code, Cursor, Copilot |
| Community | Private | Open source, Discord |
| Maintenance | Self-maintained | Community + core team |
| Install | `git clone && ./install.sh` | `npx bmad-method install` |
