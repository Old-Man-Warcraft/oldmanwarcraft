---
name: spell-proc-reference
description: Reference for spell and proc scripting. Use when writing spell scripts, debugging proc auras, or implementing spell effects.
---

# Skill: spell-proc-reference

**Owner:** Old Man Warcraft
**Version:** 1.0

## Purpose

Reference for spell, aura, and proc scripting in AzerothCore. Covers the
`SpellScript`/`AuraScript` system, proc flags, and common patterns for custom
spell behavior.

## Spell scripting architecture

### Key classes
| Class | Purpose |
|---|---|
| `SpellScript` | Base class for spell effects, damage, targeting |
| `AuraScript` | Base class for aura (buff/debuff) behavior |
| `SpellInfo` | Static spell data from DBC files |
| `Spell` | Instance of a spell being cast |
| `Aura` | Active aura effect on a unit |
| `UnitAura` | Aura application on a specific unit |

### Registration pattern

```cpp
// 1. Define the script class
class spell_my_custom_spell : public SpellScript
{
    PrepareSpellScript(spell_my_custom_spell);

    void HandleEffect(SpellEffIndex effIndex)
    {
        // Your effect logic here
    }

    void Register() override
    {
        OnEffectHitTarget += SpellEffectFn(spell_my_custom_spell::HandleEffect, EFFECT_0, SPELL_EFFECT_SCHOOL_DAMAGE);
    }
};

// 2. Register in AddSC function
void AddSC_my_custom_scripts()
{
    RegisterSpellScript(spell_my_custom_spell);
}
```

## Spell hooks

| Hook | Purpose |
|---|---|
| `OnEffectHit` | Fires when spell effect hits target |
| `OnEffectHitTarget` | Fires for each individual target hit |
| `OnCast` | Fires when spell cast begins |
| `OnCheckCast` | Validate if spell can be cast |
| `OnObjectAreaTargetSelect` | Customize AoE target selection |
| `OnObjectTargetSelect` | Customize single target selection |
| `OnHit` | Fires when spell hits target |
| `BeforeHit` | Fires before spell hit calculation |
| `AfterHit` | Fires after spell hit calculation |
| `OnSuccessfulFinish` | Fires after successful spell completion |

## Aura hooks

| Hook | Purpose |
|---|---|
| `OnApply` | Fires when aura is applied |
| `OnRemove` | Fires when aura is removed |
| `OnEffectApply` | Fires when specific effect is applied |
| `OnEffectRemove` | Fires when specific effect is removed |
| `OnEffectPeriodic` | Fires on periodic tick |
| `OnEffectUpdatePeriodic` | Customize periodic timer |
| `DoCheckProc` | Validate proc trigger |
| `OnProc` | Handle proc effect |
| `AfterProc` | Fire after proc is processed |
| `OnEffectProc` | Handle specific effect proc |

## Proc system

Procs are triggered effects that fire on specific events (damage, healing, etc.).

### Proc flags (common)

| Flag | Description |
|---|---|
| `PROC_FLAG_NONE` | No proc |
| `PROC_FLAG_DONE_SPELL_MAGIC_DMG_CLASS_POS` | Successful hostile magic spell |
| `PROC_FLAG_DONE_SPELL_MAGIC_DMG_CLASS_NEG` | Successful hostile magic spell (negative) |
| `PROC_FLAG_DONE_SPELL_NONE_DMG_CLASS_POS` | Successful helpful non-damaging spell |
| `PROC_FLAG_DONE_SPELL_NONE_DMG_CLASS_NEG` | Successful harmful non-damaging spell |
| `PROC_FLAG_TAKEN_SPELL_MAGIC_DMG_CLASS_POS` | Taken helpful magic spell |
| `PROC_FLAG_TAKEN_SPELL_MAGIC_DMG_CLASS_NEG` | Taken harmful magic spell |
| `PROC_FLAG_DONE_MELEE_AUTO_ATTACK` | Successful melee auto attack |
| `PROC_FLAG_TAKEN_MELEE_AUTO_ATTACK` | Taken melee auto attack |
| `PROC_FLAG_DONE_RANGED_AUTO_ATTACK` | Successful ranged auto attack |
| `PROC_FLAG_TAKEN_RANGED_AUTO_ATTACK` | Taken ranged auto attack |
| `PROC_FLAG_DONE_PERIODIC` | Done periodic damage |
| `PROC_FLAG_TAKEN_PERIODIC` | Taken periodic damage |
| `PROC_FLAG_HEALTH_BELOW_35` | Health below 35% |
| `PROC_FLAG_ON_DODGE` | On dodge |
| `PROC_FLAG_ON_PARRY` | On parry |
| `PROC_FLAG_ON_BLOCK` | On block |
| `PROC_FLAG_ON_CRIT` | On critical hit |
| `PROC_FLAG_ON_KILL` | On killing blow |

### Proc script example

```cpp
class spell_my_proc : public AuraScript
{
    PrepareAuraScript(spell_my_proc);

    bool CheckProc(ProcEventInfo& eventInfo)
    {
        // Validate proc conditions
        if (eventInfo.GetDamageInfo()->GetDamage() < 100)
            return false;
        return true;
    }

    void HandleProc(ProcEventInfo& eventInfo)
    {
        // Handle the proc effect
        if (Unit* caster = GetCaster())
        {
            caster->CastSpell(caster, 12345, true); // Heal for 10%
        }
    }

    void Register() override
    {
        DoCheckProc += AuraCheckProcFn(spell_my_proc::CheckProc);
        OnProc += AuraProcFn(spell_my_proc::HandleProc);
    }
};
```

## Common patterns

### Damage modification
```cpp
void HandleDamage(SpellEffIndex effIndex)
{
    int32 damage = GetHitDamage();
    // Modify damage based on conditions
    if (Unit* caster = GetCaster())
        damage += caster->GetStat(STAT_INTELLECT) * 0.5f;
    SetHitDamage(damage);
}
```

### Target filtering
```cpp
void FilterTargets(std::list<WorldObject*>& targets)
{
    // Remove targets that don't meet criteria
    targets.remove_if([](WorldObject* target) {
        return target->ToUnit() && target->ToUnit()->HasAura(12345);
    });
}
```

### Spell effect override
```cpp
void HandleDummy(SpellEffIndex effIndex)
{
    // Override dummy effect behavior
    PreventHitDefaultEffect(effIndex);
    // Do custom logic
}
```

## Debugging

```cpp
// Log spell execution
TC_LOG_INFO("spells", "spell_my_spell: effect {} on target {} (GUID: {})",
    effIndex, GetHitUnit()->GetName(), GetHitUnit()->GetGUID().ToString());
```

## File conventions

- Spell scripts: `src/server/scripts/Spells/spell_<class>.cpp`
- Generic spells: `src/server/scripts/Spells/spell_generic.cpp`
- Registration: `AddSC_*()` in `spells_script_loader.cpp`