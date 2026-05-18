# research/ — Clinical & Academic Research Skill Bundle

37 skills across 6 sub-pillars, for clinician researchers running statistics, literature review, and article writing on air-gapped local Qwen 3.6.

## Sub-pillars

```
research/
├── literature/      ← 6 skills — PaperQA2 + LEANN + STORM backends
├── statistics/      ← 7 skills — R via mall + Python via pandasai, all local
├── manuscript/      ← 8 skills — outline → draft → claim-check → anti-leakage → response
├── visualization/   ← 6 skills — nature-figure + forest-plot + KM + Sankey + color-palette + Emil rules
├── medical-domain/  ← 4 skills — pediatric refs + dosing + guidelines + TR↔EN
└── peer-review/     ← 5 skills — ROB-2/ROBINS-I + GRADE + Devil's Advocate + 7-mode failure check
└── research-meta/   ← 1 skill — research-session helpers
```

## The 37 skills

### literature/ (6)
- `leann-search` — semantic search over local Zotero corpus
- `paperqa-summarize` — single-paper IMRaD structured summary (PaperQA2 backend)
- `paperqa-synthesize` — N papers + question → narrative with `[bibkey:page]` citations
- `paperqa-verify-citation` — claim → source match against local BibTeX
- `storm-systematic-review` — PRISMA-style screening, Co-STORM dynamic mind-map
- `guideline-cache-query` — local MAGICapp/ISPAD/ESPE/ÇEDD lookup

### statistics/ (7)
- `data-dictionary` — inspect CSV/XLSX, propose schema (top-20 rows max, no PHI leak)
- `statistical-test-picker` — outcome × predictor × design → right test + assumptions + R/Python stub
- `power-analysis` — G*Power-equivalent in R (`pwr`, `WebPower`, `simr`)
- `analysis-plan` — Two-Phase Generator-Evaluator: blind acceptance criteria → sighted plan
- `analysis-run` — emit R/Python via Quarto/Jupyter → run → narrative
- `result-interpret` — numbers → clinical interpretation w/ caveats
- `table-one-build` — Table 1 in JAMA/NEJM/Lancet/Frontiers/generic style, TR/EN

### manuscript/ (8)
- `outline-build` — Two-Phase: locked acceptance criteria first, structured outline second
- `draft-write` — section-by-section writer with `[bibkey:page]` placeholders
- `claim-check` — atomic-claim classifier (cited / needs-citation / common-knowledge / opinion)
- `anti-leakage` — `[MATERIAL GAP]` tags vs fabricated methods (from ARS)
- `writing-quality-check` — 46 AI-tells + em-dash cap + throat-clearing (from ARS)
- `style-calibration` — one-shot 6-dim voice profile from your 3-5 past papers
- `score-trajectory` — cross-revision regression detection (catches "Methodology +0.3 / Writing −0.5")
- `prisma-trAIce-disclosure` — 17-item AI disclosure (Holst 2025, JCEM-ready)
- `response-to-reviewer` — reviewer comment → response → change-in-manuscript → page/line refs

### visualization/ (6)
- `chart-spec` — chart-type recommendation per question (bar/box/violin/forest/KM/Sankey/raincloud)
- `nature-figure` — Matplotlib multi-panel SVG + 300dpi PNG (from Yuan1z0825/nature-skills)
- `forest-plot` — meta-analysis w/ I², τ², Egger
- `km-curve` — survminer/ggsurvfit-style KM + at-risk table + log-rank
- `patient-flow-sankey` — CONSORT-style flow diagram
- `color-palette` — OKLCH + Wong (color-blind) + ColorBrewer + Emil timing rules — generates ggplot + matplotlib + CSS cycler at once
- `figure-validate` — DPI ≥300, font ≥8pt, Wong palette, label overlap, Turkish character render

### medical-domain/ (4)
- `pediatric-references` — Neyzi/WHO/CDC/IAP normative tables (cached)
- `dosing-converter` — pediatric drug dosing, mg/kg → total + BSA + steroid equivalence
- `guideline-snapshot` — cached MAGICapp/ISPAD/ESPE/ÇEDD/ATA/AAP
- `tr-medical-translate` — TR ↔ EN clinical text (Turkish-Gemma-9b-T1 for TR side, Qwen 3.6 for EN medical)

### peer-review/ (5)
- `rob-assessor` — ROB-2 (RCT) or ROBINS-I (observational), domain by domain
- `grade-evidence` — GRADE per outcome: starts RCT=high / observational=low, downgrade/upgrade rules
- `devils-advocate` — pre-submission stress test w/ FNR/FPR calibration against accepted-paper corpus
- `seven-mode-failure-check` — frame-lock, hallucinated results, fabricated methods, premature synthesis, citation drift, scope creep, sycophancy
- `peer-review-checklist` — composes 12 gates into one pre-flight verdict (ready / fix-first / major-issues)

## What's notable about this bundle

- **Two-Phase Generator-Evaluator** pattern from ARS used in `outline-build` and `analysis-plan` — blind acceptance criteria first, prevents post-hoc rubric softening
- **Material Passport** is in `shared/` because both research and coding need it; here in `research/` we explicitly emit at every analysis-plan boundary
- **Voice calibration is one-shot** — run once after install on 3-5 of your published papers, then every draft skill loads `~/.agents/system-prompts/bora-voice.md`
- **No internet** — `guideline-cache-query` reads from `~/Research/cache/guidelines/` (refreshed during brief Research Mode lifts, not in-session)
- **TOON sacked** — JSON Schema in all frontmatter `inputs:` and `outputs:` per Bora's feedback

## Engines this bundle delegates to

| Skill | Backend |
|---|---|
| `leann-search` | LEANN over `~/Zotero/storage` |
| `paperqa-*` | PaperQA2 CLI `pqa` at localhost |
| `storm-systematic-review` | STORM/Co-STORM (Stanford OVAL) |
| `analysis-run` | Quarto + R `mall` + Python `pandasai` |
| `forest-plot`, `km-curve` | R `metafor`, `survminer`, `ggsurvfit` |
| `tr-medical-translate` | Turkish-Gemma-9b-T1 (TR) + Qwen 3.6 (EN medical) |

All backends speak OAI-compat to `localhost:11434` (llama-server with current Qwen loaded).
