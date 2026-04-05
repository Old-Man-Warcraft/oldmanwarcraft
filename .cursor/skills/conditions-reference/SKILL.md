---
name: conditions-reference
description: Reference for AzerothCore conditions (source types, operators, common condition types). Use when editing conditions, loot, gossip, quests, SmartAI filters, or spell_proc conditions.
---

# Conditions Reference Guide

## Overview
Conditions provide reusable conditional logic for quests, gossip, loot, SmartAI, spells, vendors, and more.

## MCP (when connected)

- **azerothcore**: `diagnose_conditions`, `explain_condition`, `search_conditions`, `get_conditions`, `list_condition_source_types`, `list_condition_types`.
- **fetch** / **exa** / **deepwiki**: External condition examples—validate `SourceType` / `ConditionType` against this guide.
- Full list: `.cursor/reference/mcp-tools-inventory.md`.

## Condition Source Types

### Loot Conditions
- **1**: `CONDITION_SOURCE_TYPE_CREATURE_LOOT_TEMPLATE` - Creature loot drops
- **2**: `CONDITION_SOURCE_TYPE_DISENCHANT_LOOT_TEMPLATE` - Disenchant results
- **3**: `CONDITION_SOURCE_TYPE_FISHING_LOOT_TEMPLATE` - Fishing loot
- **4**: `CONDITION_SOURCE_TYPE_GAMEOBJECT_LOOT_TEMPLATE` - Gameobject loot (chests)
- **5**: `CONDITION_SOURCE_TYPE_ITEM_LOOT_TEMPLATE` - Item container loot (bags)
- **6**: `CONDITION_SOURCE_TYPE_MAIL_LOOT_TEMPLATE` - Mail attachment loot
- **7**: `CONDITION_SOURCE_TYPE_MILLING_LOOT_TEMPLATE` - Milling results (Inscription)
- **8**: `CONDITION_SOURCE_TYPE_PICKPOCKETING_LOOT_TEMPLATE` - Pickpocket loot
- **9**: `CONDITION_SOURCE_TYPE_PROSPECTING_LOOT_TEMPLATE` - Prospecting results (Jewelcrafting)
- **10**: `CONDITION_SOURCE_TYPE_REFERENCE_LOOT_TEMPLATE` - Reference loot template
- **11**: `CONDITION_SOURCE_TYPE_SKINNING_LOOT_TEMPLATE` - Skinning loot
- **12**: `CONDITION_SOURCE_TYPE_SPELL_LOOT_TEMPLATE` - Spell-created loot
- **28**: `CONDITION_SOURCE_TYPE_PLAYER_LOOT_TEMPLATE` - Player loot (PvP)

### Spell/Targeting Conditions
- **13**: `CONDITION_SOURCE_TYPE_SPELL_IMPLICIT_TARGET` - Spell implicit targets (area/nearby/cone)
- **17**: `CONDITION_SOURCE_TYPE_SPELL` - Spell casting (caster/explicit target requirements)
- **24**: `CONDITION_SOURCE_TYPE_SPELL_PROC` - Spell proc triggering

### Gossip Conditions
- **14**: `CONDITION_SOURCE_TYPE_GOSSIP_MENU` - Showing gossip menu text
- **15**: `CONDITION_SOURCE_TYPE_GOSSIP_MENU_OPTION` - Showing gossip menu options

### Quest Conditions
- **19**: `CONDITION_SOURCE_TYPE_QUEST_AVAILABLE` - Quest to be available/shown

### NPC/Vendor Conditions
- **23**: `CONDITION_SOURCE_TYPE_NPC_VENDOR` - Vendor item availability

### Vehicle Conditions
- **16**: `CONDITION_SOURCE_TYPE_CREATURE_TEMPLATE_VEHICLE` - Vehicle usage
- **21**: `CONDITION_SOURCE_TYPE_VEHICLE_SPELL` - Show/hide spells in vehicle spell bar

### Spellclick Conditions
- **18**: `CONDITION_SOURCE_TYPE_SPELL_CLICK_EVENT` - Spellclick events

### SmartAI Conditions
- **22**: `CONDITION_SOURCE_TYPE_SMART_EVENT` - SmartAI script execution

### Creature Conditions
- **29**: `CONDITION_SOURCE_TYPE_CREATURE_VISIBILITY` - Creature visibility to players

### Reference Template
- **0**: `CONDITION_SOURCE_TYPE_NONE` - Reference template (SourceTypeOrReferenceId < 0)

