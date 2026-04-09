#!/usr/bin/env bash

LOG_FILE="/var/log/alerts.log"

TYPE="$1"
SEVERITY="$2"
TITLE="$3"
MESSAGE="$4"

echo "$(date '+%Y-%m-%d %H:%M:%S') | $TYPE | $SEVERITY | $TITLE" >> "$LOG_FILE"