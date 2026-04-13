# Cursor agents, rules, and skills (OMW / AzerothCore)

This repository is optimized for AI-assisted work on **AzerothCore WotLK 3.3.5a** with **Old Man Warcraft** production constraints. Use this file as the **routing index**; detailed standards live under `.cursor/`.

## Subagents (`.cursor/agents/`)

Specialized agent briefs you can invoke when the task matches. Each file is self-contained YAML frontmatter + instructions.

| Agent | Use when |
|-------|-----------|
| [production-deploy-review](.cursor/agents/production-deploy-review.md) | Pre/post checks for SQL, restarts, C++/module deploys on production |
| [upstream-merge-advisor](.cursor/agents/upstream-merge-advisor.md) | GitLab vs GitHub upstream, `modules/*` nested repos, conflict strategy |
| [notion-server-reference](.cursor/agents/notion-server-reference.md) | Host-specific facts: ports, paths, runbooks—**never guess** |
| [content-db-investigator](.cursor/agents/content-db-investigator.md) | Tracing creatures, quests, loot, SmartAI, conditions via DB/MCP |
| [core-cpp-game-reviewer](.cursor/agents/core-cpp-game-reviewer.md) | Reviewing or authoring `src/server/game/**` C++ (handlers, BGs, spells) |
| [playerbots-safety-reviewer](.cursor/agents/playerbots-safety-reviewer.md) | Bot-adjacent groups, arena, guild—null checks and known risk areas |

## Rules (`.cursor/rules/*.mdc`)

Always-on and file-scoped guidance. Highlights:

- **Always / workspace**: `mcp-usage.mdc`, `azerothcore-standards.mdc`
- **Production**: `deployment-rules.mdc`
- **Domains**: `playerbots-rules.mdc`, `smartai-scripting.mdc`, `spell-proc-rules.mdc`, `conditions-rules.mdc`, `database-rules.mdc`, `module-development.mdc`
- **Packets / PvP**: `packet-handlers-and-opcodes.mdc`, `battlegrounds-pvp.mdc`

Full catalog: open `.cursor/rules/` in the editor.

## Skills (`.cursor/skills/<name>/SKILL.md`)

Workflow and reference skills. Start with **`project-orientation`** for a structured map of the tree, MCP routing, and which skill to load next.

Other examples: `workflow-deployment-and-testing`, `database-operations`, `playerbots-system`, `workflow-gitlab-bug-reports`, `smartai-reference`, `spell-proc-reference`.

## Canonical references

- **Technical index**: [CLAUDE.md](CLAUDE.md)
- **Module and stack summary**: [.cursor/reference/PROJECT_SUMMARY.md](.cursor/reference/PROJECT_SUMMARY.md)
- **MCP tool names**: [.cursor/reference/mcp-tools-inventory.md](.cursor/reference/mcp-tools-inventory.md)
