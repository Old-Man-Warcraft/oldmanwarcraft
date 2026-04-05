---
name: spell-proc-reference
description: Reference for spell proc flags, attributes, families, and spell_proc workflows. Use when configuring or debugging procs.
---

# Spell Proc Reference Guide

## Overview
Spell procs define when auras trigger based on combat events. This guide provides quick reference for proc configuration.

## MCP (when connected)

- **azerothcore**: `diagnose_spell_proc`, `explain_proc_flags`, `get_spell_proc`, `compare_spell_dbc_vs_proc`, `search_spell_procs`, `search_spells_dbc`, `search_spells_by_proc_flags`, `get_spell_dbc_proc_info`, `list_proc_flag_types`.
- **fetch** / **firecrawl_scrape**: Official wiki or patch notes URLs; **exa** / **deepwiki** for broader lookup—always reconcile with DBC + `spell_proc` rows.
- **sequential-thinking**: Multi-proc interaction debugging.
- Full list: `.cursor/reference/mcp-tools-inventory.md`.

## Proc Flags (Combat Triggers)

### Kill/Death Flags
- **0x1**: `PROC_FLAG_KILLED` - Killed by aggressor
- **0x2**: `PROC_FLAG_KILL` - Kill target (requires XP/honor)
- **0x1000000**: `PROC_FLAG_DEATH` - Died in any way

### Melee Auto Attack Flags
- **0x4**: `PROC_FLAG_DONE_MELEE_AUTO_ATTACK` - Done melee auto attack
- **0x8**: `PROC_FLAG_TAKEN_MELEE_AUTO_ATTACK` - Taken melee auto attack
- **0x400000**: `PROC_FLAG_DONE_MAINHAND_ATTACK` - Done main-hand melee attack
- **0x800000**: `PROC_FLAG_DONE_OFFHAND_ATTACK` - Done off-hand melee attack

### Ranged Auto Attack Flags
- **0x40**: `PROC_FLAG_DONE_RANGED_AUTO_ATTACK` - Done ranged auto attack
- **0x80**: `PROC_FLAG_TAKEN_RANGED_AUTO_ATTACK` - Taken ranged auto attack

### Melee Damage Class Spell Flags
- **0x10**: `PROC_FLAG_DONE_SPELL_MELEE_DMG_CLASS` - Done melee damage class spell
- **0x20**: `PROC_FLAG_TAKEN_SPELL_MELEE_DMG_CLASS` - Taken melee damage class spell

### Ranged Damage Class Spell Flags
- **0x100**: `PROC_FLAG_DONE_SPELL_RANGED_DMG_CLASS` - Done ranged damage class spell
- **0x200**: `PROC_FLAG_TAKEN_SPELL_RANGED_DMG_CLASS` - Taken ranged damage class spell

### Positive Spell Flags (Healing/Buffs)
- **0x400**: `PROC_FLAG_DONE_SPELL_NONE_DMG_CLASS_POS` - Done positive spell (healing)
- **0x800**: `PROC_FLAG_TAKEN_SPELL_NONE_DMG_CLASS_POS` - Taken positive spell
- **0x4000**: `PROC_FLAG_DONE_SPELL_MAGIC_DMG_CLASS_POS` - Done positive magic spell
- **0x8000**: `PROC_FLAG_TAKEN_SPELL_MAGIC_DMG_CLASS_POS` - Taken positive magic spell

### Negative Spell Flags (Debuffs)
- **0x1000**: `PROC_FLAG_DONE_SPELL_NONE_DMG_CLASS_NEG` - Done negative spell (debuff)
- **0x2000**: `PROC_FLAG_TAKEN_SPELL_NONE_DMG_CLASS_NEG` - Taken negative spell
- **0x10000**: `PROC_FLAG_DONE_SPELL_MAGIC_DMG_CLASS_NEG` - Done negative magic spell
- **0x20000**: `PROC_FLAG_TAKEN_SPELL_MAGIC_DMG_CLASS_NEG` - Taken negative magic spell

### Periodic Flags
- **0x40000**: `PROC_FLAG_DONE_PERIODIC` - Done periodic damage/healing
- **0x80000**: `PROC_FLAG_TAKEN_PERIODIC` - Taken periodic damage/healing

### Damage Flags
- **0x100000**: `PROC_FLAG_TAKEN_DAMAGE` - Taken any damage

### Trap Flags
- **0x200000**: `PROC_FLAG_DONE_TRAP_ACTIVATION` - On trap activation (gameobject cast)

