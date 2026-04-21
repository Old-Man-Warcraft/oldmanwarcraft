---
description: "Use when editing AzerothCore C++ source, headers, handlers, scripts, or tests under src/. Covers subsystem boundaries, script registration, include order, and performance-sensitive paths."
name: "AzerothCore C++"
applyTo:
  - "src/**/*.cpp"
  - "src/**/*.h"
  - "src/**/*.hpp"
---
# AzerothCore C++

- Prefer existing helpers in `src/common/` and patterns in nearby code before adding new abstractions.
- Keep `WorldSession` handlers thin; heavy gameplay logic belongs in the right subsystem under `src/server/game/`.
- For scripts, inherit the correct `ScriptObject` type and register through `AddSC_*()` in the appropriate `*_script_loader.cpp`.
- In hot paths like maps, spells, and movement, avoid redundant lookups and unnecessary allocations.
- Follow the file's existing include order and precompiled-header assumptions.
- If changing generic behavior, note regression risk for related systems in PR or handoff notes.
