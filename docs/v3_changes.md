# v3 — Consolidated Changes
**Builds on local_llm_plan.md, skillset_v1.md, skillset_v2_additions.md, harness_brief.md**
**Date: 2026-05-18**

---

## 1. SACKED

- **TOON** (Token-Oriented Object Notation) — Bora flagged it as "proved bad in the past." Reverting to **JSON Schema** for all skill I/O. Frontmatter `inputs:` / `outputs:` stay JSON Schema.
- **Ollama** as a runtime — cutting the middleman. Going straight to **llama-server** (the `llama.cpp` HTTP server binary).
- **LM Studio** — already sacked in v2 round.

## 2. CONFIRMED + UPGRADED

### The 65-line file is `forrestchang/andrej-karpathy-skills`
- **GitHub stars**: 48,965 (7,939 in one day) per @seelffff
- **Original author**: forrestchang
- **Tested**: "30 codebases over 6 weeks → mistake rate drop from 41% to either 11% or 3%" (@dunik_7 — discrepancy depending on which version you read)
- **What it is**: a single CLAUDE.md / AGENTS.md / SKILL.md system prompt that codifies Karpathy's LLM coding observations
- **Action**: This becomes the **default system prompt** for all session-launches against the local Qwen 3.6 models. Pulls go into `~/.agents/system-prompts/karpathy-base.md`. Then layer on top:
  - Bora's voice profile (style-calibration output)
  - Air-gap-mode preamble
  - Task-specific persona from the launched skill

### addyosmani's Google Agent Skills (19 skills + 7 commands)
@DataChaz surfaced this. **19 engineering skills + 7 commands inspired by Google best practices.** Worth scanning + cherry-picking 4-6 of the medical-research-applicable ones (likely: spec writing, TDD, code review, test coverage, regression testing).

### Bora keeps his existing data-viz skill
- Don't replace
- Feed it the new intel: OKLCH (pie6k), Wong palette (color-blind safe), Emil Kowalski animation timing rules, ColorBrewer for ordinal data, the nature-skills `nature-figure` Matplotlib pattern (SVG + 300dpi), tabular-nums for numeric axes
- Treat as an UPGRADE PR to the existing skill, not a v3 new entry

---

## 3. NEW STACK — llama.cpp ALL THE WAY DOWN

### Architecture (post-setup, daily use)

```
┌─────────────────────────────────────────────────────────────┐
│ APP LAYER (GUI — no terminal)                              │
│ • OpenCode Desktop app  ─┐                                 │
│ • Hermes Agent Desktop  ─┼─── all speak OAI-compat HTTP    │
│ • Goose Desktop (alt)   ─┘    against localhost:11434      │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ INFERENCE LAYER (background launchctl services)            │
│                                                             │
│ Service A: llama-server --port 11434                       │
│   model: Qwen 3.6 35B-A3B Q4_K_M (MoE, fast tool-use)      │
│   ctx-size: 32768  |  n-gpu-layers: 999  |  mlock          │
│                                                             │
│ Service B: llama-server --port 11435                       │
│   model: Qwen 3.6 27B Q4_K_M (dense, writing/reasoning)    │
│   ctx-size: 32768  |  n-gpu-layers: 999  |  mlock          │
│                                                             │
│ Service C: llama-server --port 11436                       │
│   model: LFM2.5-350M Q8 (tool-call sidecar/router)         │
│   ctx-size: 8192   |  -ngl 999  |  always warm              │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ FILESYSTEM (skills + hooks + caches)                       │
│ ~/.agents/skills/         (43 SKILL.md files)              │
│ ~/.agents/hooks/          (10 hook scripts)                │
│ ~/.agents/system-prompts/ (karpathy-base + bora-voice)     │
│ ~/Research/cache/          (Zotero, guidelines, refs)      │
│ ~/Research/audit/          (per-day JSONL logs)            │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ NETWORK CONTROL                                             │
│ Little Snitch profile: "Research Mode"                      │
│ Allow:  127.0.0.1/8, ::1                                    │
│ Deny:   everything else                                     │
└─────────────────────────────────────────────────────────────┘
```

