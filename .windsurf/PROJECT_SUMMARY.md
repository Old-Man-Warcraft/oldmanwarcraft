# AzerothCore WotLK Project Summary

## Project Overview

**Project**: World of Warcraft: Wrath of the Lich King (3.3.5a) Private Server
**Framework**: AzerothCore (custom Playerbot branch)
**Primary Module**: mod-playerbots (AI-driven player-like bots)
**Expansion**: Wrath of the Lich King (3.3.5a)
**Repository**: `mod-playerbots/azerothcore-wotlk` (Playerbot branch)

## System Architecture

### Core Components

**1. AzerothCore Framework**
- C++ game server implementation
- MySQL database backend
- Modular architecture
- 15+ custom modules installed

**2. mod-playerbots Module**
- AI-driven bot system
- Alt bot support (player-controlled bots)
- Random bot population (autonomous bots)
- LLM integration for advanced AI (mod-playerbots-llm)
- Raid/dungeon capable bots

**3. Supporting Modules**
- **mod-mythic-plus**: Progressive difficulty scaling
- **mod-solocraft**: Solo player scaling
- **mod-progression-system**: Content progression control
- **mod-ah-bot-plus**: Auction house automation
- **mod-ale**: Lua scripting engine
- **mod-anticheat**: Anti-cheat protection
- **mod-challenge-modes**: Hardcore/Iron Man modes
- **mod-character-services**: Name/race/appearance changes
- **mod-globalchat**: Cross-faction chat
- **mod-guild-zone-system**: Guild zone purchasing
- **mod-pvp-titles**: PvP title system
- **mod-transmog**: Gear transmogrification
- **mod-welcome-message**: New player welcome
- **mod-arena-1v1**: 1v1 arena system
- **mod-game-state-api**: Game state API

## Database Structure

### World Database (`acore_world`)
**Shared across all realms**

Key tables:
- `creature_template`, `creature`: NPC definitions and spawns
- `gameobject_template`, `gameobject`: Object definitions and spawns
- `item_template`: Item definitions
- `quest_template`: Quest definitions
- `spell_dbc`: Spell definitions
- `spell_proc`: Spell proc configuration
- `smart_scripts`: SmartAI scripts (110+ event types, 100+ action types)
- `conditions`: Conditional logic system
- `creature_loot_template`, `gameobject_loot_template`: Loot tables

### Character Database (`acore_characters`)
**Realm-specific** (isolated per realm)

Contains player character data, inventory, quest progress, skills, spells, auras.

### Playerbots Database (`acore_playerbots`)
**Realm-specific** (isolated per realm)

Contains bot configuration, strategies, tactics, and state data.

### Auth Database (`acore_auth`)
**Shared across all realms**

Contains account data, realm list, permissions.

## Server Configuration

### Production Realm
- **Name**: Old Man Warcraft
- **RealmID**: 1
- **Port**: 8085
- **Databases**: acore_characters, acore_playerbots
- **Service**: `ac-worldserver`

### Development Realm
- **Name**: Development Realm
- **RealmID**: 2
- **Port**: 8086
- **Databases**: acore_characters_dev, acore_playerbots_dev
- **Service**: `ac-worldserver-dev`

Both realms share `acore_world` and `acore_auth` databases.

## Core Systems

### 1. SmartAI Scripting System
**Database-driven NPC behavior without C++ code**

- **110+ Event Types**: Combat, health, spells, movement, quests, interactions
- **100+ Action Types**: Casting, movement, state changes, summoning, communication
- **30+ Target Types**: Self, victim, nearby, stored lists, gameobjects
- **Phases**: Event grouping for complex multi-stage behaviors
- **Links**: Chaining scripts together for sequential execution
- **Conditions**: Optional filters using conditions table

**Key Tables**: `smart_scripts`, `conditions`

### 2. Spell System
**Spell configuration and proc mechanics**

- **Spell.dbc**: Client data (effects, casting time, range, family, proc flags)
- **spell_dbc**: Server-side spell definitions
- **spell_proc**: Proc trigger configuration
- **Proc Flags**: Bitmasks defining when spells trigger (kill, melee, spell, periodic, etc.)
- **Spell Families**: Class-specific spell groupings
- **Proc Attributes**: Additional flags (XP requirement, triggered spell support, etc.)

**Key Tables**: `spell_dbc`, `spell_proc`, `conditions`

### 3. Conditions System
**Reusable conditional logic**

