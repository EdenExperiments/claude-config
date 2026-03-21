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

## hytale-rag

**Purpose:** Semantic search over Hytale game data, client code, server code, and documentation. Used for Hytale-specific development work.

**Used by:** backend, frontend, tester (any agent working on Hytale projects)

**Available tools:**

| Tool | What it searches |
|------|-----------------|
| `mcp__hytale-rag__search_hytale_code` | Server-side game code |
| `mcp__hytale-rag__search_hytale_client_code` | Client-side game code |
| `mcp__hytale-rag__search_hytale_docs` | Hytale documentation |
| `mcp__hytale-rag__search_hytale_gamedata` | Game data / assets |
| `mcp__hytale-rag__hytale_code_stats` | Index stats for server code |
| `mcp__hytale-rag__hytale_client_code_stats` | Index stats for client code |
| `mcp__hytale-rag__hytale_docs_stats` | Index stats for docs |
| `mcp__hytale-rag__hytale_gamedata_stats` | Index stats for game data |

**How to use:**
```
mcp__hytale-rag__search_hytale_docs
query: "entity spawning"
→ returns relevant doc chunks
```

**Fallback:** If unavailable — use training knowledge and note `// hytale-rag unavailable` in context. Never block on MCP availability.

---

*Add new MCPs here as they are configured. Include: purpose, which agents use it, usage pattern, fallback.*