**No Ollama. No LM Studio. No middleman.** Three `launchctl` services keep models warm. Daily-use GUI is OpenCode/Hermes/Goose — all just HTTP clients to `localhost:11434-11436`.

### Why 3 services, not 1

- Service A and B keep BOTH Qwen models hot. Session-launch picks the port. KV cache preserved per port. Memory: 21 GB + 14 GB = ~35 GB → fits Bora's 64 GB+ M3 Max easily; tight but feasible on 48 GB; **only one at a time** for 32 GB colleagues (script unloads/loads on switch).
- Service C (LFM2.5-350M) is always warm. Used by `session-launch` for the route-classification decision (~50ms response). Costs almost nothing (~500 MB RAM).

### llama-server flags worth knowing (no fluff)

```
--mlock                  # lock weights in RAM, no swap
--n-gpu-layers 999       # offload everything to Metal
--ctx-size 32768         # 32K context (lots of headroom for chat)
--jinja                  # enable Jinja chat template
--chat-template chatml   # Qwen 3.6 uses chatml
--port 11434
--host 127.0.0.1         # ONLY localhost, never 0.0.0.0
--api-key local          # set any value; required by some clients
```

---

## 4. SETUP IS DONE BY FRONTIER LLM, NOT THE USER

**Architectural shift Bora called.** The setup phase doesn't require user terminal skills — it requires *the user's frontier LLM agent* (Claude Code, Codex, Gemini CLI, etc.) to do the work while the user supervises.

### Setup flow

```
1. User has: Claude Code / Codex / Gemini CLI (online, frontier model)
2. User pastes SETUP_PROMPT.md into that agent
3. Frontier LLM does ALL the terminal work:
   - brew install llama.cpp (build with Metal)
   - download Qwen 3.6 35B-A3B + 27B + LFM2.5-350M GGUFs from HF
   - install Python venv (uv pip + medical-research-venv lockfile)
   - install R + renv + medical-research-renv lockfile
   - install Quarto + pandoc + TeX Live + Inkscape + ImageMagick
   - install daily-use GUI (OpenCode Desktop OR Hermes OR Goose)
   - copy skill files to ~/.agents/skills/
   - copy hook files to ~/.agents/hooks/
   - download forrestchang/andrej-karpathy-skills as base system prompt
   - cache MAGICapp/ISPAD/ESPE/ÇEDD guidelines
   - cache Neyzi/WHO/CDC/IAP normative reference data
   - build LEANN index from ~/Zotero
   - install Little Snitch + Research Mode profile
   - write launchctl plist files for 3 llama-server services
   - run verification suite (Wi-Fi-airplane test, tcpdump 5s)
4. Frontier LLM hands off:
   "Setup complete. To activate:
    a) Uninstall Claude Code / Codex / Gemini CLI (System Settings → Apps)
    b) Flip Little Snitch menu → Research Mode
    c) Launch [OpenCode Desktop / Hermes / Goose]
    d) First chat will be against your local Qwen 3.6"
5. User does (a)-(c). Done. Internet for clinical work is dead.
```

**Implication**: the setup prompt can use any level of technical density — the audience is an LLM, not a human. The user just approves big choices.

---

## 5. HOOK SET FOR THE AIR-GAPPED WORKFLOW

**Building on Bora's existing 10 hooks. Adapting 5, adding 5.**

### Bora's existing patterns we ADAPT (rename + adjust target paths)

