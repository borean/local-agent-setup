#!/bin/bash
# session-end-passport.sh — fires at SessionEnd event
# Purpose: emit Material Passport, write meta.yaml, snapshot final state
# Best-effort (exit 0); SessionEnd can't block

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
DATE=$(date +%F)
AUDIT_DIR=~/Research/audit/$DATE

[ -z "$SESSION_ID" ] && exit 0
mkdir -p "$AUDIT_DIR"

# ── 1. Locate this session's ledger ────────────────────────────────────
LEDGER="$AUDIT_DIR/session-$SESSION_ID.ledger.jsonl"

# If no ledger, nothing to emit
[ ! -f "$LEDGER" ] && exit 0

# ── 2. Strip volatile fields, canonicalize, hash ───────────────────────
HASH=$(python3 <<PYEOF
import json, hashlib, sys
try:
    with open("$LEDGER") as f:
        entries = [json.loads(line) for line in f if line.strip()]
    # Strip sub-second timestamps and session UUIDs
    for e in entries:
        if 'ts' in e:
            e['ts'] = e['ts'].split('.')[0]  # drop sub-second
        e.pop('session_id', None)
    # JCS-canonicalize (sorted keys, no whitespace, UTF-8)
    canonical = json.dumps(entries, sort_keys=True, separators=(',',':'), ensure_ascii=False)
    h = hashlib.sha256(canonical.encode('utf-8')).hexdigest()
    print(h)
except Exception as e:
    sys.exit(1)
PYEOF
)

[ -z "$HASH" ] && exit 0

# ── 3. Snapshot to passports/ ──────────────────────────────────────────
mkdir -p ~/.agents/state/passports
cp "$LEDGER" ~/.agents/state/passports/$HASH.json

# ── 4. Write meta.yaml ─────────────────────────────────────────────────
cat > "$AUDIT_DIR/session-$SESSION_ID.meta.yaml" <<EOF
session_id: $SESSION_ID
date: $DATE
ended_at: $(date -Iseconds)
cwd: $CWD
passport_hash: $HASH
ledger_entries: $(wc -l < "$LEDGER")
EOF

# ── 5. Update last-passport pointer ────────────────────────────────────
echo "$HASH" > ~/.agents/state/last-passport.txt

# ── 6. Tell user (printed to whatever channel SessionEnd outputs to) ───
echo ""
echo "[PASSPORT-EMITTED hash=$HASH]"
echo "To resume in a fresh session, paste: resume_from_passport=$HASH"
echo ""

exit 0
