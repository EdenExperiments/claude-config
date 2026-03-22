# Implementation Plan: repo-modernization

**Spec:** docs/specs/2026-03-21-repo-modernization/spec.md
**Gateway:** GO — docs/specs/2026-03-21-repo-modernization/gateway.md
**Date:** 2026-03-21

---

## Task Summary

| ID | Owner | Status | Description |
|----|-------|--------|-------------|
| T1 | tester | pending | Write failing verification checks for all 19 ACs |
| T2 | backend | pending | Implement all content changes (skills, agents, README, CLAUDE.md, install.sh, settings) |
| T3 | backend | pending | Docs updates + migration verification (mcp-catalog, bmad-commit, flat-path scan) |
| T4 | reviewer | pending | Code gate review |

Note: No frontend agent needed — this is a config-only repo. T3 covers the independent docs/verification tasks that can run after T2 completes AC-8/AC-9.

---

## T1 — Write Failing Verification Checks

**Owner:** tester
**Prerequisite:** none
**Done condition:** `docs/plans/2026-03-21-repo-modernization/T1-checks.md` exists and lists a runnable command for each AC that currently fails (i.e., the AC is not yet met)

Write a verification command for each AC. These commands must be runnable after T2 to confirm each AC passes.

```
File: docs/plans/2026-03-21-repo-modernization/T1-checks.md
```

### Per-AC verification commands

**AC-1** (README lists all 10 commands):
```bash
for cmd in plan-feature execute-plan what-next correct-course abandon-feature parallel-session improve tdd-first use-context7 bootstrap; do
  grep -q "$cmd" README.md || echo "FAIL: $cmd missing from README"
done
echo "AC-1: PASS (if no FAIL lines above)"
```

**AC-2** (README documents Agent Teams flag):
```bash
grep -q "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" README.md && echo "AC-2: PASS" || echo "AC-2: FAIL"
```

**AC-3** (README documents .claude/rules/ pattern):
```bash
grep -q "rules" README.md && echo "AC-3: PASS" || echo "AC-3: FAIL"
```

**AC-4** (CLAUDE.md exists with required sections):
```bash
[ -f CLAUDE.md ] || { echo "AC-4: FAIL (file missing)"; exit 1; }
for section in "purpose" "zone" "agents" "docs/"; do
  grep -qi "$section" CLAUDE.md || echo "AC-4: FAIL (missing: $section)"
done
echo "AC-4: PASS (if no FAIL lines)"
```

**AC-5** (maxTurns in all 4 agent frontmatters):
```bash
for agent in orchestrator architect reviewer ux; do
  grep -q "maxTurns" agents/$agent.md && echo "AC-5 $agent: PASS" || echo "AC-5 $agent: FAIL"
done
```

**AC-6** (ux.md Read/Write Contract outside code fence):
```bash
# The section headings must appear as top-level markdown lines, not inside a fence
python3 -c "
import re, sys
content = open('agents/ux.md').read()
# Find all code blocks
blocks = re.findall(r'\`\`\`.*?\`\`\`', content, re.DOTALL)
for block in blocks:
    if 'Read/Write Contract' in block or 'Reads:' in block:
        print('AC-6: FAIL (Read/Write Contract is inside a code block)')
        sys.exit(1)
print('AC-6: PASS')
"
```

**AC-7** (architect and reviewer have tools whitelist; includes Write, excludes Edit/Bash):
```bash
for agent in architect reviewer; do
  grep -q "tools:" agents/$agent.md || { echo "AC-7 $agent: FAIL (no tools field)"; continue; }
  grep -q "Write" agents/$agent.md && echo "AC-7 $agent Write: PASS" || echo "AC-7 $agent Write: FAIL"
  grep -q '"Edit"' agents/$agent.md && echo "AC-7 $agent Edit: FAIL (Edit should be excluded)" || echo "AC-7 $agent Edit: PASS"
  grep -q '"Bash"' agents/$agent.md && echo "AC-7 $agent Bash: FAIL (Bash should be excluded)" || echo "AC-7 $agent Bash: PASS"
done
```

**AC-8** (all 10 skills in directory format):
```bash
for skill in plan-feature execute-plan tdd-first use-context7 parallel-session abandon-feature new-project-bootstrap what-next correct-course improve; do
  [ -f "skills/$skill/SKILL.md" ] && echo "AC-8 $skill: PASS" || echo "AC-8 $skill: FAIL"
done
```

