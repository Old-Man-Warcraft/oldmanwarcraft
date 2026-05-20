---
name: project-orientation
description: Orient the AI to the AzerothCore WotLK codebase. Use for tasks related to this codebase, especially before modifying code or when the codebase structure, MCP server access, or project conventions are unclear.
---

# Project Orientation

This skill provides a structured map of the AzerothCore WotLK codebase used by Old Man Warcraft, including MCP routing and which domain skills to load.

## When to Use This Skill

Load this skill:
1. At the start of any task involving this codebase
2. When you are unsure about the project structure
3. Before making any code modifications
4. When you need to interact with the database, deploy, or review code

## Codebase Overview

### Root layout
- `src/` - C++ source code (server core, game logic, tools)
- `modules/` - Git submodules / independent modules (playerbots, custom content)
- `data/sql/` - Database migrations (base, updates, custom)
- `apps/` - Shell scripts for CI, installation, compilation
- `conf/` - Worldserver and authserver configuration
- `doc/` - Internal documentation and changelogs
- `.cline/` - AI assistant configuration (this repo's primary assistant)
- `.clinerules/` - Legacy Cursor IDE configuration

### Source code (`src/`)
| Directory | Purpose |
|-----------|---------|
| `src/server/game/` | Core game logic: spells, AI, combat, quests, battlegrounds |
| `src/server/scripts/` | Script system: instance scripts, world scripts, custom scripts |
| `src/server/database/` | Database layer: queries, migrations, connection management |
| `src/server/apps/` | Server applications: worldserver, authserver |
| `src/server/shared/` | Shared utilities |
| `src/common/` | Platform abstractions, logging, configuration, threading |
| `src/tools/` | Map extractors, mmaps generator |
| `src/test/` | Unit and integration tests |

### Modules (`modules/`)
Custom modules live here. Key ones for Old Man Warcraft:
- `mod-playerbots` - Player bot system (NPC bots that simulate players)
- `mod-individual-progression` - Custom gearing/progression system
- Other custom content modules

### Database (`data/sql/`)
| Directory | Purpose |
|-----------|---------|
| `data/sql/base/` | Base database dumps |
| `data/sql/updates/` | Incremental SQL updates |
| `data/sql/custom/` | Custom content SQL |
| `data/sql/archive/` | Archived SQL |
| `data/sql/create/` | Database creation scripts |
| `data/sql/old/` | Deprecated SQL |

## MCP Server Routing

When a task touches these domains, use the corresponding MCP tools:

| Domain | MCP Server | Tools |
|--------|------------|-------|
| **MySQL / Database queries** | `mysql-remote` | `mysql_connection.query` for direct SQL execution |
| **Content DB investigation** | `mysql-remote` | Query creatures, quests, loot, SmartAI, conditions, gossip |
| **Git / GitHub automation** | `github` | Issues, PRs, releases, repository operations |
| **Server management** | (SSH via terminal) | `docker exec` or `acore.sh` on the game server |

### Database access
- Always route through the `mysql-remote` MCP server when querying game data
- Use `.clinerules/agents/content-db-investigator.md` guidance for tracing creatures, quests, loot tables, etc.
- The database connection is configured in MCP settings (do not hardcode credentials)

### Git workflow
- Primary remote: `origin` (Old Man Warcraft fork)
- Upstream: `azerothcore` (AzerothCore upstream)
- Use the `github` MCP server for automation
- Follow the merge strategy in `.clinerules/agents/upstream-merge-advisor.md`

## Domain Skills to Load

After orientation, load additional skills based on the task:

| Task Type | Skill to Load |
|-----------|---------------|
| Database queries, SQL changes | `database-operations` |
| Deploying, restarting, testing | `workflow-deployment-and-testing` |
| Working with playerbots | `playerbots-system` |
| Spell scripting | `spell-proc-reference` |
| SmartAI scripts | `smartai-reference` |
| Battlegrounds / PvP | `battlegrounds-pvp` |
| GitLab bug reports | `workflow-gitlab-bug-reports` |

## Production Server Context

This is a **production server** for Old Man Warcraft.

| Check | Requirement |
|-------|-------------|
| SQL safety | Verify SQL changes before running them. |
| Schema safety | Take database backups before schema changes. |
| Restart safety | Check for active players before restarting the server. |
| Host facts | Use `.clinerules/agents/notion-server-reference.md` for paths, ports, and runbooks. |

## Build System

- **Build tool**: CMake with `acore.sh` wrapper
- **Compiler**: Clang or GCC
- **Build command**: `./acore.sh compiler build`
- **Configuration**: `./acore.sh compiler configure`

## Quick Reference

```
acore.sh compiler build     # Build the server
acore.sh db-pendings        # Check pending SQL migrations
acore.sh installer          # Run the interactive installer
docker-compose up -d        # Start Docker services (DB, etc.)
docker exec -it acore-<app> bash  # Enter running containers
```
