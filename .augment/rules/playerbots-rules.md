---
trigger: model_decision
description: Apply when working with mod-playerbots, bot AI, bot commands, bot configuration, or bot performance optimization
---
# Playerbots Module Rules

## Bot Types

<bot_types>
- **Alt Bots**: Player's own characters logged in as bots, controlled via chat commands
- **Random Bots**: Autonomous bots wandering world, completing quests independently
- **Bot Classes**: All 10 WotLK classes supported with class-specific AI
- **Specialization**: Talent specialization support for each class
- **Gear Optimization**: Bot gear scales with difficulty and progression
</bot_types>

## Configuration

<configuration>
- Main config: `conf/playerbots.conf.dist`
- **AiPlayerbot.Enabled**: Enable/disable module (default: 1)
- **AiPlayerbot.RandomBotAutologin**: Auto-login random bots (default: 1)
- **AiPlayerbot.RandomBotCount**: Number of random bots (default: 50)
- **AiPlayerbot.RandomBotMinLevel**: Minimum bot level (default: 10)
- **AiPlayerbot.RandomBotMaxLevel**: Maximum bot level (default: 80)
- **AiPlayerbot.AltsEnabled**: Enable alt bots (default: 1)
- **AiPlayerbot.MaxAltsPerPlayer**: Max alts per player (default: 5)
- **AiPlayerbot.UpdateInterval**: Update frequency in ms (default: 100)
- All settings must have safe defaults
</configuration>

## Bot Commands

<bot_commands>
- `.bot add <class>`: Create new bot
- `.bot remove <name>`: Remove bot
- `.bot list`: List all bots
- `.bot follow`: Bot follows you
- `.bot stay`: Bot stays in place
- `.bot attack`: Bot attacks target
- `.bot invite`: Invite bot to group
- `.bot leave`: Bot leaves group
- `.bot strategy <name>`: Set bot strategy
- `.bot role <role>`: Set bot role (tank/dps/heal)
</bot_commands>

## Bot AI System

<bot_ai>
- **Decision Making**: Event-driven behavior system
- **Combat Strategy**: Spell rotation, cooldown management, threat handling
- **Movement**: Pathfinding, combat movement, waypoint following
- **Class-Specific**: Optimized AI for each WotLK class
- **Threat Management**: Threat calculation and target switching
- **Resource Management**: Mana, rage, energy management
- Test bot behavior in different scenarios
- Monitor bot performance for excessive CPU usage
</bot_ai>

## Performance Optimization

<performance>
- **Bot Count**: 100-200 bots per 4-core server (25-50 per core)
- **Update Interval**: Default 100ms, reduce to 50ms for responsiveness, increase to 200ms for performance
- **Pathfinding**: Cache frequently used paths, limit pathfinding distance
- **Monitoring**: Watch CPU usage, memory usage, update latency
- Reduce bot count if performance degrades
- Disable unnecessary features if needed
- Profile slow bots with server logs
</performance>

## LLM Integration (Optional)

<llm_integration>
- **Module**: mod-playerbots-llm (optional advanced AI)
- **Providers**: OpenAI, Claude, other LLM providers
- **Vector Database**: Qdrant for learning/memory
- **Features**: Dynamic strategy adaptation, heuristic learning
- **Configuration**: Set LLM provider, vector database, learning parameters
- **Performance**: Monitor CPU/memory impact of LLM processing
- Disable if performance issues occur
</llm_integration>

## Testing & Debugging

<testing_rules>
- Test on development realm (8086) first
- Use `.bot count` to check active bots
- Use `.bot stats` for performance metrics
- Enable debug logging: `.debug on`
- Check logs: `tail -f env/dist/logs-dev/Server.log | grep -i bot`
- Test bot behavior in different scenarios (combat, movement, healing)
- Verify no conflicts with other modules
- Monitor bot performance during testing
</testing_rules>

## Common Issues

<common_issues>
- **Bots not spawning**: Verify AiPlayerbot.Enabled=1, check RandomBotAutologin, verify bot count setting
- **Bots stuck in combat**: Use `.bot unstuck`, increase update frequency, check pathfinding
- **Bots not grouping**: Verify AltsEnabled=1, check party size limits, verify bot availability
- **Bots causing lag**: Reduce bot count, increase update interval, disable unnecessary features
- **Bot not healing**: Verify healing spells known, check mana, verify healing strategy active
- **Bot not casting**: Verify spell known, check mana/resource, verify cooldowns, check target validity
</common_issues>

