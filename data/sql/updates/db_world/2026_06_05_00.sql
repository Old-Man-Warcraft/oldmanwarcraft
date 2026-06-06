-- Fix BWL Suppression Room: assign ScriptName to Blackwing Taskmaster (Goblin Technicians)
-- so killing them disarms the nearest Suppression Device
UPDATE `creature_template` SET `ScriptName` = 'npc_blackwing_taskmaster' WHERE `entry` = 12458;
