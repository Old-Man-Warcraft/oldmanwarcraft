# Database Operations Guide

## Overview
This guide covers common database operations for AzerothCore development and maintenance.

## Database Structure

### World Database (`acore_world`)
**Shared across all realms**. Contains game content.

**Key Tables**:
- `creature_template`: NPC definitions
- `creature`: NPC spawn points
- `gameobject_template`: Object definitions
- `gameobject`: Object spawn points
- `item_template`: Item definitions
- `quest_template`: Quest definitions
- `spell_dbc`: Spell definitions
- `spell_proc`: Spell proc configuration
- `smart_scripts`: SmartAI scripts
- `conditions`: Conditional logic
- `creature_loot_template`: Creature loot drops
- `gameobject_loot_template`: Object loot drops

### Character Database (`acore_characters`)
**Realm-specific**. Contains player data.

**Key Tables**:
- `characters`: Player characters
- `character_inventory`: Player inventory
- `character_queststatus`: Quest progress
- `character_skills`: Skill levels
- `character_spells`: Known spells
- `character_aura`: Active auras

### Playerbots Database (`acore_playerbots`)
**Realm-specific**. Contains bot configuration.

**Key Tables**:
- `ai_playerbot_config`: Bot settings
- `ai_playerbot_strategy`: Bot strategies
- `ai_playerbot_tactics`: Bot tactics

### Auth Database (`acore_auth`)
**Shared across all realms**. Contains account data.

**Key Tables**:
- `account`: User accounts
- `realmlist`: Realm definitions
- `account_access`: Account permissions

## Common Queries

### Creature Operations

**Find creature by name**:
```sql
SELECT entry, name, level, minlevel, maxlevel, type, family
FROM creature_template
WHERE name LIKE '%dragon%'
LIMIT 20;
```

**Get creature spawn locations**:
```sql
SELECT guid, entry, map, position_x, position_y, position_z, orientation
FROM creature
WHERE entry = 12345;
```

**Count creatures in zone**:
```sql
SELECT COUNT(*) as count
FROM creature
WHERE map = 571 AND position_x BETWEEN 1000 AND 2000;
```

**Update creature level**:
```sql
UPDATE creature_template
SET level = 80, minlevel = 80, maxlevel = 80
WHERE entry = 12345;
```

### Item Operations

**Find item by name**:
```sql
SELECT entry, name, quality, itemlevel, class, subclass
FROM item_template
WHERE name LIKE '%sword%'
LIMIT 20;
```

**Get item stats**:
```sql
SELECT entry, name, itemlevel, quality, armor, stat_type1, stat_value1
FROM item_template
WHERE entry = 12345;
```

**Update item stats**:
```sql
UPDATE item_template
SET armor = 100, stat_value1 = 50
WHERE entry = 12345;
```

### Quest Operations

**Find quest by name**:
```sql
SELECT entry, title, minlevel, maxlevel, type
FROM quest_template
WHERE title LIKE '%dragon%'
LIMIT 20;
```

**Get quest rewards**:
```sql
SELECT entry, title, RewardXP, RewardMoney, RewardItem1, RewardItemCount1
FROM quest_template
WHERE entry = 12345;
```

**Update quest rewards**:
```sql
UPDATE quest_template
SET RewardXP = 10000, RewardMoney = 50000
WHERE entry = 12345;
```

### Spell Operations

**Find spell by name**:
```sql
SELECT id, name, spellLevel, maxLevel, castingTimeIndex, recoveryTime
FROM spell_dbc
WHERE name LIKE '%fireball%'
LIMIT 20;
```

**Get spell proc configuration**:
```sql
SELECT spellId, procFlags, procEx, ppmRate, cooldown, procChance
FROM spell_proc
WHERE spellId = 12345;
```

**Add spell proc**:
```sql
INSERT INTO spell_proc (spellId, procFlags, procEx, ppmRate, cooldown, charges, procChance)
VALUES (12345, 0xC, 0x0, 0, 0, 0, 15);
```