## Integration with Other Modules

<module_integration>
- **Mythic Plus**: Bots support Mythic+ dungeons, difficulty scaling applies
- **Solocraft**: Bots count toward party size, scaling adjusts for bot presence
- **Progression System**: Bots respect level brackets, follow progression rules
- **Challenge Modes**: Bots can participate in hardcore/iron man modes
- Test bot integration with each module
- Verify no conflicts or unintended interactions
</module_integration>

## Database Tables

<database_tables>
- **ai_playerbot_config**: Bot configuration and state (name, class, level, equipment, talents)
- **ai_playerbot_strategy**: Bot strategy definitions (action priorities, spell selections)
- **ai_playerbot_tactics**: Bot tactic definitions (movement, combat, healing priorities)
- Backup playerbots database before major changes
- Verify table structure after schema updates
</database_tables>

## Best Practices

<best_practices>
- Start with low bot count and increase gradually
- Monitor performance continuously
- Use appropriate strategies for bot class/role
- Test bot behavior in different scenarios
- Keep bot configuration documented
- Backup bot database regularly
- Update bot AI with new patches
- Optimize pathfinding for your maps
- Balance bot difficulty with player experience
- Use LLM integration for advanced behavior (optional)
</best_practices>

## Critical Safety Issues (2026-02-04)

### Known Race Conditions in Group Operations

**Arena Group Formation** (PlayerbotOperations.h line 319-330)
- **Issue**: Time-of-check-to-time-of-use race condition
- **Symptom**: Crashes when forming arena groups with bots
- **Root Cause**: Player can disconnect between `ObjectAccessor::FindPlayer()` and `newGroup->AddMember(member)`
- **Mitigation**: 
  - Always check `member->IsInWorld()` before AddMember
  - Verify player still valid after FindPlayer call
  - Add defensive null checks around group operations
- **Status**: KNOWN ISSUE - Use caution with arena group operations

### Unsafe Guild Operations

**Guild Member Access** (GuildManagementActions.cpp line 87)
- **Issue**: Missing null checks on guild and member pointers
- **Symptom**: Crashes when bots interact with guild systems
- **Root Cause**: `GetGuildById()` or `GetMember()` can return nullptr
- **Mitigation**:
  - Always check guild pointer before access: `if (!guild) return;`
  - Always check member pointer before access: `if (!guildMember) return;`
  - Never chain method calls without intermediate null checks
- **Status**: KNOWN ISSUE - Avoid guild operations with bots until patched

### Bot Session Validation

**Session Null Checks**
- **Issue**: Bot players may have null or invalid sessions
- **Symptom**: Crashes in session-dependent operations
- **Root Cause**: Bots don't have real client sessions
- **Mitigation**:
  - Use `member->IsInWorld()` to verify bot is active
  - Check `member->GetSession()` before accessing session data
  - Combine checks: `if (!member->IsInWorld() || !member->GetSession()) continue;`
- **Status**: KNOWN ISSUE - Apply defensive checks in all bot group operations

### Safe Group Operation Patterns

✓ **Safe**: Use GUID-based removal with ObjectAccessor
```cpp
group->RemoveMember(player->GetGUID(), GROUP_REMOVEMETHOD_LEAVE);
```

✓ **Safe**: GroupReference iteration with null checks
```cpp
for (GroupReference* gref = group->GetFirstMember(); gref; gref = gref->next()) {
    Player* member = gref->GetSource();
    if (!member) continue;
    // Safe to use member
}
```

✓ **Safe**: AddMember validates player pointer
```cpp
if (group->AddMember(player)) {
    // Success - player was valid
}
```

❌ **Unsafe**: Direct pointer dereference without checks
```cpp
Player* member = ObjectAccessor::FindPlayer(guid);
member->DoSomething();  // CRASH if member is nullptr
```

### Testing Recommendations

- Test bot group formation/disbanding extensively
- Monitor logs for race condition symptoms
- Use development realm (8086) for all bot group testing
- Enable debug logging during group operations
- Check for crashes in arena group formation scenarios
- Verify guild operations don't crash with bot participation
