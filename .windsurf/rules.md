# AzerothCore WotLK Development Rules

## Project Overview
This is a **World of Warcraft: Wrath of the Lich King (3.3.5a)** private server built on **AzerothCore**, featuring:
- **mod-playerbots**: AI-driven player-like bots with LLM integration
- **Mythic Plus System**: Progressive difficulty scaling beyond Heroic
- **Solocraft**: Automatic scaling for solo players
- **15+ custom modules**: Economy, progression, PvP, anti-cheat, and more

**Repository**: `mod-playerbots/azerothcore-wotlk` (Playerbot branch)
**Databases**: `acore_world` (shared), `acore_characters`, `acore_playerbots`, `acore_auth`
**Realms**: Production (8085), Development (8086)

---

## Architecture & Core Systems

### 1. SmartAI Scripting System
**Purpose**: Database-driven NPC/creature behavior without C++ code

**Key Concepts**:
- **Events** (110+ types): Triggers like health %, combat, quest, timers, etc.
- **Actions** (100+ types): Responses like casting, movement, dialogue, summoning
- **Targets** (30+ types): Who the action affects (self, victim, nearby, stored lists)
- **Conditions**: Optional filters using the conditions table
- **Phases**: Event grouping for complex multi-stage behaviors
- **Links**: Chaining scripts together for sequential execution

**Critical Rules**:
- Always use `SMART_EVENT_JUST_CREATED` (ID 63) for initialization, not `SMART_EVENT_RESPAWN`
- Use `SMART_EVENT_UPDATE_IC` (0) and `SMART_EVENT_UPDATE_OOC` (1) for pulse-based logic
- Link scripts with `SMART_EVENT_LINK` (61) for complex chains
- Test phase transitions thoroughly—bugs cause infinite loops
- Document event phases in comments for maintainability

**Table**: `smart_scripts` (entryorguid, source_type, id, link, event_type, event_phase_mask, event_chance, event_flags, event_param1-4, action_type, action_param1-6, target_type, target_param1-3, target_x/y/z/o, comment)

### 2. Spell System
**Core Files**: `src/server/game/Spells/`, `src/server/game/Auras/`

**Key Concepts**:
- **Spell.dbc**: Client data (effects, casting time, range, family, proc flags)
- **spell_dbc**: Server-side spell definitions
- **spell_proc**: Proc trigger configuration (when auras activate)
- **spell_proc_event**: Legacy proc event data (being phased out)
- **Proc Flags**: Bitmasks defining when spells trigger (0x1=kill, 0x2=killed, 0x4=melee auto, etc.)
- **Spell Families**: Class-specific spell groupings (SPELLFAMILY_MAGE=3, SPELLFAMILY_WARRIOR=4, etc.)

**Critical Rules**:
- Always verify proc flags match spell intent—incorrect flags cause unintended triggers
- Use `PROC_SPELL_PHASE_HIT` (0x2) for most damage procs, `PROC_SPELL_PHASE_CAST` (0x1) for cast-time effects
- Spell family masks must match class/school for spellmod interactions
- Test proc interactions with triggered spells—some have `PROC_ATTR_TRIGGERED_CAN_PROC` restrictions
- Document proc conditions in spell_proc comments

**Proc Attributes**:
- `PROC_ATTR_REQ_EXP_OR_HONOR` (0x1): Target must give XP/honor
- `PROC_ATTR_TRIGGERED_CAN_PROC` (0x2): Can proc from triggered spells
- `PROC_ATTR_REQ_MANA_COST` (0x4): Triggering spell needs mana cost
- `PROC_ATTR_REDUCE_PROC_60` (0x80): Reduced chance if actor level > 60

### 3. Conditions System
**Purpose**: Reusable conditional logic for quests, gossip, loot, SmartAI, spells, vendors

**Key Concepts**:
- **Source Types** (29 types): Where conditions apply (loot, gossip, quest, SmartAI, spell, vendor, etc.)
- **Condition Types** (40+ types): What to check (aura, item, zone, reputation, quest, level, etc.)
- **Operators**: AND (default), OR (negative SourceTypeOrReferenceId), NOT (ConditionTypeOrReference < 0)
- **ElseGroup**: Grouping for complex boolean logic

**Critical Rules**:
- Use `CONDITION_SOURCE_TYPE_SMART_EVENT` (22) for SmartAI script conditions
- Use `CONDITION_SOURCE_TYPE_SPELL_PROC` (24) for spell proc conditions
- Negative SourceTypeOrReferenceId creates OR groups—use carefully
- Test condition chains with multiple groups—logic errors cause silent failures
- Always document complex conditions in comments

