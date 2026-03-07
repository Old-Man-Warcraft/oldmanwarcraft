# Project Guidelines

## Read First
- Read [CLAUDE.md](../CLAUDE.md) before making non-trivial changes.
- For review-specific expectations, also read [.github/agents/pr-reviewer.md](agents/pr-reviewer.md).
- Use this file for workspace-wide defaults. Do not add a root `AGENTS.md` while this file exists.

## Architecture
- AzerothCore has two server executables: `authserver` in `src/server/apps/authserver/` and `worldserver` in `src/server/apps/worldserver/`.
- Put engine and gameplay logic in `src/server/game/`. Put gameplay content scripts in `src/server/scripts/`. Put shared packet and networking code in `src/server/shared/`.
- Scripts follow the AzerothCore registration pattern: implement `AddSC_*()` and wire it through the relevant script loader.
- Spell scripts are grouped by class files such as `spell_dk.cpp`, `spell_mage.cpp`, and `spell_generic.cpp`.
- Modules live under `modules/`. Treat each module as potentially independent from the main repo for history and git inspection.

## Build And Test
- Do not build by default. Build, run servers, or run broader test suites only when the task requires it or the user asks for it.
- Prefer the workspace tasks when available: `AzerothCore: Build`, `AzerothCore: Clean build`, `AzerothCore: Check codestyle cpp`, `AzerothCore: Check codestyle sql`, `AzerothCore: Run authserver (restarter)`, and `AzerothCore: Run worldserver (restarter)`.
- If unit tests are needed, use the existing test setup in `src/test/` and `apps/test-framework/`.
- CI compiles with `-Werror`, so avoid introducing warnings.

## Code Style
- Use 4 spaces for C++ and SQL indentation. Use 2 spaces for JSON, YAML, and shell scripts.
- Keep C++ lines within the project style limits and follow the existing formatting in surrounding code instead of reformatting unrelated code.
- Do not add braces around single-line statements just for style consistency if the surrounding code omits them.
- Use project naming and placement patterns already established in nearby files.

## Database And SQL
- AzerothCore uses three primary databases: `acore_auth`, `acore_characters`, and `acore_world`.
- Never modify base SQL files or merged SQL history for routine changes. New SQL updates belong in `data/sql/updates/pending_db_auth/`, `data/sql/updates/pending_db_characters/`, or `data/sql/updates/pending_db_world/`.
- Follow the standard AzerothCore SQL pattern: `DELETE` before `INSERT`, use backticks for identifiers, and preserve the existing style in nearby update files.
- Be careful with module SQL: some modules include optional or destructive SQL helpers. Use only the canonical module SQL paths unless the task explicitly requires something else.

## Repo-Specific Conventions
- Prefer targeted changes over broad refactors. This codebase is large and regressions in generic systems matter.
- If you change generic spell, map, AI, or entity logic, expect regression risk across related systems and call that out in testing notes.
- When working inside `modules/`, remember module directories can be separate git repositories. Inspect module changes with git scoped to that module when needed.
- Do not update generated, vendored, or dependency code under `deps/` unless the task explicitly targets it.

## Useful References
- Core project context: [CLAUDE.md](../CLAUDE.md)
- PR review expectations: [.github/agents/pr-reviewer.md](agents/pr-reviewer.md)
- Bash and unit test framework: [apps/test-framework/README.md](../apps/test-framework/README.md)
- SQL update notes: [data/sql/updates/README.md](../data/sql/updates/README.md)