**AC-9** (no flat skill .md files remain at skills/ root):
```bash
flat=$(ls skills/*.md 2>/dev/null | wc -l)
[ "$flat" -eq 0 ] && echo "AC-9: PASS" || echo "AC-9: FAIL ($flat flat files remain)"
```

**AC-10** (symlink resolves to plan-feature/SKILL.md):
```bash
ls -la ~/.claude/skills/plan-feature/SKILL.md && echo "AC-10: PASS" || echo "AC-10: FAIL"
```

**AC-11** (install.sh creates ~/.claude/rules):
```bash
grep -q "rules" install.sh && echo "AC-11: PASS" || echo "AC-11: FAIL"
```

**AC-12** (install.sh conditional Agent Teams reminder with .bashrc/.zshrc):
```bash
grep -q "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" install.sh && echo "AC-12a: PASS" || echo "AC-12a: FAIL"
grep -q "bashrc\|zshrc" install.sh && echo "AC-12b: PASS" || echo "AC-12b: FAIL"
```

**AC-13** (settings.local.json includes git status/log/diff/worktree and ls):
```bash
for cmd in "git status" "git log" "git diff" "git worktree" "Bash(ls"; do
  grep -q "$cmd" .claude/settings.local.json && echo "AC-13 '$cmd': PASS" || echo "AC-13 '$cmd': FAIL"
done
```

**AC-14** (new-project-bootstrap includes docs/sessions/retros/ in mkdir):
```bash
grep -q "sessions/retros" skills/new-project-bootstrap/SKILL.md && echo "AC-14: PASS" || echo "AC-14: FAIL"
```

**AC-15** (new-project-bootstrap has rules directory step):
```bash
grep -q "rules directory" skills/new-project-bootstrap/SKILL.md && echo "AC-15a: PASS" || echo "AC-15a: FAIL"
grep -q "mkdir -p .claude/rules" skills/new-project-bootstrap/SKILL.md && echo "AC-15b: PASS" || echo "AC-15b: FAIL"
```

**AC-16** (execute-plan has Prerequisites with Agent Teams flag + fallback):
```bash
grep -q "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" skills/execute-plan/SKILL.md && echo "AC-16a: PASS" || echo "AC-16a: FAIL"
grep -q "sequential\|single-agent\|fallback" skills/execute-plan/SKILL.md && echo "AC-16b: PASS" || echo "AC-16b: FAIL"
```

**AC-16b** (no flat-path references to old skill paths):
```bash
count=$(grep -r "skills/[a-z-]*\.md" . --include="*.md" --include="*.sh" | grep -v "Binary\|docs/plans\|docs/specs" | wc -l)
[ "$count" -eq 0 ] && echo "AC-16b: PASS" || echo "AC-16b: FAIL ($count references found)"
```

**AC-17** (bmad-comparison.md committed):
```bash
git ls-files docs/bmad-comparison.md | grep -q "bmad-comparison" && echo "AC-17: PASS" || echo "AC-17: FAIL"
```

**AC-18** (mcp-catalog.md has hytale-rag entry):
```bash
grep -q "hytale-rag" docs/mcp-catalog.md && echo "AC-18: PASS" || echo "AC-18: FAIL"
```

---

## T2 — Content Implementation

**Owner:** backend (general implementation agent)
**Prerequisite:** T1 done
**Parallelisation:** All items within T2 are independent EXCEPT: AC-8 must complete before AC-9; AC-16 requires AC-8 to complete first (file must exist at new path)
**Done condition:** All T2 ACs pass their T1 verification commands; changes committed to worktree

### Files to change

#### 1. Skills migration — AC-8, AC-9 (do first; sequenced)

For each of the 10 skills, create the directory and SKILL.md, then delete the flat file:
```
skills/plan-feature/SKILL.md          ← from skills/plan-feature.md
skills/execute-plan/SKILL.md          ← from skills/execute-plan.md
skills/tdd-first/SKILL.md             ← from skills/tdd-first.md
skills/use-context7/SKILL.md          ← from skills/use-context7.md
skills/parallel-session/SKILL.md      ← from skills/parallel-session.md
skills/abandon-feature/SKILL.md       ← from skills/abandon-feature.md
skills/new-project-bootstrap/SKILL.md ← from skills/new-project-bootstrap.md
skills/what-next/SKILL.md             ← from skills/what-next.md
skills/correct-course/SKILL.md        ← from skills/correct-course.md
skills/improve/SKILL.md               ← from skills/improve.md
```

