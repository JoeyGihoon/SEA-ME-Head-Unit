#!/bin/bash
set -euo pipefail

APP_BIN="${APP_BIN:-/home/yg/Head-Unit-Team1/yocto/meta-ui/recipes-ic/files/IC_someip/IC_someip/build/IC_someip}"
LOG_FILE="${LOG_FILE:-/boot/ic_someip.log}"

if [ ! -x "$APP_BIN" ]; then
  echo "App not found or not executable: $APP_BIN" >&2
  exit 1
fi

# Append log header
printf '\n==== %s ====\n' "$(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"

# Redirect stdout/stderr to log and run
exec >> "$LOG_FILE" 2>&1
exec "$APP_BIN"
