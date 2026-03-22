#!/bin/bash

set -euo pipefail

LOG_DIR="${LOG_DIR:-/data/logs}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
DRY_RUN=0
DELETE_ALL_ROTATED=0
KEEP_PATTERN='*.log'

usage() {
    echo "Usage: $0 [-n|--dry-run] [--all-rotated] [-d|--days <days>] [-l|--log-dir <path>]"
    echo ""
    echo "Removes rotated log files older than the retention period."
    echo "Use --all-rotated to remove all rotated log files regardless of age."
    echo "Keeps active base log files matching: ${KEEP_PATTERN}"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run)
            DRY_RUN=1
            shift
            ;;
        --all-rotated)
            DELETE_ALL_ROTATED=1
            shift
            ;;
        -d|--days)
            RETENTION_DAYS="$2"
            shift 2
            ;;
        -l|--log-dir)
            LOG_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if ! [[ "$RETENTION_DAYS" =~ ^[0-9]+$ ]]; then
    echo "RETENTION_DAYS must be a non-negative integer." >&2
    exit 1
fi

if [[ ! -d "$LOG_DIR" ]]; then
    echo "Log directory not found: $LOG_DIR" >&2
    exit 1
fi

if [[ $DELETE_ALL_ROTATED -eq 1 ]]; then
    mapfile -d '' files < <(find "$LOG_DIR" -maxdepth 1 -type f ! -name "$KEEP_PATTERN" -print0 | sort -z)
else
    mapfile -d '' files < <(find "$LOG_DIR" -maxdepth 1 -type f ! -name "$KEEP_PATTERN" -mtime +"$RETENTION_DAYS" -print0 | sort -z)
fi

if [[ ${#files[@]} -eq 0 ]]; then
    if [[ $DELETE_ALL_ROTATED -eq 1 ]]; then
        echo "No rotated log files found in $LOG_DIR"
    else
        echo "No rotated log files older than ${RETENTION_DAYS} days found in $LOG_DIR"
    fi
    exit 0
fi

echo "Log directory: $LOG_DIR"
if [[ $DELETE_ALL_ROTATED -eq 1 ]]; then
    echo "Retention days: all rotated logs"
else
    echo "Retention days: $RETENTION_DAYS"
fi
echo "Mode: $([[ $DRY_RUN -eq 1 ]] && echo dry-run || echo delete)"
echo ""

for file in "${files[@]}"; do
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "Would remove: $file"
    else
        rm -f -- "$file"
        echo "Removed: $file"
    fi
done

echo ""
echo "Processed ${#files[@]} file(s)."
