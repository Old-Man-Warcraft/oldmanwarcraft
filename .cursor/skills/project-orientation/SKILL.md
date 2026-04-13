---
name: project-orientation
description: Maps the OMW AzerothCore fork for AI sessions—where code, SQL, rules, skills, and agents live, and which artifact to load next. Use when onboarding, doing a repo-wide review, or choosing between core, modules, DB, and ops workflows.
---

# Project orientation (OMW / AzerothCore)

## What this repo is

- **AzerothCore WotLK 3.3.5a** fork with **custom modules** under `modules/` (often **nested Git repos**).
- **GitLab** = typical **origin**; **GitHub** = **upstream** for core and many modules.
- **Production-first host**: no assumed local dev realm; see deployment rules and Notion runbooks.

## Where things live

| Area | Path |
|------|------|
| Core C++ game | `src/server/game/` (Handlers, Spells, Battlegrounds, Maps, …) |
| Scripts (bosses, spells, commands) | `src/server/scripts/` |
| World / auth / character SQL base | `data/sql/base/db_*` |
| Pending SQL updates | `data/sql/updates/` (follow repo workflow) |
| Modules | `modules/<name>/` |
| Cursor rules | `.cursor/rules/*.mdc` |
| Cursor skills | `.cursor/skills/<skill>/SKILL.md` |
| Subagent briefs | `.cursor/agents/*.md` |
| MCP routing | `.cursor/rules/mcp-usage.mdc`, `.cursor/reference/mcp-tools-inventory.md` |

## Which artifact to load

- **Live deploy, restart, logs, rollback** → read `workflow-deployment-and-testing` + rule `deployment-rules.mdc`; agent `production-deploy-review`.
- **Upstream merge / submodule-style module** → agent `upstream-merge-advisor` + skill `workflow-gitlab-bug-reports` if ticket-driven.
- **Host paths, systemd, secrets layout** → agent `notion-server-reference` (do not invent).
- **SmartAI / conditions / loot / quests** → `smartai-reference`, `conditions-reference`, `database-operations`; agent `content-db-investigator`.
- **Spells / procs** → `spell-proc-reference`, `workflow-spell-proc-configuration`; rule `spell-proc-rules.mdc`.
- **Playerbots code or SQL** → `playerbots-system`, `bot-ai-configuration`; rule `playerbots-rules.mdc`; agent `playerbots-safety-reviewer` for group/arena/guild risk.
- **Packet / opcode / handler changes** → rule `packet-handlers-and-opcodes.mdc`; skill `workflow-opcode-handler`.
- **Arena / BG / honor** → rule `battlegrounds-pvp.mdc`; agent `core-cpp-game-reviewer` for C++ review.
- **New module scaffold** → `workflow-module-development`.

## MCP order of operations

1. **Notion** for ops truth (when the question is host-specific).
2. **azerothcore** for DB, SmartAI, spells, wiki/source search (read-first on production).
3. **oldmanwarcraft-api-remote** (`omw_*`) for site/player-facing API where relevant.
4. **GitLab-MCP** for origin MRs/issues/files.
5. **fetch / firecrawl / exa / deepwiki** for external docs—cross-check with repo and `azerothcore` tools.

## Human index

- **Repo entrypoints**: [AGENTS.md](../../AGENTS.md), [CLAUDE.md](../../CLAUDE.md), [.cursor/reference/PROJECT_SUMMARY.md](../../reference/PROJECT_SUMMARY.md).
