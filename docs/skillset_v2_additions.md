# Skill Set v2 — Additions from ARS + Karpathy + Data Viz
**Builds on v1 (36 skills). Adds 7 ARS-derived skills + reshapes 3 pillars. Total: 43 skills, 7 pillars.**

## What changed structurally
- **Pillar 1 (Session meta) grows from 5 → 6 skills**: Material Passport gets its own slot pair (emit + resume)
- **Pillar 2 (Literature) stays 6**: replaces internals with PaperQA2 + STORM backends from harness brief
- **Pillar 3 (Statistics) stays 7**
- **Pillar 4 (Manuscript) grows from 7 → 8**: adds anti-leakage + style-calibration + score-trajectory + prisma-trAIce; merges existing draft-write + claim-check
- **Pillar 5 (Visualization) grows from 4 → 6**: adds nature-figure + km-curve + sankey + color-palette
- **Pillar 6 (Medical domain) stays 4**
- **Pillar 7 (Peer review) grows from 3 → 5**: adds devils-advocate + 7-mode-failure
- **Format swap**: use **TOON** for all internal skill I/O instead of JSON — 30-60% fewer tokens, important for 27B/35B-A3B context budgets

---

## NEW: ARS-derived skills (cherry-picked from May 14-15 session)

### #02 material-passport-emit (NEW)
**Replaces v1 session-export checkpoint logic.**
- **Job**: at FULL checkpoint, hash the append-only ledger via JCS + SHA-256, emit `[PASSPORT-RESET: hash=<h>, stage=<n>, next=<n+1>]`, halt.
- **Inputs**: `{stage, ledger_path, next_stage}`
- **Outputs**: `{passport_hash, reset_marker, halt: true}`
- **Why**: turns the 11-phase manuscript pipeline and 12-phase research pipeline into truly resumable workflows. Bora's #1 pain (context exhaustion) gets a real fix.

### #03 material-passport-resume (NEW)
- **Job**: in a fresh session, accept `resume_from_passport=<hash>`, locate the ledger entry, restore minimal state, skip done stages.
- **Inputs**: `{passport_hash}`
- **Outputs**: `{restored_state, next_action, skipped_stages[]}`

### #23 anti-leakage (NEW)
- **Job**: scan a draft for fabricated methods / hallucinated data; force `[MATERIAL GAP: <description>]` tags wherever the model invented content that doesn't trace to inputs.
- **Inputs**: `{draft_text, materials_manifest}`
- **Outputs**: `{annotated_draft, gaps[]: [{location, missing_material, suggested_action}]}`
- **Why**: Open-weight models hallucinate methods more than Opus 4.7. This is the floor.

### #25 style-calibration (NEW)
- **Job**: read 3 of Bora's past published papers, extract a 6-dimensional voice profile (formality, sentence-length variance, jargon density, hedging frequency, citation density, Turkish-English code-switch ratio).
- **Inputs**: `{past_papers[]: paths}`
- **Outputs**: `{voice_profile_yaml}` saved to `~/Research/profiles/bora-voice.yaml`
- **One-shot setup skill**: run once after install, then every draft skill loads the profile.

### #26 score-trajectory (NEW)
- **Job**: across manuscript revisions, score each on N dimensions (methodology, writing, citations, figures, statistics, integrity, novelty). Flag regressions where one dimension drops while another rises.
- **Inputs**: `{manuscript_versions[]: paths}`
- **Outputs**: `{trajectory_matrix, regressions[]: [{dimension, from_version, delta, suggested_revert}]}`
- **Why**: catches fix-A-break-B during revision rounds. Same pattern survived our previous cherry-pick filter.

### #27 prisma-trAIce-disclosure (NEW)
- **Job**: generate the 17-item AI disclosure checklist (Holst et al. 2025, JMIR AI doi:10.2196/80247). Tier-tagged: Mandatory blocks pipeline, Highly Recommended warns, Optional logs.
- **Inputs**: `{manuscript_metadata}`
- **Outputs**: `{disclosure_section, blockers[], warnings[]}`
- **Why**: Frontiers/JCEM will require this within 6-12 months. Get ahead.

### #41 devils-advocate (NEW)
- **Job**: pre-submission stress test. Two-phase pattern: (a) read manuscript + abstract, generate strongest possible attack on each claim; (b) calibration mode — run the attack pattern against 5 of Bora's *accepted* papers to measure FNR/FPR before trusting on the new one.
- **Inputs**: `{manuscript_path, calibration_corpus[]}`
- **Outputs**: `{attacks[]: [{claim, attack, severity, suggested_defense}], calibration: {fnr, fpr, n_calibration_papers}}`
- **Model**: 27B dense (long-form adversarial reasoning)

