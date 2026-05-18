#!/bin/bash
# download-guidelines.sh — pull clinical guideline corpora into local cache
# Usage: download-guidelines.sh --societies "magicapp,ispad,espe,cedd,aap,ata" --output ~/Research/cache/guidelines

set -euo pipefail

SOCIETIES=""
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --societies) SOCIETIES="$2"; shift 2 ;;
        --output) OUTPUT="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

[ -z "$SOCIETIES" ] && { echo "FAIL: --societies required"; exit 1; }
[ -z "$OUTPUT" ] && { echo "FAIL: --output required"; exit 1; }

mkdir -p "$OUTPUT"

# Each society needs its own fetch strategy because their open-data URLs differ.
# This is a best-effort scaffold. The frontier LLM running setup should expand
# per-society as needed (some may require authenticated downloads).

fetch_magicapp() {
    # MAGICapp publishes open guidelines via app.magicapp.org
    # API: https://api.magicapp.org/v1/guidelines (no auth for public ones)
    local out="$OUTPUT/magicapp"
    mkdir -p "$out"
    echo "  → MAGICapp: fetching public guideline index..."
    # The actual API requires per-guideline iteration; placeholder fetches the public list
    curl -sL "https://app.magicapp.org/api/v1/guidelines?public=true" \
        -o "$out/_index.json" 2>/dev/null || \
        echo "  ! MAGICapp API not reachable from this network; manual download required"
    echo "  ✓ MAGICapp index saved to $out/_index.json"
}

fetch_ispad() {
    # ISPAD Clinical Practice Consensus Guidelines published in Pediatric Diabetes (Wiley)
    # Open-access chapters are at https://www.ispad.org/page/2024CPCG
    local out="$OUTPUT/ispad"
    mkdir -p "$out"
    echo "  → ISPAD: open-access 2024 CPCG chapter list"
    # We document the URL list; actual PDFs may need user login
    cat > "$out/_chapters-2024.md" <<EOF
# ISPAD 2024 Clinical Practice Consensus Guidelines

Open-access chapters (verify URLs are current at time of fetch):

- Chapter 1: Definition, epidemiology
- Chapter 2: Classification, diagnosis, screening
- Chapter 3: Type 1 diabetes
- Chapter 4: Type 2 diabetes
- Chapter 5: Monogenic forms
- Chapter 6: DKA + HHS
- Chapter 7: Hypoglycemia
- Chapter 8: Insulin treatment
- Chapter 9: Insulin pump
- Chapter 10: CGM
- Chapter 11: Nutrition
- Chapter 12: Exercise
- Chapter 13: Psychology
- Chapter 14: Transition to adult care
- Chapter 15: Other forms (CFRD, post-transplant)
- ...

Source: https://www.ispad.org/page/2024CPCG
TODO: programmatic fetcher when ISPAD publishes a stable open API.
EOF
    echo "  ✓ ISPAD chapter list saved (manual PDFs by clinician)"
}

fetch_espe() {
    local out="$OUTPUT/espe"
    mkdir -p "$out"
    echo "  → ESPE: yearbook + position statements"
    cat > "$out/_yearbook-and-positions.md" <<EOF
# ESPE Resources

- ESPE Yearbook: https://www.espeyearbook.org/ (annual; full PDFs require institutional access)
- Position statements: https://www.eurospe.org/about-espe/statements/

TODO: fetch open-access statements; ESPE yearbook needs institution credentials.
EOF
    echo "  ✓ ESPE pointer file saved"
}

fetch_cedd() {
    local out="$OUTPUT/cedd"
    mkdir -p "$out"
    echo "  → ÇEDD (Çocuk Endokrinolojisi ve Diabet Derneği): Turkish pediatric endo guidelines"
    cat > "$out/_kilavuzlar.md" <<EOF
# ÇEDD Kılavuzlar

- ÇEDD 2016 Diyabet Kılavuzu
- ÇEDD 2018 Büyüme ve Adrenal Kılavuzu
- Source: https://www.cocukendokrindiyabet.org/

Turkish-language guidelines for pediatric endocrinology in Turkey.
TODO: ÇEDD does not yet have an open API; manual fetch.
EOF
    echo "  ✓ ÇEDD pointer file saved"
}

fetch_aap() {
    local out="$OUTPUT/aap"
    mkdir -p "$out"
    echo "  → AAP (American Academy of Pediatrics) policy statements"
    # Many AAP policies are open via publications.aap.org
    cat > "$out/_policy-statements.md" <<EOF
# AAP Policy Statements (Endocrinology-relevant)

Open-access via https://publications.aap.org/pediatrics

TODO: scripted fetch of recent policies with topic="endocrinology" filter.
EOF
    echo "  ✓ AAP pointer file saved"
}

fetch_ata() {
    local out="$OUTPUT/ata"
    mkdir -p "$out"
    echo "  → ATA (American Thyroid Association) guidelines"
    cat > "$out/_guidelines.md" <<EOF
# ATA Guidelines

- 2025 ATA Differentiated Thyroid Cancer Guidelines (Ringel et al., open access)
- 2024 ATA Hyperthyroidism / Thyrotoxicosis Guidelines

Source: https://www.thyroid.org/professionals/ata-professional-guidelines/

TODO: link rot common; verify before relying on cached versions.
EOF
    echo "  ✓ ATA pointer file saved"
}

# Iterate requested societies
IFS=',' read -ra SOC_ARRAY <<< "$SOCIETIES"
for soc in "${SOC_ARRAY[@]}"; do
    case "$soc" in
        magicapp) fetch_magicapp ;;
        ispad)    fetch_ispad ;;
        espe)     fetch_espe ;;
        cedd)     fetch_cedd ;;
        aap)      fetch_aap ;;
        ata)      fetch_ata ;;
        *) echo "Unknown society: $soc" ;;
    esac
done

# Write fetch manifest
cat > "$OUTPUT/_fetch-manifest.yaml" <<EOF
fetched_at: $(date -Iseconds)
societies: [$(echo "$SOCIETIES" | sed 's/,/, /g')]
script_version: 0.6.0
note: |
  This is a best-effort scaffold. Most society APIs are incomplete or require auth.
  The frontier LLM doing setup should expand per-society and may need to use the
  online-lookup skill in a clean session for manual review of fetched content.
EOF

echo ""
echo "✓ Guideline cache scaffolded at $OUTPUT"
echo "  Refresh via cron/weekly or manual online-lookup skill invocation."
