# Air-Gapped Medical Research Skill Set v1 — Design Spec
**For: Qwen 3.6 27B dense + 35B-A3B MoE running locally on Apple Silicon**
**Target harnesses (finalized):**
- **Inference**: LM Studio v0.4.13 (MLX engine, GBNF tool-use, MCP, OAI-compat at `localhost:1234`)
- **Tool-call sidecar**: LFM2.5-350M (96-98% tool-call accuracy at 350M)
- **Bora power user**: OpenCode v1.15.4 (terminal) + Hermes Agent v0.14.0 (self-evolving skills)
- **Colleague GUI**: Goose v1.34.1 desktop (Apache-2.0, Linux Foundation)
- **Medical lit engine**: PaperQA2 v2026.03.18 + Local Deep Research v1.6.6 + STORM/Co-STORM
- **Skill format**: SKILL.md (Anthropic open standard Dec-18-2025, 32-tool ecosystem)
- **Skill location**: `~/.agents/skills/` (portable — auto-discovered by Goose, OpenCode, Hermes)

**Mode: Conceptual design — not for installation on current machine**

---

## DESIGN PRINCIPLES (why this set looks the way it does)

1. **Fewer skills, sharper jobs.** Open-weight models route worse to 100+ skills than to 30 well-named ones. We design ~36 cohesive skills, not 130 fragmented ones.
2. **Structured I/O everywhere.** Every skill declares a JSON schema for inputs and outputs. The harness validates. Bad tool calls fail fast and explicitly instead of corrupting downstream skills.
3. **Two-model awareness baked in.** Each skill declares its preferred model (27B dense for writing/reasoning, 35B-A3B for tool use/coding). Skills know not to ask the harness to swap mid-session.
4. **Air-gap native.** Every skill declares `network: airgap-ok | local-with-cache | online-required`. Online-required skills are absent from this set entirely.
5. **Cache, don't fetch.** Anything that would normally hit the internet (PubMed, MAGICapp, ISPAD guidelines) is replaced by a local cache that's refreshed periodically when the air-gap is briefly lifted.
6. **Composable, not magical.** Big tasks are pipelines of small skills (`leann-search → paper-summarize → evidence-synthesize → claim-check`), not one mega-skill. Easier to debug. Easier for the open-weight model to plan.
7. **Open-weight friendly defaults**: short system prompts, explicit step counts, validation checkpoints. We assume the model is good but not Opus 4.7.

---

## PILLAR MAP (6 pillars, 36 skills)

```
┌── SESSION META (5) ──────── boot, scope, log, scrub, route
├── LITERATURE (6) ──────────── leann + summarize + synthesize + verify
├── STATISTICS (7) ──────────── dictionary → test → power → plan → run → interpret → table
├── MANUSCRIPT (7) ──────────── outline → draft → check → de-AI → reporting → response → abstract
├── VISUALIZATION (4) ───────── chart → render → forest → validate
├── MEDICAL DOMAIN (4) ──────── pediatric refs, dosing, guidelines, TR↔EN
└── PEER REVIEW / GRADE (3) ── rob, grade, internal-review
```

---

## PILLAR 1 — SESSION META (5 skills)

These are the orchestration skills. They never see patient data directly. They make every other skill's job clearer.

### 01-session-launch
- **Job**: classify task → pick model → load relevant skills → set system context → start the warm Ollama process.
- **Primary model**: invoked BEFORE any model is loaded. Uses a tiny LFM2.5-350M sidecar (~500MB quantized, trained specifically for reliable tool use — saw it in your data: liquidai) for the routing decision only.
- **Inputs**: free-text user description of task
- **Outputs**: `{model, harness_args, loaded_skills[], context_files[]}`
- **Network**: airgap-ok
- **Why this exists**: KV cache preservation. Decide once, commit.

### 02-session-export
- **Job**: end-of-session housekeeping — write JSONL audit log, save `meta.yaml` with model+harness+hashes+IRB-id, capture network-log snapshot, prompt for "ready to leave research mode?"
- **Network**: airgap-ok
- **Why**: KVKK Art. 12 audit trail. Without this, your local-only story has no paperwork.

