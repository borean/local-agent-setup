---
name: clinical-data-to-manuscript
description: End-to-end orchestrator. Takes a de-identified clinical dataset + research question and walks the user through 15 phases (data dictionary → analysis → figures → draft → quality gates → submission-ready). Emits a Material Passport at every major breakpoint. Resumable. Works for first-paper users.
domain: research
pillar: manuscript
user-invocable: true
target_models:
  primary: qwen3.6:27b-q4_K_M
  fallback: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
inputs:
  type: object
  required: [data_path, research_question]
  properties:
    data_path: {type: string, description: "Path to de-identified CSV/XLSX/Parquet"}
    research_question: {type: string, description: "Single-sentence research question"}
    target_journal: {type: string, description: "JCEM | JPEM | Lancet Endo | Diabetes Care | Frontiers Endocrinology | other"}
    mode: {type: string, enum: [guided, express], default: guided}
    resume_from: {type: string, description: "Passport hash if resuming"}
    first_paper: {type: boolean, default: false}
outputs:
  type: object
  properties:
    final_manuscript: {type: string}
    figures: {type: array, items: {type: string}}
    tables: {type: array, items: {type: string}}
    submission_package: {type: string}
---

# Clinical Data → Manuscript (Orchestrator)

The big pipeline. Composes ~20 skills across 6 pillars into a 15-phase walk from raw clinical data to submission-ready manuscript. Adapted from Bora's existing `manuscript-from-clinical-data` skill, optimized for our air-gapped Qwen 3.6 setup with Material Passport at every major checkpoint.

## Two modes

- **`guided`** (default for first-paper users): each phase pauses for user confirmation, explains what's about to happen in plain language, shows the planned skill call before executing
- **`express`** (for experienced users): phases run back-to-back with minimal narration; halts only at major breakpoints for passport emit

## The 15 phases

### Group A — Plan the work (Phases 0-3)

**Major breakpoint after Phase 3 — passport emit + halt**

| Phase | Skill invoked | What happens |
|-------|---------------|--------------|
| 0 | (none — meta) | Pre-flight: confirm IRB project ID, audit folder, network=Research Mode, model loaded. |
| 1 | `data-dictionary` | Inspect dataset structure (top 20 rows only — no PHI). Propose variable types. Flag suspect values. |
| 2 | `statistical-test-picker` | Outcome × predictors × design → recommended test + assumptions + alternatives. |
| 3 | `analysis-plan` | Two-Phase Generator-Evaluator: blind acceptance criteria → sighted plan of 5 analyses with robustness checks. |

### Group B — Run the analyses (Phases 4-6)

**Major breakpoint after Phase 6 — passport emit + halt**

| Phase | Skill | What happens |
|-------|-------|--------------|
| 4 | `power-analysis` | Sanity-check the planned n vs detectable effect. |
| 5 | `analysis-run` | Emit R/Python via Quarto; execute; capture outputs (numbers, figures, tables). |
| 6 | `result-interpret` + `table-one-build` | Numbers → clinical narrative. Publication-ready Table 1 per target journal style. |

### Group C — Make the figures (Phases 7-9)

**Major breakpoint after Phase 9 — passport emit + halt**

| Phase | Skill | What happens |
|-------|-------|--------------|
| 7 | `chart-spec` | Decide chart types per result (bar/box/forest/KM/sankey/raincloud). |
| 8 | `color-palette` (one-shot) + (`forest-plot` / `km-curve` / `patient-flow-sankey` / `nature-figure`) | Generate each figure with OKLCH + Wong palette, SVG + 300dpi PNG. |
| 9 | `figure-validate` | DPI, font ≥8pt, label overlap, color-blind safety, Turkish character render. |

### Group D — Write the draft (Phases 10-11)

**Major breakpoint after Phase 11 — passport emit + halt**

| Phase | Skill | What happens |
|-------|-------|--------------|
| 10 | `outline-build` | Two-Phase G-E: locked acceptance criteria → structured outline per `target_journal`. |
| 11 | `draft-write` (called 6× — one per section) | Introduction, Methods, Results, Discussion, Conclusion, Abstract. Voice profile loaded if calibrated. |

### Group E — Quality gates (Phases 12-13)

**Major breakpoint after Phase 13 — passport emit + halt**

| Phase | Skill | What happens |
|-------|-------|--------------|
| 12 | `claim-check` + `paperqa-verify-citation` + `anti-leakage` (parallel) | Every claim classified; citations verified against PDF pages; [MATERIAL GAP] tags forced where model invented content. |
| 13 | `writing-quality-check` | 46 AI-tells regex + em-dash cap + throat-clearing detection. Rewrites flagged passages. |

### Group F — Submission prep (Phases 14-15)

**Final breakpoint after Phase 15 — passport emit + submission package**

