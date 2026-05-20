---
name: database-operations
description: Safe database querying, migrations, backups, and content investigation for AzerothCore. Use when writing SQL, querying the world/characters/auth databases, running migrations, investigating creatures/quests/loot/SmartAI/conditions, or taking database snapshots.
---

# Skill: database-operations

**Owner:** Old Man Warcraft
**Version:** 1.0

---

## Purpose

Safe database querying, backup, and migration for AzerothCore MySQL databases
(acore_world, acore_characters, acore_auth).

## Activation

When a task touches any of the following:

- Direct SQL querying or modification of game databases
- Database migrations (applying or creating SQL updates)
- Content investigation: creatures, quests, loot, SmartAI, conditions
- Schema changes, table creation, or index management

## Access

Use **`mysql-remote`** MCP server for database operations.

### Connection
- Tool: `mysql_connection.query`
- Use `acore_world`, `acore_characters`, or `acore_auth` as appropriate

## Safety Rules

### Before Any Write Operation
1. Read the existing data first
2. Backup relevant rows/table with a `CREATE TABLE … AS SELECT …` copy
3. Use transactions for multi-statement changes
4. Test with SELECT before UPDATE/DELETE
5. Verify row counts before and after

### Migration Workflow
1. Check pending migrations: `./acore.sh db-pendings`
2. Apply migrations on test/QA environment first
3. Backup production database before applying
4. Apply one migration file at a time
5. Verify each migration's effect before proceeding

### Common Verification Queries

```sql
-- Check which database a table belongs to
SELECT TABLE_SCHEMA FROM information_schema.TABLES WHERE TABLE_NAME = 'conditions';

-- Verify migration state
SELECT * FROM acore_world.updates ORDER BY name DESC LIMIT 5;
SELECT * FROM acore_characters.updates ORDER BY name DESC LIMIT 5;
SELECT * FROM acore_auth.updates ORDER BY name DESC LIMIT 5;
```

## Content Investigation Patterns

### Creature Investigation
1. `creature_template` → base stats, faction, flags, script name
2. `creature` → spawn locations, map positions
3. `creature_loot_template` → loot drops, chances
4. `creature_equip_template` → equipment
5. `creature_text` → scripted dialogue
6. `smart_scripts` → SmartAI behavior
7. `conditions` → spawn/behavior conditions

### SmartAI Queries
```sql
-- Find SmartAI scripts for a creature
SELECT * FROM acore_world.smart_scripts
WHERE entryorguid = <entry> AND source_type = 0
ORDER BY event_type, event_phase_mask, id;
```

### Conditions Lookup
```sql
-- Find conditions on a loot entry
SELECT * FROM acore_world.conditions
WHERE SourceGroup = <loot_id> AND SourceTypeOrReferenceId = 1;
```

## Migration Types

### Schema Changes
- `ALTER TABLE`, `CREATE TABLE`, `DROP TABLE` — always transactional on InnoDB
- `CREATE INDEX`, `DROP INDEX` — verify index usage afterward

### Data Updates
- INSERT/UPDATE/DELETE — always include WHERE clause
- Batch operations: use transactions and verify counts

### World Content
- New creatures, quests, items, objects
- AI scripts (SmartAI)
- Loot tables and conditions

## Emergency Procedures

### Rollback
- Restore from backup: `mysql < backup.sql`
- Or: `CREATE TABLE copy AS SELECT * FROM original` before changes

### Database Errors
- Check MySQL logs: `docker logs acore-mysql`
- Verify database connection: `mysql_connection.query` with `SELECT 1`

## Reference

For detailed content investigation patterns, see:
- `.clinerules/agents/content-db-investigator.md`
- `.clinerules/rules/database-rules.mdc`
- `.clinerules/rules/conditions-rules.mdc`
- `.clinerules/rules/smartai-scripting.mdc`

Note: The `.clinerules/` directory preserves legacy Cursor IDE references. Use `.clinerules/` for current work.