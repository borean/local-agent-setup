#!/bin/bash
# install-cron.sh — install a cron task as launchctl plist on macOS
# Usage: install-cron.sh --task airgap-nightly-handoff --schedule daily-03

set -euo pipefail

TASK=""
SCHEDULE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --task) TASK="$2"; shift 2 ;;
        --schedule) SCHEDULE="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

[ -z "$TASK" ] && { echo "FAIL: --task required"; exit 1; }
[ -z "$SCHEDULE" ] && { echo "FAIL: --schedule required (daily-03 | weekly-sun-04)"; exit 1; }

# Locate the cron task SKILL.md
TASK_DIR=""
for candidate in ~/local-agent-setup/cron/daily/$TASK ~/local-agent-setup/cron/weekly/$TASK; do
    if [ -d "$candidate" ]; then TASK_DIR="$candidate"; break; fi
done
[ -z "$TASK_DIR" ] && { echo "FAIL: task $TASK not found in cron/daily or cron/weekly"; exit 1; }

# Calendar interval per schedule
case "$SCHEDULE" in
    daily-03)
        HOUR=3
        MINUTE=$(( RANDOM % 45 ))      # spread tasks 03:00-03:45
        DAY_KEY=""
        ;;
    weekly-sun-04)
        HOUR=4
        MINUTE=$(( RANDOM % 60 ))      # 04:00-04:59 Sunday
        DAY_KEY="<key>Weekday</key><integer>0</integer>"  # 0 = Sunday in launchd
        ;;
    *)
        echo "FAIL: unknown schedule $SCHEDULE"; exit 1 ;;
esac

# Write plist
PLIST=~/Library/LaunchAgents/com.bora.cron.${TASK}.plist
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.bora.cron.${TASK}</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>-c</string>
    <string>cd $HOME && ~/.agents/bin/run-cron-task.sh "$TASK"</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key><integer>${HOUR}</integer>
    <key>Minute</key><integer>${MINUTE}</integer>
    ${DAY_KEY}
  </dict>
  <key>StandardOutPath</key><string>$HOME/.research/logs/cron-${TASK}.log</string>
  <key>StandardErrorPath</key><string>$HOME/.research/logs/cron-${TASK}.err</string>
  <key>RunAtLoad</key><false/>
</dict>
</plist>
EOF

# Load it
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"

echo "✓ Installed: com.bora.cron.${TASK} (runs ${SCHEDULE} at ${HOUR}:$(printf '%02d' $MINUTE))"
