# Architecture Review: repo-modernization

**Reviewer:** architect agent
**Date:** 2026-03-21
**Spec:** docs/specs/2026-03-21-repo-modernization/spec.md

---

## Schema Impact

None. This repo has no database, no migrations, and no structured data schema. All artifacts are Markdown files and shell scripts.

---

## Service Boundaries

None. This is a personal configuration repo with no API surface, no network services, and no inter-process contracts. The only external interface is the filesystem contract between this repo and `~/.claude/` via `install.sh` symlinks.

One implicit contract does exist and must be preserved: Claude Code's agent and skill discovery relies on specific directory layouts under `~/.claude/`. The migration from `skills/*.md` (flat) to `skills/{name}/SKILL.md` (directory) must not break that contract. Based on the current `install.sh`, `~/.claude/skills` is a symlink to the entire `skills/` directory, so Claude Code will traverse subdirectories naturally. No change to the symlink strategy is required — AC-10 correctly specifies this. Confirm Claude Code's skill loader supports directory-based discovery before marking AC-10 done.

---

## ADR

### ADR-001: Skills Migration to Directory Format

**Context.** Skills currently live as flat files: `skills/plan-feature.md`. The canonical format as of early 2026 is directory-based: `skills/plan-feature/SKILL.md`. The install.sh symlinks the entire `skills/` directory to `~/.claude/skills`.

**Decision.** Migrate all 10 skill files to directory format in a single batch. Delete the flat files. Do not duplicate (AC-9 enforces this). The symlink in install.sh does not change — it points at the `skills/` directory and traversal handles the rest.

**Consequences.**
- Positive: Aligns with the Claude Code canonical format; allows each skill to carry sibling files (e.g., examples, tests) in its own directory in future.
- Positive: AC-10 is verifiable with a single `ls` command.
- Risk: If any external script or documentation references `~/.claude/skills/plan-feature.md` (flat path), it will break silently. Mitigation: search the repo for any flat-path references before deleting the old files.
- Risk: Claude Code's skill discovery must support directory-based traversal. This is asserted by the spec ("canonical format as of March 2026") but should be verified against Claude Code release notes or source before executing the migration.

**Status:** Accepted (contingent on verification noted above).

---

### ADR-002: AC-7 Tools Whitelist for architect and reviewer Agents

**Context.** AC-7 specifies that `agents/architect.md` and `agents/reviewer.md` should have a `tools` frontmatter field restricting them to `Read`, `Grep`, `Glob`, `WebSearch`, `WebFetch` — explicitly excluding `Write`, `Edit`, and `Bash`.

**Decision.** This whitelist is architecturally UNSOUND as written and must be corrected before implementation.

**Problem.** The architect agent's Read/Write Contract (in its own definition file, confirmed by reading `agents/architect.md`) states:

  Writes: `docs/specs/YYYY-MM-DD-{feature}/arch-review.md`

The reviewer agent similarly writes `gateway.md` and `review.md`. If `Write` and `Edit` are excluded from the tools list, these agents cannot produce their required output files. The agents become read-only consumers with no ability to fulfill their documented purpose.

**Correct approach.** The tools whitelist should include `Write` for output file production. It is reasonable to exclude `Edit` (since agents write new files, not modify existing ones), and to exclude `Bash` (no shell execution needed). A safe, minimal whitelist is:

  `Read`, `Grep`, `Glob`, `WebSearch`, `WebFetch`, `Write`

**Status:** CHANGES-NEEDED — see Approval section.

---

## Shared Package Changes

None. The repo explicitly has no `packages/*` directories (confirmed in spec under "Shared Packages" and verified by filesystem inspection).

---

## Parallelisation Map

Tasks that CAN run in parallel:

