#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS_DIR="$ROOT_DIR/logs"
SCRIPTS_DIR="$ROOT_DIR/scripts"
CONFIG_FILE="$ROOT_DIR/config.cfg"

echo "Setting up Bash Maintenance Suite..."

mkdir -p "$LOGS_DIR" "$SCRIPTS_DIR"
touch "$LOGS_DIR/suite.log"

chmod +x "$ROOT_DIR"/*.sh "$SCRIPTS_DIR"/*.sh 2>/dev/null || true

for cmd in bash tar grep find date; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "❌ Missing dependency: $cmd"
        exit 1
    fi
done

for cmd in mail sudo; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "Found optional tool: $cmd"
    fi
done

if [[ ! -f "$CONFIG_FILE" ]]; then
    cat >"$CONFIG_FILE" <<'EOF'
BACKUP_DIRS="/home /etc" #directories to back up (space-separated)
BACKUP_DEST="./backups" #destination directory for backups
BACKUP_RETENTION_DAYS=7 #number of days to keep backups

LOG_FILE_TO_MONITOR="/var/log/syslog" #log file to monitor
LOG_KEYWORDS="error failed critical" #keywords to look for in the log file (space-separated)
NOTIFY_USER="" #email for notifications (leave empty to disable notifications), requires mailx/mailutils
LOG_MONITOR_FOLLOW=false #set to true to follow the log file in real-time, runs in daemon mode
EOF
    echo "Default config created: config.cfg"
else
    echo "Config file already exists."
fi

if [[ ! -w "$LOGS_DIR" ]]; then
    echo "Log directory not writable."
    sudo chmod 755 "$LOGS_DIR"
fi

echo "Setup complete! Run ./maintenance_suite.sh"
