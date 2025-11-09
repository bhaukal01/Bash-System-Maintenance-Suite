#!/usr/bin/env bash

set -euo pipefail
source "$(dirname "$0")/../utils.sh"

MODE="${1:---summary}"

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

    local cutoff
    cutoff=$(date -d "-${days} days" +%s)

    awk -v cutoff="$cutoff" -v key="$keyword" '
    function to_epoch(month, day) {
        # Convert month name to number
        months["Jan"]=1; months["Feb"]=2; months["Mar"]=3; months["Apr"]=4;
        months["May"]=5; months["Jun"]=6; months["Jul"]=7; months["Aug"]=8;
        months["Sep"]=9; months["Oct"]=10; months["Nov"]=11; months["Dec"]=12;
        # Assume current year
        year = strftime("%Y");
        cmd = sprintf("date -d \"%s %d %s\" +%%s", month, day, year);
        cmd | getline epoch; close(cmd);
        return epoch;
    }
    {
        # syslog style: "Nov  9 14:15:22"
        if ($1 ~ /^[A-Z][a-z][a-z]$/ && $2 ~ /^[0-9]+$/) {
            ts = to_epoch($1, $2)
            if (ts >= cutoff && tolower($0) ~ tolower(key))
                count++
        }
        # ISO format style: "2025-11-09"
        else if ($1 ~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}/) {
            split($1, d, "-");
            cmd = sprintf("date -d \"%s-%s-%s\" +%%s", d[1], d[2], d[3]);
            cmd | getline ts; close(cmd);
            if (ts >= cutoff && tolower($0) ~ tolower(key))
                count++
        }
    }
    END { print count+0 }
    ' "$LOG_FILE_TO_MONITOR"
}

if [[ "$MODE" == "--summary" ]]; then
    echo "---------------------------------------------"
    echo " LOG ANALYTICS SUMMARY"
    echo "---------------------------------------------"
    printf "%-15s %-15s %-15s %-15s\n" "KEYWORD" "LAST 7 DAYS" "LAST 14 DAYS" "TOTAL"

    for key in $LOG_KEYWORDS; do
        c7=$(count_occurrences "$key" 7)
        c14=$(count_occurrences "$key" 14)
        total=$(grep -i "$key" "$LOG_FILE_TO_MONITOR" | wc -l)
        printf "%-15s %-15s %-15s %-15s\n" "$key" "$c7" "$c14" "$total"
    done

    echo "---------------------------------------------"
    log "INFO" "Displayed log summary analytics successfully."
    exit 0
fi

#realtime mode code
if [[ "$MODE" == "--watch" ]]; then
    log "INFO" "Following $LOG_FILE_TO_MONITOR for real-time matches: $LOG_KEYWORDS"
    tail -F "$LOG_FILE_TO_MONITOR" 2>/dev/null | grep --line-buffered -iE "$LOG_KEYWORDS" | while read -r line; do
        log "ALERT" "$line"
    done
fi
