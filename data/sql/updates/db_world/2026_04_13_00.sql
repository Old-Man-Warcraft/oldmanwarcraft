-- DB update 2026_04_10_01 -> 2026_04_13_00
-- GitLab dev/oldmanwarcraft#21: Draenei paladin could not train Summon Warhorse (and Sense Undead) at Exodar trainers.
-- TrainerId 3 (Alliance paladin class trainer) taught spell 13820; SkillLineAbility for that spell does not match Draenei,
-- so Trainer::SendSpells skipped it in IsSpellFitByClassAndRace. Alliance paladins use Summon Warhorse spell 13819 (see
-- spell_required / player factionchange data and level-20 auto-learn lists). npc_trainer ally reference 200020 matched.
UPDATE `trainer_spell` SET `SpellId` = 13819 WHERE `TrainerId` = 3 AND `SpellId` = 13820;
UPDATE `npc_trainer` SET `SpellID` = 13819 WHERE `ID` = 200020 AND `SpellID` = 13820;
