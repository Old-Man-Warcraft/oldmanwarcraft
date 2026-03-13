---
trigger: model_decision
description: Apply when working with AzerothCore conditions system, condition_source_type, condition types, or filtering SmartAI/spell/loot/quest triggers
---
# Conditions System Rules

## Condition Source Types

<source_types>
- **22**: CONDITION_SOURCE_TYPE_SMART_EVENT - SmartAI script execution
- **24**: CONDITION_SOURCE_TYPE_SPELL_PROC - Spell proc triggering
- **14**: CONDITION_SOURCE_TYPE_GOSSIP_MENU - Showing gossip menu text
- **15**: CONDITION_SOURCE_TYPE_GOSSIP_MENU_OPTION - Showing gossip menu options
- **19**: CONDITION_SOURCE_TYPE_QUEST_AVAILABLE - Quest to be available/shown
- **23**: CONDITION_SOURCE_TYPE_NPC_VENDOR - Vendor item availability
- **1-12**: Loot conditions (creature, disenchant, fishing, gameobject, item, mail, milling, pickpocket, prospecting, reference, skinning, spell)
- Verify SourceTypeOrReferenceId matches intended source type
</source_types>

## Common Condition Types

<condition_types>
- **1**: CONDITION_AURA - Target has aura from spell
- **2**: CONDITION_ITEM - Target has item(s) in inventory
- **4**: CONDITION_ZONEID - Target is in zone
- **8**: CONDITION_QUESTREWARDED - Quest completed and rewarded
- **9**: CONDITION_QUESTTAKEN - Quest in log (active)
- **15**: CONDITION_CLASS - Target is class(es)
- **16**: CONDITION_RACE - Target is race(es)
- **27**: CONDITION_LEVEL - Target level comparison
- **36**: CONDITION_ALIVE - Target alive state
- **37**: CONDITION_HP_VAL - Target HP value
- **38**: CONDITION_HP_PCT - Target HP percentage
- Verify ConditionValue fields match condition type requirements
</condition_types>

## Condition Operators

<operators>
- **AND Logic** (default): Multiple conditions with same SourceTypeOrReferenceId are AND'd
- **OR Logic**: Use negative SourceTypeOrReferenceId to create OR groups
- **NOT Logic**: Use negative ConditionTypeOrReference to negate condition
- **ElseGroup**: Use for complex boolean logic (group 0, 1, 2, etc.)
- Test condition logic with multiple character states
- Document complex condition chains in comments
</operators>

## Condition Configuration

<configuration>
- Always verify SourceTypeOrReferenceId matches source type
- Check SourceEntry matches target entry
- Verify ConditionTypeOrReference is valid
- Check ConditionValue fields are correct
- Test conditions with multiple character states
- Use conditions to filter unnecessary triggers
- Document complex conditions in comments
</configuration>

## Testing Conditions

<testing_rules>
- Test on development realm (8086) first
- Verify conditions are satisfied before testing
- Test with multiple character states (level, class, race, quest status)
- Check server logs for condition evaluation
- Reload conditions: `.reload conditions`
- Test with fresh character if needed
- Verify no unintended side effects
</testing_rules>

## Common Condition Patterns

<common_patterns>
- **Quest Requirement**: ConditionType=8, ConditionValue1=<quest_id>
- **Level Requirement**: ConditionType=27, ConditionValue1=<level>, ConditionValue2=2 (greater)
- **Class Requirement**: ConditionType=15, ConditionValue1=<class_mask>
- **Zone Requirement**: ConditionType=4, ConditionValue1=<zone_id>
- **Item Requirement**: ConditionType=2, ConditionValue1=<item_id>, ConditionValue2=<count>
- **Aura Requirement**: ConditionType=1, ConditionValue1=<spell_id>
</common_patterns>

## Troubleshooting

<troubleshooting>
- Condition not working: Verify SourceTypeOrReferenceId and SourceEntry
- Complex conditions failing: Check AND/OR logic with negative values
- Silent failures: Review condition operator precedence
- Test each condition individually first
- Use simple conditions before complex ones
- Document all condition logic clearly
</troubleshooting>
