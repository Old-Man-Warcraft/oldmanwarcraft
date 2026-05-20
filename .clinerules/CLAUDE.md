# CLAUDE.md — Cline AI Assistant Configuration

Guidance for AI-assisted work in this repository using **Cline** (VS Code extension) and compatible tools.

## Table of Contents

- [Where Standards Live](#where-standards-live)
- [Project Identity](#project-identity)
- [Quick Reference](#quick-reference)
  - [Build](#build)
  - [Run Tests](#run-tests)
  - [Code Standards Check](#code-standards-check)
- [Repository Overview](#repository-overview)
- [Architecture](#architecture)
- [Development Guidelines](#development-guidelines)
- [Git Hooks](#git-hooks)
- [Workflows](#workflows)
- [Getting Help](#getting-help)

## Where Standards Live

| Resource | Location |
|---|---|
| **Agents** (specialized AI assistants) | `.cline/agents/` |
| **Skills** (domain reference & workflows) | `.cline/skills/` |
| **Rules** (always-on code standards) | `.cline/rules/` |
| **Workflows** (CI/CD pipeline definitions) | `.cline/workflows/` |
| **Hooks** (Git hook scripts) | `.cline/hooks/` |
| **Reference** (project facts, MCP inventory) | `.cline/reference/` |

**MCP credentials**: See `.cline/reference/mcp-tools-inventory.md` and `.cline/rules/mcp-usage.mdc` for MCP server configuration and tool routing.

## Project Identity

- **Community**: Old Man Warcraft — [oldmanwarcraft.com](https://oldmanwarcraft.com)
- **Stack**: AzerothCore WotLK 3.3.5a, heavy custom module set (see `modules/`), often on a Playerbot-oriented branch/fork
- **Git**: GitLab is the org origin; GitHub is the upstream reference for AzerothCore and many modules
- **This deployment**: Production-only host. Favor backups, maintenance windows, and off-host validation.

## Quick Reference

### Build
```sh
# Build everything
cd /root/azerothcore-wotlk && ./acore.sh compiler all

# Build only the worldserver
cd /root/azerothcore-wotlk && ./acore.sh compiler build
```

Compiled binaries go to `env/` by default (`env/build/bin/worldserver`).

### Run Tests
```sh
# Build and run tests
cd /root/azerothcore-wotlk && ./acore.sh compiler all TEST

# Run tests only (no build)
cd /root/azerothcore-wotlk/build && ctest
```

### Code Standards Check
```sh
cd /root/azerothcore-wotlk && python3 apps/codestyle/codestyle-cpp.py
cd /root/azerothcore-wotlk && python3 apps/codestyle/codestyle-sql.py
```

## Repository Overview

This is an **AzerothCore** MMORPG server emulator for **World of Warcraft: Wrath of the Lich King (3.3.5a)**. The project is a fork with **Playerbots**, modules, and custom **Old Man Warcraft (OMW)** content.

### Remote URLs
- **AzerothCore upstream:** `https://github.com/azerothcore/azerothcore-wotlk.git`
- **Playerbots upstream:** `https://github.com/mod-playerbots/azerothcore-wotlk`
- **OMW GitHub:** `https://github.com/Old-Man-Warcraft/oldmanwarcraft.git`
- **OMW GitLab origin:** `https://gitlab.thecorehosting.net/root/oldmanwarcraft`

## Architecture

### Two Server Executables
- **authserver** — Authentication and realm selection (port 3724)
- **worldserver** — Gameplay (default port 8085)

### Source Layout
```
src/
├── server/
│   ├── game/         # Core gameplay (~52 subsystems)
│   ├── scripts/      # Instance/boss/spell scripts
│   ├── database/     # Database abstraction layer
│   ├── apps/         # Authserver, worldserver binaries
│   └── shared/       # Shared code between servers
├── common/           # Shared libraries (networking, crypto, config, etc.)
├── tools/            # Map extractors and utilities
└── test/             # Unit tests (Google Test)
modules/              # Independent addons (Playerbots, mod-autobalance, etc.)
data/sql/             # Database migrations (base, updates, custom)
```

### Key Game Subsystems (`src/server/game/`)
- **Entities/** — `Player`, `Creature`, `Unit`, `Item`, `GameObject`
- **Spells/** — Spell mechanics, auras, effects
- **Maps/** — Maps, grids, instances
- **Handlers/** — Packet handlers on `WorldSession`
- **AI/** — Creature AI (SmartAI, event-driven)
- **Scripting/** — `ScriptObject` subclasses (`CreatureScript`, `SpellScript`, etc.)

### Scripting System
1. Class inherits `SpellScript`, `CreatureScript`, etc.
2. `AddSC_*()` calls `RegisterSpellScript(ClassName)`
3. `AddSC_*` wired in regional `*_script_loader.cpp`
4. Regional loaders: `spells_script_loader.cpp`, `eastern_kingdoms_script_loader.cpp`, etc.

### Databases
- **acore_auth** — Accounts, realm list, bans
- **acore_characters** — Characters, inventories, progress
- **acore_world** — Content: creatures, items, quests, spells, loot

## Development Guidelines

### Code Style
- **C++ standard:** C++17
- Base style: [AzerothCore C++ Standards](https://www.azerothcore.org/wiki/cpp-standards)
- Use `nullptr` instead of `NULL`
- Prefix member variables with `_` (e.g., `_someVar`)
- Tabs for indentation (not spaces)
- Allman brace style (braces on new line)
- Max 120 character lines

### Commit Message Format
```
Type(Scope/Subscope): Short description (max 50 chars)
```
- **Types**: feat, fix, refactor, style, docs, test, chore, ci, perf, build, revert
- **Scopes**: Core, DB, Playerbots, etc.
- **Examples**: `fix(Core/Spells): Fix damage calculation for Fireball`

### Pull Request Guidelines
- Target the `master` branch
- Include SQL updates if database changes are made
- C++ and SQL code style checks must pass
- PRs must compile on CI before merging

## Git Hooks

Install hooks to enforce code standards automatically:

```sh
bash .cline/hooks/install.sh
```

Installed hooks:
| Hook | Action |
|---|---|
| **pre-commit** | Runs C++ and SQL code style checks on staged files |
| **commit-msg** | Validates Conventional Commits format |
| **pre-push** | Warns about SQL update conflicts; optional test run |
| **post-merge** | Checks for new SQL updates after merge |

## Workflows

GitHub Actions workflows in `.cline/workflows/`:

| Workflow | Purpose |
|---|---|
| `ci-build-test.yml` | Full CI pipeline: lint → build → test → notify |
| `pre-commit-review.yml` | Pre-commit validation: commit format, code style, SQL checks |
| `deploy-production.yml` | Controlled production deployment with review checklist |
| `upstream-merge.yml` | Automated upstream merge with conflict detection and build test |

## Getting Help

If you encounter problems, use the agents and skills in `.cline/`:
- **Project orientation**: `.cline/skills/project-orientation/SKILL.md`
- **Build/deploy**: `.cline/skills/workflow-deployment-and-testing/SKILL.md`
- **Database**: `.cline/skills/database-operations/SKILL.md`
- **Spell scripting**: `.cline/skills/spell-proc-reference/SKILL.md`
- **Playerbots**: `.cline/skills/playerbots-system/SKILL.md`
- **SmartAI**: `.cline/skills/smartai-reference/SKILL.md`

### Agent Quick Reference
| Task | Agent |
|---|---|
| Pre/post deploy checks | `production-deploy-review` |
| Upstream merge strategy | `upstream-merge-advisor` |
| Server facts (host, port, path) | `notion-server-reference` |
| Creature/quest/loot DB tracing | `content-db-investigator` |
| Core C++ code review | `core-cpp-game-reviewer` |
| Playerbots safety review | `playerbots-safety-reviewer` |