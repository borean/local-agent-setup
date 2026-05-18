# Generic voice baseline — Pediatric Endocrinology

**Loaded by**: `style-calibration --mode generic --field "pediatric endocrinology"` when a user has no own-paper corpus (first-paper users).

**Replaced by**: user's calibrated profile once they've published 1+ papers and re-run `style-calibration --mode calibrate`.

**Style sources**: JCEM (Journal of Clinical Endocrinology & Metabolism) instructions-to-authors, JPEM (Journal of Pediatric Endocrinology & Metabolism), Diabetes Care (ADA), Frontiers in Endocrinology, ESPE Yearbook editorial conventions.

---

## Citation style

- **Default**: Vancouver numbered, square brackets, in-text `[1,2,5]` or `[1-3]`
- **JAMA / Diabetes Care**: also Vancouver
- **Frontiers**: author-year (Smith et al., 2024) — note when targeting Frontiers
- **References list**: numbered in citation order, not alphabetical
- **Citations placed at the end of the sentence**, before the period, unless mid-sentence specificity required
- **Multiple citations**: list smallest range possible — `[1-3]` not `[1,2,3]`; `[5,12]` for non-contiguous
- **NEVER cite review articles when the primary source is available** — exception: methodological reviews used for methods sections

---

## Section structure

### Original research

- Abstract: structured 250-300 words (Objective / Design / Setting / Participants / Intervention / Main outcome measures / Results / Conclusions) — JCEM convention
- Introduction: 3-4 paragraphs, max 600 words
- Methods: subsections — Study design, Participants, Variables, Bias, Study size, Quantitative variables, Statistical methods (per STROBE)
- Results: text + tables + figures; report effects with 95% CIs alongside p-values
- Discussion: paragraph 1 = key finding restated; paragraph 2-3 = comparison with prior work; paragraph 4 = strengths and limitations; paragraph 5 = implications
- Conclusion: 1 paragraph max, no new data
- Acknowledgments → Funding → Conflicts of Interest → Author contributions

### Case report

- Abstract: unstructured, 150 words
- Introduction: 1-2 paragraphs, justify why this case is reportable
- Case Presentation: chronological — presentation → workup → diagnosis → management → outcome
- Discussion: tie this case to the literature; what makes it educational
- Conclusion: 2 sentences max

### Review

- Abstract: unstructured, 200-300 words
- Introduction: position the field, state the review's question
- Methods: search strategy (PRISMA-ish even for narrative reviews)
- Body: thematic, not chronological
- Discussion / Implications
- Conclusion

---

## Length limits (target_journal aware)

| Journal | Abstract | Main text | Refs | Figures | Tables |
|---|---|---|---|---|---|
| JCEM | 250 | 3000 | 50 | 5 | 5 |
| JPEM | 250 | 3500 | 50 | 6 | 6 |
| Diabetes Care | 250 | 4000 | 40 | 6 | 6 |
| Frontiers Endocrinology | 350 | 12000 | 100 | unlimited | unlimited |
| Lancet Diabetes & Endocrinology | 200 | 3500 | 30 | 4 | 3 |

When `target_journal` is specified, all drafted sections respect that journal's limits.

---

## Tense & voice

- **Methods**: past tense, passive voice acceptable but active preferred ("We measured..." > "Measurements were taken...")
- **Results**: past tense, passive voice ("Mean HbA1c was 7.2%")
- **Discussion**: present tense for stable findings, past for the current study ("Our results suggest..." for the present study; "Insulin resistance is well-established..." for general)
- **Discussion of figures**: present tense ("Figure 2 shows...")
- **Conclusion**: present tense ("These findings indicate...")

**Active vs passive ratio in peds endo**: typical 1.3:1 active:passive. Older European authors run more passive; American authors more active. Match user's calibration if available; default to 1.3:1.

---

## Hedging — register conventions

Pediatric endocrinology is conservative. Standard hedge vocabulary:

**Strong claim** (use sparingly, only for well-replicated findings):
- "demonstrate(s) that"
- "show(s) that"
- "establish(es) that"

**Moderate claim** (default for novel findings):
- "suggest(s) that"
- "indicate(s) that"
- "is consistent with"

**Weak claim** (use for exploratory or single-study findings):
- "may suggest"
- "could indicate"
- "raises the possibility that"
- "is hypothesized to"

**Frequency**: 4-6 hedges per 1000 words is typical. Below 2 = overclaiming. Above 10 = waffling.

---

## Terminology

### Standard abbreviations (define on first use, then use freely)