### 03-output-scrub
- **Job**: 3-rule scrub before any output is exported (email, slide, shared doc). Catches first names, MRN format `^[0-9]{6,8}$`, TCKN format `^[1-9][0-9]{10}$`, day-precision dates. Generalizes locations.
- **Inputs**: `{text, export_target}`
- **Outputs**: `{scrubbed_text, redactions[], warnings[]}`
- **Network**: airgap-ok
- **Why**: Real leak vector is humans copy-pasting. This is the seatbelt.

### 04-network-mode-toggle
- **Job**: helper that runs the air-gap checks: `tcpdump` 5-sec sample, Little Snitch profile verification, Wi-Fi state, iCloud sync state. Returns red/yellow/green.
- **Network**: airgap-ok (paradoxically — it verifies isolation)
- **Why**: Colleagues need a one-button "am I safe right now?" check.

### 05-skill-route
- **Job**: at any point during a session, the active model can call this skill with a task description and get back a list of *which other skills to invoke in what order*. Replaces "agent decides on its own" pattern that goes off-rails on open-weight models.
- **Inputs**: `{task}`
- **Outputs**: `{plan[]: [{skill, inputs, expected_output}]}`
- **Why**: Pre-planning beats reactive tool calling on Qwen-class models. Inspired by the Generator–Reflector–Curator pattern from your data (qizhengz_alex).

---

## PILLAR 2 — LITERATURE (6 skills)

Built around LEANN-indexed Zotero corpus. Adapts what `paperclip MCP` and `Feynman` do for the open-weight + local case.

### 06-leann-search
- **Job**: semantic search over local Zotero corpus. Returns top-K chunks with file path + page + score.
- **Inputs**: `{query, top_k, filters: {year?, journal?, lang?}}`
- **Outputs**: `{results[]: [{chunk, source_file, page, score}]}`
- **Model**: 35B-A3B (tool call)
- **Cache**: `~/.leann/peds-endo-corpus` + `~/Zotero/storage`

### 07-paper-summarize
- **Job**: structured single-paper summary in deterministic IMRaD form.
- **Inputs**: `{pdf_path | bibkey}`
- **Outputs**: `{title, authors, year, journal, doi, design, n, population, intervention, comparator, primary_outcome, key_findings[], limitations[], bias_risk}`
- **Model**: 27B dense (long-form reasoning over one paper)
- **Why structured**: feeds cleanly into evidence-synthesize without further parsing.

### 08-evidence-synthesize
- **Job**: given N paper-summary objects + a research question, produce a narrative synthesis with `[bibkey:page]` citations at every claim.
- **Inputs**: `{question, summaries[], style: narrative|tabular|grade}`
- **Outputs**: `{synthesis_text, claim_map[]: [{claim, supporting_sources[]}]}`
- **Model**: 27B dense

### 09-citation-verify
- **Job**: for each `[bibkey:page]` reference in a draft, confirm the cited claim actually appears at that page in the local PDF.
- **Inputs**: `{draft_text, bibtex_path}`
- **Outputs**: `{verified[], unverified[], suggested_corrections[]}`
- **Why**: open-weight models hallucinate citations more than frontier — this is the safety net. Inspired by your `citation-verifier` skill, redesigned for offline operation.

### 10-guideline-lookup
- **Job**: query cached clinical guideline corpus (MAGICapp dumps, ISPAD, ESPE, ÇEDD, AAP, ATA).
- **Inputs**: `{condition, age_band, country?}`
- **Outputs**: `{recommendations[]: [{statement, grade, source, year}]}`
- **Cache**: `~/Research/cache/guidelines/{magicapp,ispad,espe,cedd,aap,ata}/`

### 11-systematic-review-screen
- **Job**: PRISMA-style title+abstract screening over a list of records. Two-pass: model screens; user reviews flagged.
- **Inputs**: `{records[], inclusion_criteria, exclusion_criteria}`
- **Outputs**: `{include[], exclude[], uncertain[]}` with reasoning per record.
- **Why**: Rayyan / Covidence are great cloud tools but they leak data. This is the air-gapped version.

