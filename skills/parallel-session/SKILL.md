---
name: parallel-session
description: Register your session zone and create a git worktree. Run this after plan-feature Phase 5 produces plan.md, before execute-plan. Prevents conflicts between simultaneous Opus sessions.
---

# parallel-session Skill

Run this skill AFTER plan-feature produces plan.md, BEFORE execute-plan.

## Zone Overlap Algorithm

Two sessions overlap if, for any path A (this session) and path B (other session):
- A starts with B (B is a prefix of A), OR
- B starts with A (A is a prefix of B)

`packages/*` is always a conflict zone — declare any shared package changes explicitly.

## Steps

### On Session Start

1. **Write your session file** (unique filename — no write conflict between sessions)

   Create `docs/sessions/{feature-slug}-active.md`:
   ```yaml
   feature: {feature-slug}
   worktree: plan-{feature-slug}
   paths:
     - {path/to/zone/1/}
     - {path/to/zone/2/}
   shared-packages: []   # list specific packages/* files if needed, else empty
   started: {ISO8601 timestamp}
   last-updated: {ISO8601 timestamp}
   ```

2. **Wait 2 seconds** (allows any near-simultaneous session to write)

3. **Read all session files**
   ```bash
   ls docs/sessions/*-active.md
   ```
   Read each one.

4. **Run overlap check** against each other session file
   - Apply prefix algorithm above
   - Also check `shared-packages` fields for package-level conflicts

5. **If overlap found**: delete your session file, report the conflict to the user. Stop.

6. **If no overlap**: continue.

7. **Create worktree**
   ```bash
   git worktree add -b plan-{feature-slug} ../plan-{feature-slug} main
   cd ../plan-{feature-slug}
   ```

8. **Rebase from main**
   ```bash
   git rebase main
   ```

### Rebase Checkpoints

Update `last-updated` in your session file at each of these points:
- Before dispatching T1
- Before dispatching T2/T3
- After any shared-package task merges to main
- Before final merge

### Shared Package Changes

If `shared-packages` is non-empty:
1. Create a sub-branch for shared-package work (off your feature worktree):
   ```bash
   git checkout -b plan-{feature-slug}--shared
   ```
2. Complete shared-package changes on this sub-branch and commit.
3. Merge to main:
   ```bash
   git checkout main && git merge plan-{feature-slug}--shared
   ```
4. Delete the sub-branch: `git branch -d plan-{feature-slug}--shared`
5. Rebase all active worktrees from main
6. Then proceed with T2/T3 dispatch

### On Session End

1. Delete `docs/sessions/{feature-slug}-active.md`
2. Remove worktree: `git worktree remove ../plan-{feature-slug}`

## Stale Session Recovery

If another session file has `last-updated` older than 8 hours:
1. Check the worktree branch for recent commits: `git log plan-{stale-feature} --since="8 hours ago"`
2. If no recent commits: the session was interrupted
3. Delete the stale session file
4. Log to `docs/sessions/abandoned.md`: `{date} | {feature} | reclaimed (stale — no commits in 8h)`
5. Proceed with your own session registration