| Existing (~/.claude/hooks/) | v3 (~/.agents/hooks/) | What changes |
|---|---|---|
| session-start-bootstrap.sh | session-start-airgap.sh | + Wi-Fi check, + voice profile load, + passport hash display, + show which model is loaded |
| session-end-handoff.sh | session-end-passport.sh | + emit Material Passport hash, + write meta.yaml, + run output-scrub on transcript |
| precompact-save-state.sh | precompact-passport-emit.sh | force passport emission BEFORE compaction (not just handoff) |
| skill-suggest.sh | skill-suggest-airgap.sh | filter to `network: airgap-ok \| local-with-cache`; hide `online-required` |
| notchi-hook.sh | notchi-hook.sh | KEEP AS-IS — desktop notification on MacBook notch |
| checkpoint-reminder.sh | KEEP | reminds to checkpoint passport at stages |
| skill-observer.sh | KEEP | tracks skill usage for tuning |
| stop-handoff-reminder.sh | absorbed into stop-output-scrub.sh | combined |
| verification-tracker.sh | KEEP | tracks claims for verification skill |
| verification-cooldown.sh | KEEP | post-Stop cooldown |

### NEW hooks for air-gap medical research

| Hook | Event | Job |
|---|---|---|
| **user-prompt-phi-warn.sh** | UserPromptSubmit | Regex scan for TCKN `^[1-9][0-9]{10}$`, MRN `^[0-9]{6,8}$`, common Turkish names, exact dates. Warn: "Detected possible PHI. Continue? (yes/edit/cancel)" |
| **pre-tool-network-deny.sh** | PreToolUse (matcher: `WebFetch\|WebSearch\|fetch_url\|http_get`) | Hard block + audit log every attempt |
| **post-tool-audit-jsonl.sh** | PostToolUse (matcher: `*`) | Append tool call + sanitized I/O to `~/Research/audit/$(date +%F)/session-$id.jsonl` |
| **stop-output-scrub.sh** | Stop | Run output-scrub skill on last assistant turn; flag any PHI patterns; show scrubbed version before user copies |
| **stop-score-trajectory.sh** | Stop (conditional on manuscript edit) | If session modified a `manuscript*.md` or `.qmd`, run score-trajectory skill; flag regressions in any dimension |

### How skills + hooks compose (the integration story)

- **Skill #02 material-passport-emit** is *called by* `precompact-passport-emit.sh` hook (PreCompact) AND `session-end-passport.sh` hook (SessionEnd). Belt and suspenders.
- **Skill #03 material-passport-resume** is *suggested by* `session-start-airgap.sh` hook when it detects a passport hash in the user's first prompt or in `~/.agents/state/last-passport.txt`.
- **Skill #22 writing-quality-check** + **Skill #23 anti-leakage** are *invoked by* `stop-output-scrub.sh` hook before allowing copy-paste.
- **Skill #26 score-trajectory** is *triggered by* `stop-score-trajectory.sh` hook.

So hooks are not just notifications — they are the **enforcement layer**. Skills are the *capability* layer. Hooks make sure the right capability fires at the right boundary.

---

## 6. THE SETUP PROMPT (for the frontier LLM)

Saved separately as `SETUP_PROMPT.md`. Outline:

