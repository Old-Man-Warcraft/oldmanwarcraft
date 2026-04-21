---
trigger: glob
description: AzerothCore module layout, CMake, and isolation from core
globs:
  - modules/**/*
---

# AzerothCore modules

- Modules live under `modules/<module_name>/` with a **module** `CMakeLists.txt`; root `modules/CMakeLists.txt` aggregates them.
- Keep **cross-boundary** surface small: prefer hooks, script classes, and config over editing core when possible.
- Follow the official skeleton: https://github.com/azerothcore/skeleton-module/
- Disable modules at configure time with `-DDISABLED_AC_MODULES="mod1;mod2"` when documenting conflicts.
- **Static vs dynamic** `MODULES` build affects how you export/load symbols; mirror patterns from existing first-party modules if present in the tree.
