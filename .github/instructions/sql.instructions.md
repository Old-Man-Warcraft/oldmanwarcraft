---
description: "Use when editing SQL files, database updates, world/auth/characters changes, SAI data, or module SQL. Covers pending SQL placement, safe update patterns, and AzerothCore SQL conventions."
name: "AzerothCore SQL Instructions"
applyTo: "data/sql/**/*.sql, modules/**/data/sql/**/*.sql"
---
# SQL Guidelines

- Start by placing each new SQL change in the correct pending update folder: `data/sql/updates/pending_db_auth/`, `data/sql/updates/pending_db_characters/`, or `data/sql/updates/pending_db_world/`.
- Do not edit base SQL or merged SQL history unless the task explicitly requires it.
- Keep each change scoped to the correct database: `acore_auth`, `acore_characters`, or `acore_world`.
- Follow AzerothCore SQL conventions within that file: use backticks for identifiers, place `DELETE` before `INSERT`, and preserve the style already used in nearby update files.
- When editing module SQL, use the module's standard SQL locations, such as paths documented by the module or its existing `data/sql/` tree. Avoid optional or destructive helper SQL unless the task explicitly asks for it.

See [data/sql/updates/README.md](../../data/sql/updates/README.md) and [CLAUDE.md](../../CLAUDE.md) for full project context.