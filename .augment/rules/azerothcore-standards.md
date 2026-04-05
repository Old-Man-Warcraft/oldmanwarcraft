---
trigger: always_on
---
# AzerothCore Development Standards

## Project Context
- **Framework**: AzerothCore WotLK 3.3.5a
- **Primary Module**: mod-playerbots (AI-driven bots)
- **Language**: C++ (core), SQL (database), Lua (scripting)
- **Databases**: 4 (world shared, characters realm-specific, playerbots realm-specific, auth shared)
- **Realms**: Production (8085), Development (8086)

## C++ Code Standards

<cpp_standards>
- Follow AzerothCore C++ Code Standards
- **Naming**: Classes=PascalCase, Functions=camelCase, Variables=camelCase, Constants=UPPER_SNAKE_CASE
- **Indentation**: 4 spaces (no tabs)
- **Line Length**: Max 120 characters
- **Braces**: Allman style (opening brace on new line)
- **Memory**: Use std::unique_ptr/std::shared_ptr, avoid raw pointers
- **Error Handling**: Use assertions for logic errors, exceptions for recoverable errors
- **Comments**: Doxygen-style for public functions, explain WHY not WHAT
</cpp_standards>

## Database Rules

<database_rules>
- **World Database** (`acore_world`): Shared across all realms - test on dev realm first
- **Character Databases**: Realm-specific - never modify directly, use in-game commands
- **Always Backup**: Before any major changes, run `mysqldump`
- **Use Transactions**: For multi-table updates, wrap in START TRANSACTION/COMMIT
- **Document Changes**: Add comments explaining complex queries
- **Verify Integrity**: Check data consistency after bulk updates
</database_rules>

## SmartAI Scripting

<smartai_rules>
- Use `SMART_EVENT_JUST_CREATED` (63) for initialization, not RESPAWN
- Minimize `SMART_EVENT_UPDATE_IC` (0) and `SMART_EVENT_UPDATE_OOC` (1) - they fire every update
- Always set `event_phase_mask >= 1` (0 means never triggers)
- Always set `event_chance > 0` (0 means never triggers)
- Use conditions to filter unnecessary event triggers
- Document event phases in comments for complex scripts
- Test phase transitions thoroughly - bugs cause infinite loops
- Use `SMART_EVENT_LINK` (61) for sequential actions
</smartai_rules>

## Spell Configuration

<spell_rules>
- Verify proc flags match spell intent - incorrect flags cause unintended triggers
- Use `PROC_SPELL_PHASE_HIT` (0x2) for damage procs, `PROC_SPELL_PHASE_CAST` (0x1) for cast-time effects
- Spell family masks must match class/school for spellmod interactions
- Test proc interactions with triggered spells - some have restrictions
- Document proc conditions in spell_proc comments
- Check for conflicting proc configurations before deployment
</spell_rules>

## Module Development

<module_rules>
- Create proper CMakeLists.txt with all source/header files listed
- All configuration settings must have safe defaults (usually disabled)
- Database schema in `data/sql/base/`, updates in `data/sql/updates/`
- Update script naming: `YYYY_MM_DD_XX_description.sql`
- Module must compile without warnings
- Test on both production and development realms
- Document all features in README.md
</module_rules>

## Testing & Deployment

<testing_rules>
- Always test on development realm (8086) before production (8085)
- Backup databases before applying changes
- Use pre-deployment checklist: compilation, dev testing, backup verification, no side effects
- Monitor logs after deployment for errors
- Have rollback procedure ready: stop server, restore backup, restart
- Never modify production database directly
</testing_rules>

## Safety & Stability

<safety_rules>
- **Never** modify `creature_template` directly - use `UPDATE_TEMPLATE` action
- **Never** delete rows without understanding dependencies
- **Never** change primary keys in existing records
- **Never** modify shared world database during peak hours
- **Never** enable debug logging in production without reason
- Document all dangerous operations
- **CRITICAL**: Apply defensive null checks in all bot group operations (see playerbots-rules.md)
- **CRITICAL**: Avoid arena group formation with bots until race condition is fixed
- **CRITICAL**: Avoid guild operations with bots until null check issues are patched
</safety_rules>
