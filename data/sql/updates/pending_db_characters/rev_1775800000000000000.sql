-- Restore individual progression quests for characters Shade (guid 2372) and Nekro (guid 2428)
-- Both are level 80 in Northrend; setting to PROGRESSION_WOTLK_TIER_5 (state 18 = max).
-- All intermediate progression quests (66001-66018) are inserted so there are no gaps in the chain.

DELETE FROM `character_queststatus_rewarded` WHERE `guid` IN (2372, 2428) AND `quest` BETWEEN 66001 AND 66018;
INSERT INTO `character_queststatus_rewarded` (`guid`, `quest`) VALUES
(2372, 66001), (2372, 66002), (2372, 66003), (2372, 66004), (2372, 66005),
(2372, 66006), (2372, 66007), (2372, 66008), (2372, 66009), (2372, 66010),
(2372, 66011), (2372, 66012), (2372, 66013), (2372, 66014), (2372, 66015),
(2372, 66016), (2372, 66017), (2372, 66018),
(2428, 66001), (2428, 66002), (2428, 66003), (2428, 66004), (2428, 66005),
(2428, 66006), (2428, 66007), (2428, 66008), (2428, 66009), (2428, 66010),
(2428, 66011), (2428, 66012), (2428, 66013), (2428, 66014), (2428, 66015),
(2428, 66016), (2428, 66017), (2428, 66018);
