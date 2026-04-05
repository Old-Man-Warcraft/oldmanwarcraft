# CLAUDE.md

Guidance for AI-assisted work in this repository (Cursor, Claude Code, and similar tools).

## Where standards live

- **Always-on / safety**: `.cursor/rules/` (especially `azerothcore-standards.mdc`, `playerbots-rules.mdc`).
- **Workflows & checklists**: `.cursor/skills/` (`workflow-*`, domain references).
- **Project facts & module list**: `.cursor/reference/PROJECT_SUMMARY.md`.
- **Crash analysis**: `.cursor/docs/crash-debugging.md`.

Keep long-lived facts about **Old Man Warcraft** operations in **Notion** (reference via Notion MCP when configuring or debugging live server behavior).

**MCP credentials**: Do **not** rely on `${env:VAR}` inside `mcp.json` for GUI-launched Cursor. Use **`~/.cursor/mcp.secrets.env`** + **`~/.cursor/mcp-exec-with-secrets.sh`** + **`python3 .cursor/scripts/regenerate_mcp_json.py`** (writes `~/.cursor/mcp.json` from `.cursor/reference/mcp.base.json`). Details: `.cursor/reference/mcp.env.example`, `.cursor/rules/mcp-usage.mdc`.

**MCP routing and tool catalog**: `.cursor/rules/mcp-usage.mdc` and `.cursor/reference/mcp-tools-inventory.md` (grouped `azerothcore`, `omw_*`, GitLab, Notion, fetch, firecrawl, research, browser).

## Project identity