### #42 seven-mode-failure-check (NEW)
- **Job**: explicit check for the 7 known AI research failure modes:
  1. Frame-lock (model commits to wrong frame, can't recover)
  2. Hallucinated results (numbers not in source data)
  3. Fabricated methods (described procedures never ran)
  4. Premature synthesis (combines results before validating)
  5. Citation drift (citation present but doesn't support claim)
  6. Scope creep (answers expanded beyond research question)
  7. Sycophancy (agrees with user framing despite contrary evidence)
- **Inputs**: `{manuscript_path, source_data_manifest}`
- **Outputs**: `{checks[]: [{mode, status: clean|flagged|fail, evidence}]}`

---

## REVISED: existing skills, now backed by ARS patterns

### #22 writing-quality-check (revised — was v1's #22 ai-tell-remove)
- Use the **46-term ARS list** instead of my v1 pattern list
- Adds em-dash cap (default max 1 per 100 words)
- Adds throat-clearing pattern detection ("In this article, we will...", "It's worth noting that...", "It should be noted...")
- Two-pass: regex flag → 27B dense rewrites flagged

### #21 outline-build (revised)
- Adopt **Two-Phase Generator-Evaluator** pattern from ARS
- Phase 1 (Nb, blind): pre-commit acceptance criteria for what makes a "good outline" for THIS manuscript type — locked
- Phase 2 (Na, sighted): generate outline against the locked contract
- Prevents post-hoc rubric softening (the most common Qwen failure mode)

### #17 analysis-plan (revised)
- Adopt **Pipeline State Machine** from ARS
- Replace "5 analyses proposed" with formal JSON state graph
- Add exception handlers: if assumption check fails 3× → user picks (backfill | skip-with-warning | acknowledged-limitation)
- Stored as `~/Research/{project}/analysis_state.json`, resumable via material-passport

### #43 peer-review-checklist (revised — was v1's #36)
- Now composes 12 gates instead of 6: reporting-checklist + figure-validate + claim-check + citation-verify + writing-quality-check + anti-leakage + 7-mode-failure-check + devils-advocate + score-trajectory + prisma-trAIce-disclosure + style-calibration-match + grade-evidence
- Output: structured pre-flight report with ready / fix-first / major-issues verdict + specific blockers

---

## NEW: Pillar 5 (Visualization) expansion — Emil-style for data viz

### #30 nature-figure (NEW — from Yuan1z0825's nature-skills 4.5k⭐)
- **Job**: emit matplotlib Nature-journal panel code. Multi-panel with shared legend. SVG + 300dpi PNG outputs.
- **Inputs**: `{data_path, panels[]: [{type, x, y, group}], style: nature|jama|nejm|lancet|cell}`
- **Outputs**: `{code, svg_path, png_path, caption_draft}`
- **Defaults**: 8pt min font, Wong palette default, OKLCH color model, tabular-nums for numbers

### #32 km-curve (NEW)
- **Job**: survminer/ggsurvfit-style Kaplan-Meier with at-risk table, log-rank p, median survival annotation.
- **Inputs**: `{time_col, event_col, group_col, data_path}`
- **Outputs**: `{code, figure_path, narrative}`

### #33 patient-flow-sankey (NEW)
- **Job**: CONSORT-flow / patient-flow Sankey diagram from a tracking spreadsheet.
- **Inputs**: `{flow_data_path, stages[]}`
- **Outputs**: `{code, figure_path, exclusion_table}`

### #34 color-palette (NEW — Emil+pie6k+Wong melange)
- **Job**: emit project-wide color palette in OKLCH + RGB + HEX, harmonized via OKLCH hue rotation, validated for color-blind safety (Wong test), with semantic role mappings (primary/secondary/positive/negative/categorical-N).
- **Inputs**: `{base_hue?, n_colors, color_blind_safe: true, semantic_roles[]}`
- **Outputs**: `{palette.yaml, palette.css, palette.r (ggplot scales), palette.py (matplotlib cycler)}`
- **One-shot setup skill**: generate once per project, then every figure skill loads it.

---

## SETUP-PHASE MANIFESTS (NOT skills — one-time bootstrap)

### S01 medical-research-venv (Python)
Comprehensive pre-install during setup phase, locked via `uv pip freeze` → `requirements.lock`.

Core stack:
```
# Data + stats
pandas numpy scipy scikit-learn statsmodels
pingouin lifelines pymc arviz
matplotlib seaborn plotly altair
pyarrow polars duckdb

# Medical
biopython pydicom fhir.resources
presidio-analyzer presidio-anonymizer

# Document processing
pdfplumber pymupdf docling
leann-core leann-backend-hnsw leann
paper-qa[full]

# LLM client
ollama lmstudio chatlas pydantic-ai instructor
outlines baml-py

# Notebook
jupyter ipywidgets ipython nbformat nbconvert quarto-cli

# Quality
ruff mypy pytest hypothesis
```

### S02 medical-research-renv (R)
Locked via `renv::snapshot()` → `renv.lock`.

```
# Tidy + stats
tidyverse gtsummary broom broom.mixed
survival survminer ggsurvfit cmprsk
lme4 nlme emmeans marginaleffects
meta metafor robumeta
pwr WebPower

# LLM bridge
mall ellmer chatlas

# Reporting
rmarkdown knitr quarto janitor naniar

# Viz extras
ggrepel patchwork cowplot ggsci
ggdist tidybayes
```

### S03 system-deps
```
brew install quarto pandoc texlive imagemagick inkscape ollama
ollama pull qwen3.6:35b-a3b-q4_K_M
ollama pull qwen3.6:27b-q4_K_M
ollama pull bge-m3
ollama pull glm-ocr
ollama pull hf.co/LiquidAI/LFM2.5-350M-tool-use-GGUF
```

### S04 offline-data-caches
Periodic refresh (when air-gap briefly lifted):
```
~/Research/cache/zotero-pdfs/       # your Zotero library — synced as-is
~/Research/cache/guidelines/        # MAGICapp + ISPAD + ESPE + ÇEDD + ATA + AAP dumps
~/Research/cache/references/        # Neyzi + WHO + CDC + IAP normative tables
~/Research/cache/templates/         # JCEM + JPEM + Lancet + Frontiers LaTeX templates
~/Research/cache/wheelhouse/        # uv pip download for fallback novel installs
~/Research/cache/leann-index/       # rebuilt monthly from Zotero
```

### S05 audit-skeleton
```
~/Research/audit/YYYY-MM-DD/
  session-NNN.jsonl
  session-NNN.meta.yaml
  network.log
  momentary-lifts.jsonl       # every brief air-gap break
  dataset-version.txt
  irb-project-id.txt
```

---

## HARNESS STACK — REVISED based on your questions

**Killing LM Studio entirely. Standardizing on Ollama Desktop.**

| Layer | Pick (revised) | Why |
|---|---|---|
| **Inference (always)** | **Ollama Desktop v0.24+** | Open source MIT, GUI launcher since v0.23, MLX backend, MCP, OAI-compat at `localhost:11434`, pulls GGUF/MLX from HF |
| **Tool-call sidecar** | **LFM2.5-350M** (GGUF via Ollama) | 96-98% tool-call accuracy at 350M |
| **Bora power user** | **OpenCode** v1.15.4 (desktop app) + **Hermes Agent** v0.14.0 | Both have desktop apps now; both speak SKILL.md from `~/.agents/skills/`; both run against Ollama's `:11434` endpoint |
| **Colleague GUI** | **Goose Desktop** v1.34.1 OR Ollama's built-in chat | Either works. Goose if they want skills; Ollama if pure chat |
| **Skill format** | **SKILL.md** (Anthropic open standard, 32-tool ecosystem) | Bora's existing 130 already in this format |
| **Internal skill I/O** | **TOON** (Token-Oriented Object Notation) | 30-60% fewer tokens than JSON for tabular data — matters for 27B/35B-A3B context budgets |

**No more LM Studio. No more middleman.** Ollama covers inference + GUI for model swap. Goose / Hermes / OpenCode are the chat surfaces, all pointing at the same Ollama endpoint.

---

## OPEN QUESTIONS — TO RESOLVE NEXT

1. **Material Passport schema** — exact YAML/TOON structure for the append-only ledger
2. **Style Calibration corpus** — which 3-5 of Bora's papers to use? Need a curated list
3. **Devil's Advocate calibration corpus** — which 5 accepted papers?
4. **Goose vs Ollama-built-in chat** for colleague GUI — pick one before rollout
5. **Hermes Agent self-evolving skills** — embrace or disable? Risk: skills mutate unpredictably; reward: workflows compound
6. **PaperQA2 + LEANN coexistence** — PaperQA2 has its own indexer; do we run both or just PaperQA2?
