-- Remove custom item templates above the requested threshold.
-- Keep 2000000 itself; only remove entries strictly greater than 2000000.

DELETE FROM `item_dbc` WHERE `ID` > 2000000;
DELETE FROM `item_template` WHERE `entry` > 2000000;
