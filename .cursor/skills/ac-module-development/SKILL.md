---
name: ac-module-development
description: >-
  Implements or refactors AzerothCore C++ modules under modules/. Use when
  creating a new module, adding CMake options, wiring script loaders, or when
  the user mentions mod-*, skeleton-module, or DISABLED_AC_MODULES.
---

# AzerothCore module development

## Layout

- Path: `modules/<module>/` with module `CMakeLists.txt`.
- Prefer **isolated** code: scripts, hooks, configuration; avoid copying large core patches into the module unless necessary.

## CMake

- Match options and target naming used by sibling modules in this repo.
- Document new cache options briefly in the module README if the module ships one.

## Integration patterns

- **Scripts**: same registration pattern as core (`AddSC_*`, `RegisterCreatureScript`, etc.); ensure the module’s loader is invoked from the module entry point per skeleton.
- **Config**: use AzerothCore config conventions (`.conf.dist` patterns) consistent with other modules.

## Verification

- [ ] `modules/<name>/CMakeLists.txt` and `modules/<name>/src/` exist (see [reference.md](reference.md))
- [ ] Builds with `-DMODULES=static` (or the project default) without undefined symbols
- [ ] No accidental edits to core unless the task explicitly requires it

## Additional resources

- Skeleton upstream: https://github.com/azerothcore/skeleton-module/
- CMake layout and linkage: [reference.md](reference.md)