## Condition Types

### Aura/Buff Conditions
- **1**: `CONDITION_AURA` - Target has aura from spell
  - ConditionValue1: Spell ID
  - ConditionValue2: Effect index (0-2)
  - ConditionValue3: Unused

- **102**: `CONDITION_HAS_AURA_TYPE` - Target has aura of type
  - ConditionValue1: Aura type (0-42)
  - ConditionValue2: Unused
  - ConditionValue3: Unused

### Item Conditions
- **2**: `CONDITION_ITEM` - Target has item(s) in inventory
  - ConditionValue1: Item ID
  - ConditionValue2: Item count
  - ConditionValue3: Unused

- **3**: `CONDITION_ITEM_EQUIPPED` - Target has item equipped
  - ConditionValue1: Item ID
  - ConditionValue2: Unused
  - ConditionValue3: Unused

### Location Conditions
- **4**: `CONDITION_ZONEID` - Target is in zone
  - ConditionValue1: Zone ID
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **22**: `CONDITION_MAPID` - Target is on map
  - ConditionValue1: Map ID
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **23**: `CONDITION_AREAID` - Target is in area
  - ConditionValue1: Area ID
  - ConditionValue2: Unused
  - ConditionValue3: Unused

### Reputation Conditions
- **5**: `CONDITION_REPUTATION_RANK` - Target has reputation rank with faction
  - ConditionValue1: Faction ID
  - ConditionValue2: Rank (0-8)
  - ConditionValue3: Unused

### Team/Faction Conditions
- **6**: `CONDITION_TEAM` - Target is on team
  - ConditionValue1: Team (0=Alliance, 1=Horde)
  - ConditionValue2: Unused
  - ConditionValue3: Unused

### Skill Conditions
- **7**: `CONDITION_SKILL` - Target has skill at level
  - ConditionValue1: Skill ID
  - ConditionValue2: Skill level
  - ConditionValue3: Unused

### Quest Conditions
- **8**: `CONDITION_QUESTREWARDED` - Target has completed and been rewarded quest
  - ConditionValue1: Quest ID
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **9**: `CONDITION_QUESTTAKEN` - Target has quest in log (active)
  - ConditionValue1: Quest ID
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **14**: `CONDITION_QUEST_NONE` - Target has never accepted quest
  - ConditionValue1: Quest ID
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **28**: `CONDITION_QUEST_COMPLETE` - Target has quest objectives complete (not yet rewarded)
  - ConditionValue1: Quest ID
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **47**: `CONDITION_QUESTSTATE` - Target quest state matches
  - ConditionValue1: Quest ID
  - ConditionValue2: State (0=none, 1=complete, 2=failed)
  - ConditionValue3: Unused

- **48**: `CONDITION_QUEST_OBJECTIVE_PROGRESS` - Target has quest objective progress
  - ConditionValue1: Quest ID
  - ConditionValue2: Objective index
  - ConditionValue3: Progress value

- **43**: `CONDITION_DAILY_QUEST_DONE` - Target has done daily quest today
  - ConditionValue1: Quest ID
  - ConditionValue2: Unused
  - ConditionValue3: Unused

### Character Conditions
- **15**: `CONDITION_CLASS` - Target is class(es)
  - ConditionValue1: Class mask (1=Warrior, 2=Paladin, 4=Hunter, etc.)
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **16**: `CONDITION_RACE` - Target is race(es)
  - ConditionValue1: Race mask (1=Human, 2=Orc, 4=Dwarf, etc.)
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **20**: `CONDITION_GENDER` - Target is gender
  - ConditionValue1: Gender (0=Male, 1=Female, 2=None)
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **27**: `CONDITION_LEVEL` - Target level comparison
  - ConditionValue1: Level
  - ConditionValue2: Comparison (0=equal, 1=less, 2=greater)
  - ConditionValue3: Unused

### Achievement/Title Conditions
- **17**: `CONDITION_ACHIEVEMENT` - Target has achievement
  - ConditionValue1: Achievement ID
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **18**: `CONDITION_TITLE` - Target has title
  - ConditionValue1: Title ID
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **39**: `CONDITION_REALM_ACHIEVEMENT` - Realm has achievement (any player completed)
  - ConditionValue1: Achievement ID
  - ConditionValue2: Unused
  - ConditionValue3: Unused

### Spell/Skill Conditions
- **25**: `CONDITION_SPELL` - Target knows spell
  - ConditionValue1: Spell ID
  - ConditionValue2: Unused
  - ConditionValue3: Unused

