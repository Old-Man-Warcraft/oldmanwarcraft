-- DB update 2026_04_10_00 -> 2026_04_10_01 (upstream Infernal Spear aura)
-- plus OMW: Majordomo Executus gossip_menu_id (AC PR #25309)

UPDATE `creature_template_addon` SET `auras` = '70203' WHERE `entry` IN (37126, 38258);

UPDATE `creature_template`
SET `gossip_menu_id` = 4093
WHERE `entry` = 12018;
