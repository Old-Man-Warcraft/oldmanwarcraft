---
name: smartai-reference
description: Reference for SmartAI events, actions, targets, phases, and linking. Use when authoring or debugging smart_scripts.
---

# SmartAI Reference Guide

## Overview
SmartAI is a database-driven scripting system for NPC behavior. This guide provides quick reference for all event, action, and target types.

## MCP (when connected)

- **azerothcore**: `get_smart_scripts`, `explain_smart_script`, `trace_script_chain`, `generate_sai_comments`, `list_smart_event_types`, `list_smart_action_types`, `list_smart_target_types`, `search_creatures`, `get_creature_with_scripts`, `get_creature_waypoints`, `search_gameobjects`.
- **Notion**: reload/restart and production windows.
- **fetch** / **firecrawl** / **exa**: External SAI examples—verify event/action IDs against this reference and live DB.
- Full list: `.cursor/reference/mcp-tools-inventory.md`.

## Event Types (110+ types)

### Combat Events
- **0**: `SMART_EVENT_UPDATE_IC` - In-combat pulse (every update)
- **1**: `SMART_EVENT_UPDATE_OOC` - Out-of-combat pulse
- **4**: `SMART_EVENT_AGGRO` - Entering combat
- **5**: `SMART_EVENT_KILL` - Killing a unit
- **6**: `SMART_EVENT_DEATH` - Creature death
- **7**: `SMART_EVENT_EVADE` - Evade/reset combat

### Health/Mana Events
- **2**: `SMART_EVENT_HEALTH_PCT` - Health percentage reached
- **3**: `SMART_EVENT_MANA_PCT` - Mana percentage reached
- **12**: `SMART_EVENT_TARGET_HEALTH_PCT` - Target health percentage
- **18**: `SMART_EVENT_TARGET_MANA_PCT` - Target mana percentage
- **14**: `SMART_EVENT_FRIENDLY_HEALTH` - Friendly unit low health
- **74**: `SMART_EVENT_FRIENDLY_HEALTH_PCT` - Friendly health percentage

### Spell/Damage Events
- **8**: `SMART_EVENT_SPELLHIT` - Hit by spell
- **31**: `SMART_EVENT_SPELLHIT_TARGET` - Target hit by spell
- **32**: `SMART_EVENT_DAMAGED` - Creature took damage
- **33**: `SMART_EVENT_DAMAGED_TARGET` - Target took damage
- **53**: `SMART_EVENT_RECEIVE_HEAL` - Received healing

### Casting Events
- **13**: `SMART_EVENT_VICTIM_CASTING` - Victim is casting
- **52**: `SMART_EVENT_TEXT_OVER` - Creature text finished

### Buff/Debuff Events
- **16**: `SMART_EVENT_FRIENDLY_MISSING_BUFF` - Friendly missing buff
- **23**: `SMART_EVENT_HAS_AURA` - Unit has aura
- **24**: `SMART_EVENT_TARGET_BUFFED` - Target has aura

### Movement Events
- **21**: `SMART_EVENT_REACHED_HOME` - Reached home position
- **34**: `SMART_EVENT_MOVEMENTINFORM` - Movement finished
- **65**: `SMART_EVENT_FOLLOW_COMPLETED` - Follow action completed
- **108**: `SMART_EVENT_WAYPOINT_REACHED` - Waypoint reached
- **109**: `SMART_EVENT_WAYPOINT_ENDED` - Waypoint path ended

### Summoning Events
- **17**: `SMART_EVENT_SUMMONED_UNIT` - Summoned a unit
- **35**: `SMART_EVENT_SUMMON_DESPAWNED` - Summoned unit despawned
- **54**: `SMART_EVENT_JUST_SUMMONED` - Just summoned by another unit
- **82**: `SMART_EVENT_SUMMONED_UNIT_DIES` - Summoned creature died
- **107**: `SMART_EVENT_SUMMONED_UNIT_EVADE` - Summoned unit evaded

### Quest Events
- **19**: `SMART_EVENT_ACCEPTED_QUEST` - Quest accepted by player
- **20**: `SMART_EVENT_REWARD_QUEST` - Quest rewarded to player

### Interaction Events
- **22**: `SMART_EVENT_RECEIVE_EMOTE` - Received emote from player
- **62**: `SMART_EVENT_GOSSIP_SELECT` - Gossip option selected
- **64**: `SMART_EVENT_GOSSIP_HELLO` - NPC gossip opened
- **73**: `SMART_EVENT_ON_SPELLCLICK` - Spellclick used

