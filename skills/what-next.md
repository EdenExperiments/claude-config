---
name: what-next
description: Get your bearings in the current session. Run when resuming work after an interruption, feeling lost, or unsure what to do next. Reads session state and tells you exactly where you are and what to do.
---

# what-next Skill

Run this skill when you are resuming after an interruption, are unsure of your current position, or have just been dispatched into an active session without context.

## Steps

1. **Find the active session file**

   ```bash
   ls docs/sessions/*-active.md 2>/dev/null
   ```

   - If **none found**: there is no active session. You are between features. Run `plan-feature` to start one, or ask the user which feature to resume.
   - If **multiple found**: list them for the user and ask which to resume.

2. **Read the session file** (1 file)

   Note: feature slug, worktree path, zone paths, last-updated timestamp.

   If `last-updated` is stale (> 8 hours), treat this as a potential interruption — proceed carefully and check git log before assuming state is valid.

   **If `type: quick`** — skip steps 3–4 and report directly:

   ```
   ## Current Session
   Feature: {feature-slug}
   Type: Quick Path
   Files: {files from session file}
   AC summary: {ac-summary from session file}
   Status: {status from session file}

   ## Next action
   [If status = in-progress]: "Verify ACs against {files} then update status to done and commit."
   [If status = done]: "Quick Path complete — no further action needed."
   [If status = aborted]: "Quick Path was aborted — check for a full pipeline session file for this feature."
   ```

   Execute the next action. Do not read plan.md (there is none for Quick Path).

3. **Read the plan** (1 file)

   Read `docs/plans/YYYY-MM-DD-{feature}/plan.md`.

   Find the first task that is NOT marked `done`.

4. **Read one context file** based on current task (1 file max):

   | Current task | Read this |
   |---|---|
   | T1 not started or in progress | `docs/specs/YYYY-MM-DD-{feature}/spec.md` (ACs section only) |
   | T2 or T3 not started | `docs/specs/YYYY-MM-DD-{feature}/T1-tests.md` |
   | Code gate not started | `docs/specs/YYYY-MM-DD-{feature}/T2-backend.md` or `T3-frontend.md` (Status line only) |
   | All tasks done | Nothing — proceed to merge |

5. **Report your position**

   ```
   ## Current Session
   Feature: {feature-slug}
   Worktree: {path}
   Last updated: {timestamp}

   ## Completed
   - [list of done tasks, or "none"]

   ## Current task
   {first non-done task — e.g. "T1: tester writes failing tests"}

   ## Next action
   [One specific sentence — e.g. "Dispatch the tester agent with T1 assignment" or "Rebase from main and re-dispatch backend agent for T2"]

   ## Suggested reads before acting
   [max 2 files that give the most context for the next action]
   ```

6. **Execute the next action** — do not wait for the user unless you hit a blocker or ambiguity.

## If the session file is missing but a worktree exists

```bash
git worktree list
```

If `plan-{feature}` worktrees exist without session files, a session was likely abandoned mid-work. Run the `abandon-feature` skill or re-register via `parallel-session` if you intend to resume.
