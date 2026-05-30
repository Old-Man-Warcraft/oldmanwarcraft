#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="${BACKUP_ENV_FILE:-$PROJECT_ROOT/.env}"
WORKING_DIR=""

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

cleanup() {
    if [[ -n "${WORKING_DIR:-}" && -d "$WORKING_DIR" ]]; then
        rm -rf -- "$WORKING_DIR"
    fi
}

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        log_error "Required command not found: $command_name"
        exit 1
    fi
}

load_env_file() {
    if [[ ! -f "$ENV_FILE" ]]; then
        log_error "Environment file not found: $ENV_FILE"
        log_error "Create it from the placeholder in the project root and fill in your real credentials."
        exit 1
    fi

    log_info "Loading configuration from $ENV_FILE"
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
}

require_env() {
    local variable_name="$1"

    if [[ -z "${!variable_name:-}" ]]; then
        log_error "Required environment variable is missing: $variable_name"
        exit 1
    fi
}

require_real_value() {
    local variable_name="$1"
    local variable_value="${!variable_name:-}"

    if [[ "$variable_value" == "replace_me" || "$variable_value" == "changeme" ]]; then
        log_error "Environment variable $variable_name still has a placeholder value."
        exit 1
    fi
}

resolve_aws_command() {
    if command -v aws >/dev/null 2>&1; then
        AWS_COMMAND="$(command -v aws)"
        return
    fi

    if [[ -x "/usr/local/bin/aws" ]]; then
        AWS_COMMAND="/usr/local/bin/aws"
        return
    fi

    log_error "Required command not found: aws"
    log_error "Install AWS CLI v2 or ensure /usr/local/bin is included in PATH."
    exit 1
}

resolve_dump_command() {
    if command -v mysqldump >/dev/null 2>&1; then
        DUMP_COMMAND="mysqldump"
        return
    fi

    if command -v mariadb-dump >/dev/null 2>&1; then
        DUMP_COMMAND="mariadb-dump"
        return
    fi

    log_error "Neither mysqldump nor mariadb-dump is installed."
    exit 1
}

sanitize_name() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9._-' '-' | sed -E 's/^-+//; s/-+$//'
}

aws_with_env() {
    AWS_ACCESS_KEY_ID="$BACKUP_WASABI_ACCESS_KEY" \
    AWS_SECRET_ACCESS_KEY="$BACKUP_WASABI_SECRET_KEY" \
    AWS_DEFAULT_REGION="$BACKUP_WASABI_REGION" \
        "$AWS_COMMAND" "$@" --endpoint-url "$BACKUP_WASABI_ENDPOINT"
}

upload_file() {
    local source_file="$1"
    local destination_path="$2"

    aws_with_env s3 cp "$source_file" "$destination_path" --only-show-errors
}

prune_remote_backups() {
    local host_name="$1"
    local remote_host_prefix="${BACKUP_WASABI_PREFIX}/${host_name}/"

    if [[ ! "$BACKUP_RETENTION_DAYS" =~ ^[0-9]+$ ]]; then
        log_error "BACKUP_RETENTION_DAYS must be a non-negative integer."
        exit 1
    fi

    if [[ "$BACKUP_RETENTION_DAYS" == "0" ]]; then
        log_info "Remote retention disabled because BACKUP_RETENTION_DAYS=0"
        return
    fi

    local cutoff_date
    cutoff_date="$(date -u -d "${BACKUP_RETENTION_DAYS} days ago" +%Y/%m/%d)"

    log_info "Pruning remote backups older than ${BACKUP_RETENTION_DAYS} days (before ${cutoff_date})"

    local -A expired_day_prefixes=()
    local listed_key

    while read -r _ _ _ listed_key; do
        listed_key="${listed_key//$'\r'/}"

        if [[ -z "$listed_key" || "$listed_key" != ${remote_host_prefix}* ]]; then
            continue
        fi

        local relative_key="${listed_key#${remote_host_prefix}}"
        local year month day
        IFS='/' read -r year month day _ <<< "$relative_key"

        if [[ -z "$year" || -z "$month" || -z "$day" ]]; then
            continue
        fi

        local object_date="${year}/${month}/${day}"
        if [[ "$object_date" < "$cutoff_date" ]]; then
            expired_day_prefixes["$object_date"]=1
        fi
    done < <(aws_with_env s3 ls "s3://${BACKUP_WASABI_BUCKET}/${remote_host_prefix}" --recursive)

    if [[ "${#expired_day_prefixes[@]}" == "0" ]]; then
        log_info "No remote backups exceeded the retention window."
        return
    fi

    local expired_day_prefix
    while IFS= read -r expired_day_prefix; do
        [[ -z "$expired_day_prefix" ]] && continue

        log_info "Deleting expired remote backup prefix: s3://${BACKUP_WASABI_BUCKET}/${remote_host_prefix}${expired_day_prefix}/"
        aws_with_env s3 rm "s3://${BACKUP_WASABI_BUCKET}/${remote_host_prefix}${expired_day_prefix}/" \
            --recursive \
            --only-show-errors
    done < <(printf '%s\n' "${!expired_day_prefixes[@]}" | sort)
}

