---
type: "always_apply"
---

# AzerothCore Copilot Instructions

AzerothCore is a **modular, community-driven MMORPG server framework** for World of Warcraft 3.3.5a. This is the **Playerbot branch** fork which includes core modifications for mod-playerbots compatibility.

## Branch-Specific Context

This repository uses the `Playerbot` branch with extensive module ecosystem:
- **Core patches**: `#ifdef MOD_PLAYERBOTS` guards throughout core code (WorldSession, MotionMaster, Group, Unit)
- **Installed modules**: playerbots, playerbots-llm, mythic-plus, challenge-modes, transmog, anticheat, solocraft, ah-bot-plus, pvp-titles, progression-system, globalchat
- **Config location**: `env/dist/etc/modules/*.conf` (copy from `.dist` files)

## Architecture Overview

### Core Components

**Server Applications** (`src/server/apps/`):
- **authserver**: Authentication & realm list service  
- **worldserver**: Game world server (main application)

**Game Engine** (`src/server/game/`):
- Organized by domain: AI/, Spells/, Combat/, Entities/, Scripting/, etc.
- **Critical subsystem**: SmartAI (`src/server/game/AI/SmartScripts/`) - database-driven AI for creatures/NPCs

**Database Layer** (`src/server/database/`):
- MySQL databases: `world`, `characters`, `auth`, `playerbots` (module-specific)
- SQL updates: `data/sql/updates/` with `YYYYMMDDHHMMSS_<desc>.sql` naming

**Modules System** (`modules/`):
- Plugins extending core without modifying it
- Structure: `modules/mod-<name>/src/`, `conf/`, `data/sql/`
- Loader: `<ModuleName>_loader.cpp` with `Addmod_<name>Scripts()` function
- Auto-registered via `ModulesScriptLoader.h` at compile time

### Data Flow

1. **Startup**: DatabaseLoader → ModuleMgr → ScriptMgr → World init
2. **Creature AI**: `AIName='SmartAI'` + `smart_scripts` table → event-driven actions  
3. **Player actions**: Session handlers → Script hooks → Database updates
4. **Playerbots**: `RandomPlayerbotMgr` spawns bots → `PlayerbotAI` controls behavior

## Build System

### Key Commands
```bash
./acore.sh compiler build      # Configure + compile (CMake + make)
./acore.sh compiler clean      # Remove build artifacts
./acore.sh run-worldserver     # Start worldserver with restarter
./acore.sh run-authserver      # Start authserver with restarter
service ac-worldserver restart # Restart systemd service (if configured)
```

### Module Build Integration
- Modules auto-discovered via `modules/CMakeLists.txt`
- `MOD_PLAYERBOTS` define: Enables core patches for playerbots compatibility
- `MOD_PRESENT_*` defines: Cross-module feature detection (e.g., `MOD_PRESENT_NPCBOTS`)
- Module configs: `modules/mod-<name>/conf/<name>.conf.dist` → copy to `env/dist/etc/modules/`

### Creating a New Module
```bash
cd modules && ./create_module.sh   # Interactive scaffolding
```

**Required structure**:
```
modules/mod-example/
├── src/
│   ├── CMakeLists.txt              # Build config
│   ├── example_loader.cpp          # void Addmod_exampleScripts()
│   └── ExampleScript.cpp           # Script implementations
├── conf/example.conf.dist          # Configuration template
└── data/sql/                       # SQL patches
```

**Loader pattern** (required):
```cpp
// example_loader.cpp
void AddSC_ExampleScript();          // Forward declare
void Addmod_exampleScripts() {       // Must match module name
    AddSC_ExampleScript();
}
```

## Script Hooks & Singletons

**Core singletons** (access via `sSingletonName`):
- `sScriptMgr`: All script hooks and event registrations
- `sConfigMgr->GetOption<T>("Key", default)`: Read config values
- `sObjectMgr`: Entity templates (creatures, items, quests)
- `sMapMgr`: World maps and grid loading

