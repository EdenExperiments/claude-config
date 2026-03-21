---
name: correct-course
description: Mid-implementation course correction. Use when a spec AC is wrong, an implementation approach fails, or new information changes the design. Pauses active work and re-routes cleanly without losing progress.
---

# correct-course Skill

## When to Use

- A test reveals the spec AC was stated incorrectly
- An implementation approach fails and a different approach is needed
- New information (user feedback, discovered constraint, dependency change) changes scope
- A plan task sequence is wrong and is blocking progress
- A backend/frontend agent marks a task `blocked` with a root cause that reveals a spec or plan error

## Do NOT use for

- Normal test failures while implementation is in progress — that is expected T1 red state
- Minor implementation details — just fix them inline
- Questions about the spec that the spec already answers

---

## Steps

### 1. Stop active agent dispatches

Do not dispatch new backend, frontend, or tester agents until this skill completes.

### 2. Classify the correction level

**Spec-level** — an AC is wrong, scope changed, or a requirement was misunderstood.
Signals: the spec says X but X turns out to be impossible, wrong, or not what the user wanted.

**Plan-level** — the task sequence or assignments are wrong, but the spec is correct.
Signals: T2 is blocked waiting for something T3 was supposed to do first; a task was assigned to the wrong agent.

**Implementation-level** — a specific file or approach failed, but the task structure and spec are correct.
Signals: the chosen library doesn't support the needed behaviour; a helper function has the wrong signature.

### 3. Write a correction note

Create `docs/specs/YYYY-MM-DD-{feature}/correction.md`:

```markdown
## Date
{YYYY-MM-DD}

## Correction Level
[spec / plan / implementation]

## What Was Wrong
[one paragraph: what the error was and what triggered its discovery]

## New Direction
[one paragraph: what will be done instead]

## Impact on Completed Work
[list any already-done tasks that need revisiting, or "none — completed work is unaffected"]
```

### 4. Route by correction level

**Spec-level correction:**

- Update `spec.md` with the corrected requirement or AC
- If schema or service boundary changed → re-run plan-feature from Phase 2 (arch review)
- If only ACs or scope changed → re-run plan-feature from Phase 4 (gateway only — skip arch/UX if they were already approved and unchanged)
- If T1 tests are now wrong → re-assign T1 to tester with updated spec
- Regenerate affected sections of `plan.md`

**Plan-level correction:**

- Update `plan.md` directly: fix task sequence, dependencies, or agent assignments
- Re-enter `execute-plan` at the first affected task
- No spec changes needed — gateway.md remains valid

**Implementation-level correction:**

- Dispatch a targeted fix to the specific agent with a clear description of what failed and what to try instead
- Re-run from the blocked task in `execute-plan`
- No spec or plan changes needed

### 5. Update the session file

Update `last-updated` in `docs/sessions/{feature-slug}-active.md`.

### 6. Commit the correction note

```bash
git add docs/specs/YYYY-MM-DD-{feature}/correction.md
git commit -m "chore: course correction — {one-line summary of what changed}"
```

### 7. Resume execute-plan

Re-enter `execute-plan` at the correct step based on the correction level.

---

## Repeated corrections

If the same feature requires more than 2 corrections at spec-level, stop and surface to the user. Repeated spec corrections indicate the requirements were not sufficiently understood before implementation started — the spec needs a deeper review pass before continuing.
