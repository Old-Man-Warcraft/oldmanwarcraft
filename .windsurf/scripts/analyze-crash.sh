#!/bin/bash
# AzerothCore Crash Analysis Script
# Analyzes server crashes and generates detailed reports

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

LOGDIR="/root/azerothcore-wotlk/env/dist/logs"
REPORTDIR="/root/azerothcore-wotlk/crash-reports"

# Create report directory
mkdir -p "$REPORTDIR"

# Get crash timestamp (default to latest)
CRASH_TIME="${1:-latest}"

echo -e "${BLUE}=== AzerothCore Crash Analysis ===${NC}"
echo ""

# Find most recent crash logs
if [ "$CRASH_TIME" == "latest" ]; then
    CRASH_CONTEXT=$(ls -t "$LOGDIR"/CrashContext.log.* 2>/dev/null | head -1)
    SERVER_LOG=$(ls -t "$LOGDIR"/Server.log.* 2>/dev/null | head -1)
    ERROR_LOG=$(ls -t "$LOGDIR"/Errors.log.* 2>/dev/null | head -1)
    LFG_LOG=$(ls -t "$LOGDIR"/LFG.log.* 2>/dev/null | head -1)
else
    # Find logs matching timestamp
    CRASH_CONTEXT=$(find "$LOGDIR" -name "CrashContext.log.*$CRASH_TIME*" | head -1)
    SERVER_LOG=$(find "$LOGDIR" -name "Server.log.*$CRASH_TIME*" | head -1)
    ERROR_LOG=$(find "$LOGDIR" -name "Errors.log.*$CRASH_TIME*" | head -1)
    LFG_LOG=$(find "$LOGDIR" -name "LFG.log.*$CRASH_TIME*" | head -1)
fi

if [ -z "$CRASH_CONTEXT" ]; then
    echo -e "${RED}No crash logs found!${NC}"
    exit 1
fi

TIMESTAMP=$(basename "$CRASH_CONTEXT" | sed 's/CrashContext.log.//')
REPORT_FILE="$REPORTDIR/crash-analysis-$TIMESTAMP.txt"

echo -e "${GREEN}Analyzing crash from: $TIMESTAMP${NC}"
echo ""

