#!/bin/bash
# pre-tool-network-deny.sh — fires at PreToolUse with matcher: WebFetch|WebSearch|http_get|http_post|fetch_url
# Purpose: HARD BLOCK any network-touching tool during air-gap mode
# Blocking — exit non-zero to refuse the tool call

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
DATE=$(date +%F)

# Allow-list — tools that LOOK networky but are actually local
ALLOWED=("Bash" "bash" "shell" "Read" "Write" "Edit")
for ok in "${ALLOWED[@]}"; do
    [ "$TOOL" = "$ok" ] && exit 0
done

# Deny-list — tools known to hit network
DENIED=("WebFetch" "WebSearch" "fetch_url" "http_get" "http_post" "curl_remote" "browser_navigate")
for bad in "${DENIED[@]}"; do
    if [ "$TOOL" = "$bad" ]; then
        # Audit log the attempt
        mkdir -p ~/Research/audit/$DATE
        echo "{\"event\":\"network_tool_blocked\",\"ts\":\"$(date -Iseconds)\",\"tool\":\"$TOOL\",\"session\":\"$SESSION_ID\"}" \
            >> ~/Research/audit/$DATE/events.jsonl

        # Emit refusal
        cat <<EOF >&2

🚫 BLOCKED: Tool '$TOOL' requires network access.

This session is in air-gapped Research Mode. Network tools are denied.

Alternatives:
  • For literature: use leann-search or paperqa-summarize (local Zotero corpus)
  • For guidelines: use guideline-cache-query (cached MAGICapp/ISPAD/ESPE/ÇEDD)
  • For genuine internet need: invoke request-momentary-internet skill,
    which prompts user to lift air-gap briefly, audit-logged

EOF
        exit 1   # blocks the tool call
    fi
done

# Bash commands that look like network access
if [ "$TOOL" = "Bash" ]; then
    CMD=$(echo "$TOOL_INPUT" | jq -r '.command // empty')
    if echo "$CMD" | grep -qE '\b(curl|wget|http|pip install|npm install|brew install|git clone|git pull|git push|git fetch)\b'; then
        # Allow localhost-only operations
        if echo "$CMD" | grep -qE 'localhost|127\.0\.0\.1|::1'; then
            exit 0
        fi
        mkdir -p ~/Research/audit/$DATE
        echo "{\"event\":\"network_cmd_blocked\",\"ts\":\"$(date -Iseconds)\",\"cmd\":\"$(echo "$CMD" | head -c 100)\",\"session\":\"$SESSION_ID\"}" \
            >> ~/Research/audit/$DATE/events.jsonl

        cat <<EOF >&2

🚫 BLOCKED: Bash command appears to access network.
   Command: $(echo "$CMD" | head -c 150)

   If you really need this, invoke the request-momentary-internet skill.

EOF
        exit 1
    fi
fi

# Default allow
exit 0
