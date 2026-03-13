# AzerothCore Module Overview

## Project Module Inventory (30+)

This guide provides an overview of all active modules in the project, their purposes, and key features.

## Core Modules

### mod-playerbots
**Purpose**: AI-driven bot system with player-like behavior

**Features**:
- 10 WotLK classes with class-specific AI
- Alt bots (player-controlled) and random bots (autonomous)
- Raid and dungeon capable
- Talent specialization support
- Gear optimization and scaling
- Quest completion and leveling
- Party and group formation
- Combat strategy selection

**Configuration**: `conf/playerbots.conf.dist`

**Key Settings**:
- `AiPlayerbot.Enabled`: Enable/disable module
- `AiPlayerbot.RandomBotAutologin`: Auto-login random bots
- `AiPlayerbot.RandomBotCount`: Number of random bots
- `AiPlayerbot.UpdateInterval`: Update frequency (ms)

**Database Tables**:
- `ai_playerbot_config`: Bot configuration and state
- `ai_playerbot_strategy`: Bot strategy definitions
- `ai_playerbot_tactics`: Bot tactic definitions

### mod-playerbots-llm
**Purpose**: LLM-powered AI for advanced bot decision making

**Features**:
- OpenAI, Claude, Ollama, and custom LLM providers
- Vector database (Qdrant) for semantic memory
- Game data indexing (31k+ items, 3k+ quests, 100k+ creatures, 30k+ spells)
- Chat features (whisper, party/raid, guild, say/yell)
- Conversation memory with personality
- Heuristic learning from interactions
- WoW lore context for era-appropriate responses

**Configuration**: `conf/playerbots-llm.conf.dist`

**Key Settings**:
- `PlayerbotLLM.Enabled`: Enable/disable LLM
- `PlayerbotLLM.Model`: LLM model (default: gpt-4)
- `PlayerbotLLM.Provider`: LLM provider
- `PlayerbotLLM.VectorDB`: Vector database URL

**Performance**:
- 4 LLM worker threads, 8 HTTP worker threads
- Max 5 concurrent LLM requests
- All vector DB operations are async
- Response delay: 500-3000ms

## Content & Progression Modules

### mod-progression-system
**Purpose**: Control content progression with level brackets and attunements

**Features**:
- 40+ content brackets (Classic, TBC, WotLK phases)
- Level brackets: 1-19, 20-29, ..., 60 (phases 1-3), 70 (phases 1-6), 80 (phases 1-4)
- Classic raids: MC, BWL, AQ20/40, ZG with attunement
- TBC raids: Karazhan, Gruul, Magtheridon, SSC, TK, Hyjal, BT, Sunwell
- WotLK raids: Naxx, Ulduar, ToC, ICC, Ruby Sanctum
- Arena seasons and PvP progression
- Molten Core manual rune handling option
- Kazzak phasing for world boss engagement

**Configuration**: `conf/progression_system.conf.dist`

### mod-mythic-plus
**Purpose**: Progressive difficulty scaling beyond Heroic

**Features**:
- 3 difficulty tiers: Mythic (1.25x), Legendary (2.25x), Ascendant (3.25x)
- Health and damage scaling per tier
- Level scaling: 83-85 (Mythic), 85-87 (Legendary), 87-90 (Ascendant)
- Death limits: 100 (Mythic), 30 (Legendary), 15 (Ascendant)
- Item reward offsets: +20M, +21M, +22M
- Diminishing returns system with exponent 0.96
- Per-instance scaling via `mp_scale_factors` table

**Configuration**: `conf/mod-mythic-plus.conf.dist`

### mod-challenge-modes
**Purpose**: Hardcore and challenge mode systems

**Features**:
- 8 challenge types:
  - Hardcore: Permanent death, 1.5x XP
  - SemiHardcore: Lose equipment/gold on death, 1.25x XP
  - SelfCrafted: Only self-crafted gear, 1.2x XP
  - ItemQualityLevel: Only normal/poor quality, 1.15x XP
  - SlowXpGain: 0.5x XP with talent rewards
  - VerySlowXpGain: 0.25x XP with double talent rewards
  - QuestXpOnly: XP only from quests
  - IronMan: Full Iron Man ruleset, 1.5x XP
- Reward system: titles, XP multipliers, talent points, items, achievements
- Challenge selection object in starting areas

**Configuration**: `conf/challenge_modes.conf.dist`

### mod-solocraft
**Purpose**: Automatic scaling for solo players

**Features**:
- Scales creatures and bosses based on party size
- Adjusts health, damage, and abilities
- Works with all content
- Configurable scaling factors
- Respects progression system

**Configuration**: `conf/solocraft.conf.dist`

## Economy & Services Modules

### mod-ah-bot-plus
**Purpose**: Auction house automation

**Features**:
- Bot-managed auction house
- Automatic price adjustment
- Item stocking and management
- Profit tracking
- Configurable buy/sell prices

### mod-character-services
**Purpose**: Character customization services

**Features**:
- Name changes
- Race changes
- Appearance changes (hair, skin, etc.)
- Configurable pricing
- Transaction logging

### mod-transmog
**Purpose**: Gear transmogrification system

