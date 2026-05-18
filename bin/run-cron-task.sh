#!/bin/bash
# run-cron-task.sh — dispatcher for cron task SKILL.md files
# Called by launchctl-managed plists via install-cron.sh
#
# Usage: run-cron-task.sh <task-name>
# e.g.:  run-cron-task.sh airgap-nightly-handoff
#
# Reads the SKILL.md for the task, extracts bash code blocks from the
# "## Procedure" section, executes them, logs everything.

set -uo pipefail

TASK="${1:-}"
[ -z "$TASK" ] && { echo "Usage: $0 <task-name>"; exit 1; }

# Source setup-env for $LOCAL_AGENT_SETUP + $LLAMA_PORT etc.
[ -f ~/.research/setup-env ] && source ~/.research/setup-env

# Auto-detect repo if env var unset
if [ -z "${LOCAL_AGENT_SETUP:-}" ]; then
    for candidate in ~/local-agent-setup ~/Projects/local-agent-setup ~/code/local-agent-setup ~/Documents/local-agent-setup; do
        if [ -f "$candidate/SETUP_PROMPT.md" ]; then
            export LOCAL_AGENT_SETUP=$(cd "$candidate" && pwd)
            break
        fi
    done
fi
[ -z "${LOCAL_AGENT_SETUP:-}" ] && { echo "FAIL: \$LOCAL_AGENT_SETUP not set"; exit 1; }

# Find the task's SKILL.md
SKILL_FILE=""
for dir in "$LOCAL_AGENT_SETUP/cron/daily/$TASK" "$LOCAL_AGENT_SETUP/cron/weekly/$TASK"; do
    if [ -f "$dir/SKILL.md" ]; then
        SKILL_FILE="$dir/SKILL.md"
        break
    fi
done
[ -z "$SKILL_FILE" ] && { echo "FAIL: SKILL.md not found for task '$TASK'"; exit 1; }

# Log location
LOG_DIR=~/.research/logs
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/cron-$TASK-$(date +%F).log"

{
    echo "=== run-cron-task.sh: $TASK ==="
    echo "  started: $(date -Iseconds)"
    echo "  SKILL.md: $SKILL_FILE"
    echo ""

    # Extract bash code blocks from the SKILL.md "## Procedure" section.
    # Then pipe them into bash.
    python3 - "$SKILL_FILE" <<'PYEOF'
import sys, re

with open(sys.argv[1]) as f:
    md = f.read()

# Find the "## Procedure" section (or whole file as fallback)
m = re.search(r'## Procedure\s*\n(.*?)(?=\n## |\Z)', md, re.DOTALL)
section = m.group(1) if m else md

# Extract all ```bash ... ``` blocks
blocks = re.findall(r'```(?:bash|sh)?\s*\n(.*?)```', section, re.DOTALL)

# Print blocks separated by newlines, so bash interprets them as one script
for block in blocks:
    print(block)
PYEOF
} 2>&1 | tee -a "$LOG_FILE" | bash 2>&1 | tee -a "$LOG_FILE"

EXIT_CODE=${PIPESTATUS[1]:-0}

{
    echo ""
    echo "  ended: $(date -Iseconds)"
    echo "  exit_code: $EXIT_CODE"
    echo ""
} >> "$LOG_FILE"

# Append to events.jsonl
mkdir -p ~/Research/audit/$(date +%F)
echo "{\"event\":\"cron_task\",\"task\":\"$TASK\",\"ts\":\"$(date -Iseconds)\",\"exit_code\":$EXIT_CODE,\"log\":\"$LOG_FILE\"}" \
    >> ~/Research/audit/$(date +%F)/events.jsonl

exit $EXIT_CODE
