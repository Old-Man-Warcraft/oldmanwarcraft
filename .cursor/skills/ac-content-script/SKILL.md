---
name: ac-content-script
description: >-
  Adds or fixes AzerothCore content scripts (CreatureScript, SpellScript,
  InstanceMapScript, commands). Use when working under src/server/scripts/,
  boss scripts, spell scripts, SAI-adjacent C++, or script_loader registration.
---

# AzerothCore content scripts

## Steps

1. Locate the correct region or system file (e.g. `spell_*`, zone folders) or create a file consistent with neighbors.
2. Implement script class(es) deriving from the appropriate `ScriptObject` type.
3. Add `AddSC_<name>()` calling the right `Register*Script` helpers.
4. Declare `void AddSC_<name>();` in the regional header if that pattern exists in the subtree.
5. Call `AddSC_<name>()` from the correct `*_script_loader.cpp`.

## Quality bar

- [ ] Script ID / entry / spell id bindings match DB (`acore_world`) when applicable
- [ ] No duplicate registration symbols
- [ ] Instance scripts: respect map/instance boundaries and `InstanceScript` APIs
- [ ] Spell scripts: use hooks appropriate to effect timing (`PrepareAuraScript`, etc.)

## When SQL is also required

Coordinate with `ac-sql-updates` for `creature_template`, `smart_scripts`, `spell_*` tables, etc.