---

## PILLAR 3 — STATISTICS (7 skills)

The pipeline: dictionary → test-picker → power → plan → run → interpret → table.

### 12-data-dictionary
- **Job**: inspect CSV/Excel/Parquet, propose variable types, flag suspicious values, return a clean data dictionary YAML.
- **Inputs**: `{file_path}`
- **Outputs**: `{variables[]: [{name, type, n_unique, n_missing, range, suspect_flags[]}], suggested_recodings[]}`
- **Model**: 35B-A3B (structured tool output)
- **Never sees raw rows beyond top 20** — schema-only.

### 13-statistical-test-picker
- **Job**: given outcome variable × predictor(s) × study design × sample size → recommend the right test with assumptions and citations.
- **Inputs**: `{outcome, predictors[], design, n, paired?, normality_known?}`
- **Outputs**: `{primary_test, alternatives[], assumptions_to_check[], R_function, Python_function}`
- **Model**: 27B dense (reasoning over assumptions)

### 14-power-analysis
- **Job**: G*Power-equivalent in R via `pwr` / `WebPower` / `simr` for mixed models. Computes sample size given effect + alpha + power, OR computes detectable effect given n.
- **Inputs**: `{test_type, alpha, power, effect_size | n}`
- **Outputs**: `{n_required, sensitivity_curve, R_code, citation}`

### 15-analysis-plan
- **Job**: given research question + data dictionary, propose 5 analyses ranked by clinical relevance, each with assumptions, robustness checks, sample-size sensitivity. Generator–Reflector–Curator loop internally.
- **Inputs**: `{question, data_dictionary_path}`
- **Outputs**: `{analyses[]: [{rank, description, design, primary_test, alternatives, robustness_checks[], expected_problems[]}]}`
- **Model**: 27B dense + critic pass with same 27B

### 16-analysis-run
- **Job**: emit R/Python code for a chosen analysis from the plan, execute it via Quarto/Jupyter, capture outputs, return narrative.
- **Inputs**: `{analysis_id, data_path}`
- **Outputs**: `{code_run, stdout, stderr, figures[], tables[], narrative}`
- **Model**: 35B-A3B (code + tool execution)

### 17-result-interpret
- **Job**: given analysis outputs (numbers, not raw rows), produce clinical interpretation with explicit uncertainty.
- **Inputs**: `{analysis_outputs}`
- **Outputs**: `{interpretation_text, caveats[], comparable_literature_keys[]}`
- **Model**: 27B dense

### 18-table-one-build
- **Job**: publication-ready Table 1 (baseline characteristics) in TR/EN, with proper variable formatting, missing-data row, p-values where appropriate.
- **Inputs**: `{data_path, by_group_var?, lang: tr|en, style: jama|nejm|lancet|generic}`
- **Outputs**: `{table_md, table_docx, table_latex}`
- **Model**: 35B-A3B

---

## PILLAR 4 — MANUSCRIPT (7 skills)

The writing pipeline. Heavy use of 27B dense because long-form coherence matters more here than tool-use speed.

### 19-outline-build
- **Job**: structured outline for {research_article | review | case_report | abstract | preprint}.
- **Inputs**: `{type, working_title, evidence_pack_path}`
- **Outputs**: `{sections[]: [{name, target_words, key_claims[], supporting_evidence[]}]}`
- **Model**: 27B dense

### 20-draft-write
- **Job**: section writer using outline + evidence pack. One section at a time. Inserts `[bibkey:page]` placeholders for every claim that needs a citation.
- **Inputs**: `{outline, section_name, evidence_pack_path}`
- **Outputs**: `{section_text, citation_placeholders[]}`
- **Model**: 27B dense
- **Always calls 09-citation-verify before declaring done.**

### 21-claim-check
- **Job**: split a draft into atomic claims; for each, classify as {cited, needs-citation, common-knowledge, opinion}; flag the "needs-citation" ones.
- **Inputs**: `{draft_text}`
- **Outputs**: `{claims[]: [{text, classification, suggested_search_query}]}`
- **Model**: 27B dense

