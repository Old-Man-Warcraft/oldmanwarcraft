---
description: "Use when editing AzerothCore modules, module CMake files, hooks, configs, or integration code under modules/. Covers module layout, CMake aggregation, and keeping changes isolated from core."
name: "AzerothCore Modules"
applyTo: "modules/**/*"
---
# AzerothCore Modules

- Keep each module under `modules/<module_name>/` with its own `CMakeLists.txt`; root `modules/CMakeLists.txt` handles aggregation.
- Prefer hooks, script classes, and config over direct core edits when a module can stay isolated.
- Mirror patterns from the official skeleton module and existing first-party modules before inventing new structure.
- Document configure-time conflicts with `-DDISABLED_AC_MODULES=\"mod1;mod2\"` when relevant.
- Match existing static or dynamic module loading and symbol export patterns already used in the tree.
