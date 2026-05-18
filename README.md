# local-agent-setup

A fully-local, air-gapped LLM environment for medical research — statistics, literature review, article writing — HIPAA / GDPR / KVKK compliant. Targeted at clinicians, designed to be set up by their AI agent.

**Status:** WIP. Iterating with a frontier LLM. Public when stable.

---

## What this is

A reproducible spec + skill bundle for setting up an air-gapped, open-weight LLM environment.

**Hardware requirements** (universal — chip/OS is advice, not a gate):

- **32 GB RAM minimum** for Qwen 3.6 35B-A3B Q4 (~21 GB model + ~10 GB working set)
- **80 GB free disk recommended** (~64 GB for full install: both Qwen models + LFM router + venv + R + LEANN + caches)
- See [references/storage-requirements.md](references/storage-requirements.md) for the verified per-component breakdown
- See [references/cross-platform-notes.md](references/cross-platform-notes.md) for Linux + Windows equivalents

**Platform recommendations** (in order of smoothness):

1. **Apple Silicon Mac (M3/M4)** — recommended; MLX path gives ~80 tok/s for Qwen 3.6 35B-A3B
2. **Linux (Ubuntu/Fedora) with NVIDIA GPU (CUDA) or AMD GPU (ROCm)** — fully supported via GGUF + llama.cpp; substitute systemd timers for launchctl, `ufw` for Little Snitch
3. **Windows (WSL2 + NVIDIA)** — supported via WSL2 (Linux flow inside); native Windows is more friction
4. **Apple Silicon Mac, 16 GB RAM** — drop to Qwen 3.6 8B or 14B; the 35B-A3B path is painful here

- **Inference**: `llama-server` (llama.cpp Metal build) on `localhost:11434`
- **Models**: Qwen 3.6 27B dense (writing/reasoning) + Qwen 3.6 35B-A3B MoE (coding/agentic), one at a time
- **Sidecar router**: LFM2.5-350M (always warm, ~500 MB, classifies tasks → picks model)
- **Daily-use harness**: **Hermes Agent** (TUI today via `pipx install hermes-agent`; Desktop arrives later)
- **Skills**: 74 SKILL.md files in `SKILL.md` format (Anthropic open standard) — three bundles: shared / research / coding
- **Hooks**: 11 event-driven scripts (session-start, session-end, pre-compact, etc.)
- **Cron**: 7 local-only scheduled tasks (audit-rotate, llama-server-health, leann-index-refresh, etc.)
- **Compliance**: Little Snitch "Research Mode" + Material Passport audit trail
- **Frontier LLM does the setup**, then gets uninstalled. Internet cut. User works air-gapped.

---

## Who this is for

1. **Clinician researchers** — Built around a clinical-research workflow (peds endocrinology was the seed, but the design generalizes to oncology, cardiology, rheumatology, internal medicine, etc.)
2. **Their colleagues** — non-technical clinicians who need the same setup but have a frontier LLM to do the work for them
3. **Research labs** — IRB-approved, KVKK/GDPR-compliant research on identifiable patient data without sending it to anyone's cloud

**You do not need to know `git` or the terminal.** The setup uses your existing frontier LLM (Claude Code, Codex, Gemini CLI) to do all the work.

---

## How to use this repo

### Setup — pick one of two paths

#### 🟢 Browser path (default — works for anyone, no CLI install needed)