**Script hook pattern**:
```cpp
class MyPlayerScript : public PlayerScript {
public:
    MyPlayerScript() : PlayerScript("MyPlayerScript", {
        PLAYERHOOK_ON_LOGIN,       // Declare hooks used
        PLAYERHOOK_ON_GIVE_EXP
    }) {}

    void OnPlayerLogin(Player* player) override { /* ... */ }
};

void AddSC_MyScript() { new MyPlayerScript(); }
```

**Database script hook** (for module databases like playerbots):
```cpp
class MyDatabaseScript : public DatabaseScript {
public:
    bool OnDatabasesLoading() override {
        DatabaseLoader loader("server.mymodule");
        loader.AddDatabase(MyDatabase, "MyModule");
        return loader.Load();
    }
};
```

## Playerbots Module Integration

**Core architecture** (`modules/mod-playerbots/src/`):
- `Bot/PlayerbotAI.h`: Main AI brain for each bot (strategies, commands, states)
- `Bot/RandomPlayerbotMgr.h`: Spawns/manages random world bots via `sRandomPlayerbotMgr`
- `Bot/PlayerbotMgr.h`: Per-player bot manager for altbots
- `Script/Playerbots.cpp`: Script hooks (PlayerScript, DatabaseScript)

**Bot types**:
- **Randombot**: Auto-generated bots that populate the world, configured via `playerbots.conf`
- **Altbot**: Player's own alt characters logged in as bots
- **AddClass bot**: Pre-leveled bots from account pool for quick party formation

**Key singletons**:
```cpp
sRandomPlayerbotMgr          // Random bot spawning/management
sPlayerbotAIConfig           // Config values from playerbots.conf
PlayerbotsMgr::instance()    // Global manager, access bot AI instances
```

**Accessing a bot's AI**:
```cpp
PlayerbotAI* botAI = PlayerbotsMgr::instance().GetPlayerbotAI(player);
if (botAI) {
    botAI->HandleCommand(type, msg, sender);
}
```

## Database Architecture

**Four database connections** (Playerbot branch):

| Database | Global Variable | Purpose |
|----------|----------------|---------|
| `acore_world` | `WorldDatabase` | Game data (creatures, items, quests, spawns) |
| `acore_characters` | `CharacterDatabase` | Player data (inventory, achievements, guilds) |
| `acore_auth` | `LoginDatabase` | Accounts, realm list, bans |
| `acore_playerbots` | `PlayerbotsDatabase` | Bot-specific data (strategies, caches, travel nodes) |

**Playerbots database tables** (in `modules/mod-playerbots/data/sql/playerbots/base/`):
- `playerbots_random_bots`: Bot spawn state and events
- `playerbots_db_store`: Key-value storage per bot GUID
- `playerbots_equip_cache`: Cached gear sets by spec/level
- `playerbots_travelnode*`: Pathfinding graph for bot movement
- `playerbots_weightscales`: Gear stat priorities per class/spec

**Database config** (`worldserver.conf` or `playerbots.conf`):
```conf
PlayerbotsDatabaseInfo = "127.0.0.1;3306;acore;acore;acore_playerbots"
PlayerbotsDatabase.WorkerThreads = 1
```

**Prepared statements** (see `src/server/database/Database/Implementation/PlayerbotsDatabase.h`):
```cpp
// Using prepared statements
PlayerbotsDatabase.Query(
    PlayerbotsDatabase.GetPreparedStatement(PLAYERBOTS_SEL_DB_STORE)
);
```

## Cross-Module Dependencies

**Compile-time feature detection** using `#ifdef` guards:

| Define | Set By | Purpose |
|--------|--------|---------|
| `MOD_PLAYERBOTS` | `modules/CMakeLists.txt` | Core patches for playerbots compatibility |
| `MOD_PRESENT_NPCBOTS` | npcbots module | Detect if NPCBots is installed |

**Usage pattern** (from `mod-mythic-plus`):
```cpp
#if defined(MOD_PRESENT_NPCBOTS)
    if (creature->IsNPCBot()) {
        return false;  // Skip NPC bots from scaling
    }
    if (creature->GetBotOwner()) {
        return false;  // Skip bot pets
    }
#endif
```

**Cross-module safe checks**:
```cpp
// Check if playerbots module controls this player
#ifdef MOD_PLAYERBOTS
    if (player->GetSession()->IsBot()) {
        // Handle bot-specific logic
    }
#endif
```

