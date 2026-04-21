---
trigger: glob
description: SQL update workflow for acore_world, characters, auth
globs:
  - data/sql/**/*.sql
---

# AzerothCore SQL

- **Pending only**: place new/revised statements in `data/sql/updates/pending_db_world/`, `pending_db_characters/`, or `pending_db_auth/` with a **new** descriptive filename (project convention: random/unique names until merge).
- Do **not** modify files already under `data/sql/updates/db_*` (merged history).
- Prefer **idempotent** patterns where the updater allows (e.g. `DELETE` + `INSERT`, or documented `UPDATE` guards). Follow existing files in the same folder for style.
- Match **column order** and types to the live base schema in `data/sql/base/db_*` when unsure.
- Data-only fixes: keep scope to affected rows; avoid broad `UPDATE` without a `WHERE` clause.
