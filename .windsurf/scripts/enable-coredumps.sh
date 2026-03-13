#!/bin/bash
# Enable core dumps for better crash debugging

echo "Enabling core dumps for worldserver debugging..."

# Set core dump pattern
sudo sysctl -w kernel.core_pattern=/tmp/core.%e.%p.%t
echo "Core dump pattern set to: /tmp/core.%e.%p.%t"

# Set unlimited core dump size for current session
ulimit -c unlimited
echo "Core dump size set to unlimited for current session"

# Make it permanent for systemd service
SERVICE_FILE="/etc/systemd/system/ac-worldserver.service"
if [ -f "$SERVICE_FILE" ]; then
    if ! grep -q "LimitCORE=infinity" "$SERVICE_FILE"; then
        sudo sed -i '/\[Service\]/a LimitCORE=infinity' "$SERVICE_FILE"
        sudo systemctl daemon-reload
        echo "Added LimitCORE=infinity to ac-worldserver.service"
    else
        echo "Core dumps already enabled in systemd service"
    fi
fi

# Create core dump directory with proper permissions
sudo mkdir -p /tmp/cores
sudo chmod 777 /tmp/cores
echo "Created /tmp/cores directory"

echo ""
echo "Core dumps enabled! On next crash:"
echo "  1. Core file will be at: /tmp/core.worldserver.<pid>.<timestamp>"
echo "  2. Run: gdb /path/to/worldserver /tmp/core.worldserver.*"
echo "  3. Type 'bt' for backtrace"
echo ""