**Module load order**: Modules load alphabetically by directory name. Use `acore-module.json` to declare dependencies if order matters.

## SmartAI Quick Reference

**Setup**: Set `creature_template.AIName='SmartAI'`, add rows to `smart_scripts`

| Field | Purpose |
|-------|---------|
| `entryorguid` | Creature entry (positive) or spawn GUID (negative) |
| `source_type` | 0=creature, 1=gameobject, 2=areatrigger |
| `event_type` | Trigger condition (0=timer, 4=aggro, 6=death, 8=hp%) |
| `action_type` | Response (1=say, 11=cast, 12=summon, 21=set_phase) |
| `target_type` | Target selection (0=self, 1=victim, 7=invoker) |

**Debug**: Enable logging in `worldserver.conf`, query `smart_scripts` table

## Project Conventions

### Naming & Style
- **Classes**: PascalCase (`PlayerScript`, `MythicPlus`)
- **Methods**: PascalCase (`GetOption`, `OnPlayerLogin`)
- **Variables**: camelCase or snake_case
- **Macros/Constants**: UPPER_CASE (`MOD_PLAYERBOTS`, `SMART_EVENT_AGGRO`)

### File Organization
- Headers (`.h`) alongside implementation (`.cpp`)
- Module loader: `<modulename>_loader.cpp` with `Addmod_<name>Scripts()` function
- SQL updates: `data/sql/updates/<db>_YYYYMMDDHHMMSS_<desc>.sql`

## Integration Points

### Worldserver Initialization Order
Worldserver startup follows this sequence (see `Main.cpp`):
1. **Config loading**: `sConfigMgr->LoadInitial()` → reads worldserver.conf
2. **ScriptMgr setup**: Register core script loader + module script loader
3. **DatabaseLoader**: Applies SQL updates from `data/sql/updates/`, initializes `world`/`characters`/`auth` databases
4. **Module + Script initialization**: `sScriptMgr->OnDatabasesLoading()` hook, then `OnStartup()`
5. **World initialization**: MapManager loads grids, creature spawns trigger SmartAI scripts
6. **Socket listeners**: Worldserver opens port for client connections

This order matters: Database must load before scripts create data; modules hook into lifecycle events.

### Module Loading
Modules integrate via:
1. **CMake**: `src/cmake/macros/ConfigureModules.cmake` discovers & links modules
2. **Script hooks**: `ModulesScriptLoader.h` auto-generates script loader for modules
3. **Runtime**: ModuleMgr singletons provide module-level API hooks

### Service Management
- **Startup scripts** (`apps/startup-scripts/`): PM2/systemd service management
- **Service registry**: Persistent JSON tracking services for auto-restoration
- **Config portability**: Relative paths when under `AC_SERVICE_CONFIG_DIR`

### Database Migrations
- **Updates applied on startup** via DatabaseLoader
- **Naming**: `YYYYMMDDHHMMSS_<description>.sql` in `data/sql/updates/`
- **Testing**: Apply to dev database; verify in `char/auth/world` databases

## Testing & Debugging

### Compilation Checks
```bash
python apps/codestyle/codestyle-cpp.py    # C++ style check
python apps/codestyle/codestyle-sql.py    # SQL style check
./acore.sh compiler build                 # Full build test
```

### Service Debugging
- **Worldserver logs**: `env/dist/logs/` (configured in worldserver.conf)
- **Attach console**: `./service-manager.sh attach world` (interactive commands)
- **Health check**: `./service-manager.sh is-running auth` (exit codes 0/1)

### SmartAI Inspection
- Check `smart_scripts` table for creature scripts
- Enable debug logging: Set `LogLevel` for SmartAI in config
- Verify event/action/target IDs exist in SmartScript enums

## Key Files to Know