main() {
    require_command gzip
    require_command sha256sum
    require_command date
    require_command hostname
    require_command mktemp

    load_env_file
    resolve_aws_command
    resolve_dump_command

    BACKUP_DB_HOST="${BACKUP_DB_HOST:-127.0.0.1}"
    BACKUP_DB_PORT="${BACKUP_DB_PORT:-3306}"
    BACKUP_DATABASES="${BACKUP_DATABASES:-acore_auth,acore_characters,acore_world}"
    BACKUP_WASABI_REGION="${BACKUP_WASABI_REGION:-us-east-1}"
    BACKUP_WASABI_PREFIX="${BACKUP_WASABI_PREFIX:-db-backups}"
    BACKUP_LOCAL_DIR="${BACKUP_LOCAL_DIR:-$PROJECT_ROOT/var/backups/wasabi-db}"
    BACKUP_KEEP_LOCAL_COPY="${BACKUP_KEEP_LOCAL_COPY:-0}"
    BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"

    require_env BACKUP_DB_USER
    require_env BACKUP_DB_PASSWORD
    require_env BACKUP_WASABI_ACCESS_KEY
    require_env BACKUP_WASABI_SECRET_KEY
    require_env BACKUP_WASABI_BUCKET
    require_env BACKUP_WASABI_ENDPOINT

    require_real_value BACKUP_DB_USER
    require_real_value BACKUP_DB_PASSWORD
    require_real_value BACKUP_WASABI_ACCESS_KEY
    require_real_value BACKUP_WASABI_SECRET_KEY
    require_real_value BACKUP_WASABI_BUCKET

    mkdir -p "$BACKUP_LOCAL_DIR"

    local timestamp
    timestamp="$(date -u +%Y%m%dT%H%M%SZ)"

    local date_partition
    date_partition="$(date -u +%Y/%m/%d)"

    local host_name
    host_name="$(sanitize_name "$(hostname -s 2>/dev/null || hostname)")"

    WORKING_DIR="$(mktemp -d "$BACKUP_LOCAL_DIR/.tmp.${timestamp}.XXXXXX")"
    trap cleanup EXIT

    local remote_base="s3://${BACKUP_WASABI_BUCKET}/${BACKUP_WASABI_PREFIX}/${host_name}/${date_partition}/${timestamp}"
    local manifest_file="$WORKING_DIR/manifest-${host_name}-${timestamp}.txt"

    log_info "Using dump command: $DUMP_COMMAND"
    log_info "Preparing backups in $WORKING_DIR"
    log_info "Uploading to $remote_base"

    local normalized_databases
    normalized_databases="${BACKUP_DATABASES//,/ }"

    local dumped_any=0
    while IFS= read -r database_name; do
        database_name="$(echo "$database_name" | xargs)"

        if [[ -z "$database_name" ]]; then
            continue
        fi

        dumped_any=1

        local safe_database_name
        safe_database_name="$(sanitize_name "$database_name")"

        local output_file="$WORKING_DIR/${host_name}-${safe_database_name}-${timestamp}.sql.gz"

        log_info "Dumping database: $database_name"
        MYSQL_PWD="$BACKUP_DB_PASSWORD" \
            "$DUMP_COMMAND" \
            --host="$BACKUP_DB_HOST" \
            --port="$BACKUP_DB_PORT" \
            --user="$BACKUP_DB_USER" \
            --single-transaction \
            --quick \
            --routines \
            --triggers \
            --events \
            --skip-lock-tables \
            --default-character-set=utf8mb4 \
            --databases "$database_name" \
            | gzip -9 > "$output_file"

        sha256sum "$output_file" >> "$manifest_file"

        log_info "Uploading $(basename "$output_file")"
        upload_file "$output_file" "$remote_base/$(basename "$output_file")"

        if [[ "$BACKUP_KEEP_LOCAL_COPY" == "1" ]]; then
            local final_output="$BACKUP_LOCAL_DIR/$(basename "$output_file")"
            mv "$output_file" "$final_output"
            log_info "Kept local copy at $final_output"
        fi
    done < <(printf '%s\n' $normalized_databases)

    if [[ "$dumped_any" == "0" ]]; then
        log_error "No databases configured. Set BACKUP_DATABASES in $ENV_FILE"
        exit 1
    fi

    cat <<EOF >> "$manifest_file"
remote_base=$remote_base
created_at_utc=$timestamp
host=$host_name
db_host=$BACKUP_DB_HOST
databases=$BACKUP_DATABASES
EOF

    log_info "Uploading manifest $(basename "$manifest_file")"
    upload_file "$manifest_file" "$remote_base/$(basename "$manifest_file")"

    if [[ "$BACKUP_KEEP_LOCAL_COPY" == "1" ]]; then
        local final_manifest="$BACKUP_LOCAL_DIR/$(basename "$manifest_file")"
        mv "$manifest_file" "$final_manifest"
        log_info "Kept local manifest at $final_manifest"
    fi

    prune_remote_backups "$host_name"

    log_info "Backup completed successfully."
}

main "$@"