```
You are setting up an air-gapped local medical research LLM environment
on a macOS Apple Silicon machine. The user is a Turkish pediatric
endocrinologist. After your setup completes, this device's internet
will be cut, and the user will work with local-only models.

REFERENCES (read these first):
  /Users/bora/Desktop/local_llm_plan.md       (architecture + compliance)
  /Users/bora/Desktop/skillset_v1.md          (base 36 skills)
  /Users/bora/Desktop/skillset_v2_additions.md (ARS-derived additions)
  /Users/bora/Desktop/harness_brief.md         (harness rationale)
  /Users/bora/Desktop/v3_changes.md            (this file's parent)

PRE-FLIGHT (ask user once, with sensible defaults):
  1. Confirm M-series chip + RAM tier (you'll detect via system_profiler)
  2. Confirm Zotero library path
  3. Confirm IRB project ID for audit folder naming
  4. Confirm preferred daily-use GUI: OpenCode Desktop (default) /
     Hermes Agent Desktop / Goose Desktop
  5. Confirm Little Snitch is installed (or install if not)

PHASE 1 — INFERENCE LAYER (~30 min download time)
  brew install llama.cpp (built with -DLLAMA_METAL=ON)
  mkdir -p ~/.research/{models,logs,services}
  wget Qwen 3.6 35B-A3B Q4_K_M GGUF → ~/.research/models/
  wget Qwen 3.6 27B Q4_K_M GGUF → ~/.research/models/
  wget LFM2.5-350M GGUF → ~/.research/models/
  Write 3 launchctl plists → ~/.research/services/
  launchctl load all 3 services
  Verify: curl localhost:11434/v1/models, /v1/chat/completions

PHASE 2 — SKILLS + HOOKS + SYSTEM PROMPT
  git clone forrestchang/andrej-karpathy-skills → temp
  Copy 65-line markdown → ~/.agents/system-prompts/karpathy-base.md
  Write 43 SKILL.md files → ~/.agents/skills/  (per skillset_v1 + v2)
  Write 10 hook scripts → ~/.agents/hooks/
  chmod +x all hooks
  Symlink to harness-specific dirs as needed

PHASE 3 — PYTHON + R + QUARTO + LATEX
  brew install python@3.13 R quarto pandoc texlive imagemagick inkscape uv
  python -m venv ~/.research/venv && source it
  uv pip install -r medical-research-venv.lock (50+ packages)
  R -e 'renv::restore()' from medical-research-renv.lock
  Verify: python -c "import pandas, statsmodels, lifelines, paperqa", R -e 'library(tidyverse, gtsummary, mall)'

PHASE 4 — CACHES + ZOTERO INDEX
  Build LEANN index from ~/Zotero/storage → ~/.leann/peds-endo-corpus
  Download MAGICapp/ISPAD/ESPE/ÇEDD/ATA/AAP guideline dumps → ~/Research/cache/guidelines/
  Download Neyzi/WHO/CDC/IAP normative tables → ~/Research/cache/references/
  Download journal LaTeX templates → ~/Research/cache/templates/

PHASE 5 — DAILY-USE GUI
  Install user's choice: OpenCode Desktop / Hermes / Goose
  Configure to point at localhost:11434 (35B-A3B) and :11435 (27B dense)
  Configure skills path: ~/.agents/skills/
  Configure hooks path: ~/.agents/hooks/

PHASE 6 — AIR-GAP CONFIGURATION
  Install Little Snitch Research Mode profile
  Disable iCloud Desktop & Documents sync
  Exclude ~/Research/ from Time Machine
  Disable Spotlight web suggestions

PHASE 7 — VERIFICATION SUITE
  Test 1: curl localhost:11434/v1/chat/completions → success
  Test 2: tcpdump -i any -c 50 not host 127.0.0.1 → no traffic during chat
  Test 3: Wi-Fi airplane test → chat still works
  Test 4: All 43 skills discoverable via GUI
  Test 5: All 10 hooks fire on test events
  Test 6: Audit log file created with today's date
  Test 7: Run a sample analysis through Pillar 3 skills (R + ellmer)

HAND-OFF (final user message):
  "Setup complete. Verification results: [results table].
  To go live air-gapped:
    1. Open System Settings → General → Login Items & Extensions
       → uninstall Claude Code / Codex / Gemini CLI
    2. Click Little Snitch menu icon → switch to 'Research Mode'
    3. Launch [OpenCode/Hermes/Goose] Desktop from Applications
    4. Type: 'session-launch write-mode' for first chat
  Your local Qwen 3.6 is ready. Audit folder: ~/Research/audit/"
```

The setup prompt itself is verbose because **the audience is an LLM**, not Bora. Density is feature.

---

## 7. DAILY USE — WHAT BORA AND COLLEAGUES ACTUALLY DO

After setup, here's the typical session:

