#!/bin/bash
# download-references.sh — fetch normative growth charts + reference data
# Usage: download-references.sh --output ~/Research/cache/references

set -euo pipefail

OUTPUT=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --output) OUTPUT="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

[ -z "$OUTPUT" ] && { echo "FAIL: --output required"; exit 1; }
mkdir -p "$OUTPUT"

# ─── WHO Child Growth Standards (open) ───────────────────────────────────
fetch_who() {
    local out="$OUTPUT/who"
    mkdir -p "$out"
    echo "  → WHO: 2006/2007 Child Growth Standards (open)"

    # WHO publishes LMS reference tables as CSVs on https://www.who.int/tools/child-growth-standards
    local base="https://cdn.who.int/media/docs/default-source/child-growth"
    for sex in boys girls; do
        for measure in weight-for-age length-for-age weight-for-length bmi-for-age; do
            local fname="${measure}-${sex}-zscore-expanded-tables.xlsx"
            curl -sL "$base/$fname" -o "$out/$fname" 2>/dev/null || \
                echo "  ! WHO $fname not fetched (URL may have changed)"
        done
    done
    echo "  ✓ WHO references attempted"
}

# ─── CDC 2000 Growth Charts ──────────────────────────────────────────────
fetch_cdc() {
    local out="$OUTPUT/cdc"
    mkdir -p "$out"
    echo "  → CDC: 2000 Growth Charts data files"
    # https://www.cdc.gov/growthcharts/percentile_data_files.htm
    for fname in wtage.csv lenageinf.csv hcageinf.csv statage.csv wtstat.csv bmiagerev.csv; do
        curl -sL "https://www.cdc.gov/growthcharts/data/zscore/$fname" -o "$out/$fname" 2>/dev/null || \
            echo "  ! CDC $fname not fetched"
    done
    echo "  ✓ CDC references attempted"
}

# ─── Turkish (Neyzi 2015) ────────────────────────────────────────────────
fetch_neyzi() {
    local out="$OUTPUT/neyzi"
    mkdir -p "$out"
    echo "  → Neyzi 2015 (Turkish pediatric reference): not openly available as CSV"
    cat > "$out/_README.md" <<EOF
# Neyzi 2015 Turkish Pediatric Growth Reference

Published in: Neyzi O, et al. JCRPE 2015;7(4):280-93. doi:10.4274/jcrpe.2183

Reference: LMS parameters for weight, length/height, head circumference,
weight-for-length, BMI in Turkish children 0-18 years.

NOT available as open machine-readable data. Most Turkish pediatric tools
(including Bora's ceddcozum.vercel.app/tools/auxology) have transcribed
the tables manually.

To populate this cache:
  1. Open ceddcozum.vercel.app/tools/auxology (Bora's existing tool)
  2. Export LMS coefficients to CSV
  3. Save as $out/neyzi-2015-lms.csv

Or: invoke the online-lookup skill in a clean session and have a frontier
LLM extract the tables from the published PDF.
EOF
    echo "  ✓ Neyzi pointer saved (manual fetch required)"
}

# ─── IAP (Indian Academy of Pediatrics) 2015 ─────────────────────────────
fetch_iap() {
    local out="$OUTPUT/iap"
    mkdir -p "$out"
    echo "  → IAP 2015 Indian Growth Charts"
    cat > "$out/_README.md" <<EOF
# IAP 2015 Growth Charts

Khadilkar et al. Indian Pediatr 2015;52(1):47-55.
Reference for Indian children — relevant for South Asian patients in Turkey or as comparison group.

NOT openly available as data. Tables in published paper supplementary.
EOF
    echo "  ✓ IAP pointer saved"
}

# ─── Standard pediatric lab reference ranges ──────────────────────────────
fetch_lab_refs() {
    local out="$OUTPUT/pediatric-labs"
    mkdir -p "$out"
    echo "  → Pediatric lab reference ranges"
    cat > "$out/_README.md" <<EOF
# Pediatric Laboratory Reference Ranges

Sources:
- Children's Hospital of Philadelphia (CHOP) — open, https://www.chop.edu/
- Royal Children's Hospital Melbourne — https://www.rch.org.au/clinicalguide/
- Lab-specific ranges (your hospital's own): manual entry

Hormonal references — pediatric endo specific:
- IGF-1, IGFBP-3 by age + Tanner stage
- TSH, free T4 by age
- Cortisol, ACTH circadian
- LH, FSH, estradiol, testosterone by Tanner stage
- HbA1c interpretation thresholds (ADA, ISPAD)

Population-specific norms (Turkish): consult ÇEDD guidelines.
EOF
    echo "  ✓ Pediatric labs pointer saved"
}

# Run all fetches
fetch_who
fetch_cdc
fetch_neyzi
fetch_iap
fetch_lab_refs

# Manifest
cat > "$OUTPUT/_fetch-manifest.yaml" <<EOF
fetched_at: $(date -Iseconds)
sources:
  - who: 2006/2007 child growth standards
  - cdc: 2000 growth charts
  - neyzi: 2015 Turkish reference (manual fetch required)
  - iap: 2015 Indian reference (manual fetch required)
  - pediatric-labs: pointer to common sources
script_version: 0.6.0
note: |
  Reference data updates rarely; refresh annually.
  Neyzi + IAP are not open; require manual transcription or institutional access.
EOF

echo ""
echo "✓ Reference cache scaffolded at $OUTPUT"
echo "  WHO + CDC may have partial fetches depending on URL stability."
echo "  Neyzi + IAP require manual fetch — see per-folder _README.md."
