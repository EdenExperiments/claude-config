---
name: plan-feature
description: Full 5-phase planning pipeline. Run this skill when a new feature is requested. Produces a reviewed, gateway-approved spec and implementation plan before any code is written.
---

# plan-feature Skill

Run this skill when a feature is requested. Do not write any code until Phase 5 (or the Quick Path) produces plan.md and the orchestrator has run parallel-session.

## Phase 0 — Scale Check

Answer all four questions before starting:

1. Is this a **bug fix, typo, copy change, or config tweak** — NOT a new feature or new behaviour?
2. Will it touch **≤3 files** total?
3. Does it require **NO new API endpoints, routes, or schema columns**?
4. Does it touch **NO shared `packages/` files**?

**If any answer is "no" or "maybe" → use the Full Pipeline (Phase 1 below). Do not try to force it into the Quick Path.**

If ALL four are an unambiguous "yes" → use the Quick Path below.

---

### Quick Path (small tasks only — all 4 checks must be YES)

1. **Write a mini-spec** (5–10 lines max) directly in the session — no file needed:
   - What: one sentence describing the change
   - Why: one sentence (bug report, user feedback, etc.)
   - ACs: 2–4 assertions only (e.g., "clicking X does Y", "field Z accepts empty string without error")
   - Files to change: explicit list (≤3 files)

2. **Pause and check for hidden complexity.** Ask yourself: does writing the mini-spec reveal any ambiguity, side effects, or unknowns? If yes — abort Quick Path, use Full Pipeline.

3. **Implement directly.** For a ≤3-file change with clear ACs, the orchestrator or a single specialist agent can implement inline. No T1 tester dispatch needed for trivial one-liner fixes, but write at least 1 test assertion for any logic change.

4. **Quick review.** After implementing, re-read the 2–4 ACs and confirm each is met. No gateway.md needed.

5. **Commit and done.** No session file, no worktree, no plan.md needed for Quick Path.

**Abort to Full Pipeline immediately if:**
- The implementation touches a 4th file
- A schema or API change turns out to be needed
- Any AC cannot be verified with certainty
- The fix introduces a new behaviour (not just restoring a broken one)

---

## Phase 1 — Spec Draft (Orchestrator)

Input: feature request or user story
Output: `docs/specs/YYYY-MM-DD-{feature}/spec.md` tagged DRAFT

Steps:
1. Read `CLAUDE.md` and any related existing specs or decisions
2. Clarify requirements, edge cases, and acceptance criteria with the user
   — every AC must be a verifiable assertion (e.g., "POST /skills returns 201 with id field")
   — "it should feel fast" is NOT a valid AC
3. Identify which zones (directory paths) will be touched
4. Identify any `packages/*` files that must change
5. Write spec.md to `docs/specs/YYYY-MM-DD-{feature}/spec.md`

## Phase 2 — Architecture Review (dispatch Architect agent)

Input: spec.md
Output: `docs/specs/YYYY-MM-DD-{feature}/arch-review.md`

Dispatch the architect agent. Wait for arch-review.md.

If CHANGES-NEEDED: update spec.md per architect's notes, re-dispatch architect.
If APPROVED: proceed to Phase 3.

## Phase 3 — UX Review (dispatch UX agent)

Input: spec.md
Output: `docs/specs/YYYY-MM-DD-{feature}/ux-review.md`

Dispatch the ux agent. Wait for ux-review.md.

If CHANGES-NEEDED: update spec.md per UX notes, re-dispatch ux agent.
If APPROVED: proceed to Phase 4.

## Phase 4 — Spec Gateway (dispatch Reviewer agent)

Input: spec.md + arch-review.md + ux-review.md
Output: `docs/specs/YYYY-MM-DD-{feature}/gateway.md`

Dispatch the reviewer agent in spec-gate mode. Wait for gateway.md.

If NO-GO: fix specific items listed in gateway.md, re-run from Phase 2 if arch/UX changes needed.
If GO: proceed to Phase 5.

## Phase 5 — Implementation Plan (Orchestrator)

Input: spec.md (APPROVED) + arch-review.md (Parallelisation Map)
Output: `docs/plans/YYYY-MM-DD-{feature}/plan.md`

Steps:
1. Create `docs/plans/YYYY-MM-DD-{feature}/` directory
2. Write plan.md with numbered tasks and assigned owners:
   - T1: tester — write failing tests from spec ACs
   - T2: backend — implement against T1 tests
   - T3: frontend — implement against T1 tests
   - T4: reviewer — code gate review
3. Apply Parallelisation Map from arch-review.md:
   — sequence shared-package tasks before T2/T3
   — mark which tasks can run in parallel
4. T1 ALWAYS comes before T2 and T3
5. After writing plan.md: run the `parallel-session` skill to register zone + create worktree
6. Then run the `execute-plan` skill
