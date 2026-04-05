---
description: "Create an AzerothCore SQL update in the correct pending database folder. Use when adding or fixing world, auth, characters, SAI, or module SQL changes."
name: "Create SQL Update"
argument-hint: "Describe the SQL change and, if known, the target database: auth, characters, world, or module"
agent: "agent"
---
Use [sql.instructions.md](../instructions/sql.instructions.md) and [CLAUDE.md](../../CLAUDE.md).

Create or update an AzerothCore SQL change for the requested task.

## Workflow

1. Determine the correct target database or module SQL path. If it is ambiguous, ask a concise clarifying question before editing files.
2. Inspect nearby pending SQL updates and relevant table usage so the new change matches existing project patterns.
3. Create the SQL change only in the correct pending location or canonical module SQL path. Do not edit base SQL files or merged SQL history unless the task explicitly requires it.
4. Follow AzerothCore SQL conventions: backticks for identifiers, `DELETE` before `INSERT`, compact multi-row inserts where practical, and preserve nearby formatting.
5. If the change affects generic data or scripted behavior, mention likely verification steps and regression areas.

## Output

Return:
- The SQL file path created or updated
- The target database and affected tables
- Any assumptions or follow-up questions
- Suggested validation steps, including import/test notes when relevant