### State Conditions
- **10**: `CONDITION_DRUNKENSTATE` - Target's drunken state
  - ConditionValue1: Drunken state (0=sober, 1=tipsy, 2=drunk, 3=wasted)
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **21**: `CONDITION_UNIT_STATE` - Target has unit state
  - ConditionValue1: Unit state
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **42**: `CONDITION_STAND_STATE` - Target stand state
  - ConditionValue1: Stand state (0=stand, 1=sit, 2=sit_chair, etc.)
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **44**: `CONDITION_CHARMED` - Target is charmed
  - ConditionValue1: Unused
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **46**: `CONDITION_TAXI` - Target is on taxi/flight path
  - ConditionValue1: Unused
  - ConditionValue2: Unused
  - ConditionValue3: Unused

### Health/Status Conditions
- **36**: `CONDITION_ALIVE` - Target alive state
  - ConditionValue1: Alive (0=dead, 1=alive)
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **37**: `CONDITION_HP_VAL` - Target HP value
  - ConditionValue1: HP value
  - ConditionValue2: Comparison (0=equal, 1=less, 2=greater)
  - ConditionValue3: Unused

- **38**: `CONDITION_HP_PCT` - Target HP percentage
  - ConditionValue1: HP percentage (0-100)
  - ConditionValue2: Comparison (0=equal, 1=less, 2=greater)
  - ConditionValue3: Unused

- **40**: `CONDITION_IN_WATER` - Target in water
  - ConditionValue1: Unused
  - ConditionValue2: Unused
  - ConditionValue3: Unused

### Proximity Conditions
- **29**: `CONDITION_NEAR_CREATURE` - Target is near creature
  - ConditionValue1: Creature entry
  - ConditionValue2: Distance (yards)
  - ConditionValue3: Unused

- **30**: `CONDITION_NEAR_GAMEOBJECT` - Target is near gameobject
  - ConditionValue1: Gameobject entry
  - ConditionValue2: Distance (yards)
  - ConditionValue3: Unused

- **35**: `CONDITION_DISTANCE_TO` - Target is distance from another condition target
  - ConditionValue1: Distance (yards)
  - ConditionValue2: Comparison (0=equal, 1=less, 2=greater)
  - ConditionValue3: Unused

### Type/Entry Conditions
- **31**: `CONDITION_OBJECT_ENTRY_GUID` - Target is specific object type/entry/guid
  - ConditionValue1: Entry
  - ConditionValue2: GUID
  - ConditionValue3: Type (0=creature, 1=gameobject)

- **32**: `CONDITION_TYPE_MASK` - Target matches type mask
  - ConditionValue1: Type mask
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **24**: `CONDITION_CREATURE_TYPE` - Target creature is type
  - ConditionValue1: Creature type (0-14)
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **45**: `CONDITION_PET_TYPE` - Target has pet type
  - ConditionValue1: Pet type (0=none, 1=summon, 2=hunter_pet, 3=vehicle)
  - ConditionValue2: Unused
  - ConditionValue3: Unused

### Relation Conditions
- **33**: `CONDITION_RELATION_TO` - Target has relation to another condition target
  - ConditionValue1: Target index
  - ConditionValue2: Relation (0=self, 1=friend, 2=enemy, 3=neutral)
  - ConditionValue3: Unused

- **34**: `CONDITION_REACTION_TO` - Target has reaction to another condition target
  - ConditionValue1: Target index
  - ConditionValue2: Reaction (0=hostile, 1=unfriendly, 2=neutral, 3=friendly, 4=honored)
  - ConditionValue3: Unused

### Game State Conditions
- **11**: `CONDITION_WORLD_STATE` - World state has value
  - ConditionValue1: World state ID
  - ConditionValue2: Value
  - ConditionValue3: Comparison (0=equal, 1=less, 2=greater)

- **12**: `CONDITION_ACTIVE_EVENT` - Game event is active
  - ConditionValue1: Event ID
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **13**: `CONDITION_INSTANCE_INFO` - Instance script data check
  - ConditionValue1: Instance data ID
  - ConditionValue2: Value
  - ConditionValue3: Comparison (0=equal, 1=less, 2=greater)

- **49**: `CONDITION_DIFFICULTY_ID` - Current difficulty matches
  - ConditionValue1: Difficulty ID (0=normal, 1=heroic, 2=raid_10, 3=raid_25)
  - ConditionValue2: Unused
  - ConditionValue3: Unused