**Common Condition Types**:
- `CONDITION_AURA` (1): Has spell aura
- `CONDITION_ITEM` (2): Has item in inventory
- `CONDITION_ZONEID` (4): In specific zone
- `CONDITION_QUESTREWARDED` (8): Quest completed
- `CONDITION_LEVEL` (27): Level comparison
- `CONDITION_CLASS` (15), `CONDITION_RACE` (16): Class/race checks

### 4. Loot System
**Tables**: `creature_loot_template`, `gameobject_loot_template`, `item_loot_template`, etc.

**Key Concepts**:
- **Loot Templates**: Define what items drop and their probability
- **Conditions**: Filter loot by player state (level, quest, class, etc.)
- **Loot Groups**: Mutually exclusive items (only one drops)
- **Reference Loot**: Reusable loot tables

**Critical Rules**:
- Always add conditions for quest/class-specific loot to prevent unintended drops
- Use loot groups for mutually exclusive items
- Test loot with multiple characters to verify condition logic
- Document complex loot chains in comments

### 5. Quest System
**Tables**: `quest_template`, `quest_objectives`, `quest_poi`, `quest_greeting`

**Key Concepts**:
- **Quest Types**: Elite, PvP, Raid, Dungeon, Repeatable, Daily, Weekly
- **Quest Flags**: Sharable, Tracking, Expansion-specific
- **Objectives**: Kill creatures, collect items, explore areas, cast spells
- **Rewards**: Experience, reputation, items, money
- **Prerequisites**: Conditions for quest availability

**Critical Rules**:
- Always set appropriate quest flags (elite, raid, etc.)
- Use conditions for level/faction/quest prerequisites
- Test quest chains with fresh characters
- Verify reward amounts match difficulty
- Document complex quest logic in comments

---

## C++ Code Standards