# Start report
{
    echo "==================================================================="
    echo "AzerothCore Crash Analysis Report"
    echo "Timestamp: $TIMESTAMP"
    echo "Generated: $(date)"
    echo "==================================================================="
    echo ""

    # System crash information from dmesg
    echo "--- SYSTEM CRASH INFO (dmesg) ---"
    dmesg | grep -i "worldserver\|segfault" | tail -20
    echo ""

    # Last lines of crash context (what was happening)
    echo "--- LAST 100 LINES BEFORE CRASH ---"
    tail -100 "$CRASH_CONTEXT" | grep -v "^$"
    echo ""

    # LFG activity analysis
    echo "--- LFG ACTIVITY (last 50 queue operations) ---"
    if [ -f "$CRASH_CONTEXT" ]; then
        grep -i "queues LFG\|LFG.*queue\|Proposal\|Compatible" "$CRASH_CONTEXT" | tail -50
    fi
    echo ""

    # Bot activity
    echo "--- BOT ACTIVITY (last 30 bot actions) ---"
    if [ -f "$CRASH_CONTEXT" ]; then
        grep -i "Bot GUID\|bot.*login\|bot.*logout" "$CRASH_CONTEXT" | tail -30
    fi
    echo ""

    # Error patterns
    echo "--- ERROR PATTERNS ---"
    if [ -f "$ERROR_LOG" ]; then
        echo "Total errors in log: $(wc -l < "$ERROR_LOG")"
        echo ""
        echo "Error types:"
        grep -i "error\|warn\|critical" "$ERROR_LOG" 2>/dev/null | \
            sed 's/^.*\(ERROR\|WARN\|CRITICAL\)[^:]*: //' | \
            sort | uniq -c | sort -rn | head -20
    fi
    echo ""

    # LFG errors
    echo "--- LFG SPECIFIC ERRORS ---"
    if [ -f "$LFG_LOG" ]; then
        cat "$LFG_LOG" | head -50
    fi
    echo ""

    # Memory/pointer issues
    echo "--- POTENTIAL NULL POINTER / MEMORY ISSUES ---"
    if [ -f "$ERROR_LOG" ]; then
        grep -i "not found\|nullptr\|null\|invalid\|disbanded\|deleted" "$ERROR_LOG" 2>/dev/null | tail -20
    fi
    echo ""

    # Group/session issues
    echo "--- GROUP/SESSION ACTIVITY ---"
    if [ -f "$CRASH_CONTEXT" ]; then
        grep -i "group\|session\|player.*logout\|player.*login" "$CRASH_CONTEXT" | tail -40
    fi
    echo ""

    # Stack trace if available
    echo "--- STACK TRACE (if available) ---"
    if [ -f "/var/crash/worldserver.crash" ]; then
        cat "/var/crash/worldserver.crash"
    else
        echo "No stack trace available. Consider enabling core dumps."
    fi
    echo ""

    # Check for core dumps
    CORE_FILE=$(find /tmp -name "core.*" -mtime -1 2>/dev/null | tail -1)
    if [ -n "$CORE_FILE" ]; then
        echo "--- CORE DUMP ANALYSIS ---"
        echo "Core file found: $CORE_FILE"
        if command -v gdb &> /dev/null; then
            echo "Running GDB backtrace..."
            gdb -batch -ex "bt" -ex "quit" /root/azerothcore-wotlk/env/dist/bin/worldserver "$CORE_FILE" 2>&1
        fi
    else
        echo "No core dump found in /tmp"
    fi
    echo ""

    # Crash signature analysis
    echo "--- CRASH SIGNATURE ---"
    SEGFAULT_LINE=$(dmesg | grep -i "worldserver.*segfault" | tail -1)
    if [ -n "$SEGFAULT_LINE" ]; then
        echo "$SEGFAULT_LINE"
        echo ""
        
        # Parse segfault address
        SEGFAULT_ADDR=$(echo "$SEGFAULT_LINE" | grep -oP 'segfault at \K[0-9a-f]+')
        if [ "$SEGFAULT_ADDR" == "0" ]; then
            echo "Type: NULL POINTER DEREFERENCE"
            echo "Likely causes:"
            echo "  - Accessing player/group/session pointer without null check"
            echo "  - ObjectAccessor::FindConnectedPlayer() returned null"
            echo "  - GetGroup() returned null but wasn't checked"
        elif [ ${#SEGFAULT_ADDR} -gt 10 ]; then
            echo "Type: USE-AFTER-FREE / MEMORY CORRUPTION"
            echo "Likely causes:"
            echo "  - Accessing deleted object"
            echo "  - Iterator invalidation"
            echo "  - Dangling pointer after clear() or erase()"
        else
            echo "Type: INVALID MEMORY ACCESS"
            echo "Address: 0x$SEGFAULT_ADDR"
        fi
    fi
    echo ""

    # Recommendations
    echo "--- RECOMMENDATIONS ---"
    echo "1. Review last operations before crash (see above)"
    echo "2. Check for pattern: LFG queue operations, bot activity, group changes"
    echo "3. If NULL pointer (addr=0): Add null checks for player/group/session"
    echo "4. If corrupted addr: Check for iterator invalidation or use-after-free"
    echo "5. Enable core dumps for full stack traces (see setup instructions)"
    echo ""

} > "$REPORT_FILE"

# Display report
cat "$REPORT_FILE"

echo ""
echo -e "${GREEN}Report saved to: $REPORT_FILE${NC}"
echo ""

# Suggest fixes based on patterns
echo -e "${YELLOW}=== AUTOMATED ANALYSIS ===${NC}"

if grep -q "segfault at 0 " <<< "$SEGFAULT_LINE"; then
    echo -e "${RED}NULL POINTER DETECTED${NC}"
    echo "Check these files for missing null checks:"
    echo "  - src/server/game/DungeonFinding/LFGMgr.cpp"
    echo "  - src/server/game/DungeonFinding/LFGQueue.cpp"
    echo "  - src/server/game/Handlers/LFGHandler.cpp"
fi

if grep -qi "queues LFG" "$CRASH_CONTEXT"; then
    echo -e "${YELLOW}LFG ACTIVITY DETECTED BEFORE CRASH${NC}"
    echo "High probability: LFG system bug"
    echo "Review LFG queue operations and proposal handling"
fi

if grep -qi "Group disbanded\|not found" "$ERROR_LOG" 2>/dev/null; then
    echo -e "${YELLOW}GROUP SYNCHRONIZATION ISSUES${NC}"
    echo "Race condition possible between group operations"
fi

echo ""
echo -e "${BLUE}To enable core dumps for better debugging:${NC}"
echo "  sudo sysctl -w kernel.core_pattern=/tmp/core.%e.%p"
echo "  ulimit -c unlimited"
echo ""