### Initialization Events
- **37**: `SMART_EVENT_AI_INIT` - AI initialized
- **63**: `SMART_EVENT_JUST_CREATED` - Just created/spawned
- **11**: `SMART_EVENT_RESPAWN` - On respawn
- **25**: `SMART_EVENT_RESET` - After combat/respawn/spawn

### Vehicle Events
- **27**: `SMART_EVENT_PASSENGER_BOARDED` - Vehicle passenger boarded
- **28**: `SMART_EVENT_PASSENGER_REMOVED` - Vehicle passenger removed

### State Events
- **29**: `SMART_EVENT_CHARMED` - Unit charmed/mind controlled
- **30**: `SMART_EVENT_CHARMED_TARGET` - Charmed target event
- **38**: `SMART_EVENT_DATA_SET` - SetData called on creature
- **66**: `SMART_EVENT_EVENT_PHASE_CHANGE` - Event phase changed
- **70**: `SMART_EVENT_GO_STATE_CHANGED` - GO state changed
- **77**: `SMART_EVENT_COUNTER_SET` - Counter set to value

### Range/Distance Events
- **9**: `SMART_EVENT_RANGE` - Target in range check
- **10**: `SMART_EVENT_OOC_LOS` - Out of combat, target in LOS
- **26**: `SMART_EVENT_IC_LOS` - In combat, target in LOS
- **67**: `SMART_EVENT_IS_BEHIND_TARGET` - Behind target check
- **75**: `SMART_EVENT_DISTANCE_CREATURE` - Distance to creature
- **76**: `SMART_EVENT_DISTANCE_GAMEOBJECT` - Distance to gameobject
- **110**: `SMART_EVENT_IS_IN_MELEE_RANGE` - In melee range check

### Game Event Events
- **68**: `SMART_EVENT_GAME_EVENT_START` - Game event started
- **69**: `SMART_EVENT_GAME_EVENT_END` - Game event ended

### Gameobject Events
- **46**: `SMART_EVENT_AREATRIGGER_ONTRIGGER` - Areatrigger triggered
- **71**: `SMART_EVENT_GO_EVENT_INFORM` - GO event inform

### Instance Events
- **45**: `SMART_EVENT_INSTANCE_PLAYER_ENTER` - Player entered instance

### Transport Events
- **41**: `SMART_EVENT_TRANSPORT_ADDPLAYER` - Player added to transport
- **42**: `SMART_EVENT_TRANSPORT_ADDCREATURE` - Creature added to transport
- **43**: `SMART_EVENT_TRANSPORT_REMOVE_PLAYER` - Player removed from transport
- **44**: `SMART_EVENT_TRANSPORT_RELOCATE` - Transport relocated

### Timer Events
- **59**: `SMART_EVENT_TIMED_EVENT_TRIGGERED` - Timed event triggered
- **60**: `SMART_EVENT_UPDATE` - Pulse (in or out of combat)

### Linking Events
- **61**: `SMART_EVENT_LINK` - Linked from another script
- **72**: `SMART_EVENT_ACTION_DONE` - Action completed

### Player Proximity Events
- **101**: `SMART_EVENT_NEAR_PLAYERS` - Near minimum players
- **102**: `SMART_EVENT_NEAR_PLAYERS_NEGATION` - Below max players nearby

## Action Types (100+ types)

### Communication Actions
- **1**: `SMART_ACTION_TALK` - Say/yell/emote from creature_text
- **4**: `SMART_ACTION_SOUND` - Play sound
- **5**: `SMART_ACTION_PLAY_EMOTE` - Play emote animation
- **10**: `SMART_ACTION_RANDOM_EMOTE` - Play random emote
- **17**: `SMART_ACTION_SET_EMOTE_STATE` - Set emote state
- **84**: `SMART_ACTION_SIMPLE_TALK` - Simple talk (targets speak)

### Combat Actions
- **11**: `SMART_ACTION_CAST` - Cast spell on target
- **20**: `SMART_ACTION_AUTO_ATTACK` - Enable/disable auto attack
- **21**: `SMART_ACTION_ALLOW_COMBAT_MOVEMENT` - Allow combat movement
- **24**: `SMART_ACTION_EVADE` - Force evade
- **25**: `SMART_ACTION_FLEE_FOR_ASSIST` - Flee and call for help
- **27**: `SMART_ACTION_COMBAT_STOP` - Stop combat
- **39**: `SMART_ACTION_CALL_FOR_HELP` - Call for help
- **49**: `SMART_ACTION_ATTACK_START` - Start attacking target
- **85**: `SMART_ACTION_SELF_CAST` - Self-cast spell
- **86**: `SMART_ACTION_CROSS_CAST` - Casters cast on targets
- **92**: `SMART_ACTION_INTERRUPT_SPELL` - Interrupt spell cast
- **122**: `SMART_ACTION_FLEE` - Flee from combat
- **123**: `SMART_ACTION_ADD_THREAT` - Add/remove threat

