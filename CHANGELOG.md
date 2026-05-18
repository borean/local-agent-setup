# Changelog

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
