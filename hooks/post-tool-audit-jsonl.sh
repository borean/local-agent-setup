#!/bin/bash
# post-tool-audit-jsonl.sh — fires at PostToolUse for ALL tools (matcher: *)
# Purpose: append every tool call to today's session JSONL audit log
# Non-blocking (exit 0) — append-only

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -c '.tool_input // {}')
TOOL_RESULT_SUMMARY=$(echo "$INPUT" | jq -r '.tool_result_summary // .tool_response // "" | tostring | .[0:500]')
DATE=$(date +%F)

[ -z "$SESSION_ID" ] && exit 0
[ -z "$TOOL" ] && exit 0

AUDIT_DIR=~/Research/audit/$DATE
mkdir -p "$AUDIT_DIR"
LEDGER="$AUDIT_DIR/session-$SESSION_ID.ledger.jsonl"

# Sanitize tool_input — strip any obvious PHI before persisting to disk
SANITIZED=$(echo "$TOOL_INPUT" | python3 -c "
import json, sys, re
try:
    data = json.load(sys.stdin)
    def scrub(v):
        if isinstance(v, str):
            v = re.sub(r'\b[1-9][0-9]{10}\b', '[TCKN]', v)
            v = re.sub(r'\b(MRN|protokol)[: #]?[0-9]{6,8}\b', '\\\\1: [MRN]', v, flags=re.IGNORECASE)
            v = re.sub(r'\b[0-9]{1,2}[./-][0-9]{1,2}[./-](19|20)[0-9]{2}\b', '[DATE]', v)
            v = re.sub(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', '[EMAIL]', v)
            return v[:1000]  # cap length
        if isinstance(v, dict): return {k: scrub(vv) for k,vv in v.items()}
        if isinstance(v, list): return [scrub(x) for x in v]
        return v
    print(json.dumps(scrub(data), ensure_ascii=False))
except: print('{}')
")

# Append entry
echo "{\"ts\":\"$(date -Iseconds)\",\"event\":\"tool_use\",\"tool\":\"$TOOL\",\"input\":$SANITIZED,\"result_summary\":$(echo "$TOOL_RESULT_SUMMARY" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || echo '""')}" \
    >> "$LEDGER"

exit 0