### Movement Actions
- **29**: `SMART_ACTION_FOLLOW` - Follow target
- **46**: `SMART_ACTION_MOVE_FORWARD` - Move forward
- **59**: `SMART_ACTION_SET_RUN` - Set run/walk
- **60**: `SMART_ACTION_SET_FLY` - Set fly mode
- **61**: `SMART_ACTION_SET_SWIM` - Set swim mode
- **62**: `SMART_ACTION_TELEPORT` - Teleport target
- **66**: `SMART_ACTION_SET_ORIENTATION` - Set facing/orientation
- **69**: `SMART_ACTION_MOVE_TO_POS` - Move to position
- **79**: `SMART_ACTION_SET_RANGED_MOVEMENT` - Set ranged movement
- **89**: `SMART_ACTION_RANDOM_MOVE` - Random movement
- **97**: `SMART_ACTION_JUMP_TO_POS` - Jump to position
- **101**: `SMART_ACTION_SET_HOME_POS` - Set home position
- **232**: `SMART_ACTION_WAYPOINT_START` - Start waypoint
- **234**: `SMART_ACTION_MOVEMENT_STOP` - Movement stop
- **235**: `SMART_ACTION_MOVEMENT_PAUSE` - Movement pause
- **236**: `SMART_ACTION_MOVEMENT_RESUME` - Movement resume

### Summoning Actions
- **12**: `SMART_ACTION_SUMMON_CREATURE` - Summon creature
- **50**: `SMART_ACTION_SUMMON_GO` - Summon gameobject
- **107**: `SMART_ACTION_SUMMON_CREATURE_GROUP` - Summon creature group

### State/Flag Actions
- **2**: `SMART_ACTION_SET_FACTION` - Change faction
- **3**: `SMART_ACTION_MORPH_TO_ENTRY_OR_MODEL` - Change model
- **8**: `SMART_ACTION_SET_REACT_STATE` - Set react state
- **18**: `SMART_ACTION_SET_UNIT_FLAG` - Set unit flags
- **19**: `SMART_ACTION_REMOVE_UNIT_FLAG` - Remove unit flags
- **22**: `SMART_ACTION_SET_EVENT_PHASE` - Set event phase
- **23**: `SMART_ACTION_INC_EVENT_PHASE` - Increment/decrement phase
- **30**: `SMART_ACTION_RANDOM_PHASE` - Set random phase
- **31**: `SMART_ACTION_RANDOM_PHASE_RANGE` - Set phase in range
- **40**: `SMART_ACTION_SET_SHEATH` - Set sheath state
- **43**: `SMART_ACTION_MOUNT_TO_ENTRY_OR_MODEL` - Mount/dismount
- **44**: `SMART_ACTION_SET_INGAME_PHASE_MASK` - Set phase mask
- **47**: `SMART_ACTION_SET_VISIBILITY` - Set visibility
- **48**: `SMART_ACTION_SET_ACTIVE` - Set active (keep updated)
- **63**: `SMART_ACTION_SET_COUNTER` - Set counter value
- **81**: `SMART_ACTION_SET_NPC_FLAG` - Set NPC flags
- **82**: `SMART_ACTION_ADD_NPC_FLAG` - Add NPC flags
- **83**: `SMART_ACTION_REMOVE_NPC_FLAG` - Remove NPC flags
- **103**: `SMART_ACTION_SET_ROOT` - Root/unroot
- **117**: `SMART_ACTION_DISABLE_EVADE` - Disable evade
- **142**: `SMART_ACTION_SET_HEALTH_PCT` - Set health percentage

### Quest/Loot Actions
- **6**: `SMART_ACTION_FAIL_QUEST` - Fail quest for player
- **7**: `SMART_ACTION_OFFER_QUEST` - Offer quest to player
- **15**: `SMART_ACTION_CALL_AREAEXPLOREDOREVENTHAPPENS` - Complete quest area/event
- **26**: `SMART_ACTION_CALL_GROUPEVENTHAPPENS` - Group quest event
- **33**: `SMART_ACTION_CALL_KILLEDMONSTER` - Credit kill for quest
- **56**: `SMART_ACTION_ADD_ITEM` - Add item to player
- **57**: `SMART_ACTION_REMOVE_ITEM` - Remove item from player

