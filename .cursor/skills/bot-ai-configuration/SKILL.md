---
name: bot-ai-configuration
description: Covers bot AI configuration, strategies, tactics, and tuning. Use when changing bot behavior, strategies, or playerbots.conf settings.
---

# Bot AI Configuration Guide

## Overview
This guide covers configuring bot AI strategies, tactics, and behavior for different classes and roles.

## MCP (use when connected)

- **azerothcore**: Inspect `ai_playerbot_strategy`, `ai_playerbot_tactics`, `ai_playerbot_config` via `query_database`; `search_azerothcore_source` for behavior code in `mod-playerbots`.
- **oldmanwarcraft-api-remote**: Armory / PvP tools (`omw_search_armory_characters`, `omw_get_pvp_*`) when validating **displayed** character or bracket data against bot activity.
- **sequential-thinking**: Untangle multi-class or raid-wide tactic changes before editing SQL or config.
- Catalog: `.cursor/reference/mcp-tools-inventory.md`.

## Bot Classes & Specializations

### Warrior
**Specializations**: Protection (Tank), Arms (DPS), Fury (DPS)

**Protection Strategy**:
- Priority: Threat generation, damage mitigation, shield management
- Key abilities: Shield Block, Shield Wall, Taunt, Revenge
- Threat rotation: Sunder Armor, Revenge, Shield Slam
- Cooldown management: Shield Wall for heavy damage phases

**Arms/Fury Strategy**:
- Priority: Sustained damage, cooldown usage, threat awareness
- Key abilities: Mortal Strike, Execute, Bloodthirst, Whirlwind
- Resource management: Rage generation and spending
- Threat awareness: Don't pull threat from tank

### Paladin
**Specializations**: Holy (Healer), Protection (Tank), Retribution (DPS)

**Holy Strategy**:
- Priority: Tank healing, party healing, mana management
- Key abilities: Holy Light, Flash of Light, Holy Shock, Divine Favor
- Healing priority: Tank > Damaged party > Self
- Mana management: Judgement for mana return

**Protection Strategy**:
- Priority: Threat generation, damage mitigation, consecration
- Key abilities: Consecration, Holy Shield, Shield of Righteousness
- Threat rotation: Consecration, Shield of Righteousness, Hammer of Justice
- Cooldown management: Divine Shield for emergency situations

**Retribution Strategy**:
- Priority: Sustained damage, seal management, judgment
- Key abilities: Seal of Command, Judgment, Divine Storm, Crusader Strike
- Seal rotation: Maintain appropriate seal for situation
- Threat awareness: Monitor threat level

### Priest
**Specializations**: Discipline (Healer), Holy (Healer), Shadow (DPS)

**Discipline Strategy**:
- Priority: Tank healing, damage prevention, mana management
- Key abilities: Power Word: Shield, Penance, Power Infusion
- Healing priority: Tank > Damaged party > Self
- Shield management: Maintain shields on tank and party

**Holy Strategy**:
- Priority: Party healing, healing over time, mana management
- Key abilities: Heal, Greater Heal, Renew, Prayer of Mending
- Healing priority: Tank > Damaged party > Self
- HoT management: Maintain Renew on party members

**Shadow Strategy**:
- Priority: Sustained damage, DoT management, mana conservation
- Key abilities: Shadow Word: Pain, Vampiric Touch, Mind Blast, Mind Flay
- DoT rotation: Maintain DoTs on target
- Threat awareness: Don't pull threat from tank

### Rogue
**Specializations**: Assassination (DPS), Combat (DPS), Subtlety (DPS)

**Assassination Strategy**:
- Priority: Poison application, sustained damage, energy management
- Key abilities: Mutilate, Envenom, Deadly Poison, Instant Poison
- Poison rotation: Maintain deadly and instant poisons
- Energy management: Spend energy on high-damage abilities

**Combat Strategy**:
- Priority: Sustained damage, cooldown usage, energy management
- Key abilities: Sinister Strike, Eviscerate, Killing Spree
- Cooldown management: Use Killing Spree on cooldown
- Threat awareness: Don't pull threat from tank

**Subtlety Strategy**:
- Priority: Burst damage, stealth mechanics, energy management
- Key abilities: Backstab, Shadowstrike, Hemorrhage, Evasion
- Stealth usage: Use for positioning and burst damage
- Threat awareness: Manage threat carefully

### Druid
**Specializations**: Balance (DPS), Feral (Tank/DPS), Restoration (Healer)

