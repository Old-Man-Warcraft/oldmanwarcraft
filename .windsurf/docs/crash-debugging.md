# Crash Debugging Guide

## Quick Start

### Analyze Latest Crash
```bash
cd /root/azerothcore-wotlk
./.windsurf/scripts/analyze-crash.sh
```

### Analyze Specific Crash by Timestamp
```bash
./.windsurf/scripts/analyze-crash.sh "2026-02-10 14-55-58"
```

### Enable Core Dumps (Better Stack Traces)
```bash
./.windsurf/scripts/enable-coredumps.sh
```

### Monitor for Crashes in Real-Time
```bash
./.windsurf/scripts/monitor-crashes.sh
```

---

## Crash Analysis Report Contents

The analysis script generates comprehensive reports including:

1. **System Crash Info** - dmesg segfault details
2. **Last 100 Lines** - Context before crash
3. **LFG Activity** - Queue operations near crash time
4. **Bot Activity** - Bot logins/logouts/actions
5. **Error Patterns** - Categorized errors from logs
6. **Memory Issues** - Null pointer/use-after-free indicators
7. **Group/Session Activity** - Player state changes
8. **Stack Trace** - If core dump available
9. **Crash Signature** - Automatic crash type detection
10. **Recommendations** - Suggested fixes

---

## Crash Types Detected

### NULL Pointer Dereference (segfault at 0)
```
Causes:
- FindConnectedPlayer() returned null
- GetGroup() not checked before use
- GetSession() on disconnected player

Fix: Add defensive null checks
```

### Use-After-Free (corrupted address)
```
Causes:
- Iterator invalidation during container modification
- Accessing deleted objects
- Dangling pointers after clear()/erase()

Fix: Cache pointers, check validity before use
```

### Memory Corruption (random address)
```
Causes:
- Buffer overflow
- Double-free
- Heap corruption

Fix: Enable AddressSanitizer (see below)
```

---

## Advanced Debugging

### Enable Debug Symbols
Edit build configuration:
```bash
cd /root/azerothcore-wotlk/conf/dist
# Add to worldserver.conf:
Logger.scripts.core=6,Console Server
Logger.sql.sql=6,Console Server
```

### Compile with AddressSanitizer (Memory Bug Detection)
```bash
cd /root/azerothcore-wotlk
mkdir build-asan
cd build-asan

cmake ../ \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_CXX_FLAGS="-fsanitize=address -fno-omit-frame-pointer -g" \
  -DCMAKE_C_FLAGS="-fsanitize=address -fno-omit-frame-pointer -g" \
  -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=address" \
  -DCMAKE_INSTALL_PREFIX=/root/azerothcore-wotlk/env

make -j$(nproc)
make install
```

**Warning**: AddressSanitizer adds ~2x memory overhead and 50% performance penalty. Use on development realm only.

### Core Dump Analysis
After enabling core dumps:
```bash
# When crash occurs, core file appears at /tmp/core.worldserver.*
CORE_FILE=$(ls -t /tmp/core.worldserver.* | head -1)

# Load in GDB
gdb /root/azerothcore-wotlk/env/dist/bin/worldserver $CORE_FILE

# GDB commands:
(gdb) bt              # Full backtrace
(gdb) bt full         # With local variables
(gdb) frame 0         # Jump to crash frame
(gdb) print variable  # Inspect variable
(gdb) info locals     # All local variables
(gdb) list            # Source code at crash
```

---

## Common Crash Patterns

### Pattern 1: LFG Bot Queue Crashes
**Symptoms**: Bots queuing for LFG immediately before crash

**Logs to check**:
```bash
grep "queues LFG" /root/azerothcore-wotlk/env/dist/logs/CrashContext.log.* | tail -50
```

**Common causes**:
- Group disbanded while processing queue
- Player disconnected during proposal
- Iterator invalidated during queue update

**Fixed vulnerabilities**:
- ✅ Null player checks in UpdateRaidBrowser
- ✅ Group validation before member iteration
- ✅ Roles pointer use-after-free in bestCompatible

### Pattern 2: Group Synchronization Crashes
**Symptoms**: "Group disbanded" or "Player not found" errors before crash

**Common causes**:
- Race condition between group operations
- Group deleted while being accessed
- Member removed during iteration

**Prevention**:
- Cache group pointers before multi-call sequences
- Validate group exists before accessing members
- Use iterator-safe erase patterns

### Pattern 3: Session/Player Lifecycle Crashes
**Symptoms**: Player logout/login immediately before crash

**Common causes**:
- Accessing player after logout
- Session destroyed but referenced
- Async operations on deleted objects

**Prevention**:
- Always null-check FindConnectedPlayer results
- Don't cache Player* across async boundaries
- Validate session before use

---

## Logging Best Practices

### Enable Detailed LFG Logging
Edit `worldserver.conf`:
```
Logger.lfg=6,Console Server
```

### Custom Debug Logging
Add to code for investigation:
```cpp
LOG_ERROR("lfg.debug", "TRACE: Function={} Player={} Group={}",
    __FUNCTION__, 
    player ? player->GetGUID().ToString() : "null",
    group ? group->GetGUID().ToString() : "null");
```

### Performance Logging
Monitor slow operations:
```cpp
auto start = std::chrono::steady_clock::now();
// ... operation ...
auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(
    std::chrono::steady_clock::now() - start).count();
if (duration > 100) {
    LOG_WARN("performance", "Slow operation: {} took {}ms", __FUNCTION__, duration);
}
```

---

## Automated Testing

### Stress Test LFG System
```bash
# Queue many bots simultaneously
.gm on
.server set loglevel 6

# In game, use bot commands:
.bot command all lfg queue
```

### Monitor Resource Usage
```bash
# Watch memory usage during stress test
watch -n 1 'ps aux | grep worldserver | grep -v grep'

# Check for memory leaks
valgrind --leak-check=full --show-leak-kinds=all \
  /root/azerothcore-wotlk/env/dist/bin/worldserver
```

---

## Crash Report Locations

- **Analysis Reports**: `/root/azerothcore-wotlk/crash-reports/`
- **Core Dumps**: `/tmp/core.worldserver.*`
- **Server Logs**: `/root/azerothcore-wotlk/env/dist/logs/`
- **System Logs**: `dmesg | grep worldserver`

---

## Emergency Procedures

### If Server Keeps Crashing

1. **Stop server immediately**:
   ```bash
   service ac-worldserver stop
   ```

2. **Analyze last crash**:
   ```bash
   ./.windsurf/scripts/analyze-crash.sh
   ```

3. **Check for pattern** (3+ crashes in same function):
   ```bash
   dmesg | grep worldserver | tail -20
   ```

4. **Apply hotfix** or **disable problematic feature**:
   ```sql
   # Example: Disable LFG if crashes persist
   UPDATE acore_world.lfg_dungeon_template SET entry=0;
   ```

5. **Restore from backup** if data corruption suspected

6. **Test on development realm first** before restarting production

---

## Contact & Support

For persistent crashes:
1. Generate crash report with analyze-crash.sh
2. Include last 200 lines of crash context
3. Note any patterns (LFG, bots, groups, etc.)
4. Provide dmesg segfault details
5. If core dump available, include backtrace

Report format:
```
Crash Type: [NULL_POINTER / USE_AFTER_FREE / CORRUPTION]
Frequency: [once / repeating every X minutes]
Pattern: [LFG queue / bot activity / player logout / etc.]
Last known good state: [timestamp]
Recent changes: [code changes / config changes / module updates]
```
