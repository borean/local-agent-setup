# Generic voice baseline — Internal Medicine

**Loaded by**: `style-calibration --mode generic --field "internal medicine"` for first-paper users.

**STATUS: STUB**. Skeleton with structural placeholders. PRs welcome.

---

## Citation style

- Default: NEJM style (Vancouver numbered)
- For JAMA Internal Medicine: AMA
- For BMJ: Vancouver with author-year fallback
- For Annals of Internal Medicine: NEJM/Vancouver

## Section structure

Standard IMRaD per STROBE (observational) or CONSORT (RCT). NEJM-style structured abstract:
- Background / Methods / Results / Conclusions (4 sections)

## Length limits — CONSULT online-lookup cache

Rough current ranges (May 2026; verify):
- NEJM: ~3500w main, ~250w structured abstract
- JAMA: ~3500w, ~300w
- Annals Int Med: ~3500w, ~300w
- BMJ: ~3000-5000w depending on type
- JGIM: ~4000w

## Tense + voice

- Methods: past, active preferred (NEJM convention: ~1.5:1 active:passive)
- Results: past
- Discussion: present for established facts, past for current study

## Hedging vocabulary

Internal medicine is broad — claims range across high-stakes (mortality) to descriptive. Calibrate per claim type:

- Mortality / hard outcomes: "is associated with"
- Soft outcomes / scales: "may improve"
- Surrogates: "is consistent with" / "warrants further investigation"

Frequency 4-6 per 1000 words.

## Standard abbreviations

Field-wide rather than subspecialty:
- BP, HR, RR, T (vitals); MAP
- CBC, CMP, BMP, ABG
- ICU, ED, OR
- HF (heart failure), HTN, T2D, CKD, COPD, OSA
- ACEi, ARB, BB, CCB, SSRI, NSAID
- ASA, P2Y12, DOAC, LMWH
- eGFR, ACR, INR, aPTT
- BMI, SBP, DBP

## Phrases to avoid

Generic AI-tells. Plus IM-specific:
- "high mortality" → quantify (e.g., 30-day mortality 4.2%)
- "well-known" → cite or remove
- "in this rapidly evolving landscape" — never

## Statistics

- Cohort: report adjusted HR/OR with 95% CI; document adjustment set in DAG or list
- RCT: ITT primary, per-protocol sensitivity; report attrition with reasons
- Subgroups: pre-specified > post-hoc; CONSORT 2010 flow diagram for RCTs
- Survival: KM + Cox; report PH assumption test
- Calibration / discrimination for prediction models: c-statistic, calibration plot

## Pediatric exclusion

This preset assumes adult medicine. For pediatric IM (uncommon), use the peds-endo preset as a closer base.

## Credit

Skeleton. Source materials TBD: AMA Manual of Style, NEJM author guide, BMJ author guide.