## Spell Type Mask

Filters which spell types trigger the proc:

- **0x0**: `PROC_SPELL_TYPE_NONE` - Any spell type
- **0x1**: `PROC_SPELL_TYPE_DAMAGE` - Damage spells only
- **0x2**: `PROC_SPELL_TYPE_HEAL` - Healing spells only
- **0x4**: `PROC_SPELL_TYPE_NO_DMG_HEAL` - Other spells (no damage/heal)
- **0x7**: `PROC_SPELL_TYPE_MASK_ALL` - Any spell type

**Example**: Proc only on damage spells = `0x1`

## Spell Phase Mask

Defines when during spell execution the proc triggers:

- **0x0**: `PROC_SPELL_PHASE_NONE` - Any phase
- **0x1**: `PROC_SPELL_PHASE_CAST` - On spell cast start
- **0x2**: `PROC_SPELL_PHASE_HIT` - On spell hit
- **0x4**: `PROC_SPELL_PHASE_FINISH` - On spell finish (after all effects)
- **0x7**: `PROC_SPELL_PHASE_MASK_ALL` - Any phase

**Example**: Proc when spell hits = `0x2`

## Hit Mask

Filters which hit results trigger the proc:

- **0x0**: `PROC_HIT_NONE` - Default (NORMAL|CRITICAL for TAKEN, +ABSORB for DONE)
- **0x1**: `PROC_HIT_NORMAL` - Non-critical hit
- **0x2**: `PROC_HIT_CRITICAL` - Critical hit
- **0x4**: `PROC_HIT_MISS` - Miss
- **0x8**: `PROC_HIT_FULL_RESIST` - Full resist
- **0x10**: `PROC_HIT_DODGE` - Dodge
- **0x20**: `PROC_HIT_PARRY` - Parry
- **0x40**: `PROC_HIT_BLOCK` - Block (partial or full)
- **0x80**: `PROC_HIT_EVADE` - Evade
- **0x100**: `PROC_HIT_IMMUNE` - Immune
- **0x200**: `PROC_HIT_DEFLECT` - Deflect
- **0x400**: `PROC_HIT_ABSORB` - Absorb (partial or full)
- **0x800**: `PROC_HIT_REFLECT` - Reflect
- **0x1000**: `PROC_HIT_INTERRUPT` - Interrupt
- **0x2000**: `PROC_HIT_FULL_BLOCK` - Full block (all damage)
- **0x2fff**: `PROC_HIT_MASK_ALL` - Any hit result

**Example**: Proc on critical hits = `0x2`

## Proc Attributes

Additional flags controlling proc behavior:

- **0x1**: `PROC_ATTR_REQ_EXP_OR_HONOR` - Target must give XP or honor
- **0x2**: `PROC_ATTR_TRIGGERED_CAN_PROC` - Can proc from triggered spells
- **0x4**: `PROC_ATTR_REQ_MANA_COST` - Triggering spell must have mana cost
- **0x8**: `PROC_ATTR_REQ_SPELLMOD` - Triggering spell must be affected by this aura's spellmod
- **0x10**: `PROC_ATTR_USE_STACKS_FOR_CHARGES` - Consume stack instead of charge on proc
- **0x80**: `PROC_ATTR_REDUCE_PROC_60` - Reduced proc chance if actor level > 60
- **0x100**: `PROC_ATTR_CANT_PROC_FROM_ITEM_CAST` - Cannot proc from item-casted spells

## Spell Families

For spellmod interactions and spell family filtering:

- **0**: `SPELLFAMILY_GENERIC` - Generic spells
- **1**: `SPELLFAMILY_UNK1` - Events, holidays
- **3**: `SPELLFAMILY_MAGE` - Mage spells
- **4**: `SPELLFAMILY_WARRIOR` - Warrior spells
- **5**: `SPELLFAMILY_WARLOCK` - Warlock spells
- **6**: `SPELLFAMILY_PRIEST` - Priest spells
- **7**: `SPELLFAMILY_DRUID` - Druid spells
- **8**: `SPELLFAMILY_ROGUE` - Rogue spells
- **9**: `SPELLFAMILY_HUNTER` - Hunter spells
- **10**: `SPELLFAMILY_PALADIN` - Paladin spells
- **11**: `SPELLFAMILY_SHAMAN` - Shaman spells
- **12**: `SPELLFAMILY_UNK2` - Silence resistance spells
- **13**: `SPELLFAMILY_POTION` - Potion spells
- **15**: `SPELLFAMILY_DEATHKNIGHT` - Death Knight spells
- **17**: `SPELLFAMILY_PET` - Pet spells

