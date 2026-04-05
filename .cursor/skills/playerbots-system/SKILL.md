---
name: playerbots-system
description: Documents mod-playerbots architecture, bot types, performance, and key database tables. Use when editing playerbots code, config, or ai_playerbot_* SQL.
---

# Playerbots System Guide

## Overview
The mod-playerbots module adds AI-driven player-like bots to AzerothCore. This guide covers the system architecture and configuration.

## MCP (use when connected)

- **azerothcore**: `query_database` on `ai_playerbot_*` tables; `soap_check_connection` / `soap_server_info` when checking live bot load; `search_azerothcore_source` / `read_source_file` for core/module C++ paths.
- **oldmanwarcraft-api-remote**: `omw_search_armory_characters`, `omw_get_armory_character`, PvP/leaderboard tools when correlating **site** data with bot behavior (not a substitute for SQL on the realm DB).
- **Notion**: strategies your team documented for OMW bot tuning.
- Full tool names: `.cursor/reference/mcp-tools-inventory.md`.

## Core Concepts

### Bot Types

**Alt Bots**
- Player's own characters logged in as bots
- Controlled via chat commands
- Can form parties with player
- Useful for solo content and leveling

**Random Bots**
- Autonomous bots wandering the world
- Complete quests independently
- Run dungeons and raids
- Populate the server world

**Bot Classes**
- All 10 WotLK classes supported
- Class-specific AI and strategies
- Talent specialization support
- Gear optimization

### Bot AI System

**Decision Making**
- Event-driven behavior system
- Combat strategy selection
- Target prioritization
- Threat management

**Movement**
- Pathfinding and navigation
- Combat movement
- Waypoint following
- Evade and reset handling

**Combat**
- Spell rotation execution
- Cooldown management
- Threat monitoring
- Healing and support

### LLM Integration (mod-playerbots-llm)

**Features**
- Large Language Model decision making
- Vector database for learning
- Dynamic strategy adaptation
- Heuristic learning from interactions

**Configuration**
- LLM provider (OpenAI, Claude, etc.)
- Vector database (Qdrant)
- Learning rate and parameters
- Strategy optimization

## Configuration

### Main Configuration File
**Location**: `conf/playerbots.conf.dist`

**Key Settings**:

```
# Enable/disable playerbots module
AiPlayerbot.Enabled = 1

# Random bot settings
AiPlayerbot.RandomBotAutologin = 1
AiPlayerbot.RandomBotCount = 50
AiPlayerbot.RandomBotMinLevel = 10
AiPlayerbot.RandomBotMaxLevel = 80

# Alt bot settings
AiPlayerbot.AltsEnabled = 1
AiPlayerbot.MaxAltsPerPlayer = 5

# Performance settings
AiPlayerbot.UpdateInterval = 100
AiPlayerbot.MaxBotProcessingTime = 50

# Difficulty settings
AiPlayerbot.DungeonDifficulty = 1
AiPlayerbot.RaidDifficulty = 1

# Economy settings
AiPlayerbot.GoldPerLevel = 100
AiPlayerbot.GoldPerKill = 10
```

### Bot Strategy Configuration

**Strategy Types**
- Tank strategies (threat management, mitigation)
- DPS strategies (damage optimization, positioning)
- Healer strategies (healing priority, mana management)
- Support strategies (buffs, debuffs, crowd control)

**Tactic Selection**
- Combat tactics (rotation, cooldown usage)
- Movement tactics (positioning, kiting)
- Survival tactics (healing, defensive abilities)
- Group tactics (party coordination)

## Bot Commands

### Basic Commands
```
.bot add <class> - Create new bot
.bot remove <name> - Remove bot
.bot list - List all bots
.bot info <name> - Get bot info
```

### Control Commands
```
.bot follow - Bot follows you
.bot stay - Bot stays in place
.bot attack - Bot attacks target
.bot cast <spell> - Bot casts spell
.bot equip <item> - Bot equips item
```

### Group Commands
```
.bot invite - Invite bot to group
.bot leave - Bot leaves group
.bot disband - Disband bot group
```

### Strategy Commands
```
.bot strategy <name> - Set bot strategy
.bot tactics <name> - Set bot tactics
.bot role <role> - Set bot role (tank/dps/heal)
```

## Bot AI Architecture

### Event System
- Combat events (aggro, kill, death)
- Movement events (reached waypoint, blocked)
- Spell events (cast complete, interrupted)
- Item events (loot, equip)

### Decision Tree
```
1. Check if alive
2. Check if in combat
3. If in combat:
   - Evaluate threats
   - Select target
   - Choose action (cast, move, heal)
4. If out of combat:
   - Check for nearby enemies
   - Follow waypoint
   - Perform idle action
```

### Action Selection
- Priority-based action selection
- Cooldown checking
- Resource management (mana, rage, energy)
- Target validation

### Threat Management
- Threat calculation per target
- Threat table maintenance
- Threat-based target switching
- Aggro management

## Performance Optimization

