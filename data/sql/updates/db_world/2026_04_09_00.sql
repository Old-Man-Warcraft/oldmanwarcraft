-- Fix Majordomo Executus gossip duplication blocking Ragnaros intro
-- NPC 12018 uses scripted gossip in boss_majordomo_executus.cpp.
-- Keeping a DB gossip_menu_id active adds duplicate options and allows a non-scripted path.
UPDATE `creature_template`
SET `gossip_menu_id` = 0
WHERE `entry` = 12018;
