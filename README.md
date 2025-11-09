# System Maintenance Suite

## Description

The System Maintenance Suite is a collection of Bash scripts designed to automate essential Linux system maintenance tasks. It provides an interactive console menu for running backups, performing system updates, and monitoring system logs. The suite is modular, configurable, and designed with industry-standard logging.

## Features

- Configurable backup system with per-directory backup support
- Automated system updates and cleanup for multiple package managers
- Log monitoring with keyword analytics and real-time tracking
- Unified logging format with timestamps and levels
- Setup and configuration handled through setup script
- Utilities for permission checks and dependency validation

## Modules

### 1. Setup Script (`setup.sh`)

Initializes and validates the environment. Creates required directories, sets permissions, checks dependencies, and generates default configuration if missing.

### 2. Configuration File (`config.cfg`)

Holds all configurable options such as backup directories, backup retention period, log file paths, and monitored keywords. Users can edit this file to customize suite behavior.

### 3. Utilities (`utils.sh`)

Provides shared functions for logging, directory creation, command validation, and permission detection. All other scripts depend on this utility module.

### 4. Main Controller (`maintenance_suite.sh`)

The entry point for the suite. Presents an interactive menu to execute maintenance tasks such as backup, update, and log analysis.

### 5. Backup Module (`scripts/backup.sh`)

Creates compressed backups for each configured directory individually. Manages backup retention based on the defined number of days.

### 6. Update and Cleanup Module (`scripts/update_cleanup.sh`)

Detects the system’s package manager automatically and performs updates and cleanup. Supports APT, DNF, YUM, Pacman, and APK.

### 7. Log Monitoring Module (`scripts/log_monitor.sh`)

Analyzes the system log for configured keywords. Provides statistics for the number of occurrences in the last 7 days, 14 days, and total count. Supports both summary and live monitoring modes.

## Logging

All operations are logged in `logs/suite.log` using the format:

```
[YYYY-MM-DD HH:MM:SS] [LEVEL] message
```

## Usage

1. Run `setup.sh` to initialize the environment.
2. Execute `maintenance_suite.sh` to open the interactive menu.
3. Choose an operation from the menu to perform maintenance tasks.
