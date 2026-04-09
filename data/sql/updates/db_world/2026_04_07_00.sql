-- DB update 2026_03_28_00 -> 2026_04_07_00
-- Address startup Errors.log: invalid spell_ranks chains, creature data, loot validation,
-- spell_target_position mismatch, orphaned spell_script_names, SmartAI without scripts.

-- 1. spell_ranks: chains 150000-150010 reference missing first_spell_id in spell_dbc
DELETE FROM `spell_ranks` WHERE `first_spell_id` BETWEEN 150000 AND 150010;

-- 2. creature 441153 had unit_class 0 (invalid)
UPDATE `creature_template` SET `unit_class` = 1 WHERE `entry` = 441153 AND `unit_class` = 0;

-- 3. spell_target_position: spell 90003 does not use TARGET_DEST_DB (17)
DELETE FROM `spell_target_position` WHERE `ID` = 90003;

-- 4. creature_template references loot templates with no rows (boss placeholders)
UPDATE `creature_template` SET `lootid` = 0 WHERE `entry` IN (987400, 987401, 987408, 987411);

-- 5. fishing_loot_template entry 268 group 1: total chance was 200% (max 100%)
UPDATE `fishing_loot_template` SET `Chance` = `Chance` * 0.5 WHERE `Entry` = 268 AND `GroupId` = 1;

-- 6. item_loot_template: item 910001 not in item_template
DELETE FROM `item_loot_template` WHERE `Entry` = 911100 AND `Item` = 910001;

-- 7. spell_script_names pointing at scripts not built into this binary (custom MP auras)
DELETE FROM `spell_script_names` WHERE `spell_id` IN (
    80000001, 80000002, 80000003, 80000004, 80000005,
    80000006, 80000007, 80000008, 80000009, 80000010
);

-- 8. SmartAI enabled but no smart_scripts rows
UPDATE `creature_template` SET `AIName` = '' WHERE `entry` IN (9500802, 9500804);

-- 9. Remove broken premium vendors with invalid custom item lists (errors.log spam)
DELETE FROM `npc_vendor` WHERE `entry` IN (9500800, 9500801, 9500802, 9500803, 9500804, 9500805);
DELETE FROM `game_event_npc_vendor` WHERE `guid` IN (9500800, 9500801, 9500802, 9500803, 9500804, 9500805);
DELETE FROM `conditions`
WHERE `SourceTypeOrReferenceId` = 23
  AND `SourceGroup` IN (9500800, 9500801, 9500802, 9500803, 9500804, 9500805);

-- Optional hard removal of NPC templates/spawns can be done later if desired; keeping non-vendor data for now.
