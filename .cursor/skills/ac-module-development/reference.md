# AzerothCore modules — CMake reference

Use with **`ac-module-development`**. Official skeleton: https://github.com/azerothcore/skeleton-module/

## Directory contract

| Path | Purpose |
|------|--------|
| `modules/<name>/CMakeLists.txt` | Picked up by root `CMakeLists.txt` (`add_subdirectory`); omit module from tree or use `DISABLED_AC_MODULES` to skip. |
| `modules/<name>/src/` | Must exist as a **directory** for the module to appear in `GetModuleSourceList()` (used by `modules/CMakeLists.txt`). Sources are collected from here. |
| `modules/<name>/conf/*.conf.dist` | Optional; listed at configure time and installed via `CopyModuleConfig`. |
| `modules/<name>/<name>.cmake` | Optional; `include(... OPTIONAL)` from `modules/CMakeLists.txt` for extra targets/flags. |

## Disabling a module at configure time

```bash
cmake .. -DDISABLED_AC_MODULES="mod-foo;mod-bar"
```

Names are **directory basenames** under `modules/` (see root `CMakeLists.txt`).

## Linkage (`MODULES` cache)

Global option: `MODULES` = `none` | `static` | `dynamic` (defaults in `conf/dist/config.cmake`).

Per-module linkage is exposed when using a **custom** modules build (see `MODULES` / module options in `ccmake`); each module can be `default`, `disabled`, `static`, or `dynamic`. Static modules are linked into the `modules` target; dynamic ones become separate shared libraries (see `modules/CMakeLists.txt`).

## Special cases in-tree

`modules/CMakeLists.txt` contains **hard-coded** branches for known modules (e.g. `mod-ale`, `mod-playerbots`): extra compile definitions, link libraries, install rules. New modules normally do **not** need edits there unless you add similar cross-cutting behavior.

## Deprecated script API

If `AC_ADD_SCRIPTS_*` globals mention a module, that module is forced to **static** linkage with a configure-time notice (`deprecated loader api`).
