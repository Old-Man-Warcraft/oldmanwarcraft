-- DB update 2026_04_26_03 -> 2026_05_06_00
-- Reassert quest turn-in data and restore missing request text for quest 7424 "What the Hoof?"

DELETE FROM `creature_questender` WHERE `id` = 14188 AND `quest` = 7424;
INSERT INTO `creature_questender` (`id`, `quest`) VALUES
(14188, 7424);

DELETE FROM `quest_request_items` WHERE `ID` = 7424;
INSERT INTO `quest_request_items` (`ID`, `EmoteOnComplete`, `EmoteOnIncomplete`, `CompletionText`, `VerifiedBuild`) VALUES
(7424, 1, 0, 'Make them all limp, $N. Show them that goblins are not so easy to push around!', 12340);
