# Generic voice baseline — Surgery

**Loaded by**: `style-calibration --mode generic --field "surgery"` for first-paper users.

**STATUS: STUB**. Skeleton with structural placeholders. PRs welcome.

---

## Citation style

- Default: Annals of Surgery style (Vancouver)
- JAMA Surgery: AMA
- BJS / Br J Surg: Vancouver
- Ann Surg Oncol: Vancouver

## Section structure

Standard IMRaD per STROBE (observational), CONSORT (RCT), or PROCESS / SCARE (case series / case report — surgery-specific reporting guidelines).

Surgery-specific structure:
- Methods MUST include: operative technique with sufficient detail to replicate, patient selection criteria, follow-up duration
- Results MUST include: morbidity (Clavien-Dindo classification default), mortality (30-day and in-hospital separately), length of stay, conversion rate (if minimally invasive)
- Discussion MUST address: surgeon experience, learning curve, generalizability beyond the reporting institution

## Length limits — CONSULT online-lookup cache

Rough current ranges (May 2026; verify):
- Annals of Surgery: ~3500w
- JAMA Surgery: ~3000w
- Surgery: ~3000w
- BJS: ~3500w
- Ann Surg Oncol: ~4000w

## Tense + voice

- Methods: past, passive somewhat more common ("The procedure was performed via..." remains acceptable)
- Operative technique descriptions: present tense procedural narrative ("The peritoneum is opened... the vessels are ligated...") — convention in surgical journals
- Results / Discussion: past for current study, present for established practice

## Hedging vocabulary

Surgical literature tends toward less hedging — outcomes are concrete (alive/dead, complication/no complication). Hedge where uncertainty is real:

- "is associated with" (most outcomes)
- "favors" (when comparing techniques, not yet definitive)
- "in our experience" — caveat for institutional series

Frequency 3-5 per 1000 words (lower than medicine — more declarative).

## Standard abbreviations

- OR / OT (operating room/theater), POD (postoperative day)
- LOS (length of stay), ICU LOS
- MIS (minimally invasive surgery), LAP, ROBOT
- EBL (estimated blood loss), TXR (transfusion)
- 30D-M / 30D-Mb / 30D-MM (30-day mortality, morbidity, major morbidity)
- CD I-V (Clavien-Dindo grades)
- ASA I-V (ASA physical status)
- BMI, BSA
- DVT, PE, SSI (surgical site infection), DGE (delayed gastric emptying)

## Phrases to avoid

Generic AI-tells. Plus surgery-specific:
- "favorable outcomes" → quantify (CD ≤II rate, 30D-M, LOS)
- "expert hands" → describe surgeon volume / experience explicitly
- "the gold standard" — only cite consensus statements; surgery rarely has true gold standards

## Statistics

- Observational comparison of techniques: propensity score (matching, IPTW) is increasingly expected
- Time-to-event: Kaplan-Meier + Cox for survival outcomes (cancer surgery)
- Complications: report rates with 95% CI; never just count
- Learning curve: CUSUM analysis where applicable
- Volume-outcome: hierarchical modeling preferred

## What this preset does NOT do

- Doesn't differentiate by surgical subspecialty (general, vascular, cardiothoracic, neurosurgery, ortho, etc.) — too broad
- Doesn't include operative video / image reporting conventions

## Credit

Skeleton. Source materials TBD: AMA Manual, EQUATOR Network surgery-specific guidelines (PROCESS, SCARE, IDEAL framework), Clavien-Dindo classification (Dindo et al. 2004), ASA physical status classification.
