---
name: improve
description: Synthesise retro notes from completed features into targeted skill and agent improvements. Run manually after 3–5 features. Proposes changes for human approval — never edits files autonomously.
---

# improve Skill

## When to Use

Run manually when you want to iterate on the agent system. Suggested cadence: after 3–5 merged features. Do not run automatically.

## Steps

### 1. Find unprocessed retros

```bash
grep -rl "processed: —" docs/sessions/retros/ 2>/dev/null
```

If no results: "No unprocessed retros found. Run after completing more features." Stop.

### 2. Read all unprocessed retro notes

Read every file returned in step 1. This step has no file count limit — it is the one explicit exception to the ≤4-file read constraint.

### 3. Identify patterns

Group findings across retros. **Single-occurrence issues are ignored** — a pattern requires ≥2 occurrences in the unprocessed batch.

Pattern types to look for:
- Same agent task blocked (T2 or T3 blocked) across multiple features — same root cause
- Same reviewer flag appearing more than once
- Spec-level corrections on multiple features
- Quick Path aborts — task unexpectedly required full pipeline

### 4. Draft proposals

For each pattern:

1. Read the specific skill or agent file it relates to (1 file per pattern)
2. Draft a targeted proposal:
   - **What:** the exact change — add/remove/rewrite a section. Never a full rewrite.
   - **Why:** cite the retro notes that evidence this (e.g. "T2 blocked in 3 of last 4 features — same missing dep")
   - **Size check:** if the proposed addition is >10 lines, identify equivalent content to remove first. Net line count must be neutral or negative unless a whole section is genuinely absent. If a skill file has visibly grown since the last cycle, prefer net-negative edits regardless of individual proposal size.
   - **Generalisability check:** would this change help any future feature, or only this specific one? One-feature-specific guidance is never added.

### 5. Present proposals to user

Present one proposal at a time:

```
## Proposal {N}/{total}

**Target:** `{path/to/file.md}`
**Pattern:** {description of recurring issue}
**Evidence:** {feature slugs and what each showed}

**Proposed change:**
[old text → new text, or "add after line X: ..."]

**Size impact:** +{N} lines / -{N} lines / neutral

Approve? (yes / no / skip)
```

Wait for user response before proceeding to next proposal.

### 6. Apply approved changes

For each approved proposal: edit the target file in `~/claude-config/` with the targeted change.

### 7. Mark retros as processed

In each retro file that was read in step 2, update:
```
processed: —
```
to:
```
processed: {YYYY-MM-DD}
```

### 8. Commit (two separate repos)

In `~/claude-config/` (skill/agent edits):
```bash
cd ~/claude-config
git add .
git commit -m "chore: improve agent system — {one-line summary of changes}"
git push
```

In the project repo (retro processed markers):
```bash
git add docs/sessions/retros/
git commit -m "chore: mark retros processed — {YYYY-MM-DD}"
```

## Hard Constraints

- **One-time events are never added** — ≥2 occurrences required
- **No whole-file rewrites** — targeted section edits only
- **Size gate** — net neutral or negative line count unless a section is genuinely absent
- **Generalisable only** — never add guidance specific to a single feature's implementation
- **Human gate** — every proposal requires explicit approval before applying
- **Validity check** — each proposal must answer yes to: "Would this change have prevented the documented problem?"
