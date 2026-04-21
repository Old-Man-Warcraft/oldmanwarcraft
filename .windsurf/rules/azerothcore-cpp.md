---
trigger: glob
description: C++ conventions for AzerothCore core, shared, scripts, tests
globs:
  - src/**/*.cpp
  - src/**/*.h
  - src/**/*.hpp
---

# AzerothCore C++

- Prefer existing helpers in `src/common/` and patterns in nearby code before adding new abstractions.
- **Handlers** (`WorldSession` methods): keep packet logic thin; heavy work belongs in game subsystems.
- **Scripts**: inherit the right `ScriptObject` type; register via `Register*Script` from an `AddSC_*()` wired into the appropriate `*_script_loader.cpp`.
- **Hot paths** (maps, spells, movement): avoid allocations and redundant lookups; profile mentally before micro-optimizing.
- **Includes**: follow file's existing include order and PCH assumptions.
- If changing generic behavior, note **regression risk** (spells, movement, instances, DB layer) in PR description.
