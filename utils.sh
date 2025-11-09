#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS_DIR="$ROOT_DIR/logs"
LOG_FILE="$LOGS_DIR/suite.log"
CONFIG_FILE="$ROOT_DIR/config.cfg"

mkdir -p "$LOGS_DIR"
touch "$LOG_FILE"

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    printf "[%s] [%s] %s\n" "$timestamp" "$level" "$message" | tee -a "$LOG_FILE"
}

require_command() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log "ERROR" "Required command '$cmd' not found."
        return 1
    fi
    return 0
}

ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || { log "ERROR" "Failed to create directory: $dir"; exit 1; }
    fi
}