- **29 Source Types**: Loot, gossip, quest, SmartAI, spell, vendor, vehicle, etc.
- **40+ Condition Types**: Aura, item, zone, reputation, quest, level, class, race, etc.
- **Operators**: AND (default), OR (negative SourceTypeOrReferenceId), NOT (negative ConditionTypeOrReference)
- **ElseGroup**: Complex boolean logic grouping

**Key Table**: `conditions`

### 4. Loot System
**Item drop configuration**

- **Loot Templates**: Define what items drop and probability
- **Conditions**: Filter loot by player state
- **Loot Groups**: Mutually exclusive items
- **Reference Loot**: Reusable loot tables

**Key Tables**: `creature_loot_template`, `gameobject_loot_template`, `item_loot_template`, etc.

### 5. Quest System
**Quest definitions and progression**

- **Quest Types**: Elite, PvP, Raid, Dungeon, Repeatable, Daily, Weekly
- **Objectives**: Kill creatures, collect items, explore areas, cast spells
- **Rewards**: Experience, reputation, items, money
- **Prerequisites**: Conditions for quest availability

**Key Table**: `quest_template`

### 6. Playerbots AI System
**Intelligent bot behavior**

- **Decision Making**: Event-driven behavior system
- **Combat Strategy**: Spell rotation, cooldown management, threat handling
- **Movement**: Pathfinding, combat movement, waypoint following
- **Class-Specific AI**: Optimized for each WotLK class
- **LLM Integration**: Advanced AI with learning capabilities (optional)

**Key Tables**: `ai_playerbot_config`, `ai_playerbot_strategy`, `ai_playerbot_tactics`

## Development Workflow

### Typical Development Cycle

1. **Design**: Plan feature/fix in development realm
2. **Implement**: Write code or database changes
3. **Test**: Test on development realm (port 8086)
4. **Review**: Verify functionality, performance, side effects
5. **Deploy**: Apply to production realm (port 8085)
6. **Monitor**: Watch logs for errors, monitor performance

### Key Tools

- **MySQL**: Database management
- **CMake**: Build system
- **Git**: Version control
- **Screen**: Server console access
- **Logs**: Server.log for debugging

### Testing Checklist

- Code compiles without warnings
- Changes tested on development realm
- Database changes backed up and verified
- SmartAI scripts tested with multiple NPCs
- Spell/proc interactions verified
- Loot conditions tested with multiple characters
- Quest chains tested from start to finish
- No unintended side effects
- Performance impact assessed
- Documentation updated

## Windsurf Documentation Structure

### Rules (`.windsurf/rules.md`)
**System-wide development standards and guidelines**

- Project overview and architecture
- Core systems documentation (SmartAI, Spells, Conditions, Loot, Quests, Playerbots)
- C++ code standards (naming, style, memory management)
- Module development guidelines
- Database rules and best practices
- Testing and verification procedures
- Safety and stability guidelines
- Documentation standards
- Version control practices
- Performance optimization tips
- Troubleshooting guide

### Workflows (`.windsurf/workflows/`)
**Step-by-step processes for common tasks**

1. **smartai-debugging.md**: Debug and troubleshoot SmartAI scripts
   - Verify script exists
   - Check event configuration
   - Verify conditions
   - Test script execution
   - Common event/action issues
   - Phase debugging
   - Link debugging
   - Performance checks

2. **spell-proc-configuration.md**: Configure and debug spell procs
   - Verify spell exists
   - Check spell proc entry
   - Decode proc flags
   - Decode spell type/phase mask
   - Check proc conditions
   - Test proc triggering
   - Common proc issues
   - Spell family configuration
   - Proc attributes
   - Performance optimization

3. **module-development.md**: Create and develop new modules
   - Create module structure
   - Configure CMakeLists.txt
   - Create configuration file
   - Create database schema
   - Create update scripts
   - Implement module class
   - Create README.md
   - Build and test
   - Database integration
   - Documentation

4. **deployment-and-testing.md**: Deploy changes safely
   - Pre-deployment checklist
   - Backup procedures
   - Database updates
   - Code deployment
   - Configuration updates
   - Server startup
   - Verification
   - Rollback procedures
   - Testing on development realm
   - Monitoring post-deployment

### Skills (`.windsurf/skills/`)
**Reusable knowledge patterns and reference documentation**

1. **smartai-reference.md**: Complete SmartAI reference
   - 110+ event types with descriptions
   - 100+ action types with descriptions
   - 30+ target types with descriptions
   - Event parameters
   - Action parameters
   - Best practices
   - Related resources

