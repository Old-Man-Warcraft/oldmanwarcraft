---
name: workflow-raid-debugging
description: Workflow for investigating raid encounters, boss scripts, and instance issues. Use when debugging raids or ICC/ToC-style content.
---

# Raid Debugging Workflow

## Overview
This workflow helps identify and fix bot behavior issues in raid encounters. Covers positioning, threat management, spell rotation, and healing.

## Prerequisites
- Raid-capable environment (production requires a **scheduled** test or off-peak repro)
- MySQL client for database queries
- Server console access (e.g. `screen -r worldserver` or docker attach)
- Raid instance available for testing

## MCP (use when connected)

- **azerothcore**: `get_creature_template`, `get_smart_scripts`, `trace_script_chain`, `explain_smart_script`, `search_spells`, `diagnose_spell_proc` for bosses and spell IDs; `query_database` for instance-related rows.
- **oldmanwarcraft-api-remote**: `omw_get_world_boss`, `omw_list_world_bosses`, `omw_get_armory_character` / guild tools if correlating with web-facing raid or roster data.
- **fetch** / **firecrawl** / **exa**: External strat or Blizzard-reference pages; verify against DBC/SmartAI in DB.
- Catalog: `.cursor/reference/mcp-tools-inventory.md`.

## Debugging Steps

### 1. Verify Bot Raid Configuration

Check bot raid strategy and tactics:
```sql
SELECT * FROM ai_playerbot_strategy 
WHERE name LIKE '%raid%' OR name LIKE '%boss%';

SELECT * FROM ai_playerbot_tactics 
WHERE name LIKE '%raid%' OR name LIKE '%boss%';
```

**What to check**:
- Strategy exists for raid encounter
- Tactics defined for bot role (tank/dps/heal)
- Action priorities are correct
- Spell selections match encounter mechanics

### 2. Check Raid Action Context

Verify raid-specific actions are configured:
```sql
SELECT entryorguid, source_type, id, event_type, action_type, comment 
FROM smart_scripts 
WHERE entryorguid IN (SELECT entry FROM creature_template WHERE type = 1)
AND comment LIKE '%raid%'
ORDER BY entryorguid, id;
```

**What to check**:
- Boss encounter scripts exist
- Event types match encounter phases
- Actions trigger at correct health percentages
- Phase transitions are properly configured

### 3. Test Bot Positioning

Enable debug logging and observe bot movement:
```
.debug on
```

Spawn raid encounter and observe:
- Bot positioning relative to boss
- Tank positioning (threat range)
- Ranged DPS positioning (safe distance)
- Healer positioning (line of sight)
- Movement during phase transitions

**Common positioning issues**:
- Bots standing in fire/bad areas
- Tanks not maintaining threat range
- Ranged DPS too close to boss
- Healers out of line of sight
- Bots not moving during phase transitions

### 4. Check Threat Management

Monitor threat table during combat:
```
.threat list
```

**What to check**:
- Tank has highest threat
- DPS threat is below tank threat
- Threat resets on phase transitions
- Threat properly transferred on tank death

**Common threat issues**:
- DPS pulling threat from tank
- Threat not resetting on phase change
- Threat table not updating
- Tank not generating enough threat

### 5. Verify Spell Rotation

Check bot spell selection during combat:
```bash
tail -f env/dist/logs/Server.log | grep -i "cast\|spell"
```

**What to check**:
- Correct spells being cast
- Cooldowns respected
- Resource management (mana, rage, energy)
- Spell interrupts on dangerous casts
- Crowd control applied correctly

**Common spell issues**:
- Wrong spell being cast
- Cooldowns not tracked
- Out of resources (mana/rage/energy)
- Spell interrupted unexpectedly
- Crowd control not applied

### 6. Test Healing Coverage

Monitor healing during raid encounter:
```bash
tail -f env/dist/logs/Server.log | grep -i "heal"
```

**What to check**:
- Healers casting healing spells
- Healing priority correct (tank > DPS > self)
- Mana management (not running out)
- Healing spell selection appropriate
- Healing coverage for all party members

**Common healing issues**:
- Healers not healing
- Wrong healing priority
- Healers running out of mana
- Healing spells not cast
- Healing coverage gaps

### 7. Verify Phase Transitions

Check boss phase mechanics:
```sql
SELECT id, event_type, event_phase_mask, action_type, action_param1 
FROM smart_scripts 
WHERE entryorguid = <boss_entry>
ORDER BY id;
```

**What to check**:
- Phase transitions at correct health percentages
- Actions change per phase
- Bots adapt to new mechanics
- No infinite loops in phase transitions

**Common phase issues**:
- Phase transition doesn't trigger
- Bots don't adapt to new phase
- Infinite loop in phase changes
- Wrong mechanics for phase

### 8. Test Crowd Control

Verify CC mechanics are working:
```bash
tail -f env/dist/logs/Server.log | grep -i "stun\|root\|fear\|silence"
```

**What to check**:
- CC spells being cast
- CC targets correct enemies
- CC duration appropriate
- CC breaks on damage

**Common CC issues**:
- CC spells not cast
- CC targeting wrong enemies
- CC duration too short
- CC breaks immediately

### 9. Check Debuff Handling

Monitor debuff application and removal:
```bash
tail -f env/dist/logs/Server.log | grep -i "debuff\|dispel"
```

**What to check**:
- Dangerous debuffs being dispelled
- Dispel priority correct
- Dispel timing appropriate
- Debuff stacks managed

**Common debuff issues**:
- Debuffs not dispelled
- Wrong debuffs dispelled
- Dispel timing wrong
- Debuff stacks too high

### 10. Performance Check

Monitor bot performance during raid:
```bash
top -p $(pgrep worldserver)
```

**What to check**:
- CPU usage reasonable
- Memory usage stable
- No memory leaks
- Update latency acceptable

**Common performance issues**:
- High CPU usage
- Memory leaks
- Excessive update latency
- Bot lag during combat

## Verification Checklist

- [ ] Bot raid strategy exists and is configured
- [ ] Raid action context properly set up
- [ ] Bot positioning correct for encounter
- [ ] Threat management working properly
- [ ] Spell rotation appropriate for encounter
- [ ] Healing coverage adequate
- [ ] Phase transitions working correctly
- [ ] Crowd control mechanics functioning
- [ ] Debuff handling working
- [ ] Performance acceptable
- [ ] No infinite loops or deadlocks
- [ ] Bots survive encounter

## Useful Commands

```bash
# View bot info
.bot info <name>

# Check bot spells
.bot spells <name>

# View threat table
.threat list

# Enable debug logging
.debug on

# Disable debug logging
.debug off

# View logs
tail -f env/dist/logs/Server.log

# Search logs for specific content
grep -i "pattern" env/dist/logs/Server.log

# Monitor real-time combat
tail -f env/dist/logs/Server.log | grep -i "cast\|heal\|damage"

# Check server status
systemctl status ac-worldserver
```

## Related Resources

- Playerbots Wiki: https://github.com/mod-playerbots/mod-playerbots/wiki
- SmartAI Guide: https://www.azerothcore.org/wiki/smart_scripts
- Raid Mechanics: https://www.azerothcore.org/wiki/raid_encounters
