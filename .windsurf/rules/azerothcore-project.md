---
trigger: always_on
description: Old Man Warcraft dev realm — AzerothCore 3.3.5a context, docs pointer, PR habits
---

# AzerothCore (Old Man Warcraft)

This tree is **AzerothCore WotLK 3.3.5a** (GPL v2). Treat `CLAUDE.md` as the canonical build layout, CMake flags, DB names, and commit format.

## Defaults for agents

- Prefer **minimal diffs**; do not refactor unrelated code.
- **C++**: 4 spaces, no tabs, wrap near 80 columns, `{}`-style logging; match surrounding style.
- **Build**: do not run full builds unless the user asks (see `CLAUDE.md`).
- **SQL**: new changes go under `data/sql/updates/pending_db_*` only; never edit merged update files under `data/sql/updates/db_*` outside pending.
- **Disclose** AI assistance in PR text when your team requires it.

## Where things live

- Core gameplay: `src/server/game/`
- Content scripts: `src/server/scripts/` (+ regional `*_script_loader.cpp`)
- Handlers: `src/server/game/Handlers/`
- Modules: `modules/<name>/` (each module has its own `CMakeLists.txt`)

When work touches a specialized area, the matching scoped rule below also applies.