| Path | Purpose |
|------|---------|
| [src/server/game/AI/SmartScripts/](src/server/game/AI/SmartScripts/) | SmartAI event-driven system (2250+ lines of config enums) |
| [src/server/game/Scripting/](src/server/game/Scripting/) | Script hook registration (ScriptMgr, ScriptObject) |
| [src/server/apps/worldserver/Main.cpp](src/server/apps/worldserver/Main.cpp) | Worldserver bootstrap & initialization |
| [modules/how_to_make_a_module.md](modules/how_to_make_a_module.md) | Module creation guide |
| [CMakeLists.txt](CMakeLists.txt) | Root build configuration |
| [data/sql/updates/README.md](data/sql/updates/README.md) | Database update conventions |
| [modules/mod-playerbots/src/Bot/](modules/mod-playerbots/src/Bot/) | PlayerbotAI, RandomPlayerbotMgr - core bot logic |
| [src/server/database/Database/Implementation/PlayerbotsDatabase.h](src/server/database/Database/Implementation/PlayerbotsDatabase.h) | Playerbots prepared statements |
| [env/dist/etc/modules/](env/dist/etc/modules/) | Module config files (copy .dist → .conf) |

## Common Pitfalls

1. **Modules not loading**: Verify `<ModuleName>.cmake` exists and CMakeLists.txt includes module in build
2. **SQL updates not applied**: Check update file name format and database migration status
3. **Script not registering**: Ensure `AddSC_*()` is declared in ScriptLoader.h and called in AddScripts()
4. **SmartAI not triggering**: Verify creature has `AIName='SmartAI'` and script source matches creature entry
5. **Service won't start**: Check config file paths, database connectivity, and binary executable bit
6. **Entity references fail**: Always verify entries exist in template tables (`creature_template`, `gameobject_template`, etc.) before referencing
7. **Quest conditions not working**: Ensure `quest_template` source_type matches condition source (type 19 = quest availability)

## Entity Reference Conventions

**Creature Entry vs GUID**:
- **entry**: Template ID, use for SmartAI (`smart_scripts.entryorguid` with `source_type=0`)
- **guid**: Unique spawn ID per instance, use for object state (`creature.guid`)

**Database Entity Relationships**:
- `creature_template` → spawned as `creature` rows
- `creature.id` references `creature_template.entry`
- `smart_scripts.entryorguid=creature.id` with `source_type=0` for creature AI
- Quest objectives reference creatures by entry via `quest_objectives.type` and `object_id`
- Spell effects reference creatures/objects by entry: `SpellInfo::Effects` 

**SQL Safety Pattern**:
```cpp
// Always check existence before accessing
CreatureTemplate const* proto = sObjectMgr->GetCreatureTemplate(entry);
if (!proto) { 
    LOG_ERROR("module", "Missing creature template: {}", entry); 
    return; 
}
```

## Advanced Patterns

### Async Operations & Queries
AzerothCore uses asynchronous database queries via `CharacterDatabase`, `WorldDatabase`, `LoginDatabase`:
- **Async callback pattern**: Use `*Database.AsyncQuery()` with lambda callbacks to avoid blocking world loop
- **Transaction safety**: Group related updates in transactions to ensure consistency
- **Thread pool**: World loop runs on single thread; long queries must be async to prevent freeze

Example:
```cpp
WorldDatabase.AsyncQuery(
    fmt::format("SELECT * FROM creature_template WHERE entry = {}", entry),
    [entry](QueryResult result) { 
        if (result) { /* handle result */ } 
    }
);
```

### Cross-cutting Domains
Some subsystems touch multiple game domains:
- **Conditions** (`src/server/game/Conditions/`): Used by quests, spells, SmartAI, events
- **Handlers** (`src/server/game/Handlers/`): Network message routing to domain handlers
- **DataStores** (`src/server/game/DataStores/`): Caches DBC data; accessed globally
- **Pools** (`src/server/game/Pools/`): Spawn management for creatures/objects across zones

### Performance-Critical Paths
- **Grid updates**: Called frequently per-frame; minimize overhead in spell/combat logic
- **Spell proc system**: Spell casting can trigger many spell scripts; use flags to reduce unnecessary calls
- **Combat damage**: Hit multiple times per fight; optimize damage calculation chains

## References

- **Module catalog**: https://www.azerothcore.org/catalogue.html
- **Community Discord**: https://discord.gg/gkt4y2x
- **Wiki**: http://www.azerothcore.org/wiki/