- **Community**: Old Man Warcraft — [oldmanwarcraft.com](https://oldmanwarcraft.com)
- **Stack**: AzerothCore WotLK 3.3.5a, heavy **custom module** set (see `modules/`), often on a **Playerbot-oriented** branch/fork.
- **Git**: **GitLab** is the org origin for day-to-day work; **GitHub** is the **upstream** reference for AzerothCore and many modules. `modules/*` are commonly **separate Git repositories** (submodules or nested clones)—treat upstream sync per subtree, not only the root remote.
- **This deployment**: **Production-only** on this host (no local dev realm). Favor backups, maintenance windows, and off-host or tooling validation instead of “test on 8086 first.”

## Project overview (technical)

AzerothCore is an open-source MMORPG server emulator for World of Warcraft patch 3.3.5a (Wrath of the Lich King). C++ with CMake, MySQL for data. Licensed under GNU GPL v2.

## Build commands

### Configure and build (out-of-source build required)

- Skip building unless explicitly requested.

```bash
mkdir -p build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/azeroth-server -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DSCRIPTS=static -DMODULES=static

make -j$(nproc)
make install
```

### Key CMake options

- `SCRIPTS`: none, static, dynamic, minimal-static, minimal-dynamic (default: static)
- `MODULES`: none, static, dynamic (default: static)
- `APPS_BUILD`: none, all, auth-only, world-only (default: all)
- `TOOLS_BUILD`: none, all, db-only, maps-only (default: none)
- `BUILD_TESTING`: Enable unit tests (default: OFF)
- `USE_COREPCH` / `USE_SCRIPTPCH`: Precompiled headers (default: ON)

### Unit tests

```bash
cmake .. -DBUILD_TESTING=ON
make -j$(nproc)
./src/test/unit_tests
# or
ctest
```

Tests use Google Test and live in `src/test/`. The test binary links against the `game` library.

## Architecture

### Two server executables

- **authserver** (`src/server/apps/authserver/`): Authentication and realm selection (port 3724)
- **worldserver** (`src/server/apps/worldserver/`): Gameplay (default game port **8085** in stock configs)

### Source layout (`src/`)

- **`src/common/`** — Shared libraries: networking (Asio), crypto, configuration, logging, threading, collision, utilities
- **`src/server/game/`** — Core game logic (~52 subsystems)
- **`src/server/scripts/`** — Content scripts (bosses, spells, commands, instances)
- **`src/server/database/`** — Database abstraction and schema updater
- **`src/server/shared/`** — Shared between auth and world (packets, realm definitions)
- **`src/test/`** — Unit tests (Google Test)

### Key game subsystems (`src/server/game/`)

- **Entities/** — `Player`, `Creature`, `Unit`, `Item`, `GameObject`
- **Spells/** — Spell mechanics, auras, effects
- **Maps/** — Maps, grids, instances
- **Handlers/** — Packet handlers on `WorldSession`
- **AI/** — Creature AI
- **Scripting/** — `ScriptObject` subclasses (`CreatureScript`, `SpellScript`, etc.)
- **Server/** — `WorldSession`, `World`, opcodes

### Scripting system

1. Class inheriting `SpellScript`, `CreatureScript`, etc.
2. `AddSC_*()` calling `RegisterSpellScript(ClassName)` (or equivalent)
3. `AddSC_*` wired in regional `*_script_loader.cpp`
4. Regional loaders: `spells_script_loader.cpp`, `eastern_kingdoms_script_loader.cpp`, etc.
5. Spell scripts often grouped by class: `spell_dk.cpp`, `spell_mage.cpp`, `spell_generic.cpp`, …

### Databases

- **acore_auth** — Accounts, realm list, bans (`data/sql/base/db_auth/`)
- **acore_characters** — Characters, inventories, progress (`data/sql/base/db_characters/`)
- **acore_world** — Content: creatures, items, quests, spells, loot (`data/sql/base/db_world/`)

SQL updates: `data/sql/updates/pending_*` (per DB) until merged upstream; after merge, under `data/sql/updates/` with DB subdirs. Do not edit SQL files outside the intended update workflow.

Playerbots and other modules may add **acore_playerbots** and extra tables—see module SQL under `modules/*/data/sql/`.

### Module system

Modules live under `modules/`, each with its own `CMakeLists.txt`. Disable with `-DDISABLED_AC_MODULES="mod1;mod2"`. Upstream skeleton: https://github.com/azerothcore/skeleton-module/

### Dependencies

Bundled in `deps/`: Boost, MySQL client, OpenSSL, zlib, recastnavigation, g3dlite, fmt, argon2, jemalloc, and others.

## Staying current with upstream

- Prefer **small, reversible commits** for local customization so merges/rebases stay tractable.
- For **core**: fetch/compare **GitHub AzerothCore** (or your chosen upstream branch) against **GitLab**; resolve conflicts in favor of upstream behavior unless a documented OMW override requires keeping a patch.
- For **each module**: same pattern inside `modules/<name>`—that directory may have its own `origin` (GitLab) and `upstream` (GitHub).
- After upstream pulls: **full compile**, apply **SQL updates** in order, smoke-test critical paths, watch **Server.log / Errors.log**.

## Commit message format

Conventional Commits:

```
Type(Scope/Subscope): Short description (max 50 chars)
```

- **Types**: feat, fix, refactor, style, docs, test, chore
- **Scopes**: Core (C++), DB (SQL), etc.
- **Examples**: `fix(Core/Spells): Fix damage calculation for Fireball`, `fix(DB/SAI): Missing spell to NPC Hogger`

## Code style (aligned with `.cursor/rules`)

- **C++**: 4 spaces, no tabs; **max 120** character lines; **Allman** braces; naming per AzerothCore conventions (PascalCase classes, camelCase functions/variables).
- **JSON / YAML / shell**: 2-space indent where applicable.
- UTF-8, LF line endings.
- Prefer `{}`-style format strings over printf-style `%u` in new code where the codebase already does.
- CI may enforce additional formatting; build with `-Werror` in clean configurations.

## PR / review expectations

- Disclose AI assistance in PRs when required by policy.
- In-game or server-log validation for gameplay-impacting changes.
- Generic core changes need regression thought for related systems (spells, maps, handlers).
