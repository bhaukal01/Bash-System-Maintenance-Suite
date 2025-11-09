#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/utils.sh"

SCRIPTS_DIR="$ROOT_DIR/scripts"

show_menu() {
cat <<EOF
==========================
  Maintenance Suite
==========================
1) Run Backup
2) Run System Update & Cleanup
3) Monitor Logs (Scan)
4) Monitor Logs (Follow)
5) View Log (Last 50 lines)
6) Exit
EOF
}

run_backup() { "$SCRIPTS_DIR/backup.sh"; }
run_update_cleanup() { "$SCRIPTS_DIR/update_cleanup.sh"; }
run_log_monitor_scan() { "$SCRIPTS_DIR/log_monitor.sh" --summary; }
run_log_monitor_follow() { "$SCRIPTS_DIR/log_monitor.sh" --watch & }

while true; do
    show_menu
    read -rp "Select option: " opt
    case $opt in
        1) run_backup;;
        2) run_update_cleanup;;
        3) run_log_monitor_scan;;
        4) run_log_monitor_follow;;
        5) tail -n 50 "$LOG_FILE";;
        6) log "INFO" "Exiting Maintenance Suite."; exit 0;;
        exit) log "INFO" "Exiting Maintenance Suite."; exit 0;;
        *) echo "Invalid choice";;
    esac
done
