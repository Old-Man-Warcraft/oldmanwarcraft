#!/usr/bin/env bash
# clean_logs.sh — Delete all timestamped rotated log files from /root/logs/
# Matches files like: AuctionHouse.log.2026-05-23 19-57-51
# Does NOT touch: active *.log files, gm_*.log files, or chronicle_logs/

LOG_DIR="${1:-/root/logs}"

if [[ ! -d "$LOG_DIR" ]]; then
    echo "ERROR: Log directory not found: $LOG_DIR" >&2
    exit 1
fi

# Pattern: <Name>.log.<YYYY-MM-DD HH-MM-SS>
mapfile -d '' FILES < <(find "$LOG_DIR" -maxdepth 1 -type f \
    -regextype posix-extended \
    -regex '.*/[^/]+\.log\.[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}-[0-9]{2}-[0-9]{2}' \
    -print0)

COUNT=${#FILES[@]}

if [[ $COUNT -eq 0 ]]; then
    echo "No timestamped log files found in $LOG_DIR."
    exit 0
fi

echo "Found $COUNT timestamped log file(s) to delete in $LOG_DIR"

TOTAL_BYTES=0
for f in "${FILES[@]}"; do
    SIZE=$(stat -c%s "$f" 2>/dev/null || echo 0)
    TOTAL_BYTES=$(( TOTAL_BYTES + SIZE ))
done

# Convert to human-readable
if command -v numfmt &>/dev/null; then
    HR=$(numfmt --to=iec-i --suffix=B "$TOTAL_BYTES")
else
    HR="${TOTAL_BYTES} bytes"
fi

echo "Total size to reclaim: $HR"
echo ""

# Dry-run mode: pass --dry-run as second arg (or -n)
if [[ "${2:-}" == "--dry-run" || "${2:-}" == "-n" ]]; then
    echo "[DRY RUN] Would delete:"
    for f in "${FILES[@]}"; do
        echo "  $f"
    done
    exit 0
fi

DELETED=0
ERRORS=0
for f in "${FILES[@]}"; do
    if rm -- "$f"; then
        (( DELETED++ ))
    else
        echo "ERROR: failed to delete: $f" >&2
        (( ERRORS++ ))
    fi
done

echo "Deleted $DELETED file(s)."
[[ $ERRORS -gt 0 ]] && echo "Errors: $ERRORS" >&2 && exit 1
exit 0
