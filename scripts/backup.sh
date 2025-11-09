#!/usr/bin/env bash

set -euo pipefail
source "$(dirname "$0")/../utils.sh"

log "INFO" "Starting backup process..."

# check for configured backup directories
if [[ -z "${BACKUP_DIRS:-}" ]]; then
    log "ERROR" "No backup source configured in utils or config.cfg."
    exit 1
fi

: "${BACKUP_DEST:="/opt/backups"}"
: "${BACKUP_RETENTION_DAYS:=7}"

ensure_dir "$BACKUP_DEST"

timestamp=$(date '+%Y%m%d_%H%M%S')

# iterate over backup directories
for dir in $BACKUP_DIRS; do
    if [[ ! -e "$dir" ]]; then
        log "WARN" "Skipping non-existent directory: $dir"
        continue
    fi

    clean_name=$(basename "$dir")
    backup_file="$BACKUP_DEST/${clean_name}_${timestamp}.tar.gz"

    log "INFO" "Creating backup for $dir → $backup_file"

    # Create backup
    if tar -czpf "$backup_file" "$dir" 2>>"$LOG_FILE"; then
        log "SUCCESS" "Backup created successfully: $backup_file"
    else
        log "ERROR" "Failed to create backup for $dir"
        continue
    fi
done

# old backup cleanup
if [[ "$BACKUP_RETENTION_DAYS" -gt 0 ]]; then
    log "INFO" "Removing backups older than $BACKUP_RETENTION_DAYS days from $BACKUP_DEST"
    find "$BACKUP_DEST" -type f -name '*.tar.gz' -mtime +"$BACKUP_RETENTION_DAYS" -print -delete 2>>"$LOG_FILE" || {
        log "WARN" "Error occurred during old backup cleanup."
    }
    log "CLEANUP" "Backup rotation completed."
fi

log "INFO" "Backup process completed."
exit 0