- **T1DM**, **T1D** — type 1 diabetes mellitus (T1D preferred per ADA 2018+)
- **T2DM**, **T2D** — type 2 diabetes
- **HbA1c** — glycated hemoglobin (note: per ADA, report as %; per IFCC, mmol/mol — JCEM accepts both, JPEM prefers %)
- **CGM** — continuous glucose monitoring
- **TIR / TBR / TAR** — time in/below/above range
- **DKA** — diabetic ketoacidosis
- **GH**, **rhGH** — growth hormone, recombinant human GH
- **IGF-1** — insulin-like growth factor 1
- **GHD** — growth hormone deficiency
- **CAH** — congenital adrenal hyperplasia (specify 21-OHD vs 11β-OHD when relevant)
- **PCOS** — polycystic ovary syndrome (avoid in pre-pubertal; AYPCOS in adolescent)
- **DSD** — differences/disorders of sex development (use "differences" per 2018 consensus)
- **CPP / DPP** — central / delayed precocious puberty
- **MODY** — maturity-onset diabetes of the young (specify subtype, e.g. MODY-3 = HNF1A)

### Phrases to avoid (AI-tells common in clinical writing)

- "delve into" → "examine" or "describe"
- "underscore" → "show" or "highlight"
- "robust" → "consistent" or "reliable" (or just drop)
- "moreover" → "in addition" or just start a new sentence
- "furthermore" → ditto
- "in this article" / "in this study, we will" → just describe what you did
- "it is worth noting that" → just say the thing
- "novel insights" → describe the specific insight
- "groundbreaking" / "paradigm-shifting" — never. Especially never as a self-description.
- "comprehensive review" — only if it actually IS comprehensive (defined inclusion criteria); otherwise "narrative review"

### Phrases that are CORRECT but flagged by some AI-detectors

These are fine in clinical writing, ignore detector warnings:
- "consistent with" (clinical reasoning standard)
- "established" (after enough evidence)
- "evidence-based"
- "warrants further investigation" (only when it actually does)

---

## Statistics reporting conventions

- **Continuous variables**: mean ± SD for normally distributed; median (IQR) for skewed; note which
- **Categorical**: n (%)
- **Effect estimates**: always with 95% CI; p-value is supplementary, not primary
- **P-values**: report exact to 3 decimals if p ≥ 0.001; otherwise p<0.001; never "p<0.05" alone
- **Sample size**: state in abstract AND methods, with reason (power calc OR convenience sample, named)
- **Missing data**: state how handled; "complete case" is acceptable but only with justification
- **Subgroup analyses**: must be pre-specified; if post-hoc, label as such

---

## Pediatric-specific conventions

- **Age expression**: chronological age in years for ≥3yo; "years; months" format for <3yo (e.g., "2; 4" = 2 years 4 months)
- **Growth references**: state which (Neyzi / WHO 2007 / CDC 2000 / IAP / local-Turkish if applicable)
- **Pubertal status**: Tanner stages (B1-B5 for breast, G1-G5 for genitals, P1-P5 for pubic hair); state separately
- **Bone age**: state which atlas (Greulich-Pyle most common; TW2/TW3 if European or Turkish cohort)
- **Body composition**: BMI z-score not raw BMI for cross-age comparison
- **Reference range**: lab values must include the reference range and lab method
- **DXA**: pediatric Z-scores need volumetric correction (use vBMD / BMAD) — flag if raw areal BMD reported

---

## Ethics statement template

Every empirical paper needs an Ethics section in Methods. Default template:

> The study was approved by the Ethics Committee of [INSTITUTION] ([IRB-NUMBER], date: [DATE]). Written informed consent was obtained from parents/legal guardians of all participants. For participants aged ≥7 years, written informed assent was also obtained, in accordance with the Declaration of Helsinki (2013 revision) and Turkish KVKK Law 6698. All data were de-identified at source prior to analysis.

For retrospective studies, replace "Written informed consent..." with "The requirement for informed consent was waived by the IRB given the retrospective nature of the study and the use of de-identified data."

---

## What this preset does NOT do

- Doesn't write your manuscript for you — it shapes the model's drafts to be journal-appropriate
- Doesn't replace your own judgment on what to claim
- Doesn't auto-include local refs (Turkish-language sources) — supply via Zotero
- Doesn't enforce specific journal templates — that's `outline-build` with `target_journal:` argument

---

## When to switch off generic mode

Once you have your first accepted paper:

```bash
style-calibration --mode calibrate --papers /path/to/your-first-paper.pdf --username $USER
```

The calibrated profile replaces this generic baseline. Re-run after every 5 acceptances.

Generic mode is a scaffold. Your own voice is what you're building toward.

---

## Credit

- **JCEM instructions to authors** (Endocrine Society)
- **JPEM instructions to authors** (De Gruyter)
- **Diabetes Care editorial conventions** (ADA)
- **ESPE Yearbook editorial style** (European Society for Paediatric Endocrinology)
- **STROBE statement** (von Elm et al. 2007) for observational study structure
- **Vancouver style** (ICMJE Recommendations)
- **Reference range / pediatric statistics conventions**: synthesis of Cole's growth references, ISCD Pediatric Position Statement (DXA), ISPAD Clinical Practice Consensus Guidelines

This is a generic baseline. The actual style of any specific journal in 2026 may have shifted; verify against current instructions-to-authors before final submission.
