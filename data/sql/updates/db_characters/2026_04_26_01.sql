-- DB update 2026_04_26_00 -> 2026_04_26_01
CREATE TABLE IF NOT EXISTS `prestige_stats` (
    `player_id` int unsigned NOT NULL,
    `prestige_level` int unsigned NOT NULL DEFAULT 0,
    `draft_state` tinyint unsigned NOT NULL DEFAULT 0,
    `stored_class` tinyint unsigned NOT NULL DEFAULT 0,
    `successful_drafts` int unsigned NOT NULL DEFAULT 0,
    `total_expected_drafts` int unsigned NOT NULL DEFAULT 0,
    `rerolls` int unsigned NOT NULL DEFAULT 0,
    `bans` int unsigned NOT NULL DEFAULT 0,
    `offered_spell_1` int unsigned NOT NULL DEFAULT 0,
    `offered_spell_2` int unsigned NOT NULL DEFAULT 0,
    `offered_spell_3` int unsigned NOT NULL DEFAULT 0,
    `taskmaster_state` tinyint unsigned NOT NULL DEFAULT 0,
    PRIMARY KEY (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `draft_bans` (
    `player_id` int unsigned NOT NULL,
    `spell_id` int unsigned NOT NULL,
    PRIMARY KEY (`player_id`, `spell_id`),
    KEY `idx_draft_bans_spell_id` (`spell_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `drafted_spells` (
    `player_guid` int unsigned NOT NULL,
    `spell_id` int unsigned NOT NULL,
    PRIMARY KEY (`player_guid`, `spell_id`),
    KEY `idx_drafted_spells_spell_id` (`spell_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;