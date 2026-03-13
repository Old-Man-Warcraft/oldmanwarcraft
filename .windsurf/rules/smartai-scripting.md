---
trigger: model_decision
description: Apply when creating or debugging SmartAI scripts, smart_scripts table, creature events, actions, targets, or phase management
---
# SmartAI Scripting Rules

## Event Configuration

<event_rules>
- Always verify `event_phase_mask >= 1` (0 means script never triggers)
- Always verify `event_chance > 0` (0 means script never triggers)
- Use `SMART_EVENT_JUST_CREATED` (63) for initialization, not RESPAWN (11)
- Minimize `SMART_EVENT_UPDATE_IC` (0) and `SMART_EVENT_UPDATE_OOC` (1) - they fire every update cycle
- Use conditions to filter unnecessary triggers
- Document event parameters in comments
- Test with multiple creatures to verify behavior
</event_rules>

## Action Configuration

<action_rules>
- Verify `action_type` is valid (0-236)
- Check all `action_param` values match action type requirements
- Verify `target_type` and parameters are correct
- Test spell casting actions with `.spell <id>` to verify spell exists
- Verify creature has required resources (mana, power) for spell actions
- Document complex action chains in comments
</action_rules>

## Target Selection

<target_rules>
- `SMART_TARGET_SELF` (0): Self (the creature)
- `SMART_TARGET_VICTIM` (1): Current victim/target
- `SMART_TARGET_HOSTILE_RANDOM` (2): Random hostile nearby
- `SMART_TARGET_HOSTILE_NEAREST` (4): Nearest hostile
- `SMART_TARGET_CREATURE_GUID` (9): Specific creature by GUID
- `SMART_TARGET_STORED` (11): Stored target list
- Verify target type matches action intent
- Test with different target types to ensure correct behavior
</target_rules>

## Phase Management

<phase_rules>
- Use `SMART_ACTION_SET_EVENT_PHASE` (22) to set specific phase
- Use `SMART_ACTION_INC_EVENT_PHASE` (23) to increment phase
- Document all phase transitions in comments
- Test phase transitions thoroughly - bugs cause infinite loops
- Verify phase_mask includes target phase in event configuration
- Use `SMART_EVENT_EVENT_PHASE_CHANGE` (66) to trigger on phase change
</phase_rules>

## Script Linking

<linking_rules>
- Use `SMART_EVENT_LINK` (61) to chain scripts together
- Verify `link` field points to valid script ID
- Linked script must have matching `entryorguid`
- Test link execution to verify sequential behavior
- Document linked script chains in comments
- Use for complex multi-stage behaviors
</linking_rules>

## Conditions

<condition_rules>
- Use `CONDITION_SOURCE_TYPE_SMART_EVENT` (22) for SmartAI conditions
- Verify conditions are satisfied before testing
- Use conditions to filter unnecessary event triggers
- Test with multiple character states to verify condition logic
- Document complex conditions in comments
- Use negative SourceTypeOrReferenceId for OR logic
</condition_rules>

## Performance

<performance_rules>
- Minimize UPDATE_IC/OOC event frequency - they fire every update
- Use conditions to filter unnecessary triggers
- Cache frequently accessed data in SetData/GetData
- Avoid nested loops in scripts
- Monitor performance with frequent UPDATE events
- Profile slow scripts with server logs
</performance_rules>

## Testing & Debugging

<testing_rules>
- Test on development realm (8086) first
- Use `.go creature <entry>` to spawn test creature
- Enable debug logging: `.debug on`
- Check server logs: `tail -f env/dist/logs-dev/Server.log`
- Reload scripts: `.reload smart_scripts`
- Test with fresh creature spawn after changes
- Verify no infinite loops in phase transitions
</testing_rules>
