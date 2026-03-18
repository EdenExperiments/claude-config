---
name: plan-feature
description: Full 5-phase planning pipeline. Run this skill when a new feature is requested. Produces a reviewed, gateway-approved spec and implementation plan before any code is written.
---

# plan-feature Skill

Run this skill when a feature is requested. Do not write any code until Phase 5 produces plan.md and the orchestrator has run parallel-session.

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