**Balance Strategy**:
- Priority: DoT management, spell rotation, mana management
- Key abilities: Moonfire, Sunfire, Starfire, Wrath
- DoT rotation: Maintain Moonfire and Sunfire
- Threat awareness: Don't pull threat from tank

**Feral (Tank) Strategy**:
- Priority: Threat generation, damage mitigation, rage management
- Key abilities: Mangle, Lacerate, Swipe, Frenzied Regeneration
- Threat rotation: Mangle, Lacerate, Swipe
- Cooldown management: Frenzied Regeneration for healing

**Feral (DPS) Strategy**:
- Priority: Sustained damage, cooldown usage, energy management
- Key abilities: Mangle, Rake, Rip, Ferocious Bite
- Combo point management: Build and spend combo points
- Threat awareness: Don't pull threat from tank

**Restoration Strategy**:
- Priority: Party healing, HoT management, mana management
- Key abilities: Rejuvenation, Regrowth, Lifebloom, Nourish
- HoT rotation: Maintain Rejuvenation and Lifebloom on party
- Healing priority: Tank > Damaged party > Self

### Shaman
**Specializations**: Elemental (DPS), Enhancement (DPS), Restoration (Healer)

**Elemental Strategy**:
- Priority: Spell rotation, cooldown usage, mana management
- Key abilities: Lightning Bolt, Chain Lightning, Lava Burst, Flame Shock
- DoT rotation: Maintain Flame Shock on target
- Threat awareness: Don't pull threat from tank

**Enhancement Strategy**:
- Priority: Melee damage, totem management, cooldown usage
- Key abilities: Stormstrike, Lava Lash, Earth Shock, Flame Shock
- Totem rotation: Maintain appropriate totems
- Threat awareness: Don't pull threat from tank

**Restoration Strategy**:
- Priority: Party healing, HoT management, mana management
- Key abilities: Healing Wave, Lesser Healing Wave, Riptide, Chain Heal
- HoT rotation: Maintain Riptide on party members
- Healing priority: Tank > Damaged party > Self

### Mage
**Specializations**: Arcane (DPS), Fire (DPS), Frost (DPS/CC)

**Arcane Strategy**:
- Priority: Spell rotation, mana management, cooldown usage
- Key abilities: Arcane Missiles, Arcane Blast, Arcane Power
- Mana management: Manage mana pool carefully
- Threat awareness: Don't pull threat from tank

**Fire Strategy**:
- Priority: DoT management, spell rotation, cooldown usage
- Key abilities: Fireball, Fire Blast, Ignite, Pyroblast
- DoT rotation: Maintain Ignite on target
- Threat awareness: Don't pull threat from tank

**Frost Strategy**:
- Priority: Crowd control, spell rotation, mana management
- Key abilities: Frostbolt, Frost Nova, Blizzard, Ice Storm
- CC usage: Use Frost Nova for crowd control
- Threat awareness: Don't pull threat from tank

### Warlock
**Specializations**: Affliction (DPS), Demonology (DPS), Destruction (DPS)

**Affliction Strategy**:
- Priority: DoT management, spell rotation, mana management
- Key abilities: Corruption, Curse of Agony, Unstable Affliction, Drain Soul
- DoT rotation: Maintain DoTs on target
- Threat awareness: Don't pull threat from tank

**Demonology Strategy**:
- Priority: Demon management, spell rotation, mana management
- Key abilities: Summon Demon, Demonic Empowerment, Soul Fire
- Demon rotation: Maintain appropriate demon for situation
- Threat awareness: Don't pull threat from tank

**Destruction Strategy**:
- Priority: Spell rotation, cooldown usage, mana management
- Key abilities: Shadowbolt, Incinerate, Conflagrate, Chaos Bolt
- Cooldown management: Use Chaos Bolt on cooldown
- Threat awareness: Don't pull threat from tank

### Hunter
**Specializations**: Beast Mastery (DPS), Marksmanship (DPS), Survival (DPS)

**Beast Mastery Strategy**:
- Priority: Pet management, sustained damage, cooldown usage
- Key abilities: Steady Shot, Kill Command, Bestial Wrath
- Pet management: Keep pet alive and attacking
- Threat awareness: Don't pull threat from tank

**Marksmanship Strategy**:
- Priority: Sustained damage, cooldown usage, focus management
- Key abilities: Aimed Shot, Steady Shot, Multi-Shot
- Focus management: Spend focus on high-damage abilities
- Threat awareness: Don't pull threat from tank