2. **spell-proc-reference.md**: Spell proc configuration reference
   - Proc flags (kill, melee, ranged, spell, periodic, etc.)
   - Spell type mask (damage, heal, other)
   - Spell phase mask (cast, hit, finish)
   - Hit mask (normal, critical, miss, dodge, parry, block, etc.)
   - Proc attributes
   - Spell families (class-specific)
   - Common proc configurations
   - Proc configuration combinations
   - Troubleshooting guide
   - Performance considerations

3. **conditions-reference.md**: Conditions system reference
   - 29 condition source types
   - 40+ condition types
   - Condition operators (AND, OR, NOT, ElseGroup)
   - Common condition patterns
   - Troubleshooting guide
   - Related resources

4. **database-operations.md**: Database operations guide
   - Database structure overview
   - Common queries (creatures, items, quests, spells, SmartAI, loot, conditions)
   - Backup and restore procedures
   - Database maintenance
   - Data import/export
   - Transaction management
   - Performance optimization
   - Common issues and solutions
   - Useful commands

5. **playerbots-system.md**: Playerbots module guide
   - Core concepts (bot types, AI system, LLM integration)
   - Configuration options
   - Bot commands
   - Bot AI architecture
   - Performance optimization
   - Debugging bot issues
   - Database tables
   - Common issues
   - Integration with other modules
   - Advanced configuration
   - Monitoring and metrics
   - Best practices

## Key Statistics

### Project Scope
- **15+ custom modules** installed
- **110+ SmartAI event types** available
- **100+ SmartAI action types** available
- **30+ SmartAI target types** available
- **29 condition source types** available
- **40+ condition types** available
- **Multiple proc flag types** for spell configuration
- **Multiple spell families** for class-specific filtering

### Database
- **4 databases**: world (shared), characters (realm-specific), playerbots (realm-specific), auth (shared)
- **2 realms**: Production (8085), Development (8086)
- **Shared world database** for all realms
- **Isolated character/playerbots databases** per realm

### Development
- **C++ codebase**: AzerothCore framework
- **Database-driven scripting**: SmartAI system
- **Modular architecture**: 15+ independent modules
- **Comprehensive testing**: Development realm for safe testing

## Important Considerations

### Safety
- Always backup databases before major changes
- Test on development realm first
- Use transactions for multi-table updates
- Never modify production directly
- Document all changes

### Performance
- SmartAI UPDATE_IC/OOC events impact CPU
- Large loot tables with many conditions slow loot generation
- Complex condition chains should be optimized
- Spell proc checks happen on every damage event
- Monitor bot AI loops for excessive CPU usage

### Stability
- SmartAI phase transitions can cause infinite loops if misconfigured
- Spell proc conflicts can cause unintended triggers
- Condition logic errors cause silent failures
- Database integrity issues can corrupt game state
- Module conflicts can cause unexpected behavior

## Getting Started

1. **Review Rules** (`.windsurf/rules.md`): Understand project standards
2. **Choose Workflow**: Select appropriate workflow for your task
3. **Reference Skills**: Use skill guides for detailed information
4. **Test on Dev**: Always test on development realm first
5. **Deploy Safely**: Follow deployment procedures for production

## Related Resources

- **AzerothCore Wiki**: https://www.azerothcore.org/wiki/
- **Playerbots Wiki**: https://github.com/mod-playerbots/mod-playerbots/wiki
- **Discord Community**: https://discord.gg/NQm5QShwf9
- **GitHub Repository**: https://github.com/mod-playerbots/azerothcore-wotlk

## Last Updated
2026-02-28

---

## Project Modules (30+)

### Core Modules
- **mod-playerbots**: AI-driven bot system with 10 WotLK classes, raid/dungeon capable
- **mod-playerbots-llm**: LLM integration with OpenAI/Claude/Ollama, vector database (Qdrant), semantic memory

### Content & Progression
- **mod-progression-system**: 40+ content brackets (Classic, TBC, WotLK phases)
- **mod-mythic-plus**: 3 difficulty tiers (Mythic/Legendary/Ascendant) with scaling
- **mod-challenge-modes**: 8 challenge types (Hardcore, SemiHardcore, IronMan, etc.)
- **mod-solocraft**: Solo player scaling system

### Economy & Services
- **mod-ah-bot-plus**: Auction house automation
- **mod-character-services**: Name/race/appearance changes
- **mod-transmog**: Gear transmogrification
- **mod-guild-zone-system**: Guild zone purchasing
- **mod-bank-loans**: Banking system

