#!/bin/bash
# user-prompt-phi-warn.sh — fires at UserPromptSubmit
# Purpose: regex-scan user prompts for PHI patterns; warn before submission
# Non-blocking (exit 0) — just injects warning context

INPUT=$(cat)
USER_MSG=$(echo "$INPUT" | jq -r '.user_message // empty')
DATE=$(date +%F)

# Quick wins: short messages can't contain PHI in any volume
[ ${#USER_MSG} -lt 20 ] && exit 0

# ── Regex patterns ─────────────────────────────────────────────────────
WARNINGS=()

# TCKN (Turkish national ID — 11 digits starting 1-9)
if echo "$USER_MSG" | grep -qE '\b[1-9][0-9]{10}\b'; then
    WARNINGS+=("Possible TCKN (11-digit ID) detected")
fi

# MRN (6-8 digit medical record number)
if echo "$USER_MSG" | grep -qE '\b(MRN|protokol|protocol)[: #]?[0-9]{6,8}\b'; then
    WARNINGS+=("Possible MRN with explicit label")
fi

# Exact dates with day precision
if echo "$USER_MSG" | grep -qE '\b[0-9]{1,2}[./-][0-9]{1,2}[./-](19|20)[0-9]{2}\b'; then
    WARNINGS+=("Exact date with day precision (consider relative dates)")
fi

# Turkish phone numbers
if echo "$USER_MSG" | grep -qE '(\+90|0)?5[0-9]{2}[ ]?[0-9]{3}[ ]?[0-9]{2}[ ]?[0-9]{2}'; then
    WARNINGS+=("Possible Turkish phone number")
fi

# Email addresses
if echo "$USER_MSG" | grep -qE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'; then
    WARNINGS+=("Email address in prompt")
fi

# ── If nothing flagged, silent exit ────────────────────────────────────
[ ${#WARNINGS[@]} -eq 0 ] && exit 0

# ── Emit warning ───────────────────────────────────────────────────────
cat <<EOF

⚠️  PHI PATTERN DETECTED IN PROMPT — INJECTED REMINDER
$(printf '   • %s\n' "${WARNINGS[@]}")

Reminder:
  • This session is air-gapped — nothing leaves your machine
  • But: copy-pasting model outputs to email/slides WILL leak PHI
  • Consider using \`output-scrub\` before any export
  • IRB project: $(cat ~/Research/audit/$DATE/irb-id.txt 2>/dev/null || echo "(not pinned)")

EOF

# Audit log
mkdir -p ~/Research/audit/$DATE
echo "{\"event\":\"phi_warning\",\"ts\":\"$(date -Iseconds)\",\"warnings\":${#WARNINGS[@]}}" \
    >> ~/Research/audit/$DATE/events.jsonl

exit 0
