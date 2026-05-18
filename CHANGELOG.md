# Changelog

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
