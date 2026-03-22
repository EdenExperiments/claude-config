# UX Review: repo-modernization
**Reviewed by:** UX Agent
**Date:** 2026-03-21
**Spec:** `docs/specs/2026-03-21-repo-modernization/spec.md`

---

## Flow Correctness

The end-to-end developer workflow is coherent. The spec addresses a real and well-scoped problem: a config repo that has drifted from current Claude Code conventions, creating invisible failure modes (undocumented env flags, broken agent contracts, silent install gaps).

The chaining of concerns is logical:

1. Install (`install.sh`) gets the user to a working state.
2. `CLAUDE.md` gives Claude project context so subsequent work inside this repo is grounded.
3. README documents what exists so human developers can discover and use it.
4. Agent frontmatter modernisation makes agent behavior safe and predictable.
5. Skills migration to directory format aligns with the canonical format, enabling forward compatibility.
6. `execute-plan` prerequisite documentation closes the "why doesn't spawnTeam work" dead end.
7. `new-project-bootstrap` gains the `docs/sessions/retros/` and `.claude/rules/` scaffold steps so new projects start correctly structured.

One gap in flow: AC-10 specifies that the symlink `~/.claude/skills -> ~/claude-config/skills` must resolve correctly after migration, but the spec does not describe what `install.sh` should do when the symlink already exists and points to the old flat-file layout. A developer re-running `install.sh` after a partial or pre-migration install could hit a stale symlink or a no-op that leaves the old structure in place. The upgrade path (re-run vs. first install) is unspecified.

A second minor gap: AC-11 adds `~/.claude/rules` directory creation to `install.sh`, but the spec does not say whether `install.sh` should also symlink `~/.claude/rules` to a repo-managed `rules/` directory or leave it as a bare local directory. This ambiguity means the implementer must guess, and the two choices have meaningfully different semantics (repo-managed vs. machine-local).

---

## Mobile Viability

N/A. This is a CLI tooling and configuration repo with no UI surface. There are no touch targets, layouts, or scroll behaviors to evaluate.

---

## Navigation Changes

The following command and invocation pattern changes have discoverability implications:

**Skills directory migration (AC-8, AC-9)**
The canonical invocation path for skills changes from `skills/plan-feature.md` to `skills/plan-feature/SKILL.md`. Any external documentation, README anchors, or bookmarks pointing to flat skill files will silently break. The spec correctly removes the flat files (AC-9) rather than duplicating them, which prevents stale reads, but it does not mention updating any cross-references. The README rewrite (AC-1) should be the natural fix, but this dependency is not stated explicitly.

**New commands surface via README (AC-1)**
Nine of ten slash commands are currently undocumented. After this change, all ten appear in the README table. This is a net-positive discoverability gain. No concern here beyond ensuring the table descriptions are action-oriented (what does the command do, not just its name).

**`execute-plan` prerequisite gating (AC-2, AC-16)**
The env flag requirement is currently invisible — users invoke `execute-plan`, it silently falls back or fails, and there is no in-command guidance. AC-16 adds a Prerequisites section to the skill itself, which is the right place: the user sees the requirement at the point of use, not only in the README. This is good progressive disclosure. No concern.

**`install.sh` post-install output (AC-12)**
Adding a printed reminder for `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=true` is the correct ergonomic choice. One suggestion for the spec: it should clarify whether the message is printed unconditionally or only when Agent Teams support is detected as absent. An unconditional message is simpler to implement and still useful; a conditional one is less noisy for users who have already configured their shell. The spec should pick one.

**`new-project-bootstrap` step numbering (AC-14, AC-15)**
AC-15 adds a section titled "### 6. Create rules directory (optional)". If there are currently fewer than six numbered steps, this will be out of sequence. If there are already six or more, a new step 6 will collide with or renumber existing steps. The spec should state the current step count and where the new step inserts.

---

## Edge Cases

The following unhappy paths and error states are not explicitly covered by the spec and should be addressed:

