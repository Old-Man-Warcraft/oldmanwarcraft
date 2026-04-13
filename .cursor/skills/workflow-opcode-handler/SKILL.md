---
name: workflow-opcode-handler
description: Wires new or changed client–server opcodes to WorldSession handlers in AzerothCore. Use when editing Opcodes.cpp/h, Handlers/*.cpp, or packet flow; includes OMW playerbots safety notes.
---

# Opcode and handler workflow

## Locate definitions

- **Opcode enum and tables**: `src/server/game/Server/Protocol/Opcodes.h`, `Opcodes.cpp`.
- **Handler bodies**: `src/server/game/Handlers/*.cpp` (grouped by feature: mail, guild, arena, etc.).
- **Registration**: handler functions are bound in **`WorldSession`** opcode dispatch tables—search for an existing opcode in the same feature area and mirror placement.

## Implementation checklist

- [ ] Opcode name matches **client 3.3.5a** expectations (compare with sniff/wiki or upstream AC).
- [ ] **Status** (handled, deprecated, unused) set consistently with adjacent opcodes.
- [ ] Handler validates **`WorldSession`**, **`GetPlayer()`**, and any **group/guild/arena** pointers before use.
- [ ] For **bot sessions**, avoid assumptions that UI-only packets or timing match human clients; prefer safe no-ops when state is incomplete.
- [ ] No handler should **crash** on malformed or cross-version packets—log and return where the codebase already does so for similar opcodes.

## Verify

- [ ] Full **cmake + compile** after opcode table edits (easy to typo initializer rows).
- [ ] In-game or staging exercise of the feature; tail **Errors.log** for asserts.
- [ ] If SQL or character fields are involved, follow **`database-operations`** and backup policy.

## References

- Rule: `.cursor/rules/packet-handlers-and-opcodes.mdc`
- Standards: `.cursor/rules/azerothcore-standards.mdc` (style, braces, line length)
