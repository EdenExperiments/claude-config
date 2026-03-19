---
name: execute-plan
description: Execute an approved implementation plan via Agent Teams. Run after plan-feature and parallel-session. Requires gateway.md = GO.
---

# execute-plan Skill

## Agent Teams Primer

Agent Teams are independent Claude Code sessions with their own context windows. They coordinate via:
- A shared task list with file locking (states: pending → in_progress → done / blocked)
- A JSON mailbox in `~/.claude/teams/` for SendMessage peer communication

Use `spawnTeam` to create the team. Assign tasks to teammates. Monitor via task states — do not poll files.

## Steps

1. **Verify prerequisites**
   - Read `docs/plans/YYYY-MM-DD-{feature}/plan.md` (task list)
   - Read `docs/specs/YYYY-MM-DD-{feature}/arch-review.md` (Parallelisation Map)
   - Confirm `docs/specs/YYYY-MM-DD-{feature}/gateway.md` = GO
   - Update `last-updated` in session file

2. **Rebase from main**
   ```bash
   git rebase main
   ```

3. **Dispatch tester → T1**
   - Assign T1 to tester teammate
   - Wait for task state = `done`
   - T1 done means: test code committed to worktree, T1-tests.md manifest exists, tests verified failing
   - Update `last-updated` in session file

4. **Handle shared-package tasks (if any)**
   - If Parallelisation Map lists shared-package changes: dispatch as a standalone task first
   - Merge shared-package changes to main
   - Rebase all active worktrees before continuing

5. **Dispatch backend (T2) and frontend (T3)**
   - Per Parallelisation Map: parallel where allowed, sequential where required
   - Use SendMessage to communicate blockers between teammates
   - Task state = `blocked` means tests are failing — do not wait indefinitely, surface to user
   - Update `last-updated` in session file when both T2 and T3 = done

6. **Rebase from main**

7. **Dispatch reviewer → code gate**
   - Reviewer reads plan.md, T1-tests.md, T2-backend.md, T3-frontend.md
   - Reviewer also reads all source files in `## Files Changed` sections

8. **On GO**
   - Merge worktree to main
   - Write retro note to `docs/sessions/retros/{feature-slug}-retro.md` (see format below)
   - Delete `docs/sessions/{feature-slug}-active.md`
   - `git worktree remove ../{branch}`

### Retro Note Format

Sources to read before writing (already available from this session):
- `docs/plans/YYYY-MM-DD-{feature}/plan.md` — any blocked tasks?
- `docs/specs/YYYY-MM-DD-{feature}/correction.md` — if it exists
- `docs/specs/YYYY-MM-DD-{feature}/review.md` — code gate flags
- `docs/sessions/{feature-slug}-active.md` — metadata (read before deleting)

Write facts only — no analysis:

```
## {feature-slug} — {YYYY-MM-DD}

type: full
corrections: none | 1 spec-level | 1 plan-level | 2 spec-level | etc.
blocks: none | T2 blocked ({reason}) | T3 blocked ({reason})
reviewer-flags: none | "{flag 1}" | "{flag 1}", "{flag 2}"
quick-path-abort: no | yes → {reason}
summary: clean | 1 plan correction | reviewer flagged 2 issues
processed: —
# processed: filled in by the improve skill after synthesis
```

9. **On NO-GO**
   - Read `review.md` findings
   - Re-dispatch specific agent(s) with targeted instructions
   - Re-run from step 5 (or step 3 if tester changes needed)

## Resume Protocol (after interruption)

1. Read `plan.md` — identify which tasks have state `done`
2. Re-enter at the first task that is not `done`
3. Rebase from main
4. Update `last-updated` in session file (or re-run parallel-session if session file was deleted)