**1. Re-running `install.sh` on an existing install (upgrade path)**
The spec is written as if `install.sh` is always a first-time install. A developer who installed before this migration would have `~/.claude/skills` pointing to a flat-file layout. After pulling the updated repo and re-running `install.sh`, does the symlink update? Does `install.sh` check for and handle an already-existing symlink? The spec should require idempotent symlink creation (force-overwrite or skip-if-correct).

**2. `~/.claude/rules` already exists**
If a developer already has a `~/.claude/rules` directory from manual setup, `install.sh` running `mkdir -p ~/.claude/rules` is safe (no-op). But if that directory contains files, and the spec later changes to symlink it, those files would become invisible. Since the spec currently leaves this as a bare directory, the risk is low — but it should be noted as intentionally local-only and not symlinked, to prevent future implementers from symlinking it and clobbering user state.

**3. Skills migration is run while a Claude Code session is active**
If a developer migrates skills (deletes flat files, creates directory structure) while a running Claude Code session holds references to the old paths, the session may produce errors or fall back silently. The spec should include a note that the migration should be done outside active sessions or that Claude Code tolerates path changes gracefully.

**4. Agent frontmatter `tools` allowlist breaks existing workflows (AC-7)**
Restricting `architect.md` and `reviewer.md` to read-only tools (`Read`, `Grep`, `Glob`, `WebSearch`, `WebFetch`) is a correctness improvement, but it is a breaking change for any existing workflow that invokes these agents and expects them to write. The spec should explicitly state that this is an intentional behavior change and that callers (orchestrator, user) should not expect write side-effects from these agents after migration.

**5. `agents/ux.md` formatting bug fix (AC-6) and self-reference**
The UX agent reads its own definition file when invoked. If the bug fix is applied mid-session, the running agent may have loaded the old (broken) definition. This is not a deployment concern for a config repo, but the spec should note that the fix takes effect only after Claude Code reloads the agent definition (i.e., in a new session).

**6. `docs/bmad-comparison.md` commit (AC-17)**
This file is currently untracked. The spec says "commit it" but does not specify what the file should contain, who authored it, or whether it needs review before commit. If the file contains placeholder or draft content, committing it as-is may create noise. The spec should assert a minimum content bar or confirm the file is already in a committable state.

**7. Empty or absent `docs/mcp-catalog.md` (AC-18)**
If `docs/mcp-catalog.md` does not yet exist, the implementer must create it. The spec only says "contains an entry with heading `## hytale-rag`" — it does not specify whether other MCP entries are expected, what the file's overall structure is, or whether a template exists. The spec should clarify whether this is an append to an existing file or a new file creation, and provide a minimal structure example.

---

## Approval

CHANGES-NEEDED

- **Upgrade path for `install.sh`**: Spec must describe behavior when `~/.claude/skills` symlink already exists (idempotent overwrite vs. skip). Current spec assumes first-time install only.
- **`~/.claude/rules` symlink vs. bare directory**: Spec must explicitly state that `~/.claude/rules` is created as a bare local directory (not symlinked to a repo path), so implementers do not create a variant that clobbers user-local rules.
- **`install.sh` post-install message conditionality**: Spec should specify whether the Agent Teams reminder message prints unconditionally or only when the env var is unset.
- **`new-project-bootstrap` step count and insertion point**: AC-15 references "### 6. Create rules directory" but does not confirm current step count or resolve potential numbering collision.
- **AC-7 breaking-change callout**: Add an explicit note that restricting `architect.md` and `reviewer.md` to read-only tools is a behavior change for existing callers, not just a frontmatter addition.
- **`docs/bmad-comparison.md` content bar (AC-17)**: Spec should confirm the file is in a committable state or define a minimum content requirement before it can be committed.
- **`docs/mcp-catalog.md` file existence (AC-18)**: Spec should clarify whether this is an append to an existing file or a new file, and provide a minimal structure example for the `## hytale-rag` entry.
