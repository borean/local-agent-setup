# SETUP_PROMPT.md

**For**: a frontier AI agent (Claude Code, OpenAI Codex, Gemini CLI) running on the human's laptop, with shell + filesystem access, currently online.

**Goal**: leave the laptop with a fully-local, air-gapped, medical-research LLM environment. After your setup completes, the human will uninstall you and cut internet for clinical work.

**Status: WORK IN PROGRESS.** This file is the outline; expand each phase before pasting to a real frontier LLM. Read `docs/local_llm_plan.md`, `docs/v3_changes.md`, `docs/harness_brief.md`, `docs/skillset_v1.md`, `docs/skillset_v2_additions.md`, `references/preflight-install-order.md`, `system-prompts/karpathy-12-rules.md` first.

---

## Pre-flight (ask the human ONCE, then commit)

```
1. Confirm hardware: `system_profiler SPHardwareDataType` — should be Apple Silicon M-series, 32 GB+ RAM
2. Confirm Zotero library path (default ~/Zotero)
3. Confirm IRB project ID for audit folder naming
4. Confirm daily-use GUI: Hermes Agent Desktop (default) OR Goose Desktop OR OpenCode Desktop
5. Confirm Little Snitch installed (offer to install via brew if not)
6. Confirm Bora-voice corpus: which 3-5 of the user's published papers? (paths)
7. Confirm Devil's Advocate corpus: which 5 *accepted* papers? (paths)
8. Confirm user has admin/sudo password ready
```

Don't ask again after this block. Make sensible defaults the rest of the way.

---

## Phase 0 — Pre-flight infrastructure (per references/preflight-install-order.md)

```
brew install direnv mitmproxy uv pipx
pipx install inspect-ai
# Pick a secrets manager — default to 1Password CLI if installed, else doppler
brew install 1password-cli || brew install doppler/cli/doppler

# litellm as local proxy in front of llama-server (logs all prompts to audit)
uv pip install --user litellm

# Initialize ~/.research/lessons.md
mkdir -p ~/.research && touch ~/.research/lessons.md
```

---

## Phase 1 — Inference layer (llama.cpp Metal, NO Ollama)

```
brew install llama.cpp                          # built with -DLLAMA_METAL=ON
mkdir -p ~/.research/{models,logs,services}

# Download GGUFs from Hugging Face (mirror to ~/.research/models/)
# Qwen 3.6 35B-A3B MoE Q4_K_M  (~21 GB)
# Qwen 3.6 27B dense Q4_K_M    (~14 GB)
# LFM2.5-350M Q8                (~500 MB)
huggingface-cli download unsloth/Qwen3.6-35B-A3B-GGUF Qwen3.6-35B-A3B-Q4_K_M.gguf --local-dir ~/.research/models
huggingface-cli download unsloth/Qwen3.6-27B-GGUF Qwen3.6-27B-Q4_K_M.gguf --local-dir ~/.research/models
huggingface-cli download LiquidAI/LFM2.5-350M-tool-use-GGUF LFM2.5-350M-tool-use-Q8_0.gguf --local-dir ~/.research/models

# Write launchctl plist for ONE llama-server at a time (per Bora's "1 at a time" preference)
# Service: ~/.research/services/com.bora.llama-server.plist
# Default model: 35B-A3B; swap via `research-session` launcher script
launchctl load ~/.research/services/com.bora.llama-server.plist

# Always-warm LFM2.5-350M router on port 11436
launchctl load ~/.research/services/com.bora.lfm-router.plist

# Verify
curl -s http://localhost:11434/v1/models | jq .
curl -s http://localhost:11436/v1/models | jq .
```

---

## Phase 2 — Skills + Hooks + System Prompt

```
# Clone this repo
git clone https://github.com/borean/local-agent-setup ~/local-agent-setup
mkdir -p ~/.agents/{skills,hooks,system-prompts,state}

# System prompt (Karpathy 12 rules + air-gap preamble + bora voice placeholder)
cp ~/local-agent-setup/system-prompts/karpathy-12-rules.md ~/.agents/system-prompts/
cp ~/local-agent-setup/system-prompts/air-gap-preamble.md ~/.agents/system-prompts/
# bora-voice.md filled in Phase 5 after style-calibration

# Skills — 43 core + 19 cherry-picks
cp -r ~/local-agent-setup/skills/* ~/.agents/skills/
# Pull external cherry-picks at pinned commits
# addyosmani/agent-skills @ <pinned-sha>: 9 skills → ~/.agents/skills/coding/
# mattpocock/skills @ <pinned-sha>: 4 skills
# vercel-labs/agent-skills @ <pinned-sha>: 4 skills

# Hooks
cp ~/local-agent-setup/hooks/*.sh ~/.agents/hooks/
chmod +x ~/.agents/hooks/*.sh

# Symlink Hermes Agent skill discovery to ~/.agents/skills/
ln -sf ~/.agents/skills ~/.hermes/skills
ln -sf ~/.agents/hooks ~/.hermes/hooks
```

---

## Phase 3 — Python venv + R + Quarto + LaTeX

