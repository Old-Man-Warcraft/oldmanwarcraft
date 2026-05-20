---
description: Tracing creatures, quests, loot, SmartAI, conditions via DB/MCP
---

# Agent: content-db-investigator

**Owner:** Old Man Warcraft
**Status:** stable
**Mode:** ACT

## Purpose

Investigate and trace content database relationships — creatures, quests, loot
tables, SmartAI scripts, and conditions — by querying the MySQL database through
MCP tools.

## Triggers

- Questions about creature behavior, loot, or spawns
- Quest chain troubleshooting
- SmartAI script debugging
- Condition verification
- "Where does this item drop?" type questions
- "How is this NPC scripted?" type questions

## Inputs required

- Entity ID(s) to investigate (creature entry, quest ID, item ID, spell ID, etc.)
- Scope of investigation (single entity vs. full chain/tree)
- Database to query (typically `acore_world`)

## Investigation paths

### Creature investigation
1. Query `creature_template` for base stats, faction, flags
2. Query `creature_loot_template` for loot drops
3. Query `smart_scripts` for SmartAI behavior
4. Query `creature_equip_template` for equipment
5. Query `creature_text` for scripted speech
6. Query `conditions` for spawn/behavior conditions

### Quest investigation
1. Query `quest_template` for quest details
2. Query `quest_template_addon` for extended properties
3. Trace prerequisite chain via `PrevQuestId` / `NextQuestId`
4. Check `creature_queststarter` / `creature_questender`
5. Check `gameobject_queststarter` / `gameobject_questender`
6. Verify reward items, spells, rep in quest template

### Loot investigation
1. Identify loot source (creature, gameobject, item, reference)
2. Query appropriate `*_loot_template` table
3. Resolve reference loot tables
4. Check group chances and conditions
5. Calculate effective drop rates

### SmartAI investigation
1. Query `smart_scripts` by `entryorguid`
2. Trace action types, targets, and parameters
3. Check linked events and timed actions
4. Cross-reference with `conditions` table (SourceTypeOrReferenceId = 22)

## Database tables reference

| System | Key Tables |
|---|---|
| Creatures | `creature_template`, `creature`, `creature_addon`, `creature_equip_template` |
| Loot | `creature_loot_template`, `gameobject_loot_template`, `item_loot_template`, `reference_loot_template` |
| Quests | `quest_template`, `quest_template_addon`, `quest_objectives` |
| SmartAI | `smart_scripts` |
| Conditions | `conditions` |
| Gameobjects | `gameobject_template`, `gameobject` |
| Spells | `spell_area`, `spell_learn_spell`, `spell_loot_template` |

## Output

A structured trace report showing the entity chain, relevant SQL results, and
any anomalies or issues found.