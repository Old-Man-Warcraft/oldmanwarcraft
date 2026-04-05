# Nemesis System (`mod-nemesis-system`) Design Document

## 1. Overview

**The Fantasy:**
A player is leveling in Stranglethorn Vale and gets careless around a standard Defias Pillager. The player dies. Instead of just walking back to their corpse and finding a standard reset mob, the server announces:
> *"A Defias Pillager has absorbed the soul of [Player] and evolved into a Nemesis!"*

When the player resurrects, that specific Pillager is now 20% larger, has a menacing red aura, hits significantly harder, and has a new random elite affix. The player must now either group up with their playerbots, call out in general chat for help, or use all their cooldowns to get revenge and claim a high-value bounty.

**Problem Solved:** 
Dying in the open world is currently just a minor time-loss annoyance; the world doesn't react to player failures or create organic stories. This module introduces dynamic, emergent gameplay by turning player defeats into personalized world bosses.

**Target Audience:** Leveling players, open-world farmers, and solo adventurers.

---

## 2. Core Mechanics

### 2.1 The Trigger
*   A player is killed by a non-trivial PvE creature in the open world.
*   **Exclusions:** Instanced dungeons, raids, battlegrounds, existing world bosses, critters, and trivial mobs (e.g., grey-con to the player) cannot become Nemeses.

### 2.2 The Transformation
*   Upon killing the player, the creature restores its health to 100%.
*   It gains a "Nemesis Rank" (starting at Rank 1).
*   It gains a visual indicator (e.g., increased size, a persistent fiery aura).
*   It rolls a random "Affix" (a custom passive ability).
*   A server-wide or zone-wide broadcast can optionally announce the birth of the Nemesis.

### 2.3 Ranks and Scaling
If a player (or multiple players) keeps dying to the same Nemesis, it ranks up, becoming progressively more dangerous.

*   **Rank 1:** +50% Maximum Health, +50% Damage, +20% Size. Gains 1 Affix.
*   **Rank 2:** +100% Maximum Health, +100% Damage, +30% Size.
*   **Rank 3:** +200% Maximum Health, +200% Damage, +40% Size. Gains 2nd Affix.
*   **Rank 4+ (Max 5):** Exponential scaling. Requires a group (or playerbots) to defeat.

### 2.4 Affixes (Examples)
*   **Vampiric:** Heals for 50% of melee damage dealt.
*   **Juggernaut:** Immune to all crowd control and interrupts.
*   **Molten Core:** Periodically drops fire patches under the target.
*   **Arcane Enchanted:** Casts rotating arcane beams.
*   **Swift:** +50% movement and attack speed.

---

## 3. Technical Architecture

### 3.1 Required Core Hooks
*   `PlayerScript::OnPlayerKilledByCreature`: The primary trigger. Captures the `Player*` victim and the `Creature*` killer. Evaluates if the creature is eligible.
*   `CreatureScript::OnCreatureDeath`: Handles the defeat of a Nemesis, distributes custom loot, and cleans up the database record.
*   `CreatureScript::OnCreatureAddWorld` (or `OnCreatureUpdate`): Re-applies Nemesis buffs, auras, and scaling if the chunk unloads/reloads or if the server restarts.

### 3.2 Database Schema (`characters` database)
Active Nemeses must be persisted across server restarts and chunk unloads.

