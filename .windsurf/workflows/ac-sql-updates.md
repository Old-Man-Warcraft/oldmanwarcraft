---
description: Author AzerothCore SQL pending updates for acore_world, characters, or auth
---

# AzerothCore SQL updates

Use when adding or fixing quests, creatures, loot, spells data, SAI, or any table change; when the user mentions `pending_db_*` or database patches.

## Before writing SQL

1. Identify target DB: `world`, `characters`, or `auth`.
2. Open similar **already merged** files under `data/sql/updates/db_*` only as **style reference**, not to edit.
3. Confirm column names against `data/sql/base/db_<name>/` when needed.

## File placement

| Database    | Pending directory                              |
|-------------|------------------------------------------------|
| world       | `data/sql/updates/pending_db_world/`           |
| characters  | `data/sql/updates/pending_db_characters/`      |
| auth        | `data/sql/updates/pending_db_auth/`            |

Use one logical change per file when possible. Filename: unique, descriptive (repository uses assorted naming until merge).

## Checklist

- [ ] Correct `pending_db_*` folder
- [ ] Narrow `WHERE` clauses; no accidental full-table updates
- [ ] Ordering and types consistent with base schema
- [ ] No edits to non-pending `data/sql/updates/db_*` paths
