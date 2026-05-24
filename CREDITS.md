# Credits

This repo is a remix. Every idea we lifted is credited here.

If we used your work and missed you, open an issue — we'll add you immediately.

---

## Models

- **Alibaba Qwen team** — Qwen 3.6 27B dense + 35B-A3B MoE (the workhorse models)
- **Liquid AI** — LFM2.5-350M (the tool-call sidecar router, 96-98% accuracy at 350M params)
- **YTU CE Cosmos** — Turkish-Gemma-9b-T1 (the Turkish-language model for clinical text)
- **Google Health AI** — MedGemma 1.5 (medical reasoning, English)
- **MedAIBase** — AntAngelMed (100B/6.1B active medical LLM, Apache-2.0)

## Inference + harness

- **ggerganov + llama.cpp contributors** — the backbone of all local inference
- **Apple MLX team** — fastest Mac inference path
- **Nous Research** — Hermes Agent (the harness we picked) + agentskills.io public skill hub
- **Ben Hylak / raindrop-ai** — Raindrop Workshop (the local agent debugger)
- **mitmproxy contributors** — HTTP-level wiretap for the audit trail
- **Astral team (Charlie Marsh et al.)** — `uv`, `ruff` (10-100× faster Python tooling)
- **UK AI Safety Institute / Anthropic / DeepMind** — `inspect-ai` eval framework

## Skill format + conventions

- **Anthropic** — the SKILL.md open standard (December 18, 2025)
- **forrestchang** — `andrej-karpathy-skills` (the 65-line CLAUDE.md, 12-rule version, 48,965⭐). Reduces mistake rate 41% → 3% across 30 codebases / 6 weeks.
- **Andrej Karpathy** — the underlying coding observations
- **@DeRonin_** — surfacing the 12 rules in May 2026

## The 5-step preflight (direnv / litellm / uv / mitmproxy / inspect-ai)

- **Andrej Karpathy** (via @DeRonin_) — *"the install order I run before any new agentic project"*

## Architectural patterns from ARS (academic-research-skills)

