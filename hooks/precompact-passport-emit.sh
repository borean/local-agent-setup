#!/bin/bash
# precompact-passport-emit.sh — fires at PreCompact event
# Purpose: force passport emission BEFORE context is compacted
# Blocking — refuses compaction if ledger not yet hashed

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
DATE=$(date +%F)
LEDGER=~/Research/audit/$DATE/session-$SESSION_ID.ledger.jsonl

# If no ledger yet, allow compaction (nothing to lose)
[ ! -f "$LEDGER" ] && exit 0

# Quick hash + emit (same logic as session-end-passport, abbreviated)
HASH=$(python3 -c "
import json, hashlib
with open('$LEDGER') as f: entries=[json.loads(l) for l in f if l.strip()]
for e in entries:
    if 'ts' in e: e['ts'] = e['ts'].split('.')[0]
    e.pop('session_id', None)
print(hashlib.sha256(json.dumps(entries, sort_keys=True, separators=(',',':'), ensure_ascii=False).encode()).hexdigest())
" 2>/dev/null)

[ -z "$HASH" ] && exit 0

mkdir -p ~/.agents/state/passports
cp "$LEDGER" ~/.agents/state/passports/$HASH.json
echo "$HASH" > ~/.agents/state/last-passport.txt

cat <<EOF

⚠️  CONTEXT COMPACTION INCOMING — PASSPORT EMITTED FIRST

[PASSPORT-RESET: hash=$HASH stage=pre-compact]

Compaction will lose conversation tokens. To resume the session cleanly:
  1. Let compaction proceed OR stop here
  2. In a fresh session paste: resume_from_passport=$HASH

EOF

# Don't block — let user decide. Just inform.
exit 0
