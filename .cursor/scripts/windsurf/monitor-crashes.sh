#!/bin/bash
# Continuous crash monitoring script
# Watches for worldserver crashes and automatically generates reports

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGDIR="/root/azerothcore-wotlk/env/dist/logs"
LAST_CRASH=""

echo "Starting crash monitor..."
echo "Watching for worldserver crashes..."
echo "Press Ctrl+C to stop"
echo ""

while true; do
    # Check for new crash logs
    LATEST_CRASH=$(ls -t "$LOGDIR"/CrashContext.log.* 2>/dev/null | head -1)
    
    if [ -n "$LATEST_CRASH" ] && [ "$LATEST_CRASH" != "$LAST_CRASH" ]; then
        TIMESTAMP=$(basename "$LATEST_CRASH" | sed 's/CrashContext.log.//')
        
        echo ""
        echo "=========================================="
        echo "CRASH DETECTED at $TIMESTAMP"
        echo "=========================================="
        echo ""
        
        # Run analysis
        "$SCRIPT_DIR/analyze-crash.sh" "$TIMESTAMP"
        
        # Check system logs
        echo "System crash info:"
        dmesg | grep -i worldserver | tail -3
        
        echo ""
        echo "Monitoring continues..."
        echo ""
        
        LAST_CRASH="$LATEST_CRASH"
    fi
    
    sleep 5
done
