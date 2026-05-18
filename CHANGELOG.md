# Changelog

## [0.8.0] — 2026-05-18 — Phase renumber + real ceddcozum integration (tools, not data)

### Changed — phases renumbered (no decimals)

Per Bora: "do not do decimal phases. rename them if needed. no moat. no backwards compat."

Old → New:

| Old | New | Phase |
|---|---|---|
| 0 | 0 | Pre-flight Infrastructure |
| 1 | 1 | Inference Layer |
| 2 | 2 | Skills + Hooks + System Prompts |
| 3 | 3 | Python + R + Quarto + TeX |
| 4 + 4.5 (merged) | 4 | Caches + Zotero + Journal Guidelines + Field Preset |
| — | **5** | **ceddcozum Tool Integration** (NEW) |
| 5 | 6 | Style Calibration |
| 6 | 7 | Daily-Use GUI |
| 7 | 8 | Air-gap Configuration |
| 8 | 9 | Cron / Scheduled Tasks |
| 9 | 10 | Verification Suite |

Total: 11 phases (0-10). All references in README, AGENTS.md, and SETUP_PROMPT.md updated.

### Fixed — ceddcozum integration: it's a CLI for 33 calculators, not a data export tool

Looked at the actual published package (`ceddcozum@0.2.2`, `npm install -g ceddcozum`). The `--export-references` command I'd assumed in v0.7.0 doesn't exist and **shouldn't exist** — the package is a CLI dispatch for 33 pediatric clinical calculators, with Neyzi LMS data baked INSIDE the calculator functions. The right integration is exposing the 33 calculators as **agent-callable tools**, not extracting their data.

The package already designed for LLM-agent use:
- `ceddcozum --schemas` dumps all 33 tool schemas in OpenAI function-calling format
- `ceddcozum <tool> --args '{"...":"..."}'` invokes with JSON args
- `ceddcozum <tool> --format json` returns parsed output

New Phase 5 implementation:
```bash
npm install -g ceddcozum
mkdir -p ~/.agents/tools
ceddcozum --schemas > ~/.agents/tools/ceddcozum-schemas.json
cp -r ~/local-agent-setup/skills/coding/bora/ceddcozum-tools ~/.agents/skills/coding/bora/
```

New skill `skills/coding/bora/ceddcozum-tools/SKILL.md` is a schema-driven dispatcher that:
- Looks up tool from `ceddcozum-schemas.json`
- Validates args against the tool's JSON Schema (fail-loud per Karpathy rule #12)
- Invokes `ceddcozum <tool> --args '...' --format json`
- Returns parsed result

**Result**: the local Qwen gets 33 live calculators in its tool palette — auxology, IGF SDS, BMD SDS+vBMD, HbA1c↔glucose conversion, HOMA-IR/QUICKI, steroid equivalents, blood pressure percentiles, thyroid volume SDS, etc. All local, no network.

Removed the broken Phase 4 `npx ceddcozum --export-references` block; replaced with a comment pointing at Phase 5.

### Decisions

- No backwards-compatibility shims for the renumbering (nothing is released yet, no users to break)
- The schema-driven dispatch in ceddcozum-tools auto-picks up new calculators when Bora ships `ceddcozum@0.3+`
- Lazy-load of tools: session-launch decides which subset of 33 schemas to inject (default: Growth + Diabetes most common)

### Open

- Hermes Agent + `ceddcozum-tools` skill: needs actual integration test (`ceddcozum auxology` from inside a Hermes session)
- Documentation pointing AGENTS.md / browser-AI flow at the 33-tool palette so they know to suggest these tools instead of asking the model to compute SDS manually

---

## [0.7.0] — 2026-05-18 — Browser-AI-first setup flow + field-preset generation at setup time + npx ceddcozum + direnv mandatory

### Changed — setup audience expanded to browser AIs

Per Bora: most users will paste the repo URL into ChatGPT or Claude.ai (browser), NOT install a CLI coding agent. README rewritten to make browser path the **default**:

- **🟢 Browser path**: paste repo URL into ChatGPT/Claude.ai, the AI reads the repo and walks you through Phases 0-9 command-by-command, you paste each command into Terminal yourself. No CLI install needed.
- **🔵 Power-user path**: Claude Code / Codex / Gemini CLI users get the same setup ~30% faster because the agent runs commands directly.

`AGENTS.md` rewritten to handle both scenarios — browser AI walks through one command at a time, CLI agent runs phases directly. Both end at the same hand-off message.

