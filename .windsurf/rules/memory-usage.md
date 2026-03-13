---
trigger: always_on
description: Apply when using Cascade's memory system to store and retrieve project information
---
# Memory System Usage Rules

## Memory System Overview

Cascade has access to a persistent knowledge graph memory system that stores:
- **Entities**: Named objects with observations (facts about them)
- **Relations**: Connections between entities with relationship types
- **Semantic Search**: Query memory by natural language

## When to Use Memory

<memory_triggers>
- **Project Information**: Architecture, modules, systems, configurations
- **Critical Issues**: Known bugs, race conditions, safety concerns
- **Development Patterns**: Coding standards, workflows, best practices
- **Module Details**: Configuration options, features, integration points
- **Database Schema**: Table structures, relationships, constraints
- **System Behavior**: Performance characteristics, limitations, quirks
- **User Preferences**: Explicit requests to remember something
- **Important Decisions**: Architectural choices, design patterns
</memory_triggers>

## Memory Operations

### Search Memory
Use `mcp5_search_nodes` to find relevant information:
```
Query: "playerbots LLM configuration"
Returns: Entities matching the query with their observations
```

### Read Full Graph
Use `mcp5_read_graph` to see all stored knowledge:
```
Returns: All entities and relations in the knowledge graph
```

### Open Specific Nodes
Use `mcp5_open_nodes` to retrieve specific entities by name:
```
Names: ["mod-playerbots-llm Module", "Database Architecture"]
Returns: Full details of specified entities
```

### Create Entities
Use `mcp5_create_entities` to store new information:
```json
{
  "name": "Entity Name",
  "entityType": "category",
  "observations": [
    "Fact 1 about the entity",
    "Fact 2 about the entity"
  ]
}
```

### Add Observations
Use `mcp5_add_observations` to add facts to existing entities:
```json
{
  "entityName": "Existing Entity",
  "contents": ["New fact 1", "New fact 2"]
}
```

### Create Relations
Use `mcp5_create_relations` to link entities:
```json
{
  "from": "Entity A",
  "to": "Entity B",
  "relationType": "uses|extends|integrates_with|depends_on|governs|guides"
}
```

### Update Entities
Use `mcp5_create_entities` with Action="update" to modify existing entities.

### Delete Information
Use appropriate delete operations when information becomes outdated or incorrect.

## Entity Types

<entity_types>
- **system_architecture**: Overall project structure and organization
- **module**: Individual AzerothCore modules (mod-*)
- **database_system**: Database structure and operations
- **scripting_system**: SmartAI, Lua, or other scripting systems
- **spell_system**: Spell configuration and proc mechanics
- **conditional_logic**: Conditions system and logic
- **bot_system**: Playerbot AI and behavior
- **process**: Development workflows and procedures
- **coding_standards**: Code style and best practices
- **module_list**: Collections of related modules
- **operations**: Server management and operations
- **configuration**: System configuration and settings
- **known_issue**: Documented bugs or limitations
</entity_types>

## Relation Types

<relation_types>
- **uses**: Entity A uses Entity B (e.g., "SmartAI uses Conditions System")
- **extends**: Entity A extends Entity B (e.g., "mod-playerbots-llm extends Playerbots AI")
- **integrates_with**: Entity A integrates with Entity B (mutual relationship)
- **depends_on**: Entity A depends on Entity B (hard dependency)
- **governs**: Entity A governs Entity B (controls or manages)
- **guides**: Entity A guides Entity B (provides direction)
- **interacts_with**: Entity A interacts with Entity B (loose coupling)
</relation_types>

## Best Practices

<best_practices>
1. **Search Before Creating**: Always search memory before creating new entities to avoid duplicates
2. **Specific Names**: Use descriptive, unique names for entities (e.g., "mod-playerbots-llm Module" not "LLM Module")
3. **Atomic Observations**: Each observation should be a single, complete fact
4. **Factual Only**: Store only verified facts, not speculation or assumptions
5. **Update Regularly**: Add observations when new information is discovered
6. **Clean Up**: Delete outdated or incorrect information promptly
7. **Meaningful Relations**: Create relations that add value to understanding
8. **Consistent Types**: Use standard entity and relation types for consistency
9. **Critical Information**: Always store safety-critical information (bugs, race conditions, security issues)
10. **User Requests**: Honor explicit user requests to remember information
</best_practices>

## Current Memory State

As of 2026-02-08, the memory system contains:

### Core Entities
- **AzerothCore Project Architecture**: Overall project structure, realms, databases
- **Database Architecture**: 4 databases (world, characters, playerbots, auth)
- **SmartAI Scripting System**: 110+ events, 100+ actions, 30+ targets
- **Spell Proc System**: Proc flags, spell families, proc attributes
- **Conditions System**: 29 source types, 40+ condition types
- **Playerbots AI System**: Bot types, AI behavior, performance characteristics
- **Development Workflow**: Design -> Test -> Deploy -> Monitor cycle
- **C++ Code Standards**: Naming conventions, memory management, safety rules
- **Server Management**: Production (8085) and development (8086) realms

### Module Entities
- **mod-playerbots-llm Module**: LLM integration, vector DB, game data indexing
- **mod-challenge-modes Module**: 8 challenge types with rewards
- **mod-mythic-plus Module**: 3 difficulty tiers with scaling
- **mod-progression-system Module**: 40+ content brackets
- **Additional Modules**: 15+ supporting modules

### Relations
- Module integration relationships
- System dependencies
- Workflow governance
- Standard compliance

## Memory Maintenance

<maintenance_rules>
- **Weekly Review**: Review memory for outdated information
- **After Major Changes**: Update memory when systems change
- **Bug Discovery**: Immediately document critical issues
- **Configuration Changes**: Update module configurations when modified
- **New Modules**: Document new modules as they're added
- **Deprecations**: Remove or mark deprecated features
- **Performance Updates**: Update performance characteristics when tuned
</maintenance_rules>

## Examples

### Example 1: Finding Module Configuration
```
Search: "playerbots LLM configuration options"
Result: mod-playerbots-llm Module entity with all config settings
```

### Example 2: Checking for Known Issues
```
Search: "playerbots arena group race condition"
Result: Playerbots AI System with CRITICAL arena group formation issue
```

### Example 3: Understanding System Relationships
```
Open: ["SmartAI Scripting System", "Conditions System"]
Result: SmartAI uses Conditions for filtering events
```

### Example 4: Adding New Module Information
```
Create Entity: "mod-new-feature Module"
Observations: ["Configuration: path/to/config", "Feature: description"]
Create Relation: "mod-new-feature Module" integrates_with "AzerothCore Project Architecture"
```

## Integration with Windsurf Rules

Memory system complements Windsurf rules:
- **Rules**: Static guidelines and standards (in .windsurf/rules/)
- **Memory**: Dynamic project state and discoveries
- **Workflows**: Step-by-step procedures (in .windsurf/workflows/)
- **Memory**: Context and background for workflows

Use memory to:
- Store project-specific details not in rules
- Track evolving system state
- Document discovered issues
- Remember user preferences
- Build knowledge over time

## Critical Safety Information in Memory

The memory system stores critical safety information:
- **Race Conditions**: Arena group formation, guild operations
- **Null Check Issues**: Bot session validation, group operations
- **Performance Limits**: Bot counts, update intervals
- **Database Safety**: Backup requirements, transaction usage
- **Deployment Rules**: Never auto-restart servers, test on dev first

Always check memory for safety-critical information before:
- Modifying bot group operations
- Deploying to production
- Changing database schemas
- Implementing new features
- Troubleshooting crashes
