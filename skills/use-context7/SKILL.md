---
name: use-context7
description: Use Context7 to retrieve up-to-date library documentation. Load this skill before writing any code that uses a third-party library you are not 100% certain about.
---

# use-context7 Skill

## When to Use

Any time you are about to write code that uses a third-party library API and you are not 100% certain the API is correct or current. This includes:

- React hooks and lifecycle
- TanStack Query (useQuery, useMutation options)
- Next.js App Router (server components, routing, cookies)
- chi router (middleware, routing patterns)
- pgx (query patterns, scanning, transactions)
- Supabase JS client (browser auth, realtime) — use `supabase/supabase-js`
- Supabase Go client (server-side auth) — use `supabase-go`
- Vitest (configuration, mocking, setup)
- React Testing Library (queries, user events, async)

If in doubt: use Context7. A 10-second lookup prevents a 20-minute debugging session.

## Steps

1. **Resolve the library ID**

   ```
   mcp__plugin_context7_context7__resolve-library-id
   libraryName: "tanstack/react-query"
   ```

   Returns: `/tanstack/query` (or similar)

2. **Query the specific topic**

   ```
   mcp__plugin_context7_context7__query-docs
   context7CompatibleLibraryID: "/tanstack/query"
   topic: "useQuery options"
   tokens: 3000
   ```

3. **Extract the API pattern you need** from the result.

## Fallback (if Context7 is unavailable or slow)

- Use your training knowledge
- Add this inline comment next to the usage: `// Context7 unavailable — verify against current docs`
- Never block or wait — flag and continue

## Common Library IDs (for speed)

| Library | resolve-library-id input |
|---------|------------------------|
| React | `react` |
| TanStack Query | `tanstack/react-query` |
| Next.js | `next` |
| chi | `go-chi/chi` |
| pgx | `jackc/pgx` |
| Vitest | `vitest` |
| React Testing Library | `testing-library/react` |
| Tailwind CSS | `tailwindcss` |
| Supabase JS client (frontend) | `supabase/supabase-js` |
| Supabase Go client (backend) | `supabase-go` |