```
brew install python@3.13 R quarto pandoc texlive imagemagick inkscape
python3.13 -m venv ~/.research/venv
source ~/.research/venv/bin/activate
uv pip install -r ~/local-agent-setup/setup-prompts/medical-research-venv.lock

# R via renv
R --vanilla -e 'install.packages("renv"); renv::restore(lockfile="~/local-agent-setup/setup-prompts/renv.lock")'

# Wheelhouse for offline fallback installs
uv pip download -r ~/local-agent-setup/setup-prompts/medical-research-venv.lock -d ~/.research/wheelhouse/

# Verify
python -c "import pandas, statsmodels, lifelines; from paperqa import Docs; print('ok')"
R -e 'library(tidyverse); library(gtsummary); library(mall); cat("ok\n")'
```

---

## Phase 4 — Caches + Zotero index

```
mkdir -p ~/Research/cache/{guidelines,references,templates,wheelhouse}

# LEANN index from Zotero
uv pip install leann-core leann-backend-hnsw leann
leann build --source ~/Zotero/storage --embed-model bge-m3 --output ~/.leann/peds-endo-corpus

# Guideline caches (MAGICapp, ISPAD, ESPE, ÇEDD, ATA, AAP)
# Pull each guideline org's full open guideline set as PDFs
# Cache to ~/Research/cache/guidelines/{magicapp,ispad,espe,cedd,ata,aap}/

# Normative reference data
# Neyzi (Turkish), WHO, CDC, IAP growth charts
# Cache to ~/Research/cache/references/

# Journal LaTeX templates
# JCEM, JPEM, Lancet Endo, Diabetes Care, Frontiers
# Cache to ~/Research/cache/templates/
```

---

## Phase 5 — Bora-voice calibration (one-time)

```
# Run Skill #25 style-calibration on the 3-5 papers Bora pointed to in pre-flight
hermes run skill style-calibration --inputs <paper1.pdf> <paper2.pdf> <paper3.pdf>
# Output: ~/.agents/system-prompts/bora-voice.md
```

---

## Phase 6 — Daily-use GUI

```
# Default: Hermes Agent Desktop
brew install --cask hermes-agent
# Configure via plist or first-run wizard:
#   provider: openai-compatible
#   base_url: http://localhost:11434/v1
#   api_key: local
#   model: qwen3.6:35b-a3b-q4_K_M
#   skills_path: ~/.agents/skills
#   hooks_path: ~/.agents/hooks
```

---

## Phase 7 — Air-gap configuration

```
# Little Snitch Research Mode profile
# Allow: 127.0.0.1/8, ::1
# Deny: all else
# Save profile, do NOT activate yet — verification first

# Disable iCloud Desktop & Documents sync
# Exclude ~/Research/ from Time Machine
# Disable Spotlight web suggestions

# Audit skeleton
mkdir -p ~/Research/audit/$(date +%F)
echo "$(date) — setup complete by frontier LLM" > ~/Research/audit/$(date +%F)/setup.log
```

---

## Phase 8 — Cron / launchctl scheduled tasks

```
# 7 air-gap-friendly tasks per docs/v3_changes.md §8
# Daily 03:00: airgap-nightly-handoff, llama-server-health, audit-rotate, leann-index-refresh
# Weekly Sun 04:00: manuscript-snapshot, passport-cleanup, skill-usage-report
# Each gets a launchd plist in ~/Library/LaunchAgents/
```

---

## Phase 9 — Verification suite

```
Test 1: curl localhost:11434/v1/chat/completions → response from Qwen 3.6
Test 2: NOW activate Little Snitch Research Mode
Test 3: tcpdump -i any -c 50 not host 127.0.0.1 → ZERO output (no external traffic)
Test 4: Wi-Fi airplane test — chat still works
Test 5: All 43+19 skills discoverable in Hermes
Test 6: All 10 hooks fire on test events (manually trigger session start)
Test 7: Sample analysis through Pillar 3 skills (R + mall against localhost:11434)
Test 8: Sample literature query through Pillar 2 (LEANN + PaperQA2)
Test 9: Sample manuscript outline → draft → claim-check round trip
Test 10: Material Passport emit + resume in fresh session
```

---

## Hand-off (printed by you to the human)

```
✅ Setup complete. Results:
  • llama-server running on :11434 with Qwen 3.6 35B-A3B
  • LFM2.5-350M router on :11436
  • 62 skills installed at ~/.agents/skills/
  • 10 hooks at ~/.agents/hooks/
  • Audit log started at ~/Research/audit/{date}/
  • Verification suite: [N/10 passed]

🔒 To activate air-gap mode:
  1. System Settings → General → Apps → Uninstall me (the frontier LLM agent you're talking to right now)
  2. Click Little Snitch menu icon → switch to "Research Mode"
  3. Launch Hermes Agent Desktop from /Applications/
  4. In Hermes, type: session-launch write-mode
  5. Your local Qwen 3.6 is now your research assistant.

📁 Audit folder: ~/Research/audit/
📋 KVKK Art. 12 logs auto-populate per session.

That's it. I'm leaving now. Good luck.
```

---

## Notes for the frontier LLM

- **Do not paste raw patient data into your own context.** This setup is about preparing the user's machine to handle PHI, not about you handling it.
- **Approve big choices via human.** Don't pick the daily-use GUI for them; ask.
- **Verify Phase 9 fully before printing the hand-off.** Don't claim "setup complete" if any test failed.
- **Write to `~/.research/lessons.md` as you go.** Every workaround, every weird hardware quirk, every config tweak. Future setups across the user's team will reference this.
