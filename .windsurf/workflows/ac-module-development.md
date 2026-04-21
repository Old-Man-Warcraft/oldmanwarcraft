---
description: Create or update an AzerothCore module under modules/ — CMake layout, hooks, script loaders
---

# AzerothCore module development

Use when creating a new module, adding CMake options, wiring script loaders, or when the user mentions `mod-*`, skeleton-module, or `DISABLED_AC_MODULES`.

## Layout

- Path: `modules/<module>/` with module `CMakeLists.txt`.
- Prefer **isolated** code: scripts, hooks, configuration; avoid copying large core patches into the module unless necessary.

## Directory contract

| Path | Purpose |
|------|---------|
| `modules/<name>/CMakeLists.txt` | Picked up by root `CMakeLists.txt` (`add_subdirectory`); use `DISABLED_AC_MODULES` to skip. |
| `modules/<name>/src/` | Must exist as a **directory**; sources collected from here. |
| `modules/<name>/conf/*.conf.dist` | Optional; installed via `CopyModuleConfig`. |
| `modules/<name>/<name>.cmake` | Optional; `include(... OPTIONAL)` from `modules/CMakeLists.txt` for extra targets/flags. |

## CMake

- Match options and target naming used by sibling modules in this repo.
- Disable at configure time: `cmake .. -DDISABLED_AC_MODULES="mod-foo;mod-bar"`.
- Global linkage option: `MODULES` = `none` | `static` | `dynamic` (default: `static`).
- Document new cache options briefly in the module README.

## Integration patterns

- **Scripts**: same registration pattern as core (`AddSC_*`, `RegisterCreatureScript`, etc.); ensure the module's loader is invoked from the module entry point per skeleton.
- **Config**: use AzerothCore config conventions (`.conf.dist` patterns) consistent with other modules.

## Verification checklist

- [ ] `modules/<name>/CMakeLists.txt` and `modules/<name>/src/` exist
- [ ] Builds with `-DMODULES=static` (or the project default) without undefined symbols
- [ ] No accidental edits to core unless the task explicitly requires it

## Additional resources

- Skeleton upstream: https://github.com/azerothcore/skeleton-module/
- Hard-coded module branches in `modules/CMakeLists.txt` (e.g. `mod-ale`, `mod-playerbots`): new modules normally do **not** need edits there.