- **Imbad0202** — [academic-research-skills](https://github.com/Imbad0202/academic-research-skills) (6.9k⭐, CC BY-NC 4.0). We adapted the patterns; the originals are under CC BY-NC.
- Specifically:
  - **Material Passport + `resume_from_passport=<hash>`** — context-exhaustion fix
  - **PRISMA-trAIce 17-item AI disclosure** (Holst et al. 2025, JMIR AI, doi:10.2196/80247) — the underlying checklist
  - **RAISE framework** — agentic governance
  - **Writing Quality Check** — 46 AI-tells + em-dash cap
  - **Anti-Leakage Protocol** — `[MATERIAL GAP]` tags
  - **Style Calibration** — 6-dim voice profile
  - **7-Mode AI Research Failure Checklist** — frame-lock, hallucinated results, fabricated methods, premature synthesis, citation drift, scope creep, sycophancy
  - **Devil's Advocate + Calibration Mode** — FNR/FPR-measured attack pattern
  - **Pipeline State Machine** — formal exception handlers
  - **Two-Phase Generator-Evaluator** — blind acceptance criteria → sighted execution
  - **Score Trajectory** — cross-revision regression detection
  - **Three-Layer Citation Emission**

## Cherry-picked coding skills

- **Addy Osmani (Google Chrome team)** — `addyosmani/agent-skills` (43,273⭐). 11 of 23 lifted.
- **Matt Pocock** — `mattpocock/skills/engineering`. 5 of 10 lifted.
- **Vercel Labs** — `vercel-labs/agent-skills`. 4 of 7 lifted (3 moved to `research/visualization/`).
- **shadcn** — shadcn CLI v4 skill from `shadcn-ui/ui/skills/shadcn`.
- **Peter Steinberger (@steipete)** — Clawpatch (semantic feature-slice code review).

## Skills, data-viz, and infrastructure intel

- **Emil Kowalski** — *Agents with Taste* (animation timing rules, scale(0.95) not scale(0), 65ch line cap, `:active scale(0.97)`)
- **Yuan1z0825** — `nature-skills` (4.5k⭐) — Nature-journal Matplotlib pattern (SVG + 300dpi)
- **@pie6k** — OKLCH color model evangelism (random hue slider stays harmonious)
- **Bang Wong** — color-blind safe palette (Nature Methods 2011)
- **Edward Tufte** — *The Visual Display of Quantitative Information* (Graphics Press, 1983/2001). The nine criteria of graphical excellence + the seven remedies (B1–B7) underpin `references/dataviz-principles.md` Part I.
- **gnurio** — `tufte-vdqi-plugin` / Chartwright (MIT, ~6k⭐). The criteria-plus-remedies encoding of Tufte's principles was lifted from their `tufte-principles.md` and adapted into `references/dataviz-principles.md` Part I.
- **Cole Nussbaumer Knaflic** — *Storytelling with Data* (Wiley, 2015). The six lessons (context → visual → clutter → attention → designer → story) plus active titles, preattentive attributes, strategic color are the basis of `references/dataviz-principles.md` Part II.
- **Mitchell Hashimoto** — Ghostty auto-256-from-16 color theme generation pattern
- **@DataChaz** — TOON (we ultimately sacked it per Bora's past experience, but credit for the concept)

## Engineering practices in tweet form

- **@dunik_7** — surfaced the 41% → 11% → 3% mistake-rate finding
- **@sharbel** — "Karpathy documented the exact ways LLMs fail at coding" — pointed at the canonical patterns repo
- **@abhijitwt** — "Codex will review your output once you are done" — two-pass critique pattern
- **@nbaschez** — "When I report a bug, first write a test that reproduces it" — already in Bora's global CLAUDE.md
- **@omarsar0** — reusable workflows compound exponentially
- **@akshay_pachaar** — `.claude/` folder anatomy
- **@bcherny (Boris)** — "Claude Code works great out of the box" — vanilla is the right config
- **@victormustar** — "Qwen3.5-35B-A3B is the before/after for local agents" calibration point
- **@zaimiri** — the 10-minute Ollama + Claude Code recipe (we adapted it; Ollama dropped, llama-server direct)
- **@Alexintosh** — Qwen3.5 35B on iPhone 5.6 tok/s data point
- **@viktoroddy** — Claude Design + Opus 4.7 tutorial
- **@PrajwalTomar_** — Cursor + Opus 4.5 scrollytelling pattern

## Backends our skills delegate to

- **Future House** — PaperQA2 (Apache-2.0, mature peer-reviewed scientific RAG)
- **Stanford OVAL Lab** — STORM/Co-STORM (Wikipedia-length cited reports)
- **LearningCircuit** — Local Deep Research (~95% SimpleQA on Qwen 3.6-27B)
- **LEANN authors** — @LiorOnAI surfaced; MIT licensed; 60M chunks in 6GB
- **IBM** — Docling (medical PDF extraction with table + equation preservation)
- **Microsoft** — Presidio (PII detection — Turkish recognizers exist but disabled by default)
- **OpenAI** — privacy-filter (gpt-oss arch 1.5B/50M MoE, PII filter, F1=96%)

## Compliance + regulatory frame

- **Eric Topol** — *Paradox of medical AI implementation* (the headline framing for medical-ai-deck)
- **EchoBench authors** — quantified medical VLM sycophancy (Claude 3.7 Sonnet 45.98%, GPT-4.1 59.15%, medical-tuned >95%)
- **Holst et al. 2025** — PRISMA-trAIce 17-item AI disclosure checklist (JMIR AI doi:10.2196/80247)
- **EMQN** — CYP21A2 / 21-OHD genetic testing guidelines (the actual clinical content)
- **MAGICapp** — GRADE evidence platform (5,467+ public guidelines)
- **Turkish DPA** — Agentic AI guidance, April 15, 2026

## Tutorial inspiration

- **Anonymous academic tutorial author** — the 5-part Claude Code tutorial for academic researchers (shared by Bora) — our colleague-onboarding doc is heavily adapted from this, written by someone who clearly teaches researchers for a living. **If you're the author and want a name credit, please open an issue.**

## R packages

- **mlverse / Posit** — `mall` package (R↔Ollama bridge)
- **Hadley Wickham et al.** — `tidyverse`, `ellmer`
- **Therese Christianson & Frank Harrell** — `gtsummary`, `rms`
- **Hannah Frick et al.** — `tidymodels`
- **Schloerke / mlverse** — `chattr`

## Python packages

- **PaperQA2 team** — Future House
- **Andrew Ng + DeepLearning.AI** — concept of AI for clinicians (curriculum we reference)
- **mlpack/Outlines/BAML/Pydantic AI/Instructor authors** — constrained generation alternatives we considered but ended up using llama.cpp GBNF + LFM2.5 instead

## Personal thanks

- **Bora Ulukapı** — for the iterative process: TOON sacked, hooks-and-skills designed together, 3-bundle split, "credit where it's due" insistence
- **Every clinician using AI responsibly on patient data** — you make this stack matter

---

## How we credit in-place

Every SKILL.md file ends with a `## Credit` section pointing to the original source. Every reference doc has citations inline. Every external cherry-pick lives next to a `PERSONAL-NOTES.md` (per-user adaptation notes; was named `BORA-NOTES.md` prior to v0.9.5) that says where it came from and how we adapted it.

This file aggregates all of that for visibility.

If something is missing or misattributed, the fix is one issue + one PR away.

---

*"Be a few rules ahead of AI twitter before this becomes mass-opinion."* — Andrej Karpathy
