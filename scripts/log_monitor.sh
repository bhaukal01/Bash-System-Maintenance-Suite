#!/usr/bin/env bash

set -euo pipefail
source "$(dirname "$0")/../utils.sh"

MODE="${1:---summary}"  # default: summary mode

: "${LOG_FILE_TO_MONITOR:="/var/log/syslog"}"
: "${LOG_KEYWORDS:="error failed critical"}"

if [[ ! -f "$LOG_FILE_TO_MONITOR" ]]; then
    log "ERROR" "Log file not found: $LOG_FILE_TO_MONITOR"
    exit 1
fi

log "INFO" "Analyzing log file: $LOG_FILE_TO_MONITOR"
log "INFO" "Keywords configured: $LOG_KEYWORDS"

count_occurrences() {
    local keyword="$1"
    local days="$2"

    recent_logs=$(awk -v d="$days" -v today="$(date +%s)" '
        {
            # Try to parse timestamp from log line
            # Matches "Nov 09" or "2025-11-09" formats
            match($0, /[A-Z][a-z]{2} [0-9]{1,2}|[0-9]{4}-[0-9]{2}-[0-9]{2}/, arr)
            if (arr[0] != "") {
                logdate = arr[0]
                cmd = "date -d \"" logdate "\" +%s 2>/dev/null"
                cmd | getline ts
                close(cmd)
                if (ts >= today - (d * 86400)) print $0
            }
        }
    ' "$LOG_FILE_TO_MONITOR")

    echo "$recent_logs" | grep -i "$keyword" | wc -l
}

if [[ "$MODE" == "--summary" ]]; then
    echo "---------------------------------------------"
    echo " LOG ANALYTICS SUMMARY"
    echo "---------------------------------------------"
    printf "%-15s %-15s %-15s %-15s\n" "KEYWORD" "LAST 7 DAYS" "LAST 14 DAYS" "TOTAL"

    for key in $LOG_KEYWORDS; do
        count7=$(count_occurrences "$key" 7)
        count14=$(count_occurrences "$key" 14)
        total=$(grep -i "$key" "$LOG_FILE_TO_MONITOR" | wc -l)
        printf "%-15s %-15s %-15s %-15s\n" "$key" "$count7" "$count14" "$total"
    done

    echo "---------------------------------------------"
    log "INFO" "Displayed log summary analytics successfully."
    exit 0
fi

# --- Fallback: Continuous watch mode ---
if [[ "$MODE" == "--watch" ]]; then
    log "INFO" "Following $LOG_FILE_TO_MONITOR for real-time matches: $LOG_KEYWORDS"
    tail -F "$LOG_FILE_TO_MONITOR" 2>/dev/null | grep --line-buffered -iE "$LOG_KEYWORDS" | while read -r line; do
        log "ALERT" "$line"
    done
fi
