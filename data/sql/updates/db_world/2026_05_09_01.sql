-- DB update 2026_05_09_00 -> 2026_05_09_01
-- OMW: heirloom-style caster wands with +10% XP (spell 57353, same as stock heirlooms)
DELETE FROM `item_template` WHERE `entry` IN (2041203, 2041204, 2041205);
INSERT INTO `item_template` (
	`entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`, `Quality`, `Flags`, `FlagsExtra`,
	`BuyCount`, `BuyPrice`, `SellPrice`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`,
	`RequiredLevel`, `maxcount`, `stackable`, `ScalingStatDistribution`, `ScalingStatValue`, `dmg_min1`,
	`dmg_max1`, `dmg_type1`, `delay`, `ammo_type`, `RangedModRange`, `spellid_1`, `spelltrigger_1`,
	`spellcharges_1`, `spellppmRate_1`, `spellcooldown_1`, `spellcategory_1`, `spellcategorycooldown_1`,
	`bonding`, `description`, `Material`, `sheath`, `RequiredDisenchantSkill`, `VerifiedBuild`
) VALUES
(2041203, 2, 19, -1, 'OMW Heirloom Arcanist Wand', 21020, 7, 134221824, 0, 1, 0, 0, 26, 128, -1, 1, 0, 0, 1, 2, 516, 1, 0, 6, 1700, 0, 100, 57353, 1, 0, 0, -1, 0, -1, 1, 'Experience gained from killing monsters and completing quests increased by 10%.', 2, 0, -1, 12340),
(2041204, 2, 19, -1, 'OMW Heirloom Chaplain Wand', 20829, 7, 134221824, 0, 1, 0, 0, 26, 16, -1, 1, 0, 0, 1, 2, 516, 1, 0, 1, 1700, 0, 100, 57353, 1, 0, 0, -1, 0, -1, 1, 'Experience gained from killing monsters and completing quests increased by 10%.', 2, 0, -1, 12340),
(2041205, 2, 19, -1, 'OMW Heirloom Netherwand', 18356, 7, 134221824, 0, 1, 0, 0, 26, 256, -1, 1, 0, 0, 1, 2, 516, 1, 0, 5, 1700, 0, 100, 57353, 1, 0, 0, -1, 0, -1, 1, 'Experience gained from killing monsters and completing quests increased by 10%.', 2, 0, -1, 12340);
