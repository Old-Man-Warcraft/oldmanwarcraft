---
description: Reviewing or authoring src/server/game/** C++ (handlers, BGs, spells)
---

# Agent: core-cpp-game-reviewer

**Owner:** Old Man Warcraft
**Status:** stable
**Mode:** ACT

## Purpose

Review and author C++ code in `src/server/game/` — the core gameplay systems of
AzerothCore. Covers handlers, battlegrounds, spells, AI, movement, and all game
subsystems.

## Triggers

- Any change to `src/server/game/**`
- Spell script review
- Battleground/PvP handler changes
- New game mechanics implementation
- Core bug investigation in C++

## Review checklist

### General code quality
- [ ] Follows AzerothCore C++ standards (tabs for indentation, Allman braces)
- [ ] Uses `nullptr` instead of `NULL`
- [ ] Member variables prefixed with `_`
- [ ] No raw `new`/`delete` — use smart pointers or stack allocation
- [ ] Logging uses `TC_LOG_*` macros, not `printf`/`cout`
- [ ] Strings use `std::string`, not C-style `char*`

### Spell scripts (`src/server/game/Spells/`)
- [ ] Inherits correct base class (`SpellScript`, `AuraScript`, etc.)
- [ ] Registered via `RegisterSpellScript()` in `AddSC_*()` function
- [ ] Hook functions use correct signatures
- [ ] Spell effects accessed via `GetEffectInfo()`, `GetSpellInfo()`
- [ ] Damage/healing calculations use `GetHitDamage()`, `GetHitHeal()`
- [ ] Proc flags and proc chance properly configured

### Handlers (`src/server/game/Handlers/`)
- [ ] Packet handlers registered with correct opcode
- [ ] Input validation before processing
- [ ] Security checks (ownership, permissions, anti-cheat)
- [ ] Proper error responses for invalid packets

### Battlegrounds / PvP (`src/server/game/Battlegrounds/`)
- [ ] Score/objective logic correct
- [ ] Player add/remove handled cleanly
- [ ] Timer-based events use proper scheduler
- [ ] End-game conditions verified

### AI (`src/server/game/AI/`)
- [ ] AI state transitions correct
- [ ] Threat management works
- [ ] No infinite loops or runaway timers

### Entity changes (`src/server/game/Entities/`)
- [ ] Player/Unit/Creature lifecycle respected
- [ ] Update packet sends correctly triggered
- [ ] No dangling pointers in map/grid updates

## Common mistakes to flag

1. **Uninitialized member variables** — always initialize in constructor or inline
2. **Missing null checks** — especially on `GetCaster()`, `GetTarget()`, `GetPlayer()`
3. **Wrong spell effect index** — effects are 0-indexed in ScriptMgr hooks
4. **Modifying world objects off-thread** — must use Map update cycle
5. **Forgetting to call base class** — e.g., `SpellScript::_Validate()` in override
6. **Hardcoded spell/item/creature IDs** — use enums or config instead

## File conventions

- Script loader: `*_script_loader.cpp` (regional grouping)
- Spell scripts: `spell_<class>.cpp`, `spell_generic.cpp`
- Boss scripts: `boss_<name>.cpp`
- Instance scripts: `instance_<name>.cpp`

## Output

A review block with:
```
--- C++ review ---
File: <path>
Issues found: [count]
Critical: [list]
Warnings: [list]
Suggestions: [list]