- AC-1 (README commands table) and AC-2 (README Agent Teams section) and AC-3 (README rules pattern section) — all are additive edits to README.md but touch distinct sections; can be drafted together and applied in one pass.
- AC-4 (create CLAUDE.md) — independent new file, no dependencies.
- AC-5 (add maxTurns to agent frontmatter across all 4 agents) — independent per-file; all 4 agent files can be edited in parallel.
- AC-6 (fix ux.md Read/Write Contract fence bug) — isolated to ux.md, independent.
- AC-8 + AC-9 (skills migration: create directory structure, move files, delete flat files) — all 10 skills can be moved in parallel since they are independent files. Deletion of flat files must follow creation of directory versions (see sequencing below).
- AC-13 (settings.local.json allow-rules expansion) — independent of all other changes.
- AC-14 + AC-15 (new-project-bootstrap skill improvements) — edits to a single skill file; these two ACs must land in the same file edit but are independent of all other tasks.
- AC-17 (commit docs/bmad-comparison.md) — independent, just a git add.
- AC-18 (add hytale-rag entry to mcp-catalog.md) — independent additive edit.

Tasks that MUST be sequenced (and why):

- AC-8 before AC-9: Directory-format skill files must be created before the flat files are deleted. Deleting first would leave a window with no skill files, breaking any in-flight Claude Code session. Batch: create all 10 directory files, verify with `ls`, then delete all 10 flat files.
- AC-7 fix (corrected whitelist including Write) before any agent frontmatter edits (AC-5): If AC-5 and AC-7 are applied in separate passes, the second pass may need to re-read the file. Safer to apply both frontmatter changes (maxTurns + tools) in a single edit per agent file.
- AC-10 verification after AC-8 + AC-9: The symlink smoke test (`ls -la ~/.claude/skills/plan-feature/SKILL.md`) can only be run after the migration is complete.
- AC-11 + AC-12 (install.sh changes) are independent of skills migration but should be applied and tested together (a single `bash install.sh` run validates both).
- AC-16 (execute-plan skill Prerequisites section) must follow AC-8 (the file must exist at its new path `skills/execute-plan/SKILL.md` before it can be edited).

---

## Additional Findings

**Finding 1: AC-7 is architecturally broken — BLOCKER.**
As detailed in ADR-002, removing `Write` from the architect and reviewer tool lists prevents these agents from producing their output files. The spec must be corrected to include `Write` in the allowed tools list. `Edit` may be excluded (agents write new files, not patch existing ones). `Bash` exclusion is sound.

**Finding 2: new-project-bootstrap scope isolation.**
AC-14 and AC-15 modify `skills/new-project-bootstrap.md` (which will become `skills/new-project-bootstrap/SKILL.md` post-migration). The spec correctly scopes these changes to the skill file itself — a scaffold template that, when invoked, creates structure in OTHER project repos. There is no risk of the config repo itself being modified by these changes. No action needed, but implementors should be aware the skill's `mkdir -p` commands run in the target project's working directory, not in `~/claude-config`.

**Finding 3: Agent Teams env var placement.**
AC-2 and AC-12 document `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=true`. AC-2 puts it in README.md, AC-12 puts a reminder in install.sh output. Neither AC specifies WHERE in the shell profile to set it (`.bashrc` vs `.zshrc` vs `.profile`). This is an intentional choice to remain shell-agnostic — appropriate for a cross-shell config repo. No change required, but README language should say "shell profile (e.g. `~/.bashrc` or `~/.zshrc`)" to avoid confusion.

**Finding 4: Flat-path reference scan not specified.**
The spec does not include an AC requiring a search for any remaining references to the old flat skill paths (e.g., `skills/plan-feature.md`) after migration. This is a gap: if any command file or README hardcodes a flat path, it will silently break. Recommend adding a verification step (grep for `.md` references under `skills/`) to the implementation plan, even if not added as a formal AC.

---

## Approval

CHANGES-NEEDED

- **AC-7 must be corrected:** The `tools` frontmatter whitelist for `agents/architect.md` and `agents/reviewer.md` must include `Write`. Without it, both agents are structurally incapable of producing their required output files (`arch-review.md`, `gateway.md`, `review.md`). The corrected list should be: `Read`, `Grep`, `Glob`, `WebSearch`, `WebFetch`, `Write`. Excluding `Edit` and `Bash` is sound and should be retained.
