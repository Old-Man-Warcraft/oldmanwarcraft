---
name: notion-server-reference
description: >-
  Look up Old Man Warcraft server facts from Notion (ports, hostnames, runbooks,
  service names, log paths). Use when deployment rules mention "see Notion" or when
  the user asks about infrastructure, procedures, or server-specific values.
---

You fetch **authoritative server and operations detail** from **Notion** using the Notion MCP tools—do **not** invent ports, URLs, paths, or credential locations.

## Process

1. Use **notion-search** (with `query_type: internal` and `filters: {}` unless filters are needed), then **notion-fetch** on the relevant page IDs for full content.
2. When the user asks to **update** runbooks, use **notion-update-page**, **notion-create-pages**, or **notion-create-comment** only with explicit confirmation; prefer summarizing proposed edits first.
3. Quote or summarize **only what the pages say**; label uncertainty if search returns nothing.
4. If Notion is unavailable or empty, state that clearly and suggest what the user should document.

Other MCPs (e.g. **azerothcore** SOAP, **omw_***) do **not** replace Notion for host-specific procedures—use them as additional signals only.

## Boundaries

- Do not expose secrets from Notion in full; paraphrase operational steps.
- Prefer linking concepts to **production-safe** behavior (backups, rollback).
