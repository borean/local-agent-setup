# Changelog

## [0.6.0] — 2026-05-18 — Preflight rationalized, MLX/GGUF choice, clean-session online lookup, setup scripts, Little Snitch profile, 3 stub field presets

### Rationalized — preflight tools

User asked: "why are these needed?" Honest audit dropped/deferred several tools that don't fit air-gap use:

- `references/preflight-install-order.md` now tiered:
  - **MANDATORY**: uv, pipx, llama.cpp, Raindrop Workshop
  - **RECOMMENDED**: mitmproxy (HTTP-level audit; Raindrop covers semantic spans — pick one)
  - **DEFERRED**: inspect-ai (install when user writes evals, not day 1)
  - **OPTIONAL**: direnv + 1Password CLI/doppler (only if user does cross-project secret work outside air-gap)
  - **DROPPED**: litellm (redundant — no providers to route, no budget caps for local model, audit covered by hooks + Raindrop)
- `SETUP_PROMPT.md` Phase 0 rewritten to match the new tiering; env vars control opt-ins

### Added — MLX vs GGUF device detection

`SETUP_PROMPT.md` Phase 1 now detects M-series chip and asks:
- **GGUF (default)**: universal, ~50 tok/s for Qwen 3.6 35B-A3B Q4_K_M on M3 Max, portable to Linux/Windows colleagues
- **MLX (opt-in)**: Apple Silicon only, ~80 tok/s (~60% faster), but can't share install instructions with non-Mac colleagues
- Per-user choice; default keeps colleagues portable

### Added — clean-session online-lookup pattern

User flagged: "lifting air-gap while patient data is in context is a leak risk; do journal lookups in a clean session."

- New skill: `skills/shared/07-online-lookup/SKILL.md`
- Two-phase pattern:
  - **Phase A** (current session with PHI): emit Material Passport, halt, tell user to open fresh Hermes window
  - **Phase B** (new clean session): defensive check (verify no PHI in context), invoke `request-momentary-internet`, fetch, cache to `~/Research/cache/{slug}.yaml`, tell user to resume original session via passport
- Schemas defined for: journal-guidelines, reporting-checklist, package-version, public-dataset
- Cache refresh policy: journal guidelines monthly, reporting checklists quarterly, package versions on-demand

### Changed — peds-endo preset: removed hardcoded length limits

Per user feedback, length limits in `pediatric-endocrinology.md` were rotting bait. Replaced with:
- **Cache-consult pattern**: skills read `~/Research/cache/journal-guidelines/{slug}.yaml`; if missing or >30 days old, invoke `online-lookup` skill
- Rough current ranges kept as fallback guidance, explicitly labeled stale-risk
- `seven-mode-failure-check` mode 5 (citation drift) now applies to using hardcoded limits without cache refresh

### Added — 4 setup scripts

