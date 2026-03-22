# Spec Gateway Review: repo-modernization

**Reviewer:** reviewer agent
**Date:** 2026-03-21
**Spec:** docs/specs/2026-03-21-repo-modernization/spec.md
**Arch-review:** docs/specs/2026-03-21-repo-modernization/arch-review.md
**UX-review:** docs/specs/2026-03-21-repo-modernization/ux-review.md

---

## Spec Review Findings

### Resolution of arch-review CHANGES-NEEDED

**Arch AC-7 (Write omitted from tools whitelist) — RESOLVED.**
The spec now reads: "the list contains `Read`, `Grep`, `Glob`, `WebSearch`, `WebFetch`, `Write` and does NOT include `Edit` or `Bash`." This matches the corrected whitelist from ADR-002. The spec also adds an explicit breaking-change callout for callers, satisfying both the arch-review correction and UX finding 4.

### Resolution of ux-review CHANGES-NEEDED

**UX item 1 (install.sh upgrade path) — RESOLVED (adequate).**
AC-11 states "The existing `ln -sfn` idempotency pattern already handles re-runs correctly for symlinks." The `ln -sfn` flag force-overwrites an existing symlink, making re-runs safe. The spec does not add a separate testable assertion for the upgrade path, but the AC is written around the resulting verifiable state (`ls -la ~/.claude/skills/plan-feature/SKILL.md` exits 0), which covers both first-install and re-install. Adequate.

**UX item 2 (~/.claude/rules symlink vs. bare directory) — RESOLVED.**
AC-11 explicitly states "creates `~/.claude/rules` as a local directory (not a symlink — this is user-local project-context state, not versioned config)." Unambiguous.

**UX item 3 (install.sh message conditionality) — RESOLVED.**
AC-12 specifies the conditional guard exactly: `if [ -z "$CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" ]; then echo "..."; fi`. Testable assertion.

**UX item 4 (new-project-bootstrap step numbering) — RESOLVED.**
AC-15 specifies insertion "after the existing Step 5 'Verify' section." The current skill file (`skills/new-project-bootstrap.md`) has exactly 5 numbered steps (verified by inspection), so the new "### 6. Create rules directory (optional)" is a clean append with no collision.

**UX item 5 (AC-7 breaking-change callout) — RESOLVED.**
AC-7 includes: "This is a **breaking change** for any caller expecting the agents to inherit all parent tools; callers relying on `Edit` or `Bash` will need to be updated."

**UX item 6 (bmad-comparison.md content bar) — RESOLVED.**
AC-17 states "The file already exists with content (it is currently untracked per `git status`); no content changes are required." This asserts the file is in a committable state.

**UX item 7 (mcp-catalog.md file existence) — RESOLVED.**
AC-18 states "which already exists — this is an append operation" and specifies the required heading (`## hytale-rag`), tool names, and which agents use it.

### Arch-review Finding 4 (flat-path reference scan) — RESOLVED.
The spec added AC-16b: "a grep of the entire repo for references to old flat skill paths returns zero matches." This is a verifiable code assertion.

### Acceptance Criteria — Testability Assessment

All 18 ACs (plus AC-16b) are evaluated below.

- **AC-1:** Testable — grep README.md for all 10 command names in a table structure.
- **AC-2:** Testable — grep README.md for `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`.
- **AC-3:** Testable — grep README.md for `.claude/rules`.
- **AC-4:** Testable — file exists; grep for required subsections (project purpose, zone map, agents list, docs pointer).
- **AC-5:** Testable — grep each of the 4 agent frontmatter blocks for `maxTurns:`.
- **AC-6:** Testable — grep `agents/ux.md` for the pattern `## Read/Write Contract` outside a fenced block; a script can verify the heading does not appear between triple-backtick delimiters.
- **AC-7:** Testable — parse frontmatter `tools:` field in both agent files; assert presence of `Read`, `Grep`, `Glob`, `WebSearch`, `WebFetch`, `Write` and absence of `Edit`, `Bash`.
- **AC-8:** Testable — `ls skills/{name}/SKILL.md` for all 10 skill names exits 0.
- **AC-9:** Testable — `ls skills/*.md` returns empty or file-not-found (no flat files at skills/ root).
- **AC-10:** Testable — `ls -la ~/.claude/skills/plan-feature/SKILL.md` exits 0 and returns a non-empty file.
- **AC-11:** Testable — `ls -la ~/.claude/rules` shows a directory (not a symlink — `test -L ~/.claude/rules` exits non-zero; `test -d ~/.claude/rules` exits 0).
- **AC-12:** Testable — inspect install.sh source for the conditional guard `if [ -z "$CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" ]`; verify reminder message names `.bashrc` and `.zshrc`.
- **AC-13:** Testable — parse `settings.local.json`; assert the allow-list entries include `git status`, `git log`, `git diff`, `git worktree`, `ls`.
- **AC-14:** Testable — grep the bootstrap skill for `docs/sessions/retros/` in the `mkdir -p` command.
- **AC-15:** Testable — grep the bootstrap skill for `### 6. Create rules directory (optional)` and `mkdir -p .claude/rules`.
- **AC-16:** Testable — grep `skills/execute-plan/SKILL.md` for `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=true` and for a fallback/sequential-execution instruction.
- **AC-16b:** Testable — `grep -r "skills/.*\.md" .` (excluding SKILL.md paths) returns zero matches.
- **AC-17:** Testable — `git log --oneline -- docs/bmad-comparison.md` returns at least one commit.
- **AC-18:** Testable — grep `docs/mcp-catalog.md` for `## hytale-rag` and for each of the listed tool names.

All ACs are objectively verifiable. No subjective language ("should feel fast", "should be intuitive") appears in any criterion.

### Contradictions Check

No contradictions found between spec, arch-review, and ux-review after the spec update.

- The arch-review's concern about `Write` being absent from AC-7 is now resolved in the spec.
- The ux-review's characterization of AC-7 as "read-only" reflects the pre-fix draft; the updated spec is authoritative and consistent.
- The arch-review's Parallelisation Map is consistent with the spec's zone list and AC ordering. The sequencing rules (AC-8 before AC-9, AC-16 after AC-8, AC-7/AC-5 in a single pass) are compatible with the spec's acceptance criteria.

### Shared Packages

No shared packages exist in this repo (confirmed in spec under "Shared Packages" and in the arch-review). No sequencing plan is required.

### Remaining Minor Observations (non-blocking)

**Observation 1: Claude Code directory-traversal assumption.**
The spec asserts that the directory-based skills layout (`skills/{name}/SKILL.md`) is "canonical format as of March 2026" without citing a source. The arch-review flagged this as a risk in ADR-001 and recommended verification before marking AC-10 done. This is not a spec defect — the implementer should verify Claude Code's skill loader behavior before executing AC-8/AC-9, as called out in ADR-001.

**Observation 2: AC-16b grep pattern precision.**
AC-16b's example grep pattern (`skills/plan-feature.md`) covers the common case but does not specify whether the grep should also catch references using relative paths or full absolute paths. The implementer should run: `grep -r "skills/[^/]*.md" . --include="*.md" --include="*.sh"` to cover both cases. This is an implementation detail, not a spec defect.

---

## Verdict

GO

Both arch-review and ux-review CHANGES-NEEDED items are resolved in the updated spec. All 19 acceptance criteria (AC-1 through AC-18 plus AC-16b) are verifiable as code assertions. No hidden decisions remain. No contradictions exist between the three documents. Shared packages are absent. The Parallelisation Map in the arch-review is coherent and consistent with the spec.