**Features**:
- Transmog NPCs in major cities
- Appearance customization
- Configurable costs
- Item restrictions

### mod-guild-zone-system
**Purpose**: Guild zone purchasing

**Features**:
- Guild zones for purchase
- Zone customization
- Guild benefits
- Configurable pricing

### mod-bank-loans
**Purpose**: Banking and loan system

**Features**:
- Bank services
- Loan system with interest
- Configurable rates
- Transaction logging

## PvP & Social Modules

### mod-arena-1v1
**Purpose**: 1v1 arena system

**Features**:
- 1v1 arena matches
- Rating system
- Rewards and achievements
- Configurable brackets

### mod-pvp-titles
**Purpose**: PvP title system

**Features**:
- PvP titles based on rating
- Seasonal titles
- Title rewards
- Configurable thresholds

### mod-globalchat
**Purpose**: Cross-faction chat

**Features**:
- Global chat channel
- Cross-faction communication
- Configurable channels
- Moderation tools

### mod-weekend-xp
**Purpose**: Weekend XP bonuses

**Features**:
- Configurable weekend XP multiplier
- Automatic activation
- Announcement system

## Utility Modules

### mod-anticheat
**Purpose**: Anti-cheat protection

**Features**:
- Speed hack detection
- Teleport hack detection
- Damage hack detection
- Configurable thresholds
- Logging and banning

### mod-ale
**Purpose**: Lua scripting engine

**Features**:
- Lua script support
- Custom game logic
- Event hooks
- Configurable scripts

### mod-game-state-api
**Purpose**: Game state API

**Features**:
- REST API for game state
- Player information
- World information
- Configurable endpoints

### mod-welcome-message
**Purpose**: New player welcome system

**Features**:
- Welcome messages for new players
- Customizable messages
- Item rewards
- Gold rewards

### mod-ollama-chat
**Purpose**: Ollama chat integration

**Features**:
- Local LLM integration via Ollama
- Chat responses
- Configurable models
- Privacy-focused alternative to cloud LLMs

### mod-bot-bounty
**Purpose**: Bot bounty system

**Features**:
- Bounties on bots
- Reward system
- Configurable bounties
- Tracking system

### mod-arena-waves
**Purpose**: Arena wave system

**Features**:
- Wave-based arena challenges
- Increasing difficulty
- Reward scaling
- Leaderboards

### mod-autobalance
**Purpose**: Team balancing

**Features**:
- Automatic team balancing
- Configurable balance factors
- Skill-based balancing
- Logging and statistics

### mod-player-bot-level-brackets
**Purpose**: Bot level bracket system

**Features**:
- Bot level brackets
- Bracket-based grouping
- Configurable brackets
- Automatic assignment

### mod-breaking-news-override
**Purpose**: News system

**Features**:
- Custom news messages
- Server announcements
- Configurable news
- Scheduling

### mod-guildhouse
**Purpose**: Guild housing system

**Features**:
- Guild houses
- Customization options
- Guild benefits
- Configurable pricing

### mod-premium
**Purpose**: Premium features

**Features**:
- Premium account system
- Premium benefits
- Configurable features
- Payment integration

## Module Development Best Practices

### Creating a New Module

1. **Create module directory**: `modules/mod-<name>/`
2. **Create CMakeLists.txt**: Configure build settings
3. **Create configuration**: `conf/<name>.conf.dist`
4. **Create database schema**: `data/sql/base/` and `data/sql/updates/`
5. **Implement module class**: `src/<name>.cpp` and `src/<name>.h`
6. **Create README.md**: Document features and configuration
7. **Build and test**: Compile and test on dev realm

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

### Configuration Best Practices
- Use descriptive names: `ModuleName.FeatureName`
- Provide sensible defaults (usually disabled)
- Document all settings in comments
- Use boolean flags for on/off features
- Use numeric ranges for tuning parameters

### Database Best Practices
- Always backup before major changes
- Use transactions for multi-table updates
- Document complex queries in comments
- Verify data integrity after bulk updates
- Use update scripts with proper versioning: `YYYY_MM_DD_XX_description.sql`

## Module Integration

### Playerbots Integration
- Bots support all content modules
- Difficulty scaling applies to bots
- Bot gear scales with progression
- Bots participate in economy modules
- Bots can use character services

### Performance Considerations
- Monitor module load order
- Check for module conflicts
- Verify no duplicate functionality
- Test modules individually
- Monitor overall server performance

## Module Configuration Management

### Configuration File Locations
- Main configs: `conf/dist/`
- Module configs: `conf/dist/modules/`
- Custom configs: `env/dist/etc/`

### Configuration Reloading
```
.reload <module_name>
```

### Configuration Validation
```bash
# Check configuration syntax
grep -v "^#" conf/dist/modules/<module>.conf | grep -v "^$"
```

## Related Resources

- AzerothCore Wiki: https://www.azerothcore.org/wiki/
- Playerbots Wiki: https://github.com/mod-playerbots/mod-playerbots/wiki
- Module Development: https://www.azerothcore.org/wiki/modules
- Discord Community: https://discord.gg/NQm5QShwf9
