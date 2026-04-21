---
description: "Use when writing AzerothCore SQL updates, database fixes, schema-adjacent data changes, or pending_db_* migrations under data/sql/. Covers pending update rules, idempotent patterns, and safety constraints."
name: "AzerothCore SQL"
applyTo: "data/sql/**/*.sql"
---
# AzerothCore SQL

- Place new or revised statements only in `data/sql/updates/pending_db_world/`, `pending_db_characters/`, or `pending_db_auth/` using a new descriptive filename.
- Do not modify merged history under `data/sql/updates/db_*`.
- Prefer idempotent patterns when supported, such as guarded updates or `DELETE` plus `INSERT`.
- Match column order and types to the base schema in `data/sql/base/db_*` when unsure.
- Keep data fixes tightly scoped and avoid broad `UPDATE` statements without a `WHERE` clause.