### SmartAI Operations

**Find SmartAI scripts**:
```sql
SELECT entryorguid, source_type, id, event_type, action_type, comment
FROM smart_scripts
WHERE entryorguid = 12345
ORDER BY id;
```

**Count SmartAI scripts**:
```sql
SELECT COUNT(*) as script_count
FROM smart_scripts
WHERE entryorguid = 12345;
```

**Add SmartAI script**:
```sql
INSERT INTO smart_scripts (entryorguid, source_type, id, link, event_type, event_phase_mask, event_chance, event_flags, event_param1, event_param2, event_param3, event_param4, action_type, action_param1, action_param2, action_param3, target_type, target_param1, target_param2, target_param3, target_x, target_y, target_z, target_o, comment)
VALUES (12345, 0, 0, 0, 4, 1, 100, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Aggro: Say text');
```

### Loot Operations

**Find creature loot**:
```sql
SELECT entry, item, ChanceOrQuestChance, lootmode, groupid, mincountOrRef, maxcount
FROM creature_loot_template
WHERE entry = 12345
ORDER BY groupid, item;
```

**Add loot entry**:
```sql
INSERT INTO creature_loot_template (entry, item, ChanceOrQuestChance, lootmode, groupid, mincountOrRef, maxcount, comment)
VALUES (12345, 67890, 50, 1, 0, 1, 1, 'Rare drop');
```

**Update loot chance**:
```sql
UPDATE creature_loot_template
SET ChanceOrQuestChance = 25
WHERE entry = 12345 AND item = 67890;
```

### Condition Operations

**Find conditions for SmartAI**:
```sql
SELECT * FROM conditions
WHERE sourceTypeOrReferenceId = 22
AND sourceEntry = 12345;
```

**Add condition**:
```sql
INSERT INTO conditions (sourceTypeOrReferenceId, sourceEntry, sourceId, elseGroup, conditionTypeOrReference, conditionTarget, conditionValue1, conditionValue2, conditionValue3, negativeCondition, errorTextId, scriptName, comment)
VALUES (22, 12345, 0, 0, 8, 0, 5678, 0, 0, 0, 0, '', 'Quest 5678 completed');
```

## Backup and Restore

### Backup Database
```bash
# Single database
mysqldump -uacore -pacore acore_world > backup_world_$(date +%Y%m%d_%H%M%S).sql

# All databases
mysqldump -uacore -pacore --all-databases > backup_all_$(date +%Y%m%d_%H%M%S).sql

# With compression
mysqldump -uacore -pacore acore_world | gzip > backup_world_$(date +%Y%m%d_%H%M%S).sql.gz
```

### Restore Database
```bash
# From uncompressed backup
mysql -uacore -pacore acore_world < backup_world_20260203_120000.sql

# From compressed backup
gunzip < backup_world_20260203_120000.sql.gz | mysql -uacore -pacore acore_world

# Verify restoration
mysql -uacore -pacore acore_world -e "SELECT COUNT(*) FROM creature_template;"
```

## Database Maintenance

### Check Database Integrity
```sql
-- Check for orphaned creatures
SELECT c.entry, c.name
FROM creature c
LEFT JOIN creature_template ct ON c.entry = ct.entry
WHERE ct.entry IS NULL;

-- Check for orphaned items
SELECT i.entry, i.name
FROM item_template i
WHERE i.entry NOT IN (SELECT item FROM creature_loot_template)
AND i.entry NOT IN (SELECT item FROM gameobject_loot_template);
```

### Optimize Tables
```bash
# Optimize all tables
mysql -uacore -pacore acore_world -e "OPTIMIZE TABLE creature_template, creature, item_template, quest_template;"

# Check table sizes
mysql -uacore -pacore -e "SELECT table_name, ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb FROM information_schema.tables WHERE table_schema = 'acore_world' ORDER BY size_mb DESC;"
```

