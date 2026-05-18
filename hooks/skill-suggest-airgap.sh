#!/bin/bash
# skill-suggest-airgap.sh — fires at UserPromptSubmit
# Purpose: suggest relevant skills based on prompt keywords, filtered to airgap-ok or local-with-cache
# Non-blocking (exit 0), <200ms — keyword regex only, no LLM

INPUT=$(cat)
USER_MSG=$(echo "$INPUT" | jq -r '.user_message // empty')
[ ${#USER_MSG} -lt 15 ] && exit 0

LOW=$(echo "$USER_MSG" | tr '[:upper:]' '[:lower:]')
MATCHES=()

# ── Research / Literature ──────────────────────────────────────────────
echo "$LOW" | grep -qE 'literature|systematic review|meta.analys|prisma|cochrane' && \
    MATCHES+=("research/literature/storm-systematic-review")
echo "$LOW" | grep -qE 'find paper|search.*paper|relevant article|leann' && \
    MATCHES+=("research/literature/leann-search")
echo "$LOW" | grep -qE 'summarize paper|read.*paper|paper summary' && \
    MATCHES+=("research/literature/paperqa-summarize")
echo "$LOW" | grep -qE 'synthesi|evidence summary|narrative review' && \
    MATCHES+=("research/literature/paperqa-synthesize")
echo "$LOW" | grep -qE 'verify citation|check.*ref|citation.*correct' && \
    MATCHES+=("research/literature/paperqa-verify-citation")
echo "$LOW" | grep -qE 'guideline|ispad|espe|cedd|magicapp|recommendation' && \
    MATCHES+=("research/literature/guideline-cache-query")

# ── Statistics ─────────────────────────────────────────────────────────
echo "$LOW" | grep -qE 'csv|excel|dataset|data dictionary' && \
    MATCHES+=("research/statistics/data-dictionary")
echo "$LOW" | grep -qE 'which test|t.?test|anova|chi.?square|regression' && \
    MATCHES+=("research/statistics/statistical-test-picker")
echo "$LOW" | grep -qE 'sample size|power calc|effect size' && \
    MATCHES+=("research/statistics/power-analysis")
echo "$LOW" | grep -qE 'analysis plan|study design|hypothesis' && \
    MATCHES+=("research/statistics/analysis-plan")
echo "$LOW" | grep -qE 'run analysis|table.?one|baseline characteristic' && \
    MATCHES+=("research/statistics/analysis-run" "research/statistics/table-one-build")

# ── Manuscript ─────────────────────────────────────────────────────────
echo "$LOW" | grep -qE 'outline|structure.*paper|imrad' && \
    MATCHES+=("research/manuscript/outline-build")
echo "$LOW" | grep -qE 'draft|write.*section|introduction|methods' && \
    MATCHES+=("research/manuscript/draft-write")
echo "$LOW" | grep -qE 'reviewer|response.*review|rebut' && \
    MATCHES+=("research/manuscript/response-to-reviewer")
echo "$LOW" | grep -qE 'ai.?slop|ai.?writing|delve|moreover' && \
    MATCHES+=("research/manuscript/writing-quality-check")
echo "$LOW" | grep -qE 'fabricat|hallucin|made.up.method' && \
    MATCHES+=("research/manuscript/anti-leakage")

# ── Visualization ──────────────────────────────────────────────────────
echo "$LOW" | grep -qE 'plot|chart|figure|visualiz' && \
    MATCHES+=("research/visualization/chart-spec")
echo "$LOW" | grep -qE 'forest plot|meta.analys' && \
    MATCHES+=("research/visualization/forest-plot")
echo "$LOW" | grep -qE 'km|kaplan|survival|hazard' && \
    MATCHES+=("research/visualization/km-curve")
echo "$LOW" | grep -qE 'consort|flow.*patient|patient.*flow' && \
    MATCHES+=("research/visualization/patient-flow-sankey")

# ── Medical domain ─────────────────────────────────────────────────────
echo "$LOW" | grep -qE 'growth chart|neyzi|sds|percentile' && \
    MATCHES+=("research/medical-domain/pediatric-references")
echo "$LOW" | grep -qE 'dose|dosing|mg/kg|steroid.*equivalent' && \
    MATCHES+=("research/medical-domain/dosing-converter")

# ── Peer review / GRADE ────────────────────────────────────────────────
echo "$LOW" | grep -qE 'risk of bias|rob.?2|robins' && \
    MATCHES+=("research/peer-review/rob-assessor")
echo "$LOW" | grep -qE 'grade|evidence.*quality|downgrade|upgrade' && \
    MATCHES+=("research/peer-review/grade-evidence")
echo "$LOW" | grep -qE 'devil|hostile review|stress.*test|critique' && \
    MATCHES+=("research/peer-review/devils-advocate")

# ── Coding ─────────────────────────────────────────────────────────────
echo "$LOW" | grep -qE 'refactor|tech debt|clean up' && \
    MATCHES+=("coding/bora/zero-tech-debt")
echo "$LOW" | grep -qE 'debug|error|bug|stuck' && \
    MATCHES+=("coding/mattpocock/diagnose" "coding/google/debugging-and-error-recovery")
echo "$LOW" | grep -qE 'plan|task.*break|decompose' && \
    MATCHES+=("coding/google/planning-and-task-breakdown")
echo "$LOW" | grep -qE 'test.*driven|tdd' && \
    MATCHES+=("coding/google/test-driven-development")

# ── Meta / shared ──────────────────────────────────────────────────────
echo "$LOW" | grep -qE 'resume|continue.*session|passport' && \
    MATCHES+=("shared/material-passport-resume")
echo "$LOW" | grep -qE 'safe|airgap|network.*check' && \
    MATCHES+=("shared/network-mode-toggle")
echo "$LOW" | grep -qE 'install.*package|pip install|need.*library' && \
    MATCHES+=("shared/request-momentary-internet")

# ── Emit suggestions ───────────────────────────────────────────────────
[ ${#MATCHES[@]} -eq 0 ] && exit 0

# Dedup
UNIQUE_MATCHES=$(printf '%s\n' "${MATCHES[@]}" | sort -u)

cat <<EOF

💡 Relevant skills for this task:
$(echo "$UNIQUE_MATCHES" | sed 's|^|  • |')

(All shown are airgap-ok or local-with-cache.)

EOF

exit 0