```
1. Open OpenCode Desktop (or Hermes / Goose)
2. Type: "session-launch write-mode" or "session-launch code-mode"
   → LFM2.5-350M classifies, picks port 11434 or 11435
   → System prompt = karpathy-base + bora-voice + air-gap preamble
   → session-start-airgap.sh hook fires:
      ✓ network check (passes)
      ✓ today's audit folder created
      ✓ resume passport hash displayed if available
      ✓ voice profile loaded
3. Work for N hours
   → every tool call audited via post-tool-audit-jsonl.sh
   → PHI patterns in prompts trigger user-prompt-phi-warn.sh
   → manuscript edits tracked for score-trajectory
4. Hit context limit OR session natural break:
   → precompact-passport-emit.sh fires
   → Skill #02 emits [PASSPORT-RESET: hash=abc123def456]
   → user copies the hash
5. Quit GUI
6. Reopen GUI later, type "resume_from_passport=abc123def456"
   → Skill #03 restores state, skips done stages
   → KV cache fresh, content state preserved
```

No terminal. No network calls. Audit log auto-populated.

---

## 8. CRON / SCHEDULED TASKS — air-gap subset

**Hermes autoskillage and cron are orthogonal layers**:
- Autoskillage = in-session reactive skill *creation* from observed workflows
- Cron = out-of-session time-triggered skill *execution*
They compound: Hermes builds the skill, cron runs it on a clock.

### Existing 17 scheduled tasks — classification

**Stay on Bora's online setup (12)** — these don't run in air-gap:
- daily-research-digest, twitter-ai-scout-daily, wiki-deep-research, huggingface-model-watchdog
- world-orientation (×3), weekly-whatsapp-digest, cli-anything-watchdog
- lightpanda-watchdog, paper-trade-cycle

**Port to air-gap (5)** — local-only, no network needed:
- nightly-handoff → `airgap-nightly-handoff`
- process-guardian → `llama-server-health`
- daily-session-analysis → folded into `skill-usage-report`
- autoresearch-watchdog → keep as-is if you run autoresearch locally
- scheduled-task-validator → keep as-is, scoped to air-gap tasks only

### New air-gap cron set — 7 local-only tasks

**Daily (launchctl 03:00):**
1. **airgap-nightly-handoff** — fresh handoff.md per research project with today's activity
2. **llama-server-health** — verify ports 11434/11435/11436 respond; restart dead services; notify
3. **audit-rotate** — move yesterday's `~/Research/audit/YYYY-MM-DD/` to archive, gzip after 7 days, hash for KVKK tamper-evidence
4. **leann-index-refresh** — incremental re-index if Zotero changed

**Weekly (Sunday 04:00):**
5. **manuscript-snapshot** — versioned snapshots of active manuscripts for Skill #26 score-trajectory baseline (cap 12 per manuscript)
6. **passport-cleanup** — delete `~/.agents/state/passports/*.json` older than 30 days
7. **skill-usage-report** — weekly report: which skills invoked / never, suggest pruning

### On-demand (NOT cron) — fired by `request-momentary-internet` skill during brief Research Mode lift:
- guideline-cache-refresh (MAGICapp/ISPAD/ESPE/ÇEDD)
- reference-cache-refresh (Neyzi/WHO/CDC/IAP)
- template-cache-refresh (JCEM/JPEM/Lancet LaTeX)
- pubmed-zotero-sync (Zotero saved-search alerts)
- package-mirror-refresh (`uv pip download` for novel packages)

Triggered when you toggle Little Snitch to Setup Mode for ~10 min, weekly or monthly. Audit-logged.

---

## 9. WHAT'S LEFT TO ANSWER

1. **Style Calibration corpus** — which 3-5 of Bora's papers? (You'd hand over PDFs)
2. **Devil's Advocate calibration corpus** — which 5 *accepted* papers? (For FNR/FPR measurement)
3. **Final daily-GUI pick** — OpenCode Desktop is your lean, but should we also confirm Hermes runs alongside for self-evolving skills, or keep it as a future toggle?
4. **andrej-karpathy-skills 3% follow-up** — you said "I think there's an even better revision to 3%" — got a link or remember the author? Worth pulling if so.
5. **addyosmani's 19 Google Agent Skills** — cherry-pick 4-6 medical-research-applicable ones (spec writing, TDD, code review, regression, test coverage)? Worth a 15-min scan.