### Changed — direnv promoted to MANDATORY

Per Bora: "temporary online setup is a real and gonna-be-used thing anyway." Moving direnv from RECOMMENDED to MANDATORY means it gets installed during the one-time setup, not as friction later. PubMed/Crossref/OpenAlex keys go in per-folder `.envrc`, plain FileVault encryption is enough — no 1Password/doppler.

`preflight-install-order.md` and `SETUP_PROMPT.md` Phase 0 updated.

### Changed — field presets generated during setup, not hardcoded

Per Bora: "Full population of oncology/IM/surgery presets and US-specific peds-endo variant should be on the initial online setup phase imho. not hardcoded."

- **Moved** all 4 field presets (peds-endo, oncology, IM, surgery) from `system-prompts/field-presets/` to `references/field-preset-examples/`
- **New** `system-prompts/field-presets/README.md` explains the model: examples in `references/` are structural templates; setup generates the actual loaded preset per user
- **New Phase 4.5** in `SETUP_PROMPT.md`: synthesize field preset from template + current author guidelines fetched via `online-lookup` for the user's target journals. Cached to `~/Research/cache/journal-guidelines/`.
- For the user's exact field/locale combination (e.g., "pediatric endocrinology in US"), the setup generates a fresh customized preset. No stale stubs.

### Added — `npx ceddcozum` integration in Phase 4

Per Bora: "lets include npx ceddcozum on initial setup?" Adding to the references-cache step:

```bash
# In Phase 4 — caches
if [ "$FIELD_SLUG" = "pediatric-endocrinology" ]; then
    npx -y ceddcozum@latest --export-references --output ~/Research/cache/references/
fi
```

If `--export-references` isn't yet a command in his NPM package, the SETUP_PROMPT logs a TODO for him + falls back to cloning the package source.

Generalizable pattern: if a user has their own data tool (CSV exports, reference packages, etc.), Phase 4 invites them to invoke it during setup to seed the local cache.

### Open

- `npx ceddcozum --export-references` command itself doesn't exist yet — TODO for Bora to add to the ceddcozum package
- Browser-AI Phase 4.5 generation needs the setup AI to actually fetch live journal sites (might fail for paywalled sites)
- README quick-start tested only in a copy-paste sense; the actual "paste repo URL into ChatGPT" workflow needs a real test
- Field preset generation in Phase 4.5 may be slow with browser AIs that can't fetch multiple URLs in parallel

---

## [0.6.1] — 2026-05-18 — Preflight refinement based on Bora's "what is doppler/direnv?" pass

### Changed — Phase 0 preflight further simplified

- **direnv**: moved from OPTIONAL → RECOMMENDED. Reason: PubMed/Crossref/OpenAlex API keys for momentary-online lookups need a clean per-folder loader. Plain `.envrc` on a FileVault disk is fine for low-cosmic secrets like open API keys. ~30 LOC shell setup.
- **1Password CLI / doppler / vault**: moved from OPTIONAL → DROPPED. Reason: overkill for our threat model. The secrets we have (open APIs) don't justify a separate password manager.
- **mitmproxy**: moved from RECOMMENDED → **FALLBACK** tier. Reason: Raindrop Workshop covers semantic HTTP audit better. Don't run both. Note kept in preflight doc: install mitmproxy ONLY if Raindrop is ever dropped from the stack.
- **litellm**: confirmed DROPPED (was already).
- **inspect-ai**: confirmed DEFERRED (install when user writes first eval).

`SETUP_PROMPT.md` Phase 0 rewritten to match. Includes a working `.envrc.example` for the project folder pattern.

### Changed — Phase 1 inference format auto-detected, no prompt

- Per Bora's call: **auto-pick by device, no user prompt**
- M-series Mac → `mlx-lm.server` + MLX models from `mlx-community/...`
- Non-Apple-Silicon → `llama.cpp` + GGUF
- Both expose OpenAI-compatible HTTP — downstream skills don't care which
- LFM2.5 + Turkish-Gemma stay GGUF regardless (no MLX variants as of May 2026)
- Server-binary path + model args + flags branch on `INFERENCE_FORMAT` env var

### Why this is "0.6.1" not "0.7.0"

These are refinements to v0.6 decisions, not new features. The user's questions exposed places where I'd over-engineered (1Password) or under-decided (MLX/GGUF as user prompt vs auto-pick).

---

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