1. Open **ChatGPT** ([chat.openai.com](https://chat.openai.com)) or **Claude** ([claude.ai](https://claude.ai)) in your browser.
2. Paste this prompt:

   > Read https://github.com/borean/local-agent-setup — especially SETUP_PROMPT.md, AGENTS.md, and README.md. Then guide me through setting up the air-gapped medical research LLM environment described in the repo. I'll run terminal commands myself; you tell me what to type and what to expect. Walk through one phase at a time. Wait for me to confirm each step before moving on.

3. The browser AI reads the repo and walks you through Phases 0-10, one terminal command at a time. You paste each command into your Mac's Terminal app (Cmd-Space → "Terminal").
4. When the AI gets to the hand-off step:
   - Close the browser AI tab
   - Flip Little Snitch → "Research Mode"
   - Launch Hermes Agent (double-click `~/Desktop/Hermes.command` — opens the TUI)

**Expected total time**: ~2 hours, mostly waiting for model downloads.
**What you need**: a Mac (Apple Silicon strongly preferred), a free ChatGPT or Claude account, ~50 GB free disk space, ~2 hours of attention.
**What you don't need**: any installed CLI tool, git, Python, R, or terminal expertise. The browser AI explains each step.

#### 🔵 Power-user path (Claude Code / Codex / Gemini CLI users)

If you already have a coding-agent CLI installed and want the agent to run the commands directly (no copy-paste back and forth):

```bash
git clone https://github.com/borean/local-agent-setup ~/local-agent-setup
cd ~/local-agent-setup
# Open Claude Code, Codex, or Gemini CLI in this directory
# Tell it:
```
> Read SETUP_PROMPT.md and execute Phases 0-10. Use the verification suite. Write lessons to ~/.research/lessons.md. Print the hand-off message when done.

The CLI path is ~30% faster (the agent runs commands directly) but requires you to already have a coding-agent CLI. Both paths produce the same end state.

### Day 2+ — Daily use

- Double-click `~/Desktop/Hermes.command` (or run `hermes` in Terminal)
- Type a session opener: `session-launch write-mode` or `session-launch code-mode`
- Work
- Hit the natural context limit → Hermes emits a Material Passport hash → you paste it into next session to resume

---

## Repository layout

```
local-agent-setup/
├── README.md              ← you are here
├── AGENTS.md              ← entry-point for AI agents reading this repo
├── SETUP_PROMPT.md        ← the prompt the frontier LLM follows to set you up
├── CREDITS.md             ← every contributor + library credited
├── LICENSE                ← Apache-2.0
├── CHANGELOG.md
│
├── docs/                  ← detailed planning + research artifacts
│   ├── v3_changes.md
│   ├── local_llm_plan.md
│   ├── harness_brief.md
│   ├── skillset_v1.md
│   ├── skillset_v2_additions.md
│   └── top_100_intel.md
│
├── system-prompts/        ← system prompts the local model loads
│   ├── karpathy-12-rules.md     ← Karpathy's 12 rules (mistake rate 41% → 3%)
│   ├── air-gap-preamble.md
│   └── voice.md.example
│
├── references/            ← reusable patterns + tutorials
│   ├── preflight-install-order.md      ← direnv/litellm/uv/mitmproxy/inspect-ai
│   ├── colleague-onboarding-tutorial.md
│   ├── skill-libraries-survey.md       ← addyosmani/mattpocock/vercel-labs/shadcn cherry-picks
│   ├── ars-material-passport.md
│   ├── zero-tech-debt.md
│   └── ...
│
├── skills/                ← three independent bundles
│   ├── shared/            ← 6 cross-cutting (session-launch, material-passport, output-scrub, audit, network-toggle, request-internet)
│   ├── research/          ← 37 clinical/academic research skills, 6 sub-pillars
│   │   ├── literature/    ← leann-search, paperqa-*, storm-*, grill-with-docs
│   │   ├── statistics/    ← data-dictionary, analysis-plan, table-one-build, ...
│   │   ├── manuscript/    ← outline, draft, claim-check, anti-leakage, style-calibration, ...
│   │   ├── visualization/ ← chart-spec, nature-figure, forest-plot, color-palette, ...
│   │   ├── medical-domain/← pediatric-references, dosing, tr-medical-translate
│   │   └── peer-review/   ← rob-assessor, grade-evidence, devils-advocate, 7-mode-failure
│   └── coding/            ← 21 engineering skills cherry-picked + custom
│       ├── karpathy/      ← 12-rule-derived
│       ├── google/        ← 11 from addyosmani/agent-skills
│       ├── mattpocock/    ← 4 from mattpocock/skills/engineering
│       ├── vercel/        ← 1 from vercel-labs/agent-skills
│       ├── shadcn/        ← shadcn CLI v4
│       └── personal/      ← zero-tech-debt + clawpatch-wrapper + ceddcozum-tools
│
├── hooks/                 ← event-driven shell scripts
│   ├── session-start-airgap.sh
│   ├── session-end-passport.sh
│   ├── precompact-passport-emit.sh
│   ├── user-prompt-phi-warn.sh
│   ├── stop-output-scrub.sh
│   └── ...
│
├── cron/                  ← scheduled tasks (launchctl)
│   ├── daily/
│   │   ├── airgap-nightly-handoff/
│   │   ├── llama-server-health/
│   │   ├── audit-rotate/
│   │   └── leann-index-refresh/
│   └── weekly/
│       ├── manuscript-snapshot/
│       ├── passport-cleanup/
│       └── skill-usage-report/
│
└── setup-prompts/         ← per-platform setup recipes
    ├── macos-apple-silicon.md
    └── linux-x86.md       ← future
```

---

## Compliance summary

Local-only **technically eliminates**: third-party processor agreements, cross-border transfer, vendor breach risk, BAA requirements.

Local-only **does NOT eliminate**: KVKK VERBIS registration, GDPR Art. 35 DPIA, IRB approval, consent, audit trail, data-subject rights.

The Turkish DPA Agentic AI guidance (April 15 2026) is explicit: there is no "on-device exemption." Local processing still requires lawful basis, purpose limitation, data minimization, and privacy-by-design.

**Your local installation is a technical control, not a legal exemption.** You still owe the paperwork. This repo helps you generate it: every session writes an audit log compatible with KVKK Art. 12 requirements.

---

## Status (as of v0.9.5)

- [x] Architecture spec ([docs/local_llm_plan.md](docs/local_llm_plan.md))
- [x] Skill set design ([docs/skillset_v1.md](docs/skillset_v1.md) + [docs/skillset_v2_additions.md](docs/skillset_v2_additions.md))
- [x] Harness pick (Hermes Agent — TUI today, Desktop later; see [docs/harness_brief.md](docs/harness_brief.md))
- [x] Karpathy 12-rule system prompt
- [x] 5-step preflight install order ([references/preflight-install-order.md](references/preflight-install-order.md))
- [x] Skill library cherry-picks (addyosmani/mattpocock/vercel/shadcn)
- [x] Skill `.md` files (74 SKILL.md across shared/research/coding bundles)
- [x] Hook `.sh` files (11 of 11 written)
- [x] Cron task SKILL.md files (7 of 7 written; 4 daily + 3 weekly)
- [x] Setup prompt ([SETUP_PROMPT.md](SETUP_PROMPT.md) — 11 phases, pasteable)
- [x] Verification suite (10 tests in Phase 10)
- [x] Existing-assets audit + reuse branches (v0.9.5)
- [ ] Real-machine install validation (Phase A spine smoke test recommended first — see [references/phase-a-smoke-test.md](references/phase-a-smoke-test.md))
- [ ] Linux/Windows full setup walk-throughs (cross-platform notes exist; full walk-throughs deferred)
- [ ] Public release (post real-install validation)

---

## Credits + dependencies

- **Anthropic** for the SKILL.md open standard (Dec 18 2025)
- **forrestchang** for `andrej-karpathy-skills` (the 65-line file + 12 rules — 48,965⭐)
- **Imbad0202** for `academic-research-skills` (Material Passport pattern + ARS framework)
- **addyosmani / Google** for `agent-skills` (43,273⭐, 23 engineering skills)
- **Matt Pocock** for `skills/engineering` (10 skills)
- **Vercel Labs** for `agent-skills` (composition, react-best-practices, react-view-transitions, web-design-guidelines)
- **shadcn-ui** for the `skills/shadcn` set
- **Nous Research** for Hermes Agent (the harness)
- **Liquid AI** for LFM2.5-350M (the tool-call sidecar)
- **Alibaba Qwen** for Qwen 3.6 27B + 35B-A3B
- **Future House** for PaperQA2
- **Stanford OVAL** for STORM/Co-STORM

License: Apache-2.0