**Survival Strategy**:
- Priority: Trap usage, sustained damage, cooldown usage
- Key abilities: Explosive Trap, Snake Trap, Kill Shot
- Trap rotation: Use traps for crowd control
- Threat awareness: Don't pull threat from tank

### Death Knight
**Specializations**: Blood (Tank), Frost (DPS), Unholy (DPS)

**Blood Strategy**:
- Priority: Threat generation, damage mitigation, rune management
- Key abilities: Blood Boil, Death and Decay, Rune Strike
- Threat rotation: Blood Boil, Death and Decay, Rune Strike
- Cooldown management: Use cooldowns for heavy damage phases

**Frost Strategy**:
- Priority: Sustained damage, cooldown usage, rune management
- Key abilities: Obliterate, Frost Strike, Howling Blast
- Rune management: Manage rune cooldowns
- Threat awareness: Don't pull threat from tank

**Unholy Strategy**:
- Priority: Pet management, DoT management, rune management
- Key abilities: Plague Strike, Death Coil, Unholy Blight
- Pet management: Keep pet alive and attacking
- Threat awareness: Don't pull threat from tank

## Strategy Configuration

### Creating Custom Strategies

Database configuration:
```sql
INSERT INTO ai_playerbot_strategy (name, description, priority1, action1, priority2, action2)
VALUES ('custom_tank', 'Custom tank strategy', 1, 'taunt', 2, 'shield_block');
```

**Strategy Fields**:
- `name`: Unique strategy identifier
- `description`: Human-readable description
- `priority1-N`: Action priority (higher = more important)
- `action1-N`: Action to perform at this priority

### Tactics Configuration

Database configuration:
```sql
INSERT INTO ai_playerbot_tactics (name, description, movement, combat, healing)
VALUES ('aggressive', 'Aggressive tactics', 'charge', 'melee', 'low_priority');
```

**Tactic Fields**:
- `name`: Unique tactic identifier
- `description`: Human-readable description
- `movement`: Movement behavior (charge, kite, defensive)
- `combat`: Combat behavior (melee, ranged, spell)
- `healing`: Healing priority (high, medium, low)

## Performance Tuning

### Bot Count Recommendations
```
Server CPU: 4 cores
Recommended bot count: 100-200
Per-core budget: 25-50 bots

Monitor:
- CPU usage (should be < 80%)
- Memory usage (should be stable)
- Update latency (should be < 100ms)
- Player latency (should be < 200ms)
```

### Update Frequency Tuning
```
Default: 100ms per bot
Reduce for responsiveness: 50ms (higher CPU usage)
Increase for performance: 200ms (lower responsiveness)

Trade-off: Responsiveness vs CPU usage
```

### Pathfinding Optimization
```
- Cache frequently used paths
- Use simplified pathfinding for distant targets
- Limit pathfinding distance (e.g., 100 yards)
- Batch pathfinding updates
- Monitor cache hit rate
```

## Testing & Debugging

### Enable Debug Logging
```
.debug on
```

### Check Bot Status
```
.bot info <name>
.bot stats
.bot count
```

### Monitor Performance
```bash
top -p $(pgrep worldserver)
free -h
```

### View Logs
```bash
tail -f env/dist/logs/Server.log | grep -i "bot\|playerbot"
```

## Best Practices

1. **Start Simple**: Begin with basic strategies and add complexity gradually
2. **Test Thoroughly**: Test bot behavior in different scenarios
3. **Monitor Performance**: Watch CPU/memory usage continuously
4. **Document Changes**: Keep configuration changes documented
5. **Backup Database**: Backup playerbots database before major changes
6. **Production safety**: Test bot changes during controlled windows with backups; use off-host staging if you maintain it
7. **Optimize Gradually**: Make small changes and measure impact
8. **Balance Difficulty**: Ensure bots are challenging but fair
9. **Update Regularly**: Keep bot AI updated with new patches
10. **Gather Feedback**: Listen to player feedback on bot behavior

## Related Resources

- Playerbots Wiki: https://github.com/mod-playerbots/mod-playerbots/wiki
- Class Guides: https://www.azerothcore.org/wiki/class_guides
- Spell System: https://www.azerothcore.org/wiki/spell_system
- AI System: https://github.com/mod-playerbots/mod-playerbots/wiki/AI-System