```sql
CREATE TABLE `character_nemesis` (
    `guid` BIGINT UNSIGNED NOT NULL COMMENT 'Unique Spawn ID of the Nemesis',
    `creature_entry` INT UNSIGNED NOT NULL COMMENT 'Original creature ID',
    `map_id` INT UNSIGNED NOT NULL,
    `pos_x` FLOAT NOT NULL,
    `pos_y` FLOAT NOT NULL,
    `pos_z` FLOAT NOT NULL,
    `rank` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Current Nemesis Rank',
    `affix_mask` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Bitmask of active affixes',
    `nemesis_target_guid` INT UNSIGNED NOT NULL COMMENT 'Player GUID who fed it the most/first',
    `creation_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`guid`)
);
```

### 3.3 Scaling Logic
*   Can utilize existing core mechanics `creature->SetModifierValue(CREATURE_MOD_HEALTH, ...)` and `creature->SetModifierValue(CREATURE_MOD_DAMAGE, ...)`.
*   Can optionally integrate with `mod-autobalance` API if present, to dynamically adjust the Nemesis based on the number of players engaging it.

---

## 4. Loot & Rewards

To incentivize engaging with Nemeses rather than just avoiding them, the rewards must be compelling.

### 4.1 Revenge Bonus
If the player who originally created the Nemesis (the `nemesis_target_guid`) gets the killing blow or is in the party that kills it, they receive a "Nemesis Cache".
*   Contains level-appropriate rare/epic gear.
*   Contains bonus gold and crafting materials.

### 4.2 Bounty Hunter System
If *another* player kills a Nemesis that belongs to someone else, they receive a "Bounty Hunter Reward".
*   Encourages players to look out for unusually large mobs.
*   Fosters social interaction: "Hey, someone's Rank 3 Nemesis is wandering around Crossroads, who wants to help me kill it?"

---

## 5. Edge Cases & Anti-Exploit

### 5.1 Feeding / Corpse Farming
**Exploit:** Players repeatedly dying naked to a mob to rank it up and farm high-level Nemesis loot.
**Solution:** 
*   A Nemesis only drops loot relative to the *average item level and level of the player it killed*.
*   Players receive a hidden "Soul Weary" debuff upon creating a Nemesis, preventing them from creating another (or ranking up an existing one) for a set cooldown (e.g., 30 minutes).

### 5.2 Griefing / Corpse Camping
**Exploit:** A Nemesis becomes so powerful it camps a low-level quest hub.
**Solution:**
*   Nemeses retain their original leash/tether mechanics. If the player resurrects and runs away, the Nemesis returns to its normal spawn point.
*   Nemeses naturally decay. If a Nemesis is not engaged for 48 hours, it despawns and the database record is cleared.

### 5.3 Safe Zones & Instances
*   Hardcode restrictions against instances, battlegrounds, and sanctuaries (e.g., no Nemesis creation in capital cities if a guard gets kited).

---

## 6. Integration with the Custom Stack

This module shines when paired with the repository's existing modules:

*   **`mod-playerbots`**: A Rank 3+ Nemesis might be impossible to solo. Players can summon their bots to form a strike team to take down their rival.
*   **`mod-globalchat` / `mod-breaking-news-override`**: The server can automatically broadcast high-rank Nemesis spawns to stimulate world activity. Example: `[Bounty Board]: A Rank 4 Nemesis has been spotted in Un'Goro Crater!`
*   **`mod-autobalance`**: Ensures that if a 5-man group tackles a Nemesis, it scales appropriately to provide a challenge.

---

## 7. Implementation Plan

### Phase 1: Minimum Viable Product (MVP)
*   Database schema creation.
*   Hook `OnPlayerKilledByCreature` to flag a creature as a Nemesis in memory.
*   Apply basic size scaling (+20%) and a red visual aura.
*   Hook `OnCreatureDeath` to drop a simple reward token and clear the flag.

### Phase 2: Persistence & Ranks
*   Implement saving to and loading from the `character_nemesis` database table.
*   Implement Rank 1-5 progression, including health and damage modifiers.

### Phase 3: Affixes & Abilities
*   Develop the Affix system using dummy auras or custom spell casts triggered in `OnCreatureUpdate`.
*   Implement 3-5 basic affixes (Vampiric, Juggernaut, Swift).

### Phase 4: Integration & Polish
*   Implement the Anti-Exploit cooldowns.
*   Hook into server announcements.
*   Refine the loot tables for the "Nemesis Cache".
