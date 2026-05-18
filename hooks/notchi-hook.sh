#!/bin/bash
# notchi-hook.sh — fires at every event (PermissionRequest, PostToolUse, PreCompact, PreToolUse,
#                  SessionEnd, SessionStart, Stop, SubagentStop, UserPromptSubmit)
# Purpose: desktop notification on MacBook notch (per an optional MacBook notch-display integration)
# Non-blocking (exit 0)
# NOTE: this is the air-gap-compatible adaptation of the user's existing notchi-hook.sh (optional integration).
# It does NOT make network calls. Pure local notification.

INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.event // .hook_event // "unknown"')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

# Skip if notchi-related CLI tool isn't installed (graceful degradation)
command -v notchi >/dev/null 2>&1 || exit 0

# Map event → notification text
case "$EVENT" in
    SessionStart)
        notchi "🟢 Research session started"
        ;;
    SessionEnd)
        notchi "🔒 Research session ended — passport emitted"
        ;;
    PreCompact)
        notchi "⚠️ Context compaction — passport saved first"
        ;;
    Stop)
        # Only notify if substantive (skip silent stops)
        LAST_LEN=$(echo "$INPUT" | jq -r '.last_assistant_message // ""' | wc -c)
        [ "$LAST_LEN" -gt 200 ] && notchi "✓ Turn complete"
        ;;
    PostToolUse)
        TOOL=$(echo "$INPUT" | jq -r '.tool_name // ""')
        # Only notify for "significant" tools
        case "$TOOL" in
            Skill|Write|Edit) notchi "→ $TOOL" ;;
        esac
        ;;
esac

exit 0
