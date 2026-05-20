# Project Summary: Old Man Warcraft

| Property | Value |
|---|---|
| **Game** | World of Warcraft: Wrath of the Lich King (3.3.5a) |
| **Core** | AzerothCore (open-source server emulator) |
| **Core Fork** | Old Man Warcraft custom fork |
| **Primary Language** | C++ (server), SQL (database), Bash/Python (tooling) |
| **Build System** | CMake |
| **Version Control** | Git (GitLab primary, GitHub mirrors) |
| **CI/CD** | GitLab CI + GitHub Actions |
| **Database** | MySQL (world, characters, auth databases) |
| **Production** | Self-hosted VPS |
| **Dev Environment** | Docker Compose |
| **Testing** | Google Test + Bats (Bash) |
| **MCP Servers** | mysql-azerothcore-wotlk, notion-api, gitlab-api, github-api |

## Stack Summary

### Core Server
- `src/server/game/` — Core gameplay (spells, AI, movement, combat, etc.)
- `src/server/scripts/` — Instance/boss/spell scripts
- `src/server/database/` — DB interaction layer
- `src/common/` — Shared libraries (config, logging, threading, crypto, etc.)

### Modules (Independent Addons)
Placed under `modules/`. Over 50+ modules including:
- **playerbots** — AI-driven player bots
- **mod-autobalance** — Dynamic difficulty scaling
- **mod-eluna** — Lua scripting engine
- **mod-npc-beastmaster** — Hunter pet training NPC
- **mod-solo-lfg** — LFG for solo play

### Tools & Scripts
- `apps/` — Compiler, CI, Docker, config-merger, extractor
- `bin/` — acore-cli helper tools
- `acore.sh` — Master script for build/install/export

### Database
- World: Full 3.3.5a content (creatures, quests, items, spells, etc.)
- Characters: Player data, guilds, arena teams
- Auth: Accounts, realm info

## Key Architectural Patterns

1. **Script Object System** — All game scripts inherit from ScriptObject
2. **SmartAI** — Database-driven AI for creatures/gameobjects
3. **Event-Driven** — Game events trigger script hooks
4. **Module System** — Independent addons that hook into the core
5. **DBC/DB2** — Client data files for spell/creature/item definitions

## Repository Remotes

| Remote | URL |
|---|---|
| Origin (GitLab) | `https://gitlab.thecorehosting.net/root/oldmanwarcraft` |
| Upstream (AC) | `https://github.com/azerothcore/azerothcore-wotlk.git` |
| Upstream (Playerbots) | `https://github.com/mod-playerbots/azerothcore-wotlk` |
| OMW Fork (GitHub) | `https://github.com/Old-Man-Warcraft/oldmanwarcraft.git` |