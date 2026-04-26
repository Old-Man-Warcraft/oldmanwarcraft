-- DB update 2026_04_26_01 -> 2026_04_26_02
-- Valithria Dreamwalker
UPDATE `creature_template` SET `flags_extra` = `flags_extra` & ~128 WHERE `entry` = 37950;
