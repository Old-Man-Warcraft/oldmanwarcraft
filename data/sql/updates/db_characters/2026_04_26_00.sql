-- DB update 2026_04_12_00 -> 2026_04_26_00
INSERT INTO `character_skills` (`guid`, `skill`, `value`, `max`)
SELECT `c`.`guid`, `lang`.`skill`, 300, 300
FROM `characters` AS `c`
INNER JOIN (
    SELECT 1 AS `race`, 98 AS `skill`
    UNION ALL
    SELECT 2, 109
    UNION ALL
    SELECT 3, 98
    UNION ALL
    SELECT 3, 111
    UNION ALL
    SELECT 4, 98
    UNION ALL
    SELECT 4, 113
    UNION ALL
    SELECT 5, 109
    UNION ALL
    SELECT 5, 673
    UNION ALL
    SELECT 6, 109
    UNION ALL
    SELECT 6, 115
    UNION ALL
    SELECT 7, 98
    UNION ALL
    SELECT 7, 313
    UNION ALL
    SELECT 8, 109
    UNION ALL
    SELECT 8, 315
    UNION ALL
    SELECT 10, 109
    UNION ALL
    SELECT 10, 137
    UNION ALL
    SELECT 11, 98
    UNION ALL
    SELECT 11, 759
) AS `lang`
    ON `lang`.`race` = `c`.`race`
LEFT JOIN `character_skills` AS `cs`
    ON `cs`.`guid` = `c`.`guid`
    AND `cs`.`skill` = `lang`.`skill`
WHERE `cs`.`guid` IS NULL;
