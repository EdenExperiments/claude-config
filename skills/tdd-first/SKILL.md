---
name: tdd-first
description: TDD discipline for the tester agent. Load this skill at the start of every T1 task. Writes failing tests from spec acceptance criteria before any implementation exists.
---

# tdd-first Skill

You are writing tests. You are NOT writing implementation code. If you feel the urge to write implementation, stop and message the backend or frontend agent instead.

## Steps

1. **Read project test conventions**
   Open 2–3 existing test files (specified in your agent definition) and note:
   - File naming pattern (e.g., `*.test.tsx`, `*_test.go`)
   - Required wrappers (e.g., `QueryClientProvider`, test DB setup, `t.Parallel()`)
   - Mock patterns (e.g., vi.mock is hoisted — factory cannot reference outer variables)
   - Assertion style (e.g., `expect(x).toBe(y)` vs `assert.Equal(t, y, x)`)

2. **Read spec acceptance criteria only**
   Open `docs/specs/YYYY-MM-DD-{feature}/spec.md`.
   Read only the acceptance criteria section.
   Do NOT open any implementation files.

3. **Map each AC to test cases**
   For each AC, define one or more named test cases.
   Prefer one behavior per test.
   Use descriptive names: `"POST /skills/{id}/xp returns 201 with updated level"`.

4. **Write actual runnable test code to the worktree**
   Not a prose description — real, runnable test code.
   Tests must fail because the implementation does not exist yet.
   Follow the conventions from step 1 exactly.

5. **Verify tests fail (red state)**
   Run the test suite. Confirm the new tests fail.
   If they pass — something is wrong (implementation exists or test is wrong). Fix before continuing.

6. **Write T1-tests.md manifest**
   Create `docs/specs/YYYY-MM-DD-{feature}/T1-tests.md`:

   ```markdown
   ## Test Files Written
   - path/to/test-file.tsx
   - path/to/test_file_test.go

   ## Coverage Map
   - AC-1 ([AC text]) → test-file.tsx:12
   - AC-2 ([AC text]) → test-file.tsx:28
   - AC-3 ([AC text]) → test_file_test.go:45
   ```

7. **Commit**
   ```bash
   git add [test files] docs/specs/YYYY-MM-DD-{feature}/T1-tests.md
   git commit -m "test: failing tests for [feature] from spec ACs"
   ```

8. **Signal T1 done via Agent Teams task state**

9. **Never write implementation code**
   If you feel the urge to write a function body, handler, or component — stop.
   Use SendMessage to the backend or frontend agent to describe what needs building.
   Your output is failing tests and the T1-tests.md manifest. Nothing else.

## Task State Rules

- `done`: tests committed, verified failing (red state confirmed)
- `blocked`: one or more ACs cannot be expressed as a code assertion — list which ones in a message to orchestrator

## Red Flags — Stop and Report Before Writing

- AC that says "should be fast" / "should feel smooth" / "should look good" — not testable
- Required test infrastructure missing (no mock for a critical dependency)
- Test would duplicate existing coverage exactly
