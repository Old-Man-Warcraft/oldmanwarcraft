#!/bin/bash
# Compile worldserver with debug symbols for better crash analysis

set -e

echo "Compiling worldserver with debug symbols..."
echo ""

cd /root/azerothcore-wotlk

# Ask user which build type
echo "Select build type:"
echo "1) RelWithDebInfo (Recommended - Release optimizations + debug symbols)"
echo "2) Debug (Full debug, slower but better for debugging)"
echo "3) AddressSanitizer (Detects memory bugs, very slow)"
read -p "Choice [1-3]: " choice

case $choice in
    1)
        BUILD_TYPE="RelWithDebInfo"
        CMAKE_FLAGS=""
        ;;
    2)
        BUILD_TYPE="Debug"
        CMAKE_FLAGS=""
        ;;
    3)
        BUILD_TYPE="RelWithDebInfo"
        CMAKE_FLAGS="-DCMAKE_CXX_FLAGS='-fsanitize=address -fno-omit-frame-pointer -g' -DCMAKE_C_FLAGS='-fsanitize=address -fno-omit-frame-pointer -g' -DCMAKE_EXE_LINKER_FLAGS='-fsanitize=address'"
        echo ""
        echo "WARNING: AddressSanitizer build is SLOW. Do not use under live player load; use an isolated debug/staging environment."
        echo ""
        ;;
    *)
        echo "Invalid choice, using RelWithDebInfo"
        BUILD_TYPE="RelWithDebInfo"
        CMAKE_FLAGS=""
        ;;
esac

# Use existing build directory
cd /root/azerothcore-wotlk/var/build

echo "Configuring build with type: $BUILD_TYPE"
cmake ../../ \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_INSTALL_PREFIX=/root/azerothcore-wotlk/env \
    -DCONF_DIR=/root/azerothcore-wotlk/env/dist/etc \
    -DWITH_WARNINGS=1 \
    $CMAKE_FLAGS

echo ""
echo "Building..."
make -j$(nproc)

echo ""
echo "Installing..."
make install

echo ""
echo "Build complete!"
echo ""
echo "Debug symbols: ENABLED"
echo "Build type: $BUILD_TYPE"

if [ "$choice" == "3" ]; then
    echo ""
    echo "AddressSanitizer enabled - will detect:"
    echo "  - Use-after-free"
    echo "  - Heap buffer overflow"
    echo "  - Stack buffer overflow"
    echo "  - Memory leaks"
    echo "  - Use-after-return"
    echo ""
    echo "Performance impact: ~2x memory, ~50% slower"
fi

echo ""
echo "Don't forget to enable core dumps:"
echo "  ./.cursor/scripts/windsurf/enable-coredumps.sh"
echo ""
