---
description: Configure and debug spell proc systems
---

# Spell Proc Configuration Workflow

## Overview
Spell procs define when auras trigger based on combat events. This workflow helps configure and test proc systems.

## Prerequisites
- Understanding of spell families and proc flags
- Access to development realm (port 8086)
- MySQL client for database queries
- Combat log enabled for testing

## Configuration Steps

### 1. Verify Spell Exists
```sql
SELECT id, name, spellLevel, maxLevel, spellIconID, castingTimeIndex, recoveryTime
FROM spell_dbc 
WHERE id = <spell_id>;
```

**What to check**:
- Spell exists in spell_dbc
- Spell level and max level are correct
- Spell icon is valid

### 2. Check Spell Proc Entry
```sql
SELECT spellId, procFlags, procEx, ppmRate, cooldown, charges, procChance
FROM spell_proc 
WHERE spellId = <spell_id>;
```

**Key fields**:
- `procFlags`: When spell triggers (bitmask of PROC_FLAG_*)
- `procEx`: Spell type/phase mask (PROC_SPELL_TYPE_*, PROC_SPELL_PHASE_*)
- `ppmRate`: Procs per minute (0 = use procChance)
- `procChance`: Proc chance 0-100 (if ppmRate = 0)
- `cooldown`: Cooldown between procs in seconds
- `charges`: Number of charges (0 = unlimited)

### 3. Decode Proc Flags
```
Common proc flags:
0x1   = PROC_FLAG_KILLED (killed by aggressor)
0x2   = PROC_FLAG_KILL (kill target)
0x4   = PROC_FLAG_DONE_MELEE_AUTO_ATTACK
0x8   = PROC_FLAG_TAKEN_MELEE_AUTO_ATTACK
0x10  = PROC_FLAG_DONE_SPELL_MELEE_DMG_CLASS
0x20  = PROC_FLAG_TAKEN_SPELL_MELEE_DMG_CLASS
0x40  = PROC_FLAG_DONE_RANGED_AUTO_ATTACK
0x80  = PROC_FLAG_TAKEN_RANGED_AUTO_ATTACK
0x100 = PROC_FLAG_DONE_SPELL_RANGED_DMG_CLASS
0x200 = PROC_FLAG_TAKEN_SPELL_RANGED_DMG_CLASS
0x400 = PROC_FLAG_DONE_SPELL_NONE_DMG_CLASS_POS (healing)
0x800 = PROC_FLAG_TAKEN_SPELL_NONE_DMG_CLASS_POS
0x1000 = PROC_FLAG_DONE_SPELL_NONE_DMG_CLASS_NEG (debuff)
0x2000 = PROC_FLAG_TAKEN_SPELL_NONE_DMG_CLASS_NEG
```

**Example**: Proc on melee auto attacks (both done and taken):
- `procFlags = 0xC (0x4 | 0x8)`

### 4. Decode Spell Type/Phase Mask
```
Spell Type Mask:
0x0 = PROC_SPELL_TYPE_NONE (any spell)
0x1 = PROC_SPELL_TYPE_DAMAGE
0x2 = PROC_SPELL_TYPE_HEAL
0x4 = PROC_SPELL_TYPE_NO_DMG_HEAL
0x7 = PROC_SPELL_TYPE_MASK_ALL

Spell Phase Mask:
0x0 = PROC_SPELL_PHASE_NONE (any phase)
0x1 = PROC_SPELL_PHASE_CAST (on spell cast start)
0x2 = PROC_SPELL_PHASE_HIT (on spell hit)
0x4 = PROC_SPELL_PHASE_FINISH (on spell finish)
0x7 = PROC_SPELL_PHASE_MASK_ALL
```

**Example**: Proc on damage spells when they hit:
- `procEx = 0x3 (0x1 | 0x2)` = DAMAGE | HIT

### 5. Check Proc Conditions
```sql
SELECT * FROM conditions 
WHERE sourceTypeOrReferenceId = 24 
AND sourceEntry = <spell_id>;
```

**What to check**:
- Conditions filter procs correctly
- Condition logic matches intent
- ConditionValue fields are valid

### 6. Test Proc Triggering

**Enable combat logging**:
```
.debug on
```