### 22-ai-tell-remove
- **Job**: pattern-based AI-ism removal (no internet needed). Hits the classic tells from your dataset: "delve", "robust", "moreover", "in this article we will explore", em-dash overuse, false dichotomies, "it's not just X, it's Y", excessive bolding, parallel-list-with-em-dash patterns. Two-pass: regex-flag, then 27B-rewrite-the-flagged.
- **Inputs**: `{text, aggressiveness: low|medium|high}`
- **Outputs**: `{cleaned_text, removed_patterns[]}`
- **Model**: 27B dense

### 23-reporting-checklist
- **Job**: validate manuscript against the appropriate reporting checklist (STROBE/CONSORT/PRISMA/CARE/SQUIRE), section by section, return a checklist with missing items.
- **Inputs**: `{manuscript_path, study_type}`
- **Outputs**: `{checklist[]: [{item_number, item_text, status: present|partial|missing, suggested_addition}]}`

### 24-response-to-reviewer
- **Job**: structured reviewer-response letter builder. Each reviewer comment → response → change-in-manuscript → page+line reference.
- **Inputs**: `{reviewer_comments_text, manuscript_path}`
- **Outputs**: `{response_letter, change_log[]: [{comment_id, response, change_made, page_line}]}`
- **Model**: 27B dense

### 25-abstract-format
- **Job**: journal-specific abstract structure (JCEM, JPEM, Diabetes Care, Lancet Endo, etc.) with word counts.
- **Inputs**: `{abstract_text, target_journal}`
- **Outputs**: `{formatted_abstract, word_count_by_section, deviations[]}`

---

## PILLAR 5 — VISUALIZATION (4 skills)

Charts + tables. Light on the LLM, heavy on the code-emission pattern.

### 26-chart-spec
- **Job**: given data + question, propose the chart type (bar/box/violin/forest/KM/swimmer/raincloud/etc.) with rationale.
- **Inputs**: `{data_dictionary, question, n}`
- **Outputs**: `{chart_type, rationale, axes_proposal, palette}`

### 27-plot-render
- **Job**: emit ggplot2 or matplotlib code, run it via Quarto/Jupyter, save PNG+SVG+PDF at submission DPI.
- **Inputs**: `{chart_spec, data_path}`
- **Outputs**: `{code, image_paths[], figure_caption_draft}`
- **Model**: 35B-A3B

### 28-forest-plot
- **Job**: meta-analysis forest plot — pooled effect, CI, weights, heterogeneity (I², τ²), Egger test if N>10.
- **Inputs**: `{studies[]: [{author_year, effect, se, n}], model: fixed|random}`
- **Outputs**: `{pooled_effect, ci, i2, tau2, egger, plot_path, narrative}`

### 29-figure-validate
- **Job**: check exported figure for: font ≥8pt, DPI ≥300 for raster, no overlapping labels, color-blind safe (Wong palette check), Turkish character rendering.
- **Inputs**: `{image_path}`
- **Outputs**: `{checks[]: [{name, status, suggested_fix}]}`
- **Why**: open-weight models miss visual problems; this is a deterministic gate. Inspired by your existing `figure-pipeline` skill, redesigned.

---

## PILLAR 6 — MEDICAL DOMAIN (4 skills)

Pediatric-endo specific. Cached normative data, never online.

### 30-pediatric-references
- **Job**: lookup against cached growth charts + normative tables (Neyzi, WHO, CDC, IAP, ISPAD, ESPE, ÇEDD).
- **Inputs**: `{parameter, age, sex, reference: neyzi|who|cdc|iap, ethnicity?}`
- **Outputs**: `{p3, p10, p50, p90, p97, sds_for_value, source_citation}`
- **Cache**: `~/Research/cache/references/{neyzi,who,cdc,iap}/`

