#!/bin/bash
# Hook installer for AzerothCore / Old Man Warcraft
# Symlinks the hooks from .cline/hooks/ into .git/hooks/
#
# Usage: bash .cline/hooks/install.sh

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_SRC="$REPO_ROOT/.cline/hooks"
HOOKS_DST="$REPO_ROOT/.git/hooks"

echo "=== Installing Cline Git Hooks ==="
echo "Source: $HOOKS_SRC"
echo "Target: $HOOKS_DST"
echo ""

HOOKS=(
    "pre-commit"
    "commit-msg"
    "pre-push"
    "post-merge"
)

for hook in "${HOOKS[@]}"; do
    SRC="$HOOKS_SRC/$hook"
    DST="$HOOKS_DST/$hook"

    if [ ! -f "$SRC" ]; then
        echo "WARNING: $hook not found in $HOOKS_SRC — skipping."
        continue
    fi

    # Remove existing hook (file or symlink)
    if [ -e "$DST" ] || [ -L "$DST" ]; then
        echo "  Removing existing: $DST"
        rm -f "$DST"
    fi

    # Create relative symlink
    REL_PATH="../../.cline/hooks/$hook"
    ln -sf "$REL_PATH" "$DST"
    chmod +x "$SRC"
    echo "  Installed: $hook -> $REL_PATH"
done

echo ""
echo "=== Hooks installed successfully ==="
echo ""
echo "To verify:"
echo "  ls -la .git/hooks/ | grep '\.cline'"
echo ""
echo "To uninstall:"
echo "  rm .git/hooks/pre-commit .git/hooks/commit-msg .git/hooks/pre-push .git/hooks/post-merge"