### Gameobject Actions
- **9**: `SMART_ACTION_ACTIVATE_GOBJECT` - Activate gameobject
- **32**: `SMART_ACTION_RESET_GOBJECT` - Reset gameobject
- **70**: `SMART_ACTION_RESPAWN_TARGET` - Respawn target GO/creature
- **99**: `SMART_ACTION_GO_SET_LOOT_STATE` - Set GO loot state

### Aura/Buff Actions
- **28**: `SMART_ACTION_REMOVEAURASFROMSPELL` - Remove auras from spell
- **75**: `SMART_ACTION_ADD_AURA` - Add aura to target

### Instance/Data Actions
- **34**: `SMART_ACTION_SET_INST_DATA` - Set instance data
- **35**: `SMART_ACTION_SET_INST_DATA64` - Set instance data 64-bit
- **45**: `SMART_ACTION_SET_DATA` - Set data on target

### Creature Template Actions
- **36**: `SMART_ACTION_UPDATE_TEMPLATE` - Update creature template
- **124**: `SMART_ACTION_LOAD_EQUIPMENT` - Load equipment template
- **71**: `SMART_ACTION_EQUIP` - Equip items

### Death/Despawn Actions
- **37**: `SMART_ACTION_DIE` - Kill self
- **41**: `SMART_ACTION_FORCE_DESPAWN` - Despawn creature
- **51**: `SMART_ACTION_KILL_UNIT` - Kill target unit

### Threat Actions
- **13**: `SMART_ACTION_THREAT_SINGLE_PCT` - Modify single target threat %
- **14**: `SMART_ACTION_THREAT_ALL_PCT` - Modify all targets threat %
- **42**: `SMART_ACTION_SET_INVINCIBILITY_HP_LEVEL` - Set invincibility HP

### Taxi/Transport Actions
- **52**: `SMART_ACTION_ACTIVATE_TAXI` - Activate taxi path

### Gossip/Menu Actions
- **72**: `SMART_ACTION_CLOSE_GOSSIP` - Close gossip window
- **98**: `SMART_ACTION_SEND_GOSSIP_MENU` - Send gossip menu

### Script/Event Actions
- **64**: `SMART_ACTION_STORE_TARGET_LIST` - Store current targets
- **67**: `SMART_ACTION_CREATE_TIMED_EVENT` - Create timed event
- **73**: `SMART_ACTION_TRIGGER_TIMED_EVENT` - Trigger timed event
- **74**: `SMART_ACTION_REMOVE_TIMED_EVENT` - Remove timed event
- **78**: `SMART_ACTION_CALL_SCRIPT_RESET` - Reset all scripts
- **80**: `SMART_ACTION_CALL_TIMED_ACTIONLIST` - Call timed action list
- **87**: `SMART_ACTION_CALL_RANDOM_TIMED_ACTIONLIST` - Call random action list
- **88**: `SMART_ACTION_CALL_RANDOM_RANGE_TIMED_ACTIONLIST` - Call random range action list
- **100**: `SMART_ACTION_SEND_TARGET_TO_TARGET` - Send stored targets

### Zone/Combat Actions
- **38**: `SMART_ACTION_SET_IN_COMBAT_WITH_ZONE` - Zone-wide combat

### Health/Regen Actions
- **102**: `SMART_ACTION_SET_HEALTH_REGEN` - Enable/disable health regen

## Target Types (30+ types)

### Self Targets
- **0**: `SMART_TARGET_SELF` - Self (the creature)
- **1**: `SMART_TARGET_VICTIM` - Current victim/target

