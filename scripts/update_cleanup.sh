#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../utils.sh"

log "INFO" "Detecting package manager..."

if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get autoremove -y
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf upgrade -y
elif command -v yum >/dev/null 2>&1; then
    sudo yum update -y
elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Syu --noconfirm
elif command -v apk >/dev/null 2>&1; then
    sudo apk update && sudo apk upgrade
else
    log "ERROR" "No known package manager found."
    exit 1
fi

log "SUCCESS" "System update and cleanup complete."
