-- Majordomo Executus (12018): ensure gossip_menu_id matches stock / upstream (AzerothCore PR #25309).
-- Stock value is 4093 (DB-driven Ragnaros summon gossip; see 2026_03_30_00.sql).
-- Idempotent if already 4093; fixes realms where a local override had set this to 0.
UPDATE `creature_template`
SET `gossip_menu_id` = 4093
WHERE `entry` = 12018;