| Phase | Skill | What happens |
|-------|-------|--------------|
| 14 | `prisma-trAIce-disclosure` + (`rob-assessor` + `grade-evidence` if applicable) + `devils-advocate` | AI disclosure section. Risk-of-bias and GRADE evidence tables (if your design is RCT/systematic review/meta-analysis). Devil's Advocate stress test (calibrated if user has corpus, uncalibrated otherwise with caveat). |
| 15 | `peer-review-checklist` (composes 12 gates) | Final pre-flight: aggregate verdict (ready / fix-first / major-issues). If ready, output: submission package (manuscript + figures + tables + supplementary). |

## First-paper handling

When `first_paper: true`:

- Phase 0 includes an extra confirmation: "This is your first manuscript? Welcome. Mode forced to `guided`."
- Phase 11 (draft-write): if no voice profile exists, `style-calibration --mode generic` runs first; user can choose field-specific baseline
- Phase 14 (devils-advocate): if no calibration corpus, runs in `uncalibrated` mode with explicit caveat
- Periodic reminders at each phase: "First-paper users typically spend [X hours] here; that's normal."
- An extra `references/first-paper-onboarding.md` link is shown at Phases 0, 11, and 14

## Resume

To resume:
```
clinical-data-to-manuscript --resume_from=<passport-hash>
```

The orchestrator reads the passport, jumps to the next phase after the last completed one, restores key decisions (test choice, voice profile, target journal) into context.

## Failure modes

- **Phase fails after 3 retries** → orchestrator halts; passport emitted; user gets a structured error explaining which phase, why, and the exception-handler options (backfill / skip-with-warning / acknowledged-limitation per ARS Pipeline State Machine)
- **Dataset has PHI patterns the data-dictionary skill catches**: HALT. Run de-id first (out of scope for this skill).
- **User says "skip [skill]" mid-pipeline**: honored, logged to passport as `skipped: {phase, skill, reason}`. Final peer-review-checklist will warn about skipped gates.
- **Model unloaded mid-run** (e.g. system restart): resume via passport; KV cache lost but state preserved.
- **Target journal not in `outline-build` presets**: skill asks user to pick the nearest match OR provide instructions-to-authors as input

## What this skill is NOT

- Not a way to get a manuscript without doing the work — every phase requires user judgment
- Not a substitute for IRB approval, consent, or co-author input
- Not for non-clinical research (different orchestrator needed)
- Not for clinical trials registration (separate workflow)

## Example invocations

```
# First-paper user, guided mode (default)
$ clinical-data-to-manuscript \
    --data_path ~/Research/glp1-first-paper/cohort_clean.csv \
    --research_question "Does GLP-1 therapy improve HbA1c in adolescents with T2D over 12 weeks?" \
    --target_journal "JPEM" \
    --first_paper true

Welcome — this is your first manuscript! Running in guided mode.
Estimated total time: 12-25 hours across multiple sessions.

Phase 0/15 — Pre-flight:
  IRB project ID: IRB-2026-042 ✓
  Audit folder: ~/Research/audit/2026-05-18/ ✓
  Network mode: Research Mode ✓
  Model loaded: qwen3.6:27b-q4_K_M ✓

  Voice profile: NONE — running style-calibration --mode generic --field "pediatric endocrinology"
  Devil's Advocate corpus: NONE — Phase 14 will run uncalibrated with caveat
  
  Ready to proceed? [yes/no]

[user: yes]

Phase 1/15 — Data Dictionary:
  Inspecting cohort_clean.csv (414 rows, 23 columns)...
  Schema proposed: see ~/Research/glp1-first-paper/data-dictionary.yaml
  Suspicious values flagged: HbA1c=99 in row 312 (probably 9.9)
  
  Review the dictionary and confirm before Phase 2.

... [phases proceed; passport emitted at each major breakpoint]
```

```
# Experienced user, express mode
$ clinical-data-to-manuscript \
    --data_path ./cohort.csv \
    --research_question "..." \
    --target_journal "JCEM" \
    --mode express

[runs phases 0-3, emits passport, halts]
[PASSPORT-RESET: hash=abc123 stage=plan-complete next=run-analyses]
```

```
# Resume next day
$ clinical-data-to-manuscript --resume_from abc123
Resuming from plan-complete; next phase: run-analyses (Phase 4).
```

## Credit

Bones from Bora's existing `~/.claude/skills/manuscript-from-clinical-data/SKILL.md` (his 11-phase orchestrator). 

Air-gap adaptations:
- Material Passport at every major breakpoint (from ARS / Imbad0202)
- Two-Phase Generator-Evaluator at Phases 3 and 10 (from ARS)
- Pipeline State Machine for exception handling (from ARS)
- First-paper deferral logic for style-calibration and devils-advocate (our addition)

Composing skills, not replacing them — every phase delegates to a single-purpose skill we already have. The orchestrator owns the WHEN; the individual skills own the HOW.