- `scripts/install-cron.sh` — installs a cron task as launchctl plist (daily-03 or weekly-sun-04); randomizes minute within window to spread load
- `scripts/pin-cherry-picks.sh` — fetches upstream cherry-picks (addyosmani, mattpocock, vercel-labs, shadcn-ui) at resolved-from-main SHAs, writes pinned-commit to frontmatter
- `scripts/download-guidelines.sh` — best-effort scaffold for MAGICapp/ISPAD/ESPE/ÇEDD/AAP/ATA caches (most societies don't have stable open APIs; falls back to manual fetch instructions)
- `scripts/download-references.sh` — WHO + CDC growth chart fetchers (open URLs); Neyzi + IAP pointer files (manual fetch — not openly available)

### Added — Little Snitch profile

`setup-prompts/little-snitch-research-mode.lsrules` — strict localhost-only egress:
- Allow 127.0.0.0/8 + ::1/128
- Explicit deny for major leak vectors (.anthropic.com, .openai.com, .googleapis.com, .azure.com, .icloud.com, .apple.com, .zotero.org, .dropbox.com, .huggingface.co, .pythonhosted.org, .github.com)
- Default-deny 0.0.0.0/0 + ::/0 catch-all
- Import via Little Snitch Configuration → File → Import Rules

### Added — 3 stub field presets

For users not in pediatric endocrinology:
- `system-prompts/field-presets/oncology.md` (skeleton: AMA citation, RECIST/iRECIST, CTCAE v5.0, KM+Cox, ~5-7 hedges/1000w)
- `system-prompts/field-presets/internal-medicine.md` (skeleton: NEJM structured abstract, propensity scores, ~1.5:1 active:passive)
- `system-prompts/field-presets/surgery.md` (skeleton: Annals of Surgery style, Clavien-Dindo, present-tense operative descriptions, ~3-5 hedges/1000w)

Each is a stub awaiting first-use population. PRs welcome.

### Open

- Bridge smoke test: still pending real installation
- Field presets above are stubs; full population per real submission needs
- US-specific peds-endo variant (vs European default)
- ÇEDD/ISPAD/ESPE programmatic guideline fetchers (most are manual today)
- Neyzi 2015 LMS transcription (Bora's existing ceddcozum auxology tool has the data — could export to CSV)

---

## [0.5.0] — 2026-05-18 — Setup prompt + lockfiles + field preset + Hermes-Raindrop bridge

### Added — the pasteable SETUP_PROMPT

`SETUP_PROMPT.md` expanded from outline to a real pasteable prompt (~16 KB). 9 phases:
- Phase 0: preflight (direnv, mitmproxy, uv, pipx, inspect-ai, litellm, Raindrop Workshop)
- Phase 1: inference (llama.cpp Metal, 3 GGUFs, 2 launchctl services)
- Phase 2: skills + hooks + system prompts
- Phase 3: Python venv (50+ packages) + R (~40 packages) + Quarto + TeX
- Phase 4: caches + Zotero index
- Phase 5: style-calibration one-shot (calibrate OR generic)
- Phase 6: Hermes Agent Desktop install + config
- Phase 7: air-gap configuration (Little Snitch + iCloud + Time Machine)
- Phase 8: 7 cron tasks via launchctl
- Phase 9: 10-test verification suite

Plus full hand-off message + notes for the frontier LLM doing the install.

### Added — lockfiles

- `setup-prompts/medical-research-requirements.txt` — Python: ~50 packages curated for the air-gapped stack (pandas, numpy, scipy, statsmodels, pingouin, lifelines, pymc, paper-qa, leann, presidio, docling, ollama, pydantic-ai, opentelemetry exporters, inspect-ai)
- `setup-prompts/medical-research-renv.R` — R: ~40 packages across tidy/stats/meta/power/viz/Bayes/LLM-bridge/reporting, installs via renv, generates renv.lock

### Added — field preset

- `system-prompts/field-presets/pediatric-endocrinology.md` — generic voice baseline loaded when first-paper users run `style-calibration --mode generic --field "pediatric endocrinology"`. Covers:
  - Citation style (Vancouver, JCEM/JPEM/Diabetes Care conventions)
  - Section structure (IMRaD per STROBE; case-report variant; review variant)
  - Length limits per journal (JCEM, JPEM, Diabetes Care, Frontiers, Lancet D&E)
  - Tense+voice conventions (1.3:1 active:passive default)
  - Hedging vocabulary (strong/moderate/weak claim verbs; 4-6 hedges per 1000 words)
  - Standard abbreviations (T1D, HbA1c, GHD, CAH, DSD, MODY, etc.)
  - AI-tells to avoid ("delve", "underscore", "robust", "moreover")
  - Statistics reporting (CI primary, p secondary; missing data; subgroups pre-specified)
  - Pediatric-specific conventions (Tanner staging, bone age, BMI z-score, DXA volumetric correction)
  - Ethics statement template (KVKK + Helsinki + assent ≥7yo)

### Added — Hermes-Raindrop bridge

- `references/hermes-raindrop-bridge.md` — verdict + bridge plan.
  - **Native compat: NO** (Hermes uses openai==2.24.0 directly; Raindrop's auto-instrumentation hooks LLM client libs but misses Hermes's turn/tool/subagent structure)
  - **Recommended bridge** (~30 min): `briancaffey/hermes-otel` plugin → Workshop's OTLP `/v1/traces` endpoint at `http://localhost:5899`
  - Fallback (~50 LOC Python plugin) if OTLP rejects unauthenticated
  - Worst-case (~1 day, NOT recommended): localhost HTTP MITM at :11434
  - Two unverified assumptions called out (Workshop OTLP receiver accepting generic OTel; hermes-otel config syntax)

### Decisions

- **Voice baseline by field**: peds-endo first; oncology / IM / surgery presets stub-only for now (extend on demand)
- **Bridge before native**: don't wait for upstream support; the hermes-otel path works today
- **Phase 5 timing**: style-calibration is in-setup, not deferred to first session — gets a baseline written before user starts using Hermes

### Open

- Bridge test: run after Phase 6 (Hermes install); the verification suite Test 11 (manuscript-pipeline replay) should confirm
- Oncology / IM / surgery field presets: not yet written
- Generic field preset for non-Turkish locales (US peds endo style differs subtly from European)
- `scripts/install-cron.sh`, `scripts/pin-cherry-picks.sh`, `scripts/download-guidelines.sh`, `scripts/download-references.sh` — referenced in SETUP_PROMPT but not yet written (frontier LLM will need to author or fall back to inline bash during setup)

---

## [0.4.0] — 2026-05-18 — First-paper users + orchestrator

### Added

- **`research/manuscript/clinical-data-to-manuscript`** — 15-phase orchestrator skill that composes ~20 of our skills from raw dataset → submission-ready manuscript. Adapted from Bora's existing `manuscript-from-clinical-data`, optimized for air-gapped Qwen 3.6 with Material Passport at every major breakpoint. Two modes (`guided` for first-paper users, `express` for experienced). Resumable from any passport.
- **`references/first-paper-onboarding.md`** — explainer for users writing their first manuscript. Expected timeline (12-25 hours across 8 sessions). What to skip until later. What NOT to do.

### Changed

- **`style-calibration`** rewritten to be deferrable. Three modes:
  - `calibrate` (default for users with ≥3 published papers)
  - `generic` (loads field-specific baseline — pediatric endo / oncology / IM / surgery — for first-paper users)
  - `defer` (skip entirely; reminder every 10 sessions)
  - Frontmatter: `optional: true, deferrable: true`
- **`devils-advocate`** rewritten to be deferrable. Three modes:
  - `calibrated` (default for users with ≥5 accepted papers)
  - `uncalibrated` (first-paper users — generic Cochrane/STROBE/CONSORT reviewer patterns; output stamped with explicit caveat)
  - `defer` (skip entirely; reminder every 20 sessions)
  - Frontmatter: `optional: true, deferrable: true`

### Why these changes

User feedback: "what if the user is gonna write their first paper in life?" Both skills assume a corpus of the user's own published work. We needed graceful degradation paths so first-paper users can still benefit from the writing/critique infrastructure.

### Decisions

- **Generic-mode field presets**: pediatric endocrinology (ESPE Yearbook + JCEM), oncology (Lancet Oncology), internal medicine (NEJM), surgery (Annals of Surgery). Easily extensible.
- **Devil's Advocate uncalibrated mode** uses Cochrane methodological critiques + STROBE/CONSORT supplementary materials + EQUATOR Network reporting guidelines as its generic-reviewer corpus.
- **Orchestrator delegates, never duplicates**: every phase calls a single-purpose skill we already have. Material Passport at 6 major breakpoints means any phase failure is recoverable.

### Open

- Generic-mode field presets are placeholders; real journal-specific style sheets need population
- `clinical-data-to-manuscript` has 15 phases; the Phase-N implementations are wrappers around existing skills, no new code needed, but the orchestrator state machine itself needs implementation
- First-paper-onboarding reminders fire from `session-start-airgap.sh` — needs the hook update

---

## [0.3.0] — 2026-05-18 — Bulk skill+hook+cron implementation

### Added — meta/reference files

- `CREDITS.md` — comprehensive credit list for every idea, library, tweet author, and pattern used
- `references/compliance-primer.md` — KVKK Art. 6/12/35, GDPR Art. 9/32/35/89, HIPAA explained
- `references/devils-advocate-explained.md` — plain-language explainer of the two-phase pattern
- `references/data-viz-upgrade-PR.md` — PR-style spec for upgrading Bora's existing data-viz skill (OKLCH + Wong + Emil + nature-figure + tabular-nums + figure-validate)

### Added — skills

- **6 shared/ skills full SKILL.md**: session-launch, material-passport-emit, material-passport-resume, output-scrub, network-mode-toggle, request-momentary-internet
- **40 research/ skills** (in 6 sub-pillars):
  - literature (7): leann-search, paperqa-summarize, paperqa-synthesize, paperqa-verify-citation, storm-systematic-review, guideline-cache-query, grill-with-docs
  - statistics (7): data-dictionary, statistical-test-picker, power-analysis, analysis-plan, analysis-run, result-interpret, table-one-build
  - manuscript (10): outline-build, draft-write, claim-check, anti-leakage, writing-quality-check, style-calibration (now generic per-user), score-trajectory, prisma-trAIce-disclosure, response-to-reviewer, abstract-format
  - visualization (10): chart-spec, nature-figure, forest-plot, km-curve, patient-flow-sankey, color-palette, figure-validate + 3 vercel-labs cherry-picks (react-best-practices, react-view-transitions, web-design-guidelines)
  - medical-domain (4): pediatric-references, dosing-converter, guideline-snapshot, tr-medical-translate
  - peer-review (5): rob-assessor, grade-evidence, devils-advocate, seven-mode-failure-check, peer-review-checklist
- **21 coding/ skills**:
  - karpathy/ (3 full): fail-loud, surgical-changes, read-before-write
  - google/ (11 stubs + BORA-NOTES): from addyosmani/agent-skills
  - mattpocock/ (4 stubs + BORA-NOTES)
  - vercel/ (1 stub + BORA-NOTES): composition-patterns (the 3 visualization ones moved to research/visualization)
  - shadcn/ (1 stub + BORA-NOTES)
  - bora/ (2 full): zero-tech-debt, clawpatch-wrapper

### Added — hooks (10 shell scripts)

- `session-start-airgap.sh` — verify air-gap, load voice profile, show resumable passport
- `session-end-passport.sh` — emit Material Passport, write meta.yaml
- `precompact-passport-emit.sh` — force passport before compaction
- `user-prompt-phi-warn.sh` — regex scan prompts for PHI; warn
- `pre-tool-network-deny.sh` — HARD BLOCK network tools in air-gap
- `post-tool-audit-jsonl.sh` — append every tool call to today's ledger
- `stop-output-scrub.sh` — auto-scrub last assistant turn before copy
- `stop-score-trajectory.sh` — if manuscript edited, snapshot for regression detection
- `skill-suggest-airgap.sh` — keyword routing filtered to airgap-ok skills
- `checkpoint-reminder.sh` — soft passport reminder every 20 tool calls
- `notchi-hook.sh` — air-gap-safe desktop notifier (kept Bora's existing)

### Added — cron tasks (7 SKILL.md files)

**Daily (launchctl 03:00-03:45):**
- airgap-nightly-handoff
- llama-server-health
- audit-rotate (with SHA-256 hash chain for KVKK tamper-evidence)
- leann-index-refresh

**Weekly (Sunday 04:00-05:00):**
- manuscript-snapshot (cap 12 per manuscript)
- passport-cleanup (delete >30d, keep hash index)
- skill-usage-report (which skills used/idle/prune candidates)

### Refinements

- **TOON dropped** (Bora flagged "proved bad in past") — JSON Schema for all skill I/O
- **`style-calibration` made generic** — user provides their own 3-5 papers at setup, not Bora-mandated
- **clawpatch added** as `coding/bora/clawpatch-wrapper`
- **Hermes self-evolving skills: embrace day 1** (per Bora's call)
- **Credit-in-place doctrine** — every SKILL.md has `## Credit` section; CREDITS.md aggregates all attributions

### Open

- BORA-NOTES.md per cherry-picked skill is a stub waiting for first-use population
- Setup prompt still outline; expand to pasteable next iteration
- Hermes-Raindrop compat: not yet verified; will test post-install
- `medical-research-venv.lock` + `renv.lock` files not yet generated
- The pasteable SETUP_PROMPT version

---

## [0.2.0] — 2026-05-18 — Skills restructure + Raindrop Workshop

### Restructured

- **Skills now split into three bundles**: `shared/`, `research/`, `coding/`. Each independently installable. Each has its own README explaining scope.
- `skills/meta/` → renamed and split: cross-cutting infrastructure went to `skills/shared/`; the coding-specific zero-tech-debt went to `skills/coding/bora/zero-tech-debt/`.
- Frontmatter convention updated: `domain: shared | research | coding` replaces `pillar:`. `pillar:` becomes a *sub-pillar* within research (literature/statistics/manuscript/visualization/medical-domain/peer-review).
- Added `skills/README.md` explaining the three-bundle architecture + how runtime filtering by `domain:` works
- Added per-bundle READMEs in `skills/shared/`, `skills/research/`, `skills/coding/`

### Added

- **Raindrop Workshop** (raindrop-ai/workshop) added to preflight install order as **Step 4b** alongside mitmproxy. Local-first agent debugger from Ben Hylak. MIT, 641⭐. Resolves the TODO from v0.1.0.
- Self-healing eval loop notes — Raindrop writes evals, runs agent, fixes failures, re-runs.
- Relationship to mitmproxy: HTTP-level wiretap vs agent-level semantic tracer. Both kept; complementary.
- Relationship to inspect-ai: offline batched evals vs in-the-loop tracing. Both kept; complementary.

### Decisions

- Three-bundle split for "ease of use and maintenance" per Bora's request
- Coding bundle is **optional** — clinicians who don't vibe-code install only `shared/` + `research/`
- Cherry-pick mapping refined: 3 of 7 vercel-labs skills moved from `coding/vercel/` to `research/visualization/` (react-best-practices stays in coding because it's about React itself; react-view-transitions, web-design-guidelines, composition-patterns → no wait, composition-patterns stays coding too. Only react-view-transitions and web-design-guidelines moved.) Actually corrected: see `skills/coding/README.md` for final mapping.

### Repository housekeeping

- Updated README repo-layout diagram to show three-bundle structure
- Pinned-commit policy added to coding/README — quarterly refresh cadence, eval-suite gate on bumps

---

## [0.1.0] — 2026-05-18 — Initial scaffolding

### Added

- `README.md` — repo overview
- `AGENTS.md` — entry point for AI agents
- `SETUP_PROMPT.md` — outline for the frontier-LLM setup phase (WIP, expand before use)
- `LICENSE` — Apache-2.0
- `docs/v3_changes.md` — consolidated changes after harness research, hook intel, cron classification
- `docs/local_llm_plan.md` — full architecture + compliance plan
- `docs/harness_brief.md` — May 2026 harness verdict
- `docs/skillset_v1.md` — base 36-skill design across 7 pillars
- `docs/skillset_v2_additions.md` — ARS-derived additions (Material Passport, anti-leakage, etc.)
- `docs/top_100_intel.md` — top-100 intel from WhatsApp self-chat analysis (2591 URLs)
- `system-prompts/karpathy-12-rules.md` — the 12-rule system prompt base
- `references/preflight-install-order.md` — direnv + litellm + uv + mitmproxy + inspect-ai
- `references/colleague-onboarding-tutorial.md` — air-gap-adapted from 5-part academic Claude Code tutorial
- `references/skill-libraries-survey.md` — cherry-pick analysis of addyosmani/mattpocock/vercel/shadcn
- `skills/meta/zero-tech-debt/SKILL.md` — first skill, the "rework from end-state" pattern

### Decisions made this version

- **Harness**: Hermes Agent Desktop (single pick — replaces OpenCode/Goose options for now)
- **Inference**: `llama-server` direct (NO Ollama, NO LM Studio middleman)
- **Models**: Qwen 3.6 27B dense + 35B-A3B MoE, **1 at a time** (per Bora's preference; not parallel even on 128 GB)
- **Sidecar**: LFM2.5-350M always-warm router on port 11436
- **Skill format**: SKILL.md (Anthropic open standard, 32-tool ecosystem)
- **Skill location**: `~/.agents/skills/` (portable, auto-discovered)
- **Internal I/O**: JSON Schema (TOON sacked — proved bad in past)
- **Setup runner**: User's frontier LLM (Claude Code / Codex / Gemini CLI), then uninstalled
- **Compliance**: Little Snitch "Research Mode" + Material Passport audit trail

### Status — what's still TODO

- [ ] 43 core skills as actual SKILL.md files (1 of 43 done: zero-tech-debt)
- [ ] 10 hook scripts (0 of 10)
- [ ] 7 cron task SKILL.md files (0 of 7)
- [ ] addyosmani/mattpocock/vercel cherry-picks lifted with BORA-NOTES.md per skill (0 of 19)
- [ ] `medical-research-venv.lock` (Python requirements)
- [ ] `renv.lock` (R requirements)
- [ ] Cached guideline corpus build script
- [ ] Setup prompt — final pasteable version (currently outline)
- [ ] Verification suite scripts (Test 1-10)
- [ ] Bora's M3 Max-specific notes (128 GB tier)

### Open questions

- Style Calibration corpus — which 3-5 papers?
- Devil's Advocate corpus — which 5 accepted papers?
- Hermes self-evolving skills — embrace or disable initially?
- benhylak's agent-trace tool from May 2026 tweet — need to identify the exact repo
- thisguyknowsai "Research Accelerator" 13 prompts thread — worth scanning for any grad-student tactics