### Analyze Tables
```bash
# Analyze all tables
mysql -uacore -pacore acore_world -e "ANALYZE TABLE creature_template, creature, item_template, quest_template;"
```

## Data Import/Export

### Export Data to CSV
```bash
# Export creature data
mysql -uacore -pacore acore_world -e "SELECT entry, name, level, minlevel, maxlevel FROM creature_template;" > creatures.csv

# With headers
mysql -uacore -pacore acore_world -e "SELECT 'entry', 'name', 'level', 'minlevel', 'maxlevel' UNION ALL SELECT entry, name, level, minlevel, maxlevel FROM creature_template;" > creatures.csv
```

### Import Data from CSV
```bash
# Load from CSV
LOAD DATA LOCAL INFILE '/path/to/data.csv'
INTO TABLE creature_template
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
(entry, name, level, minlevel, maxlevel);
```

## Transaction Management

### Atomic Updates
```sql
START TRANSACTION;

UPDATE creature_template SET level = 80 WHERE entry = 12345;
UPDATE item_template SET armor = 100 WHERE entry = 67890;

-- Review changes
SELECT * FROM creature_template WHERE entry = 12345;
SELECT * FROM item_template WHERE entry = 67890;

-- Commit or rollback
COMMIT;
-- ROLLBACK;
```

## Performance Optimization

### Index Management
```sql
-- Create index for faster queries
CREATE INDEX idx_creature_entry ON creature(entry);
CREATE INDEX idx_creature_map ON creature(map);

-- Check existing indexes
SHOW INDEX FROM creature_template;

-- Drop unused index
DROP INDEX idx_old_index ON creature_template;
```

### Query Optimization
```sql
-- Use EXPLAIN to analyze query performance
EXPLAIN SELECT * FROM creature WHERE entry = 12345;

-- Look for:
-- - Full table scans (type = ALL)
-- - Missing indexes
-- - High row counts

-- Optimize by adding indexes
CREATE INDEX idx_creature_entry ON creature(entry);
```

## Common Issues

### Slow Queries
1. Check if indexes exist on WHERE clause columns
2. Use EXPLAIN to analyze query plan
3. Consider adding indexes for frequently queried columns
4. Avoid SELECT * (specify needed columns)

### Duplicate Entries
```sql
-- Find duplicates
SELECT entry, COUNT(*) as count
FROM creature_template
GROUP BY entry
HAVING COUNT(*) > 1;

-- Remove duplicates (keep first)
DELETE FROM creature_template
WHERE entry IN (
  SELECT entry FROM (
    SELECT entry FROM creature_template
    GROUP BY entry
    HAVING COUNT(*) > 1
  ) t
)
AND entry NOT IN (
  SELECT MIN(entry) FROM creature_template
  GROUP BY entry
);
```

### Data Integrity Issues
```sql
-- Find creatures with invalid templates
SELECT c.guid, c.entry
FROM creature c
LEFT JOIN creature_template ct ON c.entry = ct.entry
WHERE ct.entry IS NULL;

-- Find items with invalid entries
SELECT entry, name
FROM item_template
WHERE entry = 0 OR entry IS NULL;
```

## Useful Commands

```bash
# Connect to database
mysql -uacore -pacore acore_world

# List all databases
mysql -uacore -pacore -e "SHOW DATABASES;"

# List all tables
mysql -uacore -pacore acore_world -e "SHOW TABLES;"

# Show table structure
mysql -uacore -pacore acore_world -e "DESCRIBE creature_template;"

# Count rows in table
mysql -uacore -pacore acore_world -e "SELECT COUNT(*) FROM creature_template;"

# Run SQL file
mysql -uacore -pacore acore_world < update.sql

# Export to file
mysql -uacore -pacore acore_world -e "SELECT * FROM creature_template;" > creatures.txt
```

## Related Resources

- Database World: https://www.azerothcore.org/wiki/database-world
- SQL Syntax: https://dev.mysql.com/doc/refman/8.0/en/
- Database Backup: https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html
