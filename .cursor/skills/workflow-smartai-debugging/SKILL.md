---
name: workflow-smartai-debugging
description: Workflow for debugging SmartAI (phases, links, conditions, common failure modes). Use when NPC scripts misbehave.
---

# SmartAI Debugging Workflow

## Overview
SmartAI scripts control NPC behavior through database entries. This workflow helps identify and fix script issues.

## Prerequisites
- Production or staging worldserver access (this OMW host is **production-only**—use low-impact windows and `.reload` when safe)
- MySQL client for database queries
- Server console access (e.g. `screen -r worldserver`, docker attach, or your documented method)

## MCP (optional)

With the **azerothcore** MCP connected, use `get_smart_scripts`, `explain_smart_script`, `trace_script_chain`, `generate_sai_comments`, and creature/GO search tools to inspect chains without huge hand-pasted SQL. Use **Notion** for reload/restart steps; **fetch** / **exa** for external SAI writeups. See `.cursor/reference/mcp-tools-inventory.md`.

## Debugging Steps

### 1. Verify Script Exists
```sql
SELECT entryorguid, source_type, id, event_type, action_type, comment 
FROM smart_scripts 
WHERE entryorguid = <creature_entry> 
ORDER BY id;
```

**What to check**:
- Script entry matches creature entry
- source_type = 0 (creature)
- Event IDs are sequential
- Action types are valid (0-236)

### 2. Check Event Configuration
```sql
SELECT id, event_type, event_phase_mask, event_chance, event_flags, 
       event_param1, event_param2, event_param3, event_param4
FROM smart_scripts 
WHERE entryorguid = <creature_entry> AND event_type = <event_id>;
```

**Common issues**:
- `event_phase_mask = 0`: Script never triggers (should be >= 1)
- `event_chance = 0`: Script never triggers (should be 1-100)
- `event_param` values incorrect for event type
- Phase mismatch (creature in phase 1, script in phase 2)

### 3. Verify Conditions
```sql
SELECT * FROM conditions 
WHERE sourceTypeOrReferenceId = 22 
AND sourceEntry = <creature_entry>;
```

**What to check**:
- Conditions are satisfied (check player state)
- Condition logic is correct (AND vs OR groups)
- ConditionValue fields match expected values

### 4. Test Script Execution

**Enable debug logging**:
```
.debug on
```

**Trigger event manually**:
```
.npc say <creature_entry> "Test message"
```

**Check server logs**:
```bash
tail -f env/dist/logs/Server.log | grep -i smartai
```

**Look for**:
- Script trigger messages
- Action execution messages
- Error messages or warnings

### 5. Reload and Test
```
.reload smart_scripts
.reload conditions
```

**Test on fresh creature spawn**:
1. Despawn creature: `.go creature <entry>`
2. Kill it or wait for respawn
3. Observe behavior
4. Check logs for execution

### 6. Common Event Issues

**Event not triggering**:
- Check `event_phase_mask` includes current phase
- Verify `event_chance` > 0
- Ensure conditions are satisfied
- Check event parameters match event type

**Event triggering too often**:
- Reduce `event_chance` (lower = less frequent)
- Add conditions to filter triggers
- Increase event timer parameters

**Event triggering wrong target**:
- Check `target_type` (0=self, 1=victim, 2=hostile, etc.)
- Verify target parameters match intent
- Test with different target types

### 7. Common Action Issues

**Action not executing**:
- Verify `action_type` is valid
- Check action parameters are correct
- Ensure target is valid
- Review conditions for action

**Action executing wrong target**:
- Check `target_type` and parameters
- Test with `.npc say` to verify targeting
- Use stored target lists for complex targeting

**Spell not casting**:
- Verify spell ID exists: `.spell <id>`
- Check creature has mana/power
- Verify spell is not on cooldown
- Check for casting interrupts

### 8. Phase Debugging

**Check current phase**:
```sql
SELECT id, event_type, event_phase_mask, action_type 
FROM smart_scripts 
WHERE entryorguid = <creature_entry> 
ORDER BY id;
```

**Verify phase transitions**:
- `SMART_ACTION_SET_EVENT_PHASE` (22): Sets phase
- `SMART_ACTION_INC_EVENT_PHASE` (23): Increments phase
- Check phase_mask includes target phase

**Test phase change**:
```
.npc setdata <creature_entry> <data_id> <value>
```

### 9. Link Debugging

**Find linked scripts**:
```sql
SELECT id, link, event_type, action_type 
FROM smart_scripts 
WHERE entryorguid = <creature_entry> 
ORDER BY id;
```

**Verify links**:
- `link` field points to valid script ID
- Linked script has matching `entryorguid`
- `SMART_EVENT_LINK` (61) triggers linked script

**Test link execution**:
- Trigger first script
- Verify linked script executes
- Check logs for link messages

### 10. Performance Check

**Identify expensive scripts**:
```sql
SELECT entryorguid, COUNT(*) as script_count
FROM smart_scripts 
WHERE event_type IN (0, 1, 60)  -- UPDATE_IC, UPDATE_OOC, UPDATE
GROUP BY entryorguid 
HAVING COUNT(*) > 10;
```

**Optimize**:
- Reduce UPDATE event frequency
- Add conditions to filter unnecessary executions
- Use timers instead of constant updates
- Cache frequently accessed data

## Verification Checklist

- [ ] Script entry exists in database
- [ ] Event phase mask matches creature phase
- [ ] Event chance > 0
- [ ] Event parameters correct for event type
- [ ] Conditions satisfied (if any)
- [ ] Target type and parameters correct
- [ ] Action type valid and parameters correct
- [ ] Spell/item IDs exist (if applicable)
- [ ] Phase transitions work correctly
- [ ] Links point to valid scripts
- [ ] No infinite loops in phase transitions
- [ ] Performance acceptable (not excessive updates)

## Useful Commands

```bash
# View creature info
.go creature <entry>

# Trigger event
.npc say <entry> "message"

# Set creature data
.npc setdata <entry> <data_id> <value>

# Reload scripts
.reload smart_scripts

# View logs
tail -f env/dist/logs/Server.log

# Search logs for errors
grep -i "error\|warning" env/dist/logs/Server.log
```

## Related Resources

- SmartAI Wiki: https://www.azerothcore.org/wiki/smart_scripts
- Event Types: https://www.azerothcore.org/wiki/smart_scripts#event_type
- Action Types: https://www.azerothcore.org/wiki/smart_scripts#action_type
- Target Types: https://www.azerothcore.org/wiki/smart_scripts#target_type
