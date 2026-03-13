---
trigger: model_decision
description: Apply when performing database operations, SQL queries, backups, restores, or modifying acore_world/characters/playerbots/auth databases
---
# Database Operations Rules

## Database Structure

<database_structure>
- **acore_world** (shared): Game content - creature_template, items, quests, spells, SmartAI, loot
- **acore_characters** (realm-specific): Player data - characters, inventory, quests, skills, spells
- **acore_playerbots** (realm-specific): Bot configuration - ai_playerbot_config, strategy, tactics
- **acore_auth** (shared): Account data - accounts, realmlist, permissions
- Test changes on dev realm first before production
- Always backup before major changes
</database_structure>

## Query Best Practices

<query_practices>
- Use indexed columns in WHERE clauses
- Avoid SELECT * - specify needed columns
- Use LIMIT for large result sets
- Use EXPLAIN to analyze query performance
- Wrap multi-table updates in transactions
- Document complex queries with comments
- Verify data integrity after bulk updates
</query_practices>

## Backup & Restore

<backup_restore>
- Backup before any major changes: `mysqldump -uacore -pacore acore_world > backup.sql`
- Backup all databases: `mysqldump -uacore -pacore --all-databases > backup_all.sql`
- Compress backups: `mysqldump ... | gzip > backup.sql.gz`
- Restore: `mysql -uacore -pacore acore_world < backup.sql`
- Restore compressed: `gunzip < backup.sql.gz | mysql -uacore -pacore acore_world`
- Verify restoration: Check row counts match original
</backup_restore>

## Transaction Management

<transactions>
- Use for multi-table updates: START TRANSACTION; ... COMMIT;
- Review changes before COMMIT
- Use ROLLBACK if changes are incorrect
- Never leave transactions open
- Document transaction purpose in comments
</transactions>

## Data Integrity

<data_integrity>
- Check for orphaned creatures: LEFT JOIN creature_template
- Check for orphaned items: Verify in loot tables
- Verify quest prerequisites exist
- Check spell IDs are valid
- Verify NPC entries exist before referencing
- Run ANALYZE TABLE after bulk updates
- Run OPTIMIZE TABLE periodically
</data_integrity>

## Dangerous Operations

<dangerous_operations>
- **Never** modify creature_template directly - use UPDATE_TEMPLATE action
- **Never** delete rows without understanding dependencies
- **Never** change primary keys in existing records
- **Never** modify shared world database during peak hours
- **Never** run unverified bulk UPDATE/DELETE queries
- Always backup before dangerous operations
- Test on dev realm first
</dangerous_operations>

## Common Queries

<common_queries>
- Find creature: `SELECT * FROM creature_template WHERE name LIKE '%name%'`
- Get creature spawns: `SELECT * FROM creature WHERE entry = <id>`
- Find item: `SELECT * FROM item_template WHERE name LIKE '%name%'`
- Find quest: `SELECT * FROM quest_template WHERE title LIKE '%title%'`
- Get SmartAI scripts: `SELECT * FROM smart_scripts WHERE entryorguid = <id>`
- Get loot: `SELECT * FROM creature_loot_template WHERE entry = <id>`
- Get conditions: `SELECT * FROM conditions WHERE sourceEntry = <id>`
</common_queries>

## Maintenance

<maintenance>
- Optimize tables: `OPTIMIZE TABLE creature_template, creature, item_template`
- Analyze tables: `ANALYZE TABLE creature_template, creature, item_template`
- Check table sizes: Query information_schema.tables
- Monitor database growth
- Regular backups (daily minimum)
- Check for duplicate entries
- Verify referential integrity
</maintenance>
