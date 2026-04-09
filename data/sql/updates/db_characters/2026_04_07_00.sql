-- DB update 2026_02_24_00 -> 2026_04_07_00
-- custom_unlocked_appearances.item_template_id: MEDIUMINT max 16777215 is too small for
-- custom item entries (e.g. > 22M). Fixes MySQL 1264 "Out of range value for column item_template_id".

ALTER TABLE `custom_unlocked_appearances`
    MODIFY COLUMN `item_template_id` INT UNSIGNED NOT NULL DEFAULT 0;

-- Keep high custom item IDs exact in item-upgrade requirements (float loses precision > 16,777,216).
ALTER TABLE `mod_item_upgrade_stats_req`
    MODIFY COLUMN `req_val1` DOUBLE NOT NULL,
    MODIFY COLUMN `req_val2` DOUBLE NULL;

ALTER TABLE `mod_item_upgrade_stats_req_override`
    MODIFY COLUMN `req_val1` DOUBLE NULL,
    MODIFY COLUMN `req_val2` DOUBLE NULL;

-- Remove malformed item-upgrade requirement rows that can produce invalid item lookups at runtime.
-- NOTE: existence against item_template is validated in C++ loader; this SQL only removes structurally invalid rows.
DELETE FROM `mod_item_upgrade_stats_req`
WHERE `req_type` = 4
  AND (`req_val1` < 1 OR `req_val2` < 1 OR `req_val1` <> FLOOR(`req_val1`));

DELETE FROM `mod_item_upgrade_stats_req_override`
WHERE (`item_entry` < 1)
   OR (`req_type` = 4 AND (`req_val1` < 1 OR `req_val2` < 1 OR `req_val1` <> FLOOR(`req_val1`)));