### 31-dosing-converter
- **Job**: pediatric drug dosing — mg/kg → total dose, BSA → total dose, steroid equivalence (your existing ÇEDD tool, replicated as a skill).
- **Inputs**: `{drug, weight_kg | bsa_m2, indication, age}`
- **Outputs**: `{recommended_dose, range, max_dose, citation, contraindications[]}`

### 32-guideline-snapshot
- **Job**: cached clinical guideline retrieval (pre-downloaded MAGICapp/ISPAD/ESPE/ÇEDD/ATA/AAP).
- **Inputs**: `{condition, age, country}`
- **Outputs**: `{guideline_text, recommendations[]: [{statement, grade, evidence_quality, source, year}]}`
- **Refresh policy**: weekly online sync (the only routine network access in this entire skill set), via a one-button "Update guideline cache" GUI button outside Research Mode.

### 33-tr-medical-translate
- **Job**: TR ↔ EN translation for clinical text, preserving precise medical terminology. Two-model bridge if needed (Turkish-Gemma-9b-T1 for TR sentences, Qwen 3.6 for medical accuracy of EN).
- **Inputs**: `{text, direction: tr-to-en|en-to-tr, register: clinical|patient|academic}`
- **Outputs**: `{translation, glossary[], confidence}`
- **Model**: Turkish-Gemma-9b-T1 for TR side, 27B dense for EN.

---

## PILLAR 7 — PEER REVIEW + EVIDENCE GRADING (3 skills)

For both: writing your own RCT / observational study with proper bias assessment, AND for being a peer reviewer yourself.

### 34-rob-assessor
- **Job**: ROB-2 (RCT) or ROBINS-I (observational) risk-of-bias assessment, domain by domain.
- **Inputs**: `{study_path, design: rct|cohort|case_control|cross_sectional}`
- **Outputs**: `{domains[]: [{name, judgement: low|some|high|critical, rationale, quotes_from_paper[]}]}`
- **Model**: 27B dense

### 35-grade-evidence
- **Job**: GRADE evidence grading across outcomes. Start at "high" for RCTs / "low" for observational; downgrade for risk-of-bias / inconsistency / indirectness / imprecision / publication-bias; upgrade for large effect / dose-response / plausible confounding all in same direction.
- **Inputs**: `{outcome, studies[]: [{design, rob, effect, ci}]}`
- **Outputs**: `{grade_letter: A|B|C|D, downgrades[], upgrades[], summary_of_findings_row}`

### 36-peer-review-checklist
- **Job**: pre-submission internal peer review. Runs every quality gate: reporting-checklist (23), figure-validate (29), claim-check (21), citation-verify (09), ai-tell-remove (22) — and aggregates verdict.
- **Inputs**: `{manuscript_path}`
- **Outputs**: `{gates[]: [{name, status, blockers[]}], overall_verdict: ready|fix-first|major-issues}`
- **Why**: One command, full pre-flight. This is the "before submission" ritual.

---

## SKILL FILE FORMAT (portable across harnesses)

Every skill is one Markdown file with this exact frontmatter shape:

```yaml
---
id: 08-evidence-synthesize
name: evidence-synthesize
version: 1.0.0
pillar: literature
description: "Given N paper summaries + a research question, produce a narrative synthesis with [bibkey:page] citations at every claim."
target_models:
  primary: qwen3.6:27b-q4_K_M
  fallback: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
offline_resources:
  - ~/.leann/peds-endo-corpus
inputs:
  type: object
  required: [question, summaries]
  properties:
    question: {type: string}
    summaries: {type: array, items: {$ref: "#/defs/PaperSummary"}}
    style: {type: string, enum: [narrative, tabular, grade]}
outputs:
  type: object
  required: [synthesis_text, claim_map]
  properties:
    synthesis_text: {type: string}
    claim_map:
      type: array
      items:
        type: object
        properties:
          claim: {type: string}
          supporting_sources:
            type: array
            items: {type: string}
calls_skills: [09-citation-verify]
calls_tools: [file_read]
max_iterations: 3
guardrails:
  - "Every paragraph must end with at least one [bibkey:page] citation"
  - "If model returns text without citation, retry once with explicit reminder"
  - "If after retry still no citations, raise structured error not silent pass"
---

# Procedure
...

# Failure modes
...

# Example
...
```

