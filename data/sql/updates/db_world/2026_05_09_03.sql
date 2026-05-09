-- DB update 2026_05_09_02 -> 2026_05_09_03
--
UPDATE `creature_template` SET `flags_extra` = `flags_extra` & ~0x1
    WHERE `entry` IN (30449, 30451, 30452, 31520, 31534, 31535);