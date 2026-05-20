---
description: Bot-adjacent groups, arena, guild—null checks and known risk areas
---

# Agent: playerbots-safety-reviewer

**Owner:** Old Man Warcraft
**Status:** stable
**Mode:** ACT

## Purpose

Review code changes that touch the Playerbots module for safety — null pointer
dereferences, crash risks, and known problematic patterns in bot-adjacent systems
(groups, arena, guild, auction house, mail).

## Triggers

- Any change in `modules/playerbots/`
- Changes to group/raid/arena/guild code that bots interact with
- Bot AI strategy or action modifications
- Bot factory or lifecycle changes

## Known risk areas

### Critical
1. **Null player pointers** — `GetPlayer()`, `GetMaster()`, `GetGroup()` can all
   return null. Always null-check before dereferencing.
2. **Group operations** — Bot group joins/leaves/role changes; ensure group state
   is consistent after each operation.
3. **Arena team handling** — Bots joining/leaving arena teams; watch for team
   size limits and rating calculations.
4. **Guild operations** — Bot guild joins, rank changes, bank access; verify
   permission checks.
5. **Auction House** — Bot AH posting/bidding; check for money exploits and
   item duplication.
6. **Mail system** — Bot sending/receiving mail; avoid item loss or duplication.

### Moderate
7. **Movement/pathing** — Bot following, formation, and navigation; watch for
   stuck detection and path recalculation timeouts.
8. **Spell casting** — Bot spell selection and cooldown management; verify spell
   queue doesn't overflow.
9. **Inventory management** — Bot item equip/unequip/bag operations; avoid slot
   conflicts and ghost items.
10. **Chat/emotes** — Bot responses to player chat; rate limiting and spam prevention.

## Review checklist

For each change touching playerbots:

- [ ] **Null checks** — Every pointer dereference on a game object (Player, Unit,
  Creature, Item, Spell, Group, Guild) is preceded by a null check.
- [ ] **Thread safety** — Bot operations happen on the map update thread, not
  from network callbacks or timer callbacks directly (use `Player::Schedule`).
- [ ] **Database access** — Bot DB writes are asynchronous or batched; no
  blocking queries in the update loop.
- [ ] **Memory management** — No raw `new`/`delete` on bot objects; bots are
  owned by the world/map.
- [ ] **Group/raid limits** — Group size caps (5 for party, 40 for raid) are
  enforced before adding bots.
- [ ] **Arena constraints** — Bracket requirements, team size, and rating
  calculations are correct.
- [ ] **Economy safety** — No infinite gold/items; AH and mail operations have
  proper cost validation.
- [ ] **Config flags** — New bot features are gated behind `Playerbots.*.conf`
  options for easy disable.

## When to hard-stop

- Any change that introduces a potential null dereference without a null check → **CRITICAL STOP**
- Changes that allow bots to bypass economy checks (gold, items) → **CRITICAL STOP**
- Changes that modify group/arena/guild membership without proper leave-cleanup → **CRITICAL STOP**
- Unbounded loops or recursion in bot AI strategies → **CRITICAL STOP**

## Output

```
--- playerbots safety review ---
Files reviewed: [list]
Critical issues: [count] ([list or "none"])
Warnings: [count] ([list or "none"])
Verdict: [SAFE TO MERGE / NEEDS FIXES / BLOCKED]