Why this shape:
- Frontmatter is YAML — parseable by every harness (OpenCode, Continue, Aider, Hermes, Cline) with no adapter
- `inputs` / `outputs` are JSON Schema — feeds directly into Outlines / BAML / Pydantic AI / Instructor for constrained generation
- `target_models` lets the orchestrator route at session-launch time
- `network` lets the air-gap mode hide skills that need internet
- `calls_skills` builds a static skill-call graph the harness can validate
- `guardrails` are first-class — harness enforces them, not just hopes for them

---

## WHAT'S NOT IN THIS SKILL SET (deliberately)

- **No web-search skills.** Air-gap. Everything cached.
- **No "general-purpose" skills.** No "explain this", "summarize this", "rewrite this". The model can do that without a skill. Skills are for compound jobs that need structure + verification.
- **No code generation skills outside Pillar 3.** If you need to write a Python script unrelated to stats, just ask the model. Don't pre-build skills for tasks you can prompt for.
- **No image-gen / video-gen skills.** Online-required. Drop until back online.
- **No deployment / publishing skills.** Air-gap. Manual export only.
- **No "model swap mid-session" skills.** Hard rule. The orchestrator decides at launch and never reverses.
- **No tweet-style summarizers, social-media skills, or anything not directly serving research.**

---

## ANSWERED QUESTIONS (post-harness verdict)

1. **JSON Schema validation**: LM Studio uses llama.cpp GBNF natively when you enable tool-use mode at the endpoint — we get constrained generation for free. No Outlines/BAML/Instructor needed unless we add a Python-only pipeline.
2. **KV cache preservation**: LM Studio + Ollama both preserve KV cache for the duration the model stays loaded (we set `--keepalive 4h`). Goose, OpenCode, and Hermes all share that same backend, so they share the same cache.
3. **Skill discovery**: Filesystem scan. Goose reads `~/.agents/skills/` (portable) + `.goose/skills/` (own). OpenCode reads `.opencode/skills/` and project-level. Hermes publishes to `agentskills.io` but reads local SKILL.md. **Standardize on `~/.agents/skills/`**.
4. **Multi-skill pipelines**: `calls_skills:` array in frontmatter is the DAG manifest. Harnesses respect it; if not, the orchestrator skill (#01) reads the graph.
5. **Colleague GUI**: Goose v1.34.1 desktop — single download, native Mac/Win/Linux, one dropdown to bind LM Studio, SKILL.md from the same `~/.agents/skills/` folder.

## OPENCODE / HERMES FRONTMATTER ADDITIONS

Three optional fields the picked harnesses look for:

```yaml
compatibility:
  - opencode: ">=1.15.0"
  - goose: ">=1.34.0"
  - hermes: ">=0.14.0"
  - claude-code: ">=0.7.0"   # remove if Bora truly drops it post-setup
metadata:
  author: "bora-ulukapi"
  tags: [medical-research, peds-endo, air-gap, kvkk]
  hub_publish: false          # set true to publish to agentskills.io
```

## PIPELINE BACKEND MAP

The 36 skills don't change shape; some delegate to mature locally-runnable engines:

| Pillar 2 skill | Backend engine (locally-running) |
|---|---|
| 06-leann-search | LEANN over Zotero PDFs (raw semantic search) |
| 07-paper-summarize | PaperQA2 `pqa summarize` w/ Docling parser |
| 08-evidence-synthesize | PaperQA2 `pqa ask` (citation-first by design) |
| 09-citation-verify | PaperQA2 source-verification mode |
| 10-guideline-lookup | Local Deep Research v1.6.6 (arXiv+PubMed cache) |
| 11-systematic-review-screen | STORM/Co-STORM perspective-research mode |

Same Qwen 3.6 backend, same Ollama/LM Studio endpoint, no new model downloads. PaperQA2 and STORM both speak OAI-compat → `localhost:1234`.
