# MCP Catalog

Available MCPs and which agents use them.

## context7

**Purpose:** Retrieve up-to-date library documentation and API references.

**Used by:** backend, frontend, tester, architect

**How to use:**
1. Resolve library ID:
   ```
   mcp__plugin_context7_context7__resolve-library-id
   libraryName: "react"
   → returns "/facebook/react"
   ```
2. Query specific topic:
   ```
   mcp__plugin_context7_context7__query-docs
   context7CompatibleLibraryID: "/facebook/react"
   topic: "useEffect dependencies"
   tokens: 3000
   ```

**Common library IDs:**

| Library | Input to resolve-library-id |
|---------|---------------------------|
| React | `react` |
| TanStack Query | `tanstack/react-query` |
| Next.js | `next` |
| chi (Go) | `go-chi/chi` |
| pgx (Go) | `jackc/pgx` |
| Supabase JS client (frontend) | `supabase/supabase-js` |
| Supabase Go client (backend) | `supabase-go` |
| Vitest | `vitest` |
| React Testing Library | `testing-library/react` |
| Tailwind CSS | `tailwindcss` |

**Fallback:** If unavailable — use training knowledge + add `// Context7 unavailable` inline comment. Never block.
---

*Add new MCPs here as they are configured. Include: purpose, which agents use it, usage pattern, fallback.*
