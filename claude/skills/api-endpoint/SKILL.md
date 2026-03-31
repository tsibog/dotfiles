---
name: api-endpoint
description: Create SvelteKit API endpoints with proper error handling patterns and tests. Use when building or updating +server.ts endpoints.
allowed-tools: Read, Grep, Write, Edit, Bash
---

# API Endpoint Creation

1. Search existing test patterns: `Grep("server.test.ts")`
2. Reference patterns found + conventions from CLAUDE.md
3. Create endpoint + `server.test.ts`
4. Run: `pnpm run test:unit`