**Source**: AzerothCore C++ Code Standards (https://www.azerothcore.org/wiki/cpp-code-standards)

### Naming Conventions
- **Classes**: `PascalCase` (e.g., `PlayerBot`, `SmartScript`)
- **Functions**: `camelCase` (e.g., `getTargetList()`, `castSpell()`)
- **Variables**: `camelCase` (e.g., `targetGuid`, `spellId`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MAX_SPELL_EFFECTS`, `PROC_FLAG_KILL`)
- **Macros**: `UPPER_SNAKE_CASE` (e.g., `ASSERT(condition)`)

### Code Style
- **Indentation**: 4 spaces (no tabs)
- **Line Length**: Max 120 characters
- **Braces**: Allman style (opening brace on new line)
- **Comments**: Use `//` for single-line, `/* */` for multi-line
- **Documentation**: Doxygen-style comments for public functions

### Memory Management
- Use `std::unique_ptr` for exclusive ownership
- Use `std::shared_ptr` for shared ownership
- Avoid raw pointers except in performance-critical code
- Always check for null pointers before dereferencing

### Error Handling
- Use assertions for internal logic errors
- Use exceptions for recoverable errors
- Log errors with appropriate severity levels
- Never silently fail—always provide feedback

---

## Module Development

### Module Structure
```
mod-<name>/
├── CMakeLists.txt          # Build configuration
├── conf/
│   └── <name>.conf.dist    # Configuration template
├── data/
│   └── sql/
│       ├── base/           # Base schema
│       └── updates/        # Schema updates
├── src/
│   ├── <name>.cpp          # Main implementation
│   ├── <name>.h            # Header file
│   └── scripts/            # Optional script files
└── README.md               # Documentation
```

### Critical Rules
- **CMakeLists.txt**: Must properly set `SOURCES`, `HEADERS`, and include paths
- **Configuration**: All settings must have defaults in `.conf.dist`
- **Database**: All SQL changes must be in `updates/` with proper versioning
- **Compilation**: Module must compile without warnings
- **Testing**: Test on both production and development realms
- **Documentation**: README must explain features, configuration, and usage

### Configuration Best Practices
- Use descriptive names: `AiPlayerbot.RandomBotAutologin` not `RB_AL`
- Provide sensible defaults (usually disabled for safety)
- Document all settings in comments
- Use boolean flags for on/off features
- Use numeric ranges for tuning parameters

---

## Database Rules

### World Database (`acore_world`)
**Shared across all realms**. Changes affect all servers.

**Critical Rules**:
- Always backup before major changes
- Test SQL changes on development realm first
- Use transactions for multi-table updates
- Document complex queries in comments
- Verify data integrity after bulk updates

### Character Databases (`acore_characters`, `acore_characters_dev`)
**Realm-specific**. Isolated character data per realm.

**Critical Rules**:
- Never modify character data directly—use in-game commands when possible
- Test character-related changes on dev realm first
- Backup before large-scale character updates
- Verify account/character relationships

### Playerbots Database (`acore_playerbots`, `acore_playerbots_dev`)
**Realm-specific**. Bot configuration and state data.

**Critical Rules**:
- Backup before modifying bot configurations
- Test bot behavior changes on dev realm first
- Document bot strategy changes
- Monitor bot performance after updates

### Auth Database (`acore_auth`)
**Shared across all realms**. Account and realm list data.

**Critical Rules**:
- Never modify directly—use account management tools
- Backup before realm configuration changes
- Verify realm list consistency
- Test account creation/login after changes

---

## Testing & Verification

### Pre-Deployment Checklist
- [ ] Code compiles without warnings or errors
- [ ] Changes tested on development realm (8086)
- [ ] Database changes backed up and verified
- [ ] SmartAI scripts tested with multiple NPCs
- [ ] Spell/proc interactions verified with combat logs
- [ ] Loot conditions tested with multiple characters
- [ ] Quest chains tested from start to finish
- [ ] No unintended side effects on other systems
- [ ] Performance impact assessed (especially for loops)
- [ ] Documentation updated

### Testing Commands
```bash
# Check server status
systemctl status ac-worldserver
systemctl status ac-worldserver-dev

# View logs
tail -f env/dist/logs/Server.log
tail -f env/dist/logs-dev/Server.log

# Access console
screen -r worldserver
screen -r worldserver-dev

# Database backup
mysqldump -uacore -pacore acore_world > backup_world.sql

# Reload tables (SOAP)
.reload smart_scripts
.reload spell_proc
.reload conditions
```

### Performance Considerations
- SmartAI scripts with frequent updates (UPDATE_IC/OOC) impact CPU
- Large loot tables with many conditions slow down loot generation
- Complex condition chains should be optimized with indexed queries
- Spell proc checks happen on every damage event—keep them efficient
- Monitor bot AI loops for excessive CPU usage

---

## Safety & Stability

### Dangerous Operations
- **Never** modify `creature_template` directly—use `UPDATE_TEMPLATE` action
- **Never** delete rows without understanding dependencies
- **Never** change primary keys in existing records
- **Never** modify shared world database during peak hours
- **Never** enable debug logging in production without reason

### Rollback Procedures
1. Stop affected server: `service ac-worldserver stop`
2. Restore database backup: `mysql acore_world < backup_world.sql`
3. Verify data integrity: Check creature counts, quest counts, etc.
4. Restart server: `service ac-worldserver start`
5. Monitor logs for errors

### Monitoring & Alerts
- Check server logs daily for errors/warnings
- Monitor database size growth
- Track bot performance metrics
- Alert on spell proc failures
- Monitor player reports of broken content

---

## Documentation Standards

### Code Comments
- Explain **why**, not what (code shows what)
- Use Doxygen format for public APIs
- Document complex logic with examples
- Keep comments in sync with code

### Database Comments
- Explain non-obvious field values
- Document complex condition logic
- Link to related tables/scripts
- Include examples for configuration

### Commit Messages
Format: `[TYPE] Brief description`

Types:
- `[FEATURE]`: New functionality
- `[FIX]`: Bug fix
- `[REFACTOR]`: Code reorganization
- `[PERF]`: Performance improvement
- `[DOCS]`: Documentation
- `[TEST]`: Test additions

Example: `[FIX] SmartAI: Prevent infinite loop in phase transitions`

---

## Version Control

### Branch Strategy
- **Playerbot**: Main development branch
- **Feature branches**: `feature/description` for new features
- **Bugfix branches**: `fix/description` for bug fixes
- **Hotfix branches**: `hotfix/description` for urgent production fixes

### Pull Request Requirements
- Clear description of changes
- Test scenarios documented
- No merge conflicts
- Passes CI/CD checks
- Code review approval

### Commit History
- One logical change per commit
- Descriptive commit messages
- No merge commits (rebase instead)
- Clean history before PR

---

## Performance Optimization

### Database Queries
- Use indexed columns in WHERE clauses
- Avoid SELECT * (specify needed columns)
- Use LIMIT for large result sets
- Profile slow queries with EXPLAIN

### SmartAI Scripts
- Minimize UPDATE_IC/OOC event frequency
- Use conditions to filter unnecessary actions
- Cache frequently accessed data
- Avoid nested loops in scripts

### Spell System
- Keep proc checks lightweight
- Use spell families for efficient filtering
- Avoid expensive condition checks in procs
- Profile spell interactions with combat logs

### Bot AI
- Limit active bot count based on server capacity
- Use distance checks to reduce update frequency
- Cache pathfinding results
- Monitor CPU usage per bot

---

## Troubleshooting Guide

### Common Issues

**SmartAI Scripts Not Triggering**
- Verify event_phase_mask includes current phase
- Check conditions are satisfied
- Ensure creature is spawned (not despawned)
- Check event_chance (0-100, not 0-1)
- Review server logs for errors

**Spell Procs Not Working**
- Verify spell_proc entry exists
- Check proc_flags match trigger type
- Verify spell family is correct
- Test with combat logs enabled
- Check for conflicting conditions

**Loot Not Dropping**
- Verify loot template entry exists
- Check conditions are satisfied
- Verify item entry is valid
- Test with multiple characters
- Check for duplicate entries

**Quest Issues**
- Verify quest_template entry exists
- Check quest flags and objectives
- Test quest chain from start
- Verify NPC gossip/quest giver setup
- Check for broken quest prerequisites

**Bot Behavior Issues**
- Check bot AI configuration
- Verify bot class/spec setup
- Test with fresh bot character
- Review bot logs for errors
- Check for conflicting SmartAI scripts

---

## Resources

- **AzerothCore Wiki**: https://www.azerothcore.org/wiki/
- **Playerbots Wiki**: https://github.com/mod-playerbots/mod-playerbots/wiki
- **SmartAI Guide**: https://www.azerothcore.org/wiki/smart_scripts
- **Spell System**: https://www.azerothcore.org/wiki/spell_system
- **Conditions**: https://www.azerothcore.org/wiki/conditions
- **Discord**: https://discord.gg/NQm5QShwf9

---

## Last Updated
2026-02-28

---

## Current Project Status (2026-02-28)

### Active Modules (30+)
**Core Modules**:
- **mod-playerbots**: AI-driven bot system with 10 WotLK classes, raid/dungeon capable
- **mod-playerbots-llm**: LLM integration with OpenAI/Claude/Ollama, vector database (Qdrant), semantic memory

**Content & Progression**:
- **mod-progression-system**: 40+ content brackets (Classic, TBC, WotLK phases)
- **mod-mythic-plus**: 3 difficulty tiers (Mythic/Legendary/Ascendant) with scaling
- **mod-challenge-modes**: 8 challenge types (Hardcore, SemiHardcore, IronMan, etc.)
- **mod-solocraft**: Solo player scaling system

**Economy & Services**:
- **mod-ah-bot-plus**: Auction house automation
- **mod-character-services**: Name/race/appearance changes
- **mod-transmog**: Gear transmogrification
- **mod-guild-zone-system**: Guild zone purchasing
- **mod-bank-loans**: Banking system

**PvP & Social**:
- **mod-arena-1v1**: 1v1 arena system
- **mod-pvp-titles**: PvP title system
- **mod-globalchat**: Cross-faction chat
- **mod-weekend-xp**: Weekend XP bonuses

**Utilities**:
- **mod-anticheat**: Anti-cheat protection
- **mod-ale**: Lua scripting engine
- **mod-game-state-api**: Game state API
- **mod-welcome-message**: New player welcome
- **mod-ollama-chat**: Ollama chat integration
- **mod-bot-bounty**: Bot bounty system
- **mod-arena-waves**: Arena wave system
- **mod-autobalance**: Team balancing
- **mod-player-bot-level-brackets**: Bot level bracket system
- **mod-breaking-news-override**: News system
- **mod-guildhouse**: Guild housing
- **mod-premium**: Premium features

### Key Architectural Patterns

**Playerbots AI System**:
- Event-driven behavior with action selection
- Class-specific strategies and tactics
- Threat management and target prioritization
- Pathfinding with terrain clearance (TBC/WotLK zones)
- Flying mount support with active descent mechanics
- LLM-powered decision making (optional)

**Database Architecture**:
- `acore_world`: Shared across all realms (creature_template, spells, SmartAI, conditions, loot)
- `acore_characters`: Realm-specific player data
- `acore_playerbots`: Realm-specific bot configuration and state
- `acore_auth`: Shared account and realm data

**Raid/Dungeon Support**:
- ICC (Icecrown Citadel): Rotface, Saurfang, and other bosses with specific mechanics
- ToC (Trial of the Champion): Ground combat mechanics with Black Knight, Desecration, Paletress
- Hyjal Summit: Elemental boss mechanics
- Multiple raid strategies per boss for different roles

### Known Architectural Considerations

**Group Operations**:
- Arena group formation requires careful null checking
- Guild operations need defensive member validation
- Bot session validation essential for group operations
- Safe patterns: Group::RemoveMember uses GUID-based lookup, PlayerbotAI shutdown properly removes from groups

**Performance Tuning**:
- Bot count: 100-200 recommended per 4-core server
- Update interval: Default 100ms, adjustable for responsiveness
- SmartAI UPDATE_IC/OOC events impact CPU usage
- Spell proc checks on every damage event—keep efficient
- Pathfinding cache hit rate important for movement performance

**Flying Mechanics**:
- Active descent prevents hovering in TBC/WotLK zones
- Terrain clearance logic prevents collision issues
- Zone restrictions: Flying only in map 530 (Outland) and 571 (Northrend)
- Classic zones use ground pathfinding even with flying mounts
