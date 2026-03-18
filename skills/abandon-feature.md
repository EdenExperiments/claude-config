---
name: abandon-feature
description: Clean up a cancelled, blocked, or interrupted feature. Archives spec and plan, removes worktree and session file, logs the abandonment.
---

# abandon-feature Skill

Use when a feature is: cancelled by the user, blocked indefinitely, superseded by another approach, or the session was interrupted and will not be resumed.

## Steps

1. **Archive the spec directory**
   ```bash
   mv docs/specs/YYYY-MM-DD-{feature}/ docs/specs/archived/YYYY-MM-DD-{feature}/
   ```

2. **Archive the plan directory**
   ```bash
   mv docs/plans/YYYY-MM-DD-{feature}/ docs/plans/archived/YYYY-MM-DD-{feature}/
   ```

3. **Delete the session file**
   ```bash
   rm -f docs/sessions/{feature-slug}-active.md
   ```

4. **Remove the worktree (if it exists)**
   ```bash
   git worktree list | grep plan-{feature-slug}
   # If present:
   git worktree remove ../plan-{feature-slug}
   ```

5. **Delete the branch (safe — warns on unmerged commits)**
   ```bash
   git branch -d plan-{feature-slug}
   ```
   If there are unmerged commits you want to keep, use `git branch -m plan-{feature-slug} archived-{feature-slug}` instead.

6. **Log the abandonment**
   Append to `docs/sessions/abandoned.md`:
   ```
   {YYYY-MM-DD} | {feature-slug} | {reason: cancelled / blocked / superseded / interrupted}
   ```

7. **Commit the cleanup**
   ```bash
   git add docs/
   git commit -m "chore: archive {feature-slug} ({reason})"
   ```
