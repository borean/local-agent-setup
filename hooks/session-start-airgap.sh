#!/bin/bash
# session-start-airgap.sh — fires at SessionStart event
# Purpose: verify air-gap state, load voice profile, show resumable passport, indicate model
# Non-blocking (exit 0) — injects context, doesn't refuse session start

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
DATE=$(date +%F)

mkdir -p ~/Research/audit/$DATE

# ── 1. Network state check ─────────────────────────────────────────────
# Quick tcpdump sample (no sudo needed for read-only count via netstat)
EXT_CONNS=$(netstat -an 2>/dev/null | grep -c 'ESTABLISHED' || echo 0)
EXT_CONNS=$((EXT_CONNS - $(netstat -an 2>/dev/null | grep -c '127.0.0.1.*ESTABLISHED' || echo 0)))
NET_STATE="unknown"
[ "$EXT_CONNS" -eq 0 ] && NET_STATE="green"
[ "$EXT_CONNS" -gt 0 ] && [ "$EXT_CONNS" -lt 3 ] && NET_STATE="yellow"
[ "$EXT_CONNS" -ge 3 ] && NET_STATE="red"

# ── 2. Little Snitch profile (if installed) ────────────────────────────
LS_PROFILE="unknown"
if command -v littlesnitch >/dev/null 2>&1; then
    LS_PROFILE=$(littlesnitch profile 2>/dev/null || echo "unknown")
fi

# ── 3. Resumable passport check ────────────────────────────────────────
LAST_PASSPORT=""
if [ -f ~/.agents/state/last-passport.txt ]; then
    LAST_PASSPORT=$(head -1 ~/.agents/state/last-passport.txt)
fi

# ── 4. Voice profile presence ──────────────────────────────────────────
VOICE_LOADED="no"
VOICE_FILE=~/.agents/system-prompts/bora-voice.md
[ -f "$VOICE_FILE" ] && VOICE_LOADED="yes"

# ── 5. Currently loaded llama-server model ─────────────────────────────
CURRENT_MODEL="unknown"
if curl -s --max-time 1 http://localhost:11434/v1/models >/dev/null 2>&1; then
    CURRENT_MODEL=$(curl -s --max-time 1 http://localhost:11434/v1/models | jq -r '.data[0].id // "unknown"')
fi

# ── 6. Emit context block to model ─────────────────────────────────────
cat <<EOF

────── SESSION CONTEXT ───────
Date: $DATE  |  Session: $SESSION_ID
Network state: $NET_STATE  ($EXT_CONNS external connections)
Little Snitch: $LS_PROFILE
Loaded model: $CURRENT_MODEL  (on :11434)
Voice profile: $VOICE_LOADED
$([ -n "$LAST_PASSPORT" ] && echo "Resumable passport available: $LAST_PASSPORT")
$([ "$NET_STATE" = "red" ] && echo "⚠️  EXTERNAL CONNECTIONS DETECTED. Verify Research Mode.")
$([ "$VOICE_LOADED" = "no" ] && echo "ℹ️  No voice profile. Run style-calibration skill once on your past papers.")
─────────────────────────────

EOF

# ── 7. Audit log ───────────────────────────────────────────────────────
echo "{\"event\":\"session_start\",\"ts\":\"$(date -Iseconds)\",\"session\":\"$SESSION_ID\",\"net\":\"$NET_STATE\",\"model\":\"$CURRENT_MODEL\"}" \
    >> ~/Research/audit/$DATE/events.jsonl

exit 0