### Bot Count Tuning
```
Server CPU: 4 cores
Recommended bot count: 100-200
Per-core budget: 25-50 bots

Monitor:
- CPU usage
- Memory usage
- Update latency
- Player latency
```

### Update Frequency
```
Default: 100ms per bot
Reduce for better responsiveness: 50ms
Increase for better performance: 200ms

Trade-off: Responsiveness vs CPU usage
```

### Pathfinding Optimization
```
- Cache frequently used paths
- Use simplified pathfinding for distant targets
- Limit pathfinding distance
- Batch pathfinding updates
```

## Debugging Bot Issues

### Bot Not Moving
1. Check if bot is stuck (use `.bot unstuck`)
2. Verify pathfinding is working
3. Check for obstacles
4. Review bot logs for errors

### Bot Not Casting Spells
1. Verify spell is known (`.bot spells`)
2. Check mana/resource availability
3. Verify cooldowns
4. Check target validity

### Bot Not Healing
1. Verify healing spells are known
2. Check mana availability
3. Verify healing strategy is active
4. Check party member health

### Bot Performance Issues
1. Reduce bot count
2. Increase update interval
3. Disable LLM integration (if enabled)
4. Monitor CPU usage

## Database Tables

### ai_playerbot_config
Stores bot configuration and state:
- Bot name and class
- Level and experience
- Equipment and inventory
- Talent specialization
- Strategy and tactics

### ai_playerbot_strategy
Stores bot strategy definitions:
- Strategy name and description
- Action priorities
- Spell selections
- Cooldown management

### ai_playerbot_tactics
Stores bot tactic definitions:
- Tactic name and description
- Movement patterns
- Combat behaviors
- Healing priorities

## Common Issues

### Bots Not Spawning
1. Verify `AiPlayerbot.Enabled = 1`
2. Check `AiPlayerbot.RandomBotAutologin = 1`
3. Verify bot count setting
4. Check server logs for errors

### Bots Stuck in Combat
1. Use `.bot unstuck` command
2. Increase bot update frequency
3. Check for pathfinding issues
4. Verify evade mechanics

### Bots Not Grouping
1. Verify `AiPlayerbot.AltsEnabled = 1`
2. Check party size limits
3. Verify bot availability
4. Check for permission issues

### Bots Causing Lag
1. Reduce bot count
2. Increase update interval
3. Disable unnecessary features
4. Monitor CPU and memory usage

## Integration with Other Modules

### Mythic Plus System
- Bots support Mythic+ dungeons
- Difficulty scaling applies to bots
- Bot gear scales with difficulty
- Loot distribution to bots

### Solocraft System
- Bots count toward party size
- Scaling adjusts for bot presence
- Bot damage/healing scaled appropriately
- Loot adjusted for bot participation

### Progression System
- Bots respect level brackets
- Content locked by progression
- Bots follow progression rules
- Experience scaled by progression

## Advanced Configuration

### Custom Bot Strategies
Create custom strategy in database:
```sql
INSERT INTO ai_playerbot_strategy (name, description, priority1, action1, priority2, action2)
VALUES ('custom_tank', 'Custom tank strategy', 1, 'taunt', 2, 'shield_block');
```

### Custom Bot Tactics
Create custom tactic in database:
```sql
INSERT INTO ai_playerbot_tactics (name, description, movement, combat, healing)
VALUES ('aggressive', 'Aggressive tactics', 'charge', 'melee', 'low_priority');
```

### LLM Integration Setup
1. Configure LLM provider (OpenAI/Claude)
2. Set up vector database (Qdrant)
3. Configure learning parameters
4. Enable LLM in playerbots.conf

## Monitoring and Metrics

### Bot Statistics
```bash
# Check active bots
.bot count

# Check bot performance
.bot stats

# Check bot health
.bot health <name>
```

### Performance Metrics
- Bots per second (update frequency)
- Average decision time
- Pathfinding cache hit rate
- Combat action frequency

### Logging
```bash
# Enable bot debug logging
.debug on

# View bot logs
tail -f env/dist/logs/Server.log | grep -i "bot\|playerbot"

# Search for specific bot
grep "bot_name" env/dist/logs/Server.log
```

## Best Practices

1. **Start with low bot count** and increase gradually
2. **Monitor performance** continuously
3. **Use appropriate strategies** for bot class/role
4. **Test bot behavior** in different scenarios
5. **Keep bot configuration** documented
6. **Backup bot database** regularly
7. **Update bot AI** with new patches
8. **Optimize pathfinding** for your maps
9. **Balance bot difficulty** with player experience
10. **Use LLM integration** for advanced behavior

## Related Resources

- Playerbots Wiki: https://github.com/mod-playerbots/mod-playerbots/wiki
- Playerbots Discord: https://discord.gg/NQm5QShwf9
- Configuration Guide: https://github.com/mod-playerbots/mod-playerbots/blob/master/conf/playerbots.conf.dist
- LLM Module: https://github.com/mod-playerbots/mod-playerbots-llm
