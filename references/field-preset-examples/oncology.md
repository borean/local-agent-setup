# Generic voice baseline — Oncology

**Loaded by**: `style-calibration --mode generic --field "oncology"` for first-paper users in oncology.

**STATUS: STUB**. Full preset to be authored; current version is a skeleton with the right structural placeholders. PRs welcome.

---

## Citation style

- Default: AMA Manual of Style (Vancouver numbered)
- For Lancet Oncology: Vancouver
- For JAMA Oncology / JCO: AMA
- For Cancer / Cancer Cell: Cell Press style (numbered)

## Section structure

Standard IMRaD per STROBE (observational) or CONSORT (RCT) or PRISMA (systematic review). Cancer-specific additions:

- Methods MUST include: staging system used (TNM 8th ed default for solid tumors), histology classification (WHO 2022 default), molecular profiling if applicable
- Results MUST report: response criteria (RECIST 1.1 default for solid tumor trials; iRECIST for immunotherapy; Lugano 2014 for lymphoma)
- Discussion MUST address: prior treatment landscape, regulatory status of compared agents

## Length limits — CONSULT online-lookup cache, do not hardcode

See peds-endo preset for the cache-consult pattern. Same rule applies.

Rough current ranges (May 2026; verify): Lancet Oncology ~3500w main, JCO ~5000w, Cancer ~5000w, Frontiers Oncology ~12000w.

## Tense + voice

- Methods: past, passive acceptable in this field (~1.0:1 active:passive — slightly more passive than peds endo)
- Results: past, with effect estimates + 95% CI
- Discussion: present for stable facts, past for current study

## Hedging vocabulary

Oncology has higher stakes claims; more conservative hedging:

- Strong: "is associated with improved survival"
- Moderate: "suggests improved survival; further validation needed"
- Weak: "may indicate"

Frequency 5-7 per 1000 words (slightly higher than peds endo).

## Standard abbreviations

CR / PR / SD / PD (RECIST), DOR, PFS, OS, ORR, TTP, DCR, AEs, irAEs (immune-related AEs), ECOG PS, KPS, OS24, mPFS, BRCA, KRAS, EGFR, HER2, PD-L1, MSI-H, dMMR, TMB, ctDNA, MRD.

## Phrases to avoid

Same general AI-tells. Plus oncology-specific:
- "groundbreaking response" — be specific (CR, deep PR, prolonged SD)
- "promising results" — quantify (ORR x%, PFS y months)
- "well-tolerated" — quantify (Grade ≥3 AE rate)

## Statistics

- Survival: KM curves with log-rank or Cox; report hazard ratios with 95% CI
- Response: ORR per RECIST 1.1 (or iRECIST for IO); waterfall plots conventional
- Safety: CTCAE v5.0 default; report Grade 3-5 separately
- Subgroups: forest plots with interaction p-values
- Time-to-event: censoring rules must be explicit (e.g., death from any cause vs disease-specific)

## What this preset does NOT do

- Doesn't differentiate solid tumor vs heme malignancy specifics — too field-wide
- Doesn't include radiation oncology dosing conventions
- Doesn't include surgical oncology operative reporting

For deeper subfield calibration: provide your own papers via `style-calibration --mode calibrate` once available.

## Credit

Skeleton. Source materials TBD: AMA Manual of Style 11th ed, CONSORT 2010 for RCTs, REMARK for biomarker studies, ESMO + ASCO guidance papers.
