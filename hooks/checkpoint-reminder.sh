#!/bin/bash
# checkpoint-reminder.sh — fires at PostToolUse (matcher: *)
# Purpose: count tool calls; suggest passport emit + checkpoint after threshold
# Non-blocking (exit 0)

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
[ -z "$SESSION_ID" ] && exit 0

COUNTER_FILE=/tmp/checkpoint-$SESSION_ID.count
COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

# Thresholds for soft reminders
# Karpathy 12-rule, rule #10: "Checkpoint every significant step"
case $COUNT in
    20|40|60|80|100)
        cat <<EOF

🔖 Checkpoint reminder ($COUNT tool calls this session)

Consider:
  • Running material-passport-emit if you've completed a logical stage
  • The next compaction will be smoother with a passport in hand
  • Rule #10 (Karpathy): "Checkpoint every significant step. Claude finished
    steps 5 and 6 on top of a broken state from step 4. Nobody noticed for an hour."

EOF
        ;;
esac

exit 0