### PvP & Social
- **mod-arena-1v1**: 1v1 arena system
- **mod-pvp-titles**: PvP title system
- **mod-globalchat**: Cross-faction chat
- **mod-weekend-xp**: Weekend XP bonuses

### Utilities (15+)
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
- Plus 3+ additional utility modules

---

## Windsurf Documentation Structure (2026-02-28)

### Rules (`.windsurf/rules/`)
**System-wide development standards and guidelines**

- **azerothcore-standards.md**: C++ code standards, naming conventions, memory management
- **playerbots-rules.md**: Bot-specific guidance, raid support, movement mechanics, LLM integration
- **smartai-scripting.md**: SmartAI event/action configuration, phase management
- **spell-proc-rules.md**: Spell proc configuration, proc flags, spell families
- **conditions-rules.md**: Conditions system, source types, condition types
- **database-rules.md**: Database operations, backup procedures, safety rules
- **deployment-rules.md**: Deployment procedures, testing checklist, rollback procedures
- **module-development.md**: Module structure, CMakeLists.txt, configuration, database schema
- **memory-usage.md**: Memory system usage, entity types, relation types

### Workflows (`.windsurf/workflows/`)
**Step-by-step processes for common tasks**

- **smartai-debugging.md**: Debug SmartAI scripts, verify events, check conditions, test execution
- **spell-proc-configuration.md**: Configure spell procs, decode proc flags, test triggering
- **module-development.md**: Create modules, configure CMakeLists.txt, database schema, testing
- **deployment-and-testing.md**: Pre-deployment checklist, backup procedures, rollback procedures
- **raid-debugging.md** (NEW): Debug bot raid behavior, positioning, threat, healing, phase transitions

### Skills (`.windsurf/skills/`)
**Reusable knowledge patterns and reference documentation**

- **smartai-reference.md**: 110+ event types, 100+ action types, 30+ target types
- **spell-proc-reference.md**: Proc flags, spell type mask, spell phase mask, hit mask
- **conditions-reference.md**: 29 source types, 40+ condition types, operators
- **database-operations.md**: Common queries, backup/restore, maintenance, optimization
- **playerbots-system.md**: Core concepts, configuration, bot commands, debugging
- **bot-ai-configuration.md** (NEW): Class strategies, specializations, performance tuning, testing

---

## Key Architectural Information (2026-02-28)

### Playerbots AI System
- Event-driven behavior with action selection
- Class-specific strategies and tactics (10 WotLK classes)
- Threat management and target prioritization
- Pathfinding with terrain clearance (TBC/WotLK zones)
- Flying mount support with active descent mechanics
- LLM-powered decision making (optional)

### Raid & Dungeon Support
- **ICC (Icecrown Citadel)**: Rotface, Saurfang, and other boss mechanics
- **ToC (Trial of the Champion)**: Ground combat mechanics with Black Knight, Desecration, Paletress
- **Hyjal Summit**: Elemental boss mechanics
- **Ulduar**: Complex boss mechanics
- **Naxxramas**: Classic raid mechanics
- Multiple raid strategies per boss for different roles

### Database Architecture
- `acore_world`: Shared across all realms (creature_template, spells, SmartAI, conditions, loot)
- `acore_characters`: Realm-specific player data
- `acore_playerbots`: Realm-specific bot configuration and state
- `acore_auth`: Shared account and realm data

### Performance Tuning
- Bot count: 100-200 recommended per 4-core server
- Update interval: Default 100ms, adjustable for responsiveness
- SmartAI UPDATE_IC/OOC events impact CPU usage
- Spell proc checks on every damage event—keep efficient
- Pathfinding cache hit rate important for movement performance

---

## Windsurf Customization Complete (2026-02-28)

All Windsurf documentation has been created and organized:

✅ **Rules** - Comprehensive development standards and guidelines (updated 2026-02-28)
✅ **Workflows** - Step-by-step processes for common tasks (5 workflows)
✅ **Skills** - Detailed reference documentation for all systems (6 skills)

**Recent Updates (2026-02-28)**:
- Updated rules.md with current project modules and architecture
- Enhanced playerbots-rules.md with raid support, movement mechanics, LLM details
- Created raid-debugging.md workflow for raid encounter troubleshooting
- Created bot-ai-configuration.md skill guide for class strategies and performance tuning
- Updated PROJECT_SUMMARY.md with comprehensive module list and documentation structure

You can now use Windsurf's Customizations panel to access these rules, workflows, and skills for your AzerothCore development work.
