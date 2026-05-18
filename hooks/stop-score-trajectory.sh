#!/bin/bash
# stop-score-trajectory.sh — fires at Stop event
# Purpose: if session edited a manuscript file, run score-trajectory; flag regressions
# Non-blocking (exit 0)

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
DATE=$(date +%F)

[ -z "$CWD" ] && exit 0

# Check if any manuscript file was modified in this session window
# (compare with the audit ledger; look for Edit/Write events on .md/.qmd/.tex)
LEDGER=~/Research/audit/$DATE/session-$SESSION_ID.ledger.jsonl
[ ! -f "$LEDGER" ] && exit 0

MANUSCRIPT_EDITS=$(grep -E '"tool":"(Edit|Write)"' "$LEDGER" 2>/dev/null | \
                   grep -cE '\\.(md|qmd|tex)"' || echo 0)

[ "$MANUSCRIPT_EDITS" -eq 0 ] && exit 0

# Identify which files were touched
TOUCHED=$(grep -E '"tool":"(Edit|Write)"' "$LEDGER" | \
          python3 -c "
import json, sys
files = set()
for line in sys.stdin:
    try:
        d = json.loads(line)
        path = d.get('input',{}).get('file_path','')
        if path and path.endswith(('.md','.qmd','.tex')) and 'manuscript' in path.lower():
            files.add(path)
    except: pass
for f in files: print(f)
" 2>/dev/null)

[ -z "$TOUCHED" ] && exit 0

# For each touched manuscript, take a snapshot (will be analyzed by weekly score-trajectory cron)
SNAPSHOT_DIR=~/.agents/state/manuscript-snapshots/$DATE
mkdir -p "$SNAPSHOT_DIR"
while IFS= read -r f; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    cp "$f" "$SNAPSHOT_DIR/${SESSION_ID}-${name}"
done <<< "$TOUCHED"

# Notify
cat <<EOF

📝 Manuscript edits detected this session — snapshot taken.
Files:
$(echo "$TOUCHED" | sed 's/^/  - /')

Score-trajectory will analyze regressions in the next weekly cron run.
EOF

exit 0
