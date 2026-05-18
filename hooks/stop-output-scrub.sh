#!/bin/bash
# stop-output-scrub.sh — fires at Stop event
# Purpose: run output-scrub on the last assistant turn before user copies anything out
# Non-blocking (exit 0) — emits a scrubbed preview alongside

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
LAST_TURN=$(echo "$INPUT" | jq -r '.last_assistant_message // empty')
DATE=$(date +%F)

[ -z "$LAST_TURN" ] && exit 0
[ ${#LAST_TURN} -lt 100 ] && exit 0   # skip short turns

# Quick regex pass — if nothing flagged, exit silently
HAS_PHI=$(echo "$LAST_TURN" | python3 -c "
import sys, re
text = sys.stdin.read()
patterns = {
    'TCKN': r'\b[1-9][0-9]{10}\b',
    'MRN': r'\b(MRN|protokol)[: #]?[0-9]{6,8}\b',
    'exact_date': r'\b[0-9]{1,2}[./-][0-9]{1,2}[./-](19|20)[0-9]{2}\b',
    'phone': r'(\+90|0)?5[0-9]{2}[ ]?[0-9]{3}[ ]?[0-9]{2}[ ]?[0-9]{2}',
    'email': r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
}
flagged = [name for name, p in patterns.items() if re.search(p, text, re.IGNORECASE)]
print(','.join(flagged))
")

[ -z "$HAS_PHI" ] && exit 0

# Run scrub via the output-scrub skill if available; else inline scrub
SCRUBBED=$(echo "$LAST_TURN" | python3 -c "
import sys, re
t = sys.stdin.read()
t = re.sub(r'\b[1-9][0-9]{10}\b', '[TCKN]', t)
t = re.sub(r'\b(MRN|protokol)[: #]?[0-9]{6,8}\b', '\\\\1: [MRN]', t, flags=re.IGNORECASE)
t = re.sub(r'\b[0-9]{1,2}[./-][0-9]{1,2}[./-](19|20)[0-9]{2}\b', '[DATE]', t)
t = re.sub(r'(\+90|0)?5[0-9]{2}[ ]?[0-9]{3}[ ]?[0-9]{2}[ ]?[0-9]{2}', '[PHONE]', t)
t = re.sub(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', '[EMAIL]', t)
sys.stdout.write(t)
")

# Audit
mkdir -p ~/Research/audit/$DATE
echo "{\"event\":\"output_scrubbed\",\"ts\":\"$(date -Iseconds)\",\"patterns\":\"$HAS_PHI\",\"session\":\"$SESSION_ID\"}" \
    >> ~/Research/audit/$DATE/events.jsonl

# Emit a notice
cat <<EOF

────── OUTPUT SCRUB ALERT ──────
Patterns detected in this turn: $HAS_PHI

Before copying this output to email/slide/external doc,
review the scrubbed version below:

----- SCRUBBED PREVIEW -----
$SCRUBBED
----------------------------

Original turn is in the ledger (audit-only).
Use the scrubbed version for any external destination.
──────────────────────────────

EOF

exit 0
