---
description: Deploy changes and test on production and development realms
---

# Deployment and Testing Workflow

## Overview
This workflow ensures safe deployment of changes from development to production realm.

## Prerequisites
- Changes tested on development realm (port 8086)
- Database backups created
- All code compiled without warnings
- Documentation updated

## Pre-Deployment Checklist

### 1. Code Review
- [ ] Code follows C++ standards
- [ ] No hardcoded values
- [ ] Comments explain complex logic
- [ ] No debug logging left in
- [ ] Performance impact assessed

### 2. Database Changes
- [ ] SQL syntax verified
- [ ] Changes tested on dev realm
- [ ] Backup created before changes
- [ ] Data integrity verified
- [ ] Update script properly named (YYYY_MM_DD_XX_description.sql)

### 3. Configuration
- [ ] All settings have defaults
- [ ] Defaults are safe (usually disabled)
- [ ] Documentation complete
- [ ] No hardcoded paths or IPs

### 4. Testing
- [ ] Functionality tested on dev realm
- [ ] Edge cases tested
- [ ] No unintended side effects
- [ ] Performance acceptable
- [ ] Logs reviewed for errors

## Deployment Steps

### Step 1: Backup Production Database
```bash
# Backup world database
mysqldump -uacore -pacore acore_world > backup_world_$(date +%Y%m%d_%H%M%S).sql

# Backup character database
mysqldump -uacore -pacore acore_characters > backup_characters_$(date +%Y%m%d_%H%M%S).sql

# Backup playerbots database
mysqldump -uacore -pacore acore_playerbots > backup_playerbots_$(date +%Y%m%d_%H%M%S).sql

# Verify backups
ls -lh backup_*.sql
```

### Step 2: Stop Production Server
```bash
service ac-worldserver stop

# Verify stopped
systemctl status ac-worldserver
```

### Step 3: Apply Database Updates
```bash
# Apply world database updates
mysql -uacore -pacore acore_world < data/sql/updates/db_world/2026_02_03_00_description.sql

# Verify changes applied
mysql -uacore -pacore acore_world -e "SELECT COUNT(*) FROM <table_name>;"
```

### Step 4: Deploy Code Changes
```bash
# Rebuild if C++ changes
cd /root/azerothcore-wotlk/build
cmake .. -DCMAKE_INSTALL_PREFIX=../env/dist
make -j$(nproc)

# Verify compilation
echo "Build status: $?"
```

### Step 5: Update Configuration
```bash
# Copy new configuration if needed
cp conf/dist/modules/<module>.conf.dist env/dist/etc/modules/<module>.conf

# Edit configuration
nano env/dist/etc/modules/<module>.conf

# Verify syntax
grep -v "^#" env/dist/etc/modules/<module>.conf | grep -v "^$"
```

### Step 6: Start Production Server
```bash
service ac-worldserver start

# Monitor startup
sleep 5
systemctl status ac-worldserver

# Check logs
tail -f env/dist/logs/Server.log
```

### Step 7: Verify Deployment
```bash
# Check for errors
grep -i "error\|critical" env/dist/logs/Server.log

# Verify module loaded
grep -i "loaded\|initialized" env/dist/logs/Server.log

# Test functionality
# Use in-game commands or test scenarios
```

## Rollback Procedure

**If deployment fails**:

### Step 1: Stop Server
```bash
service ac-worldserver stop
```

### Step 2: Restore Database
```bash
# Restore from backup
mysql -uacore -pacore acore_world < backup_world_YYYYMMDD_HHMMSS.sql

# Verify restoration
mysql -uacore -pacore acore_world -e "SELECT COUNT(*) FROM <table_name>;"
```

### Step 3: Revert Code Changes
```bash
# If git repository
git revert <commit_hash>

# Rebuild
cd build && make -j$(nproc)
```

### Step 4: Restart Server
```bash
service ac-worldserver start

# Monitor
tail -f env/dist/logs/Server.log
```

### Step 5: Notify Team
- Document what went wrong
- Create issue for investigation
- Plan fix and re-test

## Testing on Development Realm

### Step 1: Apply Changes to Dev
```bash
# Stop dev server
service ac-worldserver-dev stop

# Apply database changes
mysql -uacore -pacore acore_world < data/sql/updates/db_world/update.sql

# Rebuild if needed
cd build && make -j$(nproc)

# Start dev server
service ac-worldserver-dev start
```

### Step 2: Test Functionality
```bash
# Create test character on dev realm
# Test all affected features
# Check logs for errors
tail -f env/dist/logs-dev/Server.log
```

### Step 3: Performance Testing
```bash
# Monitor CPU usage
top -p $(pgrep worldserver-dev)

# Monitor memory usage
free -h

# Check for memory leaks
valgrind --leak-check=full worldserver-dev
```

### Step 4: Stress Testing
- Spawn multiple bots
- Run dungeons/raids
- Test with multiple players
- Monitor performance metrics

## Monitoring Post-Deployment

### Daily Checks
```bash
# Check server status
systemctl status ac-worldserver

# Review error logs
grep -i "error\|critical" env/dist/logs/Server.log | tail -20

# Check database size
mysql -uacore -pacore -e "SELECT table_name, ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb FROM information_schema.tables WHERE table_schema = 'acore_world' ORDER BY size_mb DESC;"

# Monitor player count
mysql -uacore -pacore acore_auth -e "SELECT COUNT(*) FROM account;"
```

### Weekly Checks
- Review all error logs
- Check database integrity
- Verify backups completed
- Monitor bot performance
- Check for memory leaks

### Monthly Checks
- Full database backup verification
- Performance analysis
- Security audit
- Module compatibility check

## Common Issues

**Server won't start**:
- Check logs for errors
- Verify database connection
- Check configuration syntax
- Restore from backup if needed

**Database errors**:
- Check SQL syntax
- Verify table structure
- Check for duplicate entries
- Restore from backup

**Performance degradation**:
- Check for slow queries
- Monitor CPU/memory usage
- Review recent changes
- Optimize database indexes

**Module conflicts**:
- Check module load order
- Verify no duplicate functionality
- Test modules individually
- Review module dependencies

## Useful Commands

```bash
# Server management
service ac-worldserver start
service ac-worldserver stop
service ac-worldserver restart
systemctl status ac-worldserver

# Development realm
service ac-worldserver-dev start
service ac-worldserver-dev stop

# Database
mysql -uacore -pacore acore_world
mysqldump -uacore -pacore acore_world > backup.sql

# Logs
tail -f env/dist/logs/Server.log
grep -i "error" env/dist/logs/Server.log

# Build
cd build && cmake .. && make -j$(nproc)

# Reload tables (SOAP)
.reload smart_scripts
.reload spell_proc
.reload conditions
```

## Related Resources

- Server Setup: https://www.azerothcore.org/wiki/linux-server-setup
- Database Guide: https://www.azerothcore.org/wiki/database-world
- Configuration: https://www.azerothcore.org/wiki/worldserver.conf
