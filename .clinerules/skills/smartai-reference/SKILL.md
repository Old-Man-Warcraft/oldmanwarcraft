---
name: smartai-reference
description: Reference for SmartAI scripting in AzerothCore. Use when writing or debugging SmartAI scripts, event/action definitions, or creature AI behaviors.
---

# Skill: smartai-reference

**Owner:** Old Man Warcraft
**Version:** 1.0

## Purpose

Reference for SmartAI — the database-driven AI scripting system used for
creatures, gameobjects, and quests in AzerothCore.

## SmartAI overview

SmartAI is configured entirely through the `smart_scripts` table in `acore_world`.
Each row defines an event → action → target chain for a specific entity (creature,
gameobject, or area trigger).

### Key tables

| Table | Purpose |
|---|---|
| `smart_scripts` | Main AI script definitions |
| `conditions` | Conditions for events/actions (SourceTypeOrReferenceId = 22) |
| `creature_template` | Links creatures to SmartAI via `AIName = 'SmartAI'` |

## SmartAI event types

| Event | ID | Description |
|---|---|---|
| UPDATE_IC | 0 | Fires every N milliseconds |
| UPDATE_OOC | 1 | Fires every N milliseconds (out of combat) |
| HEALTH_PCT | 2 | Fires at health percentage threshold |
| MANA_PCT | 3 | Fires at mana percentage threshold |
| AGGRO | 4 | Fires on entering combat |
| KILL | 5 | Fires on killing a unit |
| DEATH | 6 | Fires on death |
| EVADE | 7 | Fires on evade |
| SPELLHIT | 8 | Fires when hit by a spell |
| RANGE | 9 | Fires when target enters range |
| OOC_LOS | 10 | Fires when target enters LOS (out of combat) |
| RESPAWN | 11 | Fires on respawn |
| TARGET_HEALTH_PCT | 12 | Fires when target reaches health % |
| VICTIM_CASTING | 13 | Fires when victim is casting |
| FRIENDLY_HEALTH | 14 | Fires when friendly unit at health % |
| FRIENDLY_BUFF | 15 | Fires when friendly missing buff |
| SUMMONED_UNIT | 16 | Fires when unit is summoned |
| TARGET_MANA_PCT | 17 | Fires when target mana reaches % |
| ACCEPTED_QUEST | 19 | Fires when quest is accepted |
| REWARD_QUEST | 20 | Fires when quest is completed |
| REACHED_HOME | 21 | Fires on reaching home position |
| RECEIVE_EMOTE | 22 | Fires on receiving an emote |
| HAS_AURA | 23 | Fires when unit has an aura |
| TARGET_BUFFED | 24 | Fires when target is buffed |
| RESET | 25 | Fires after combat resets |
| GO_LOOT_STATE_CHANGED | 26 | Fires on gameobject loot state change |
| GO_EVENT_INFORM | 27 | Fires on gameobject event |
| ACTION_DONE | 28 | Fires when an action completes |
| ON_SPELLCLICK | 29 | Fires on spellclick |
| FRIENDLY_HEALTH_PCT | 30 | Fires when friendly unit at health % |
| DISTANCE_CREATURE | 33 | Fires when creature is within distance |
| DISTANCE_GAMEOBJECT | 34 | Fires when gameobject is within distance |
| COUNTER | 35 | Fires when counter reaches value |
| DATA_SET | 37 | Fires when data is set |
| WAYPOINT_START | 38 | Triggered when waypoint movement starts |
| WAYPOINT_REACHED | 39 | Fires when waypoint is reached |
| TRANSPORT_ADDPLAYER | 43 | Fires when player boards transport |
| TRANSPORT_REMOVE_PLAYER | 45 | Fires when player leaves transport |

## SmartAI action types

| Action | ID | Description |
|---|---|---|
| ACTION_NONE | 0 | No action |
| ACTION_TALK | 1 | Say/emote text |
| ACTION_SET_FACTION | 2 | Change faction |
| ACTION_MORPH_TO_ENTRY_OR_MODEL | 3 | Transform model |
| ACTION_SOUND | 4 | Play sound |
| ACTION_EMOTE | 5 | Play emote |
| ACTION_FAIL_QUEST | 6 | Fail a quest |
| ACTION_OFFER_QUEST | 7 | Offer a quest |
| ACTION_SET_REACT_STATE | 8 | Set aggressive/passive/etc |
| ACTION_ACTIVATE_GOBJECT | 9 | Activate a gameobject |
| ACTION_RANDOM_EMOTE | 10 | Play random emote |
| ACTION_CAST | 11 | Cast a spell |
| ACTION_SUMMON_CREATURE | 12 | Summon a creature |
| ACTION_CALL_AREAEXPLOREDOREVENTHAPPENS | 15 | Trigger achievement/area trigger |
| ACTION_SET_EVENT_PHASE | 16 | Change event phase |
| ACTION_SET_FOLLOW | 19 | Set follow target |
| ACTION_RANDOM_PHASE | 20 | Set random phase |
| ACTION_DIE | 24 | Kill self |
| ACTION_SET_RUN | 27 | Toggle running |
| ACTION_SET_ACTIVE | 33 | Set active/inactive |
| ACTION_MOVE_DESPAWN | 35 | Despawn on waypoint reached |
| ACTION_CALL_TIMED_ACTIONLIST | 36 | Start timed action list |
| ACTION_SET_NPC_FLAG | 37 | Modify NPC flags |
| ACTION_ADD_NPC_FLAG | 38 | Add NPC flags |
| ACTION_REMOVE_NPC_FLAG | 39 | Remove NPC flags |
| ACTION_CALL_RANDOM_TIMED_ACTIONLIST | 42 | Random timed action list |
| ACTION_CREATE_TIMED_EVENT | 67 | Create timed event |
| ACTION_CROSS_CAST | 84 | Cast spell cross-faction |
| ACTION_START_CLOSEST_WAYPOINT | 121 | Path to nearest waypoint |

## Conditions integration

Conditions use `SourceTypeOrReferenceId = 22` for SmartAI conditions.
`SourceGroup` = creature entry, `SourceEntry` = smart_scripts entryorguid,
`SourceId` = event/action index.

Example: Add a condition that a quest must be in progress:
```sql
INSERT INTO conditions (SourceTypeOrReferenceId, SourceGroup, SourceEntry, SourceId, 
  ElseGroup, ConditionTypeOrReference, ConditionTarget, ConditionValue1, ...)
VALUES (22, <creatureEntry>, <smartScriptsId>, <actionIndex>,
  0, 47, 0, <questId>, ...);
```

## Common patterns

### Boss phases
Use `HEALTH_PCT` events to trigger phase transitions, `SET_EVENT_PHASE` to track
phase, and `INC_COUNTER`/`COUNTER` for multi-step mechanics.

### Timed ability rotation
Use `UPDATE_IC` for periodic checks and `TIMED_ACTIONLIST` for cast sequences.

### Quest-gated behavior
Use conditions on events/actions to check quest status before firing.

### Spawn/respawn setup
Use `RESPAWN` event to set initial flags, equipment, or auras.

## Troubleshooting

| Issue | Likely cause |
|---|---|
| SmartAI not firing | `AIName` not set to `'SmartAI'` in creature_template |
| Event not triggering | Wrong event_type or event_flags |
| Action does nothing | Wrong action_type or target_type |
| Phase not working | Event not setting `event_phase_mask` correctly |
| Conditions ignored | Missing condition row or wrong SourceTypeOrReferenceId |