Step: `mkdir -p skills/{name}` for each, copy content, then `git rm skills/{name}.md`

**AC-16 edit (execute-plan):** After migrating `skills/execute-plan/SKILL.md`, add a `## Prerequisites` section at the top of the skill body (before `# execute-plan Skill`):
```markdown
## Prerequisites

Agent Teams mode requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=true` to be set in your environment. Without it, `spawnTeam` is unavailable.

**Fallback (no Agent Teams):** Run T1, T2, and T3 sequentially in a single session — dispatch each specialist sub-agent in sequence, wait for completion, then proceed to the next step.
```

**AC-14 + AC-15 edit (new-project-bootstrap):** After migrating to `skills/new-project-bootstrap/SKILL.md`:
- In Step 3 "Create docs/ structure", change the `mkdir -p` command to include `docs/sessions/retros/`
- Add Step 6 "Create rules directory (optional)" after Step 5

#### 2. Agent files — AC-5, AC-6, AC-7 (apply per-file in one pass each)

`agents/orchestrator.md` — add `maxTurns: 20` to frontmatter
`agents/architect.md` — add `maxTurns: 10` and `tools: [Read, Grep, Glob, WebSearch, WebFetch, Write]` to frontmatter
`agents/reviewer.md` — add `maxTurns: 10` and `tools: [Read, Grep, Glob, WebSearch, WebFetch, Write]` to frontmatter
`agents/ux.md` — add `maxTurns: 10` to frontmatter; fix Read/Write Contract fence bug (move section outside code block)

#### 3. README.md — AC-1, AC-2, AC-3

- Expand Commands table to list all 10 slash commands
- Add "Agent Teams" section documenting `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=true` requirement
- Add `.claude/rules/` section explaining the modular rules pattern

#### 4. CLAUDE.md (new file) — AC-4

Create `CLAUDE.md` at repo root with: project purpose, zone map, global agents list, docs/ pointer.

#### 5. install.sh — AC-11, AC-12

- Add `mkdir -p ~/.claude/rules` after `mkdir -p ~/.claude/teams`
- Add conditional Agent Teams reminder at end of script

#### 6. settings.local.json — AC-13

Expand allow rules to include: `git status`, `git log`, `git diff`, `git worktree`, `ls`

---

## T3 — Docs Updates and Migration Verification

**Owner:** backend
**Prerequisite:** T2 done (AC-8/AC-9 must be complete before flat-path scan)
**Done condition:** AC-16b, AC-17, AC-18 pass their verification commands; committed to worktree

### Tasks

1. **AC-16b — Flat-path reference scan:** Run the AC-16b grep command. Fix any references found. Confirm zero matches.

2. **AC-17 — Commit bmad-comparison.md:** `git add docs/bmad-comparison.md` then commit per Commit Strategy item 6.

3. **AC-18 — Add hytale-rag to mcp-catalog.md:** Append an `## hytale-rag` section documenting purpose, tool names, and which agents use it.

---

## T4 — Code Gate Review

**Owner:** reviewer
**Prerequisite:** T2 + T3 done
**Done condition:** `docs/specs/2026-03-21-repo-modernization/review.md` written; verdict GO

Reviewer reads: this plan.md, T1-checks.md, and all source files in the "Files Changed" sections of T2 and T3.

Verify:
- All 19 ACs pass their T1 verification commands
- No regressions (flat files gone, directory files present, symlink resolves)
- Skills content preserved accurately (migration copied, not mangled)
- Breaking change callout (AC-7) is clear in the agent files

---

## Commit Strategy

Single commit per logical group:
1. Skills migration (T2 — AC-8/9): `chore: migrate skills to directory format`
2. Agent modernisation (T2 — AC-5/6/7): `chore: modernise agent frontmatter (maxTurns, tools whitelist, ux bug fix)`
3. README + CLAUDE.md (T2 — AC-1/2/3/4): `docs: rewrite README and add repo CLAUDE.md`
4. install.sh + settings (T2 — AC-11/12/13): `chore: update install.sh and settings for modern Claude Code`
5. execute-plan + new-project-bootstrap (T2 — AC-14/15/16): `feat: add Agent Teams prerequisites and rules directory step`
6. Docs + verification (T3 — AC-16b/17/18): `docs: add hytale-rag to mcp-catalog and commit bmad-comparison`
