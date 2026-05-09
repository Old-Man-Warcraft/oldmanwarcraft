-- DB update 2026_05_09_01 -> 2026_05_09_02
-- Valithria Dreamwalker
UPDATE `creature_template` SET `flags_extra` = `flags_extra` & ~128 WHERE `entry` = 37950;
