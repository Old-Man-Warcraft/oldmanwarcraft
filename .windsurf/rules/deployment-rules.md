---
trigger: model_decision
description: Apply when deploying changes, testing on realms, starting/stopping servers, applying database updates, or performing rollbacks
---
# Deployment & Testing Rules

## Pre-Deployment Checklist

<pre_deployment>
- Code compiles without errors and warnings
- Changes tested on development realm (8086)
- Database changes backed up and verified
- SmartAI scripts tested with multiple NPCs
- Spell/proc interactions verified with combat logs
- Loot conditions tested with multiple characters
- Quest chains tested from start to finish
- No unintended side effects on other systems
- Performance impact assessed
- Documentation updated
</pre_deployment>

## Backup Procedures

<backup_rules>
- Backup world database: `mysqldump -uacore -pacore acore_world > backup_world_$(date +%Y%m%d_%H%M%S).sql`
- Backup characters database: `mysqldump -uacore -pacore acore_characters > backup_characters_$(date +%Y%m%d_%H%M%S).sql`
- Backup playerbots database: `mysqldump -uacore -pacore acore_playerbots > backup_playerbots_$(date +%Y%m%d_%H%M%S).sql`
- Compress backups: `gzip backup_*.sql`
- Verify backups: `ls -lh backup_*.sql`
- Store backups in safe location
- Test restore procedure before production deployment
</backup_rules>

## Database Updates

<database_update>
- Stop production server: `service ac-worldserver stop`
- Verify stopped: `systemctl status ac-worldserver`
- Apply updates: `mysql -uacore -pacore acore_world < update.sql`
- Verify changes: `mysql -uacore -pacore acore_world -e "SELECT COUNT(*) FROM <table>"`
- Check for errors in output
- Reload affected tables if server running
</database_update>

## Code Deployment

<code_deployment>
- Rebuild if C++ changes: `cd build && cmake .. && make -j$(nproc)`
- Verify compilation: `echo "Build status: $?"`
- Check for warnings and errors
- All source files must compile successfully
- Test on development realm first
</code_deployment>

## Configuration Updates

<config_update>
- Copy new configuration: `cp conf/dist/modules/<module>.conf.dist env/dist/etc/modules/<module>.conf`
- Edit configuration: `nano env/dist/etc/modules/<module>.conf`
- Verify syntax: `grep -v "^#" env/dist/etc/modules/<module>.conf | grep -v "^$"`
- All settings must have values
- Test configuration loading on startup
</config_update>

## Server Startup

<startup_rules>
- Start production server: `service ac-worldserver start`
- Monitor startup: `sleep 5 && systemctl status ac-worldserver`
- Check logs: `tail -f env/dist/logs/Server.log`
- Look for errors or critical warnings
- Verify module loaded successfully
- Test functionality in-game
</startup_rules>

## Verification

<verification_rules>
- Check for errors: `grep -i "error\|critical" env/dist/logs/Server.log`
- Verify module loaded: `grep -i "loaded\|initialized" env/dist/logs/Server.log`
- Test functionality with in-game commands
- Monitor performance metrics
- Check player reports for issues
- Verify no unintended side effects
</verification_rules>

## Rollback Procedure

<rollback_rules>
- Stop server: `service ac-worldserver stop`
- Restore database: `mysql -uacore -pacore acore_world < backup_world_YYYYMMDD_HHMMSS.sql`
- Verify restoration: `mysql -uacore -pacore acore_world -e "SELECT COUNT(*) FROM <table>"`
- Revert code changes: `git revert <commit_hash>`
- Rebuild: `cd build && make -j$(nproc)`
- Restart server: `service ac-worldserver start`
- Monitor logs for errors
- Document what went wrong
</rollback_rules>

## Development Realm Testing

<dev_testing>
- Stop dev server: `service ac-worldserver-dev stop`
- Apply changes: `mysql -uacore -pacore acore_world < update.sql`
- Rebuild if needed: `cd build && make -j$(nproc)`
- Start dev server: `service ac-worldserver-dev start`
- Test all affected features
- Check logs: `tail -f env/dist/logs-dev/Server.log`
- Monitor performance
- Verify no side effects
</dev_testing>

## Post-Deployment Monitoring

<monitoring_rules>
- Daily: Check server status, review error logs
- Weekly: Full error log review, database integrity check, backup verification
- Monthly: Performance analysis, security audit, module compatibility check
- Monitor player reports for issues
- Track performance metrics
- Check for memory leaks
- Verify backups completed successfully
</monitoring_rules>

## Useful Commands

<useful_commands>
- Server status: `systemctl status ac-worldserver`
- Start/stop: `service ac-worldserver start/stop`
- View logs: `tail -f env/dist/logs/Server.log`
- Search logs: `grep -i "error" env/dist/logs/Server.log`
- Database backup: `mysqldump -uacore -pacore acore_world > backup.sql`
- Database restore: `mysql -uacore -pacore acore_world < backup.sql`
- Reload tables: `.reload smart_scripts` (in-game command)
</useful_commands>
