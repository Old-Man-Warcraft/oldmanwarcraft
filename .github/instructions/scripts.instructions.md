---
description: "Use when editing AzerothCore gameplay scripts, spell scripts, boss scripts, creature scripts, instance scripts, or script loaders under src/server/scripts. Covers AddSC registration and script placement conventions."
name: "AzerothCore Script Instructions"
applyTo: "src/server/scripts/**/*.cpp, src/server/scripts/**/*.h"
---
# Script Guidelines

- Keep gameplay content logic in `src/server/scripts/`; engine or generic gameplay systems belong in `src/server/game/`.
- Follow the standard registration pattern: implement `AddSC_*()` and wire the script through the relevant script loader.
- Keep spell scripts in the existing class-grouped files such as `spell_dk.cpp`, `spell_mage.cpp`, or `spell_generic.cpp` unless there is a clear existing pattern that requires a different file.
- Match the naming, registration style, and nearby helper patterns already used in the surrounding script file.
- If a script change touches generic behavior, call out regression risk and test related content, not just the specific scripted case.

See [CLAUDE.md](../../CLAUDE.md) for architecture details and [.github/copilot-instructions.md](../copilot-instructions.md) for workspace-wide defaults.