**Create test scenario**:
1. Spawn test creature: `.npc add <entry>`
2. Equip test gear with proc spell
3. Attack creature
4. Check combat log for proc triggers

**View combat log**:
```bash
tail -f env/dist/logs-dev/Server.log | grep -i "proc\|aura"
```

### 7. Common Proc Issues

**Proc not triggering**:
- Verify spell_proc entry exists
- Check procFlags match trigger type
- Verify procChance > 0 or ppmRate > 0
- Ensure conditions are satisfied
- Check cooldown hasn't prevented proc

**Proc triggering too often**:
- Reduce procChance (0-100)
- Reduce ppmRate (procs per minute)
- Increase cooldown
- Add conditions to filter triggers

**Proc triggering wrong spell**:
- Verify spellId in spell_proc is correct
- Check spell family is correct
- Verify procEx matches spell type

**Proc not respecting cooldown**:
- Verify cooldown field is set
- Check cooldown value (in seconds)
- Test with multiple procs in sequence

### 8. Spell Family Configuration

**Find spell family**:
```sql
SELECT id, name, spellFamilyName, spellFamilyFlags
FROM spell_dbc 
WHERE id = <spell_id>;
```

**Spell families** (for spellmod interactions):
- 0 = SPELLFAMILY_GENERIC
- 3 = SPELLFAMILY_MAGE
- 4 = SPELLFAMILY_WARRIOR
- 5 = SPELLFAMILY_WARLOCK
- 6 = SPELLFAMILY_PRIEST
- 7 = SPELLFAMILY_DRUID
- 8 = SPELLFAMILY_ROGUE
- 9 = SPELLFAMILY_HUNTER
- 10 = SPELLFAMILY_PALADIN
- 11 = SPELLFAMILY_SHAMAN
- 15 = SPELLFAMILY_DEATHKNIGHT

### 9. Proc Attributes

**Check proc attributes**:
```sql
SELECT spellId, procFlags, procEx, attributes
FROM spell_proc 
WHERE spellId = <spell_id>;
```

**Attributes**:
- 0x1 = PROC_ATTR_REQ_EXP_OR_HONOR (target must give XP/honor)
- 0x2 = PROC_ATTR_TRIGGERED_CAN_PROC (can proc from triggered spells)
- 0x4 = PROC_ATTR_REQ_MANA_COST (triggering spell needs mana cost)
- 0x8 = PROC_ATTR_REQ_SPELLMOD (triggering spell affected by spellmod)
- 0x10 = PROC_ATTR_USE_STACKS_FOR_CHARGES (consume stack instead of charge)
- 0x80 = PROC_ATTR_REDUCE_PROC_60 (reduced chance if actor level > 60)
- 0x100 = PROC_ATTR_CANT_PROC_FROM_ITEM_CAST (no item-casted spell procs)

### 10. Performance Optimization

**Identify expensive procs**:
```sql
SELECT spellId, procFlags, procChance, cooldown
FROM spell_proc 
WHERE procChance > 50 AND cooldown < 5
ORDER BY procChance DESC;
```

**Optimize**:
- Increase cooldown for high-chance procs
- Add conditions to filter unnecessary procs
- Use ppmRate instead of procChance for better control
- Monitor proc frequency in combat logs

## Testing Checklist

- [ ] Spell exists in spell_dbc
- [ ] spell_proc entry exists
- [ ] procFlags match intended trigger type
- [ ] procEx (spell type/phase) correct
- [ ] procChance or ppmRate > 0
- [ ] Cooldown prevents excessive triggering
- [ ] Conditions satisfied (if any)
- [ ] Spell family correct for spellmod interactions
- [ ] Proc attributes set appropriately
- [ ] No unintended side effects
- [ ] Performance acceptable

## Useful Commands

```bash
# Check spell info
.spell <spell_id>

# Enable debug logging
.debug on

# View combat log
tail -f env/dist/logs-dev/Server.log

# Search for proc messages
grep -i "proc" env/dist/logs-dev/Server.log

# Reload spell data
.reload spell_proc
.reload conditions
```

## Related Resources

- Spell Proc Wiki: https://www.azerothcore.org/wiki/spell_proc
- Proc Flags: https://www.azerothcore.org/wiki/spell_proc#procflags
- Spell Effects: https://www.azerothcore.org/wiki/spell-effects-reference
