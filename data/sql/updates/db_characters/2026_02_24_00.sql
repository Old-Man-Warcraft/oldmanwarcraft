-- DB update 2025_09_03_00 -> 2026_02_24_00
--
SET @index_exists := (
  SELECT COUNT(1)
  FROM INFORMATION_SCHEMA.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'quest_tracker'
    AND INDEX_NAME = 'idx_latest_quest_for_character'
);

SET @drop_idx_sql := IF(@index_exists > 0,
  'ALTER TABLE `quest_tracker` DROP INDEX `idx_latest_quest_for_character`;',
  'SELECT "Index idx_latest_quest_for_character does not exist.";'
);

PREPARE stmt_drop_idx FROM @drop_idx_sql;
EXECUTE stmt_drop_idx;
DEALLOCATE PREPARE stmt_drop_idx;

ALTER TABLE `quest_tracker`
  MODIFY COLUMN `id` int UNSIGNED NOT NULL DEFAULT 0 FIRST,
  ADD UNIQUE INDEX `idx_latest_quest_for_character`(`id`, `character_guid`, `quest_accept_time` DESC);
