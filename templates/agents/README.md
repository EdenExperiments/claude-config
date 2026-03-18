# Agent Templates

These templates are the starting point for project-tuned agents. Copy them into your project's `.claude/agents/` directory, then fill in every `<!-- TUNE: -->` marker.

## How to use

```bash
cp ~/.claude/templates/agents/backend.md  .claude/agents/backend.md
cp ~/.claude/templates/agents/frontend.md .claude/agents/frontend.md
cp ~/.claude/templates/agents/tester.md   .claude/agents/tester.md
```

Search for `TUNE:` in each file to find what needs customising.

## What stays the same

- The agent's role and read/write contract
- The skills it uses
- The output file format

## What you tune

- Tech stack (language, framework, libraries)
- File locations specific to this codebase
- Which Context7 libraries to use
- Test conventions (for tester.md)

## Naming

Templates are named `backend`, `frontend`, `tester`. These names do NOT conflict with the global agents (`orchestrator`, `architect`, `reviewer`, `ux`). You can rename them if your project needs different specialists (e.g., `go-api`, `react-ui`, `e2e-tester`).
