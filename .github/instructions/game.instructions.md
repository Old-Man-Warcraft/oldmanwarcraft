---
description: "Use when editing generic AzerothCore gameplay or engine code under src/server/game, including entities, spells, maps, AI, handlers, server systems, or shared gameplay infrastructure. Covers high-regression core changes and testing expectations."
name: "AzerothCore Game Core Instructions"
applyTo: "src/server/game/**/*.cpp, src/server/game/**/*.h"
---
# Game Core Guidelines

- Treat changes under `src/server/game/` as high-impact by default. Prefer targeted fixes over refactors because these systems often affect many game features at once.
- Keep generic engine and gameplay logic here; do not move content-specific behavior into scripts just to localize a fix.
- Respect subsystem boundaries already present in the tree such as `Entities/`, `Spells/`, `Maps/`, `AI/`, `Handlers/`, and `Server/`.
- When changing spell, map, AI, entity, handler, or session behavior, call out likely regression areas and test related systems, not only the immediate bug or feature.
- Add or update unit tests in `src/test/` when behavior is realistically covered there. If it is not practical to automate, document the manual verification path.
- Preserve surrounding ownership, lifecycle, and naming patterns instead of introducing new abstractions unless the task clearly requires them.

See [CLAUDE.md](../../CLAUDE.md) and [.github/copilot-instructions.md](../copilot-instructions.md) for workspace-wide architecture and build guidance.