### Phase Conditions
- **19**: `CONDITION_SPAWNMASK` - Difficulty/spawnmask check
  - ConditionValue1: Spawnmask
  - ConditionValue2: Unused
  - ConditionValue3: Unused

- **26**: `CONDITION_PHASEMASK` - Target is in phase
  - ConditionValue1: Phase mask
  - ConditionValue2: Unused
  - ConditionValue3: Unused

### Script Conditions
- **103**: `CONDITION_WORLD_SCRIPT` - World script condition check
  - ConditionValue1: Script ID
  - ConditionValue2: Value
  - ConditionValue3: Unused

### Quest Exclusive Condition
- **101**: `CONDITION_QUEST_SATISFY_EXCLUSIVE` - Player satisfies quest exclusive group
  - ConditionValue1: Quest group ID
  - ConditionValue2: Unused
  - ConditionValue3: Unused

## Condition Operators

### AND Logic (Default)
Multiple conditions with same `SourceTypeOrReferenceId` are AND'd together:
```sql
INSERT INTO conditions VALUES
(22, 0, 12345, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'SmartAI: Has aura'),
(22, 0, 12345, 0, 4, 0, 1, 0, 1234, 0, 0, 0, 0, 0, 0, 'SmartAI: In zone');
-- Both conditions must be true
```

### OR Logic (Negative SourceTypeOrReferenceId)
Use negative SourceTypeOrReferenceId to create OR groups:
```sql
INSERT INTO conditions VALUES
(22, 0, 12345, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'SmartAI: Has aura'),
(22, 0, 12345, 0, 4, 0, -1, 0, 1234, 0, 0, 0, 0, 0, 0, 'SmartAI: OR in zone');
-- Either condition can be true
```

### NOT Logic (Negative ConditionTypeOrReference)
Use negative ConditionTypeOrReference to negate a condition:
```sql
INSERT INTO conditions VALUES
(22, 0, 12345, 0, -1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'SmartAI: NOT has aura');
-- Condition is inverted
```

### ElseGroup
Group conditions for complex boolean logic:
```sql
INSERT INTO conditions VALUES
(22, 0, 12345, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Group 1: Has aura'),
(22, 0, 12345, 0, 4, 0, 1, 0, 1234, 0, 0, 0, 0, 0, 0, 'Group 1: AND in zone'),
(22, 0, 12345, 1, 15, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 'Group 2: Is warrior');
-- (Has aura AND in zone) OR (is warrior)
```

## Common Condition Patterns

### Quest Requirement
```sql
INSERT INTO conditions VALUES
(22, 0, 12345, 0, 8, 0, 1, 0, 5678, 0, 0, 0, 0, 0, 0, 'Quest 5678 completed');
```

### Level Requirement
```sql
INSERT INTO conditions VALUES
(22, 0, 12345, 0, 27, 0, 1, 0, 80, 2, 0, 0, 0, 0, 0, 'Level >= 80');
```

### Class Requirement
```sql
INSERT INTO conditions VALUES
(22, 0, 12345, 0, 15, 0, 1, 0, 8, 0, 0, 0, 0, 0, 0, 'Is Rogue');
-- Class mask: 1=Warrior, 2=Paladin, 4=Hunter, 8=Rogue, 16=Priest, 32=DK, 64=Shaman, 128=Mage, 256=Druid, 512=Warlock
```

### Zone Requirement
```sql
INSERT INTO conditions VALUES
(22, 0, 12345, 0, 4, 0, 1, 0, 3487, 0, 0, 0, 0, 0, 0, 'In Dalaran');
```

### Item Requirement
```sql
INSERT INTO conditions VALUES
(22, 0, 12345, 0, 2, 0, 1, 0, 12345, 1, 0, 0, 0, 0, 0, 'Has 1x item 12345');
```

## Troubleshooting Conditions

### Condition Not Working
1. Verify SourceTypeOrReferenceId matches source type
2. Check SourceEntry matches target entry
3. Verify ConditionTypeOrReference is valid
4. Check ConditionValue fields are correct
5. Test with simple condition first

### Complex Conditions Not Working
1. Verify ElseGroup numbering is correct
2. Check AND/OR logic with negative values
3. Test each condition individually
4. Review condition operator precedence

## Related Resources

- Conditions Wiki: https://www.azerothcore.org/wiki/conditions
- Condition Types: https://www.azerothcore.org/wiki/conditions#condition_type
- SmartAI Conditions: https://www.azerothcore.org/wiki/smart_scripts#conditions