## Common Proc Configurations

### Melee Auto Attack Proc
```sql
INSERT INTO spell_proc (spellId, procFlags, procEx, ppmRate, cooldown, charges, procChance)
VALUES (12345, 0xC, 0x0, 0, 0, 0, 15);
-- procFlags: 0x4 (done melee auto) | 0x8 (taken melee auto)
-- procChance: 15% chance per attack
```

### Spell Damage Proc
```sql
INSERT INTO spell_proc (spellId, procFlags, procEx, ppmRate, cooldown, charges, procChance)
VALUES (12345, 0x10, 0x3, 0, 0, 0, 10);
-- procFlags: 0x10 (done melee damage class spell)
-- procEx: 0x1 (damage spells) | 0x2 (on hit)
-- procChance: 10% chance per spell hit
```

### Healing Spell Proc
```sql
INSERT INTO spell_proc (spellId, procFlags, procEx, ppmRate, cooldown, charges, procChance)
VALUES (12345, 0x400, 0x2, 0, 0, 0, 20);
-- procFlags: 0x400 (done positive spell)
-- procEx: 0x2 (on hit/finish)
-- procChance: 20% chance per heal
```

### PPM-Based Proc (Procs Per Minute)
```sql
INSERT INTO spell_proc (spellId, procFlags, procEx, ppmRate, cooldown, charges, procChance)
VALUES (12345, 0xC, 0x0, 2.0, 0, 0, 0);
-- ppmRate: 2 procs per minute
-- procChance: 0 (ignored when ppmRate > 0)
```

### Proc with Cooldown
```sql
INSERT INTO spell_proc (spellId, procFlags, procEx, ppmRate, cooldown, charges, procChance)
VALUES (12345, 0xC, 0x0, 0, 5, 0, 15);
-- cooldown: 5 seconds between procs
-- Prevents excessive proc triggering
```

### Proc with Limited Charges
```sql
INSERT INTO spell_proc (spellId, procFlags, procEx, ppmRate, cooldown, charges, procChance)
VALUES (12345, 0xC, 0x0, 0, 0, 3, 15);
-- charges: 3 charges per aura application
-- Aura expires after 3 procs
```

## Proc Configuration Combinations

### Damage Dealer Proc
```
procFlags = 0x10 (done melee damage class spell)
procEx = 0x3 (damage spells | on hit)
procChance = 15
cooldown = 0
```

### Tank Proc
```
procFlags = 0x8 (taken melee auto attack)
procEx = 0x0 (any spell type)
procChance = 20
cooldown = 0
```

### Healer Proc
```
procFlags = 0x400 (done positive spell)
procEx = 0x2 (on hit)
procChance = 25
cooldown = 0
```

### Defensive Proc
```
procFlags = 0x100000 (taken any damage)
procEx = 0x0 (any spell type)
procChance = 10
cooldown = 3
```

## Proc Troubleshooting

### Proc Not Triggering
1. Verify spell_proc entry exists
2. Check procFlags match trigger type
3. Verify procChance > 0 or ppmRate > 0
4. Ensure conditions satisfied (if any)
5. Check cooldown hasn't prevented proc

### Proc Triggering Too Often
1. Reduce procChance (0-100)
2. Reduce ppmRate (procs per minute)
3. Increase cooldown
4. Add conditions to filter triggers

### Proc Triggering Wrong Spell
1. Verify spellId in spell_proc is correct
2. Check spell family is correct
3. Verify procEx matches spell type

### Proc Not Respecting Cooldown
1. Verify cooldown field is set
2. Check cooldown value (in seconds)
3. Test with multiple procs in sequence

## Performance Considerations

### High-Frequency Procs
- Use cooldown to prevent excessive triggering
- Use conditions to filter unnecessary procs
- Monitor CPU impact with frequent proc checks

### PPM vs Chance
- **PPM (ppmRate)**: Better for consistent proc frequency
- **Chance (procChance)**: Better for simple on/off procs

### Proc Stacking
- Use charges to limit proc stacking
- Use cooldown to prevent rapid re-application
- Monitor memory usage with many active procs

## Related Resources

- Spell Proc Wiki: https://www.azerothcore.org/wiki/spell_proc
- Spell Proc Event: https://www.azerothcore.org/wiki/spell_proc_event
- Conditions: https://www.azerothcore.org/wiki/conditions
- Spell Effects: https://www.azerothcore.org/wiki/spell-effects-reference
