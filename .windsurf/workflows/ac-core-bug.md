---
description: Investigate and fix a core or gameplay bug in AzerothCore
---

# AzerothCore core / gameplay bug fix

Use when fixing logic in `src/server/game/`, handlers, spells, movement, or any gameplay subsystem.

## Steps

1. Reproduce mentally from the report; locate the subsystem under `src/server/game/`.
2. Read nearby code and one caller/callee level before patching.
3. Keep the diff minimal; avoid unrelated formatting changes.
4. If the behavior is user-visible, note **in-game verification** steps for the PR description.
5. Run or add **unit tests** only when the change touches testable pure logic (`BUILD_TESTING` — see `CLAUDE.md`).

## Commit format

```
fix(Core/<Subsystem>): Short description (max 72 chars)
```

Examples:
- `fix(Core/Spells): Fix damage calculation for Fireball`
- `fix(Core/Maps): Prevent crash on empty grid unload`

## PR checklist

- [ ] Root cause identified (not a symptom workaround)
- [ ] Diff is minimal and scoped
- [ ] Regression risk noted in PR if generic code was touched
- [ ] In-game verification steps listed
- [ ] AI tool usage disclosed if applicable