### Nearby Targets
- **2**: `SMART_TARGET_HOSTILE_RANDOM` - Random hostile nearby
- **3**: `SMART_TARGET_HOSTILE_RANDOM_NOT_TOP` - Random hostile (not top threat)
- **4**: `SMART_TARGET_HOSTILE_NEAREST` - Nearest hostile
- **5**: `SMART_TARGET_HOSTILE_NEAREST_ATTACKABLE` - Nearest attackable hostile
- **6**: `SMART_TARGET_ACTION_INVOKER` - Action invoker (player who triggered)
- **7**: `SMART_TARGET_POSITION` - Position (x, y, z, o)
- **8**: `SMART_TARGET_CREATURE_RANGE` - Creature in range
- **9**: `SMART_TARGET_CREATURE_GUID` - Specific creature by GUID
- **10**: `SMART_TARGET_CREATURE_DISTANCE` - Creature at distance
- **11**: `SMART_TARGET_STORED` - Stored target list
- **12**: `SMART_TARGET_GAMEOBJECT_RANGE` - Gameobject in range
- **13**: `SMART_TARGET_GAMEOBJECT_GUID` - Specific gameobject by GUID
- **14**: `SMART_TARGET_GAMEOBJECT_DISTANCE` - Gameobject at distance
- **15**: `SMART_TARGET_INVOKER_PARTY` - Invoker's party members
- **16**: `SMART_TARGET_PLAYER_RANGE` - Player in range
- **17**: `SMART_TARGET_PLAYER_DISTANCE` - Player at distance

### Friendly Targets
- **18**: `SMART_TARGET_CLOSEST_FRIENDLY` - Closest friendly
- **19**: `SMART_TARGET_CLOSEST_FRIENDLY_MISSING_BUFF` - Closest friendly missing buff
- **20**: `SMART_TARGET_FRIENDLY_OFFSET` - Friendly at offset
- **21**: `SMART_TARGET_FRIENDLY_MISSING_BUFF` - Friendly missing buff

### Summon Targets
- **22**: `SMART_TARGET_SUMMONED_CREATURE` - Summoned creature
- **23**: `SMART_TARGET_CLOSEST_ENEMY` - Closest enemy
- **24**: `SMART_TARGET_CLOSEST_ENEMY_NOT_TOP` - Closest enemy (not top threat)

### Owner/Master Targets
- **25**: `SMART_TARGET_OWNER_OR_SUMMONER` - Owner or summoner
- **26**: `SMART_TARGET_THREAT_LIST` - All threat list members
- **27**: `SMART_TARGET_CLOSEST_PLAYER` - Closest player
- **28**: `SMART_TARGET_PLAYER_TANKING_ME` - Player tanking me
- **29**: `SMART_TARGET_RANDOM_PLAYER` - Random player

## Event Parameters

### Health/Mana Events (2, 3, 12, 18, 74)
- `param1`: Health/Mana percentage (0-100)
- `param2`: Repeat (0=once, 1=repeat)
- `param3`: Unused
- `param4`: Unused

### Range Events (9, 75, 76)
- `param1`: Min distance
- `param2`: Max distance
- `param3`: Repeat (0=once, 1=repeat)
- `param4`: Unused

### Spell Events (8, 31)
- `param1`: Spell ID
- `param2`: School mask (0=any)
- `param3`: Repeat (0=once, 1=repeat)
- `param4`: Unused

### Timer Events (59, 67)
- `param1`: Timer ID
- `param2`: Timer value (ms)
- `param3`: Repeat (0=once, 1=repeat)
- `param4`: Unused

## Action Parameters

### Cast Action (11, 85, 86)
- `param1`: Spell ID
- `param2`: Cast flags
- `param3`: Triggered (0=normal, 1=triggered)
- `param4`: Unused

### Summon Action (12, 107)
- `param1`: Creature entry
- `param2`: Duration (0=permanent)
- `param3`: Attack invoker (0=no, 1=yes)
- `param4`: Despawn timer (ms)

### Teleport Action (62)
- `param1`: Map ID
- `param2`: Unused
- `param3`: Unused
- `param4`: Unused

### Movement Action (69, 97)
- `param1`: Speed (0=walk, 1=run)
- `param2`: Unused
- `param3`: Unused
- `param4`: Unused

## Best Practices

1. **Use SMART_EVENT_JUST_CREATED** (63) for initialization, not RESPAWN
2. **Minimize UPDATE_IC/OOC** events—they fire every update cycle
3. **Use conditions** to filter unnecessary event triggers
4. **Document phases** in comments for complex scripts
5. **Test phase transitions** thoroughly—bugs cause infinite loops
6. **Use SMART_EVENT_LINK** (61) for sequential actions
7. **Cache data** in SetData/GetData instead of querying repeatedly
8. **Monitor performance** of frequently-triggered events
9. **Use stored target lists** for complex multi-target scenarios
10. **Always verify target types** match your intent

## Related Resources

- SmartAI Wiki: https://www.azerothcore.org/wiki/smart_scripts
- Introduction to SmartAI: https://www.azerothcore.org/wiki/introduction-to-smartai
- SmartAI Examples: https://www.azerothcore.org/wiki/smart_scripts_examples
