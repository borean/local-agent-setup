# SETUP_PROMPT.md

**For**: a frontier AI agent (Claude Code, OpenAI Codex, Gemini CLI) running on the human's laptop with shell + filesystem access, currently online.

**Goal**: leave the laptop with a fully-local, air-gapped, medical-research LLM environment. After your setup completes, the human will uninstall you and cut internet for clinical work.

**Paste this entire file as your initial prompt to Claude Code / Codex / Gemini CLI from inside `~/local-agent-setup/`** (after `git clone https://github.com/borean/local-agent-setup ~/local-agent-setup`).

---

## INITIAL CONTEXT (read me first)

You are setting up a medical research workstation for a Turkish pediatric endocrinologist (or their colleague). Read these BEFORE touching the system:

1. `/Users/$USER/local-agent-setup/README.md` — overview
2. `/Users/$USER/local-agent-setup/docs/local_llm_plan.md` — architecture + compliance
3. `/Users/$USER/local-agent-setup/docs/v3_changes.md` — latest design decisions
4. `/Users/$USER/local-agent-setup/docs/harness_brief.md` — why Hermes Agent Desktop won
5. `/Users/$USER/local-agent-setup/system-prompts/karpathy-12-rules.md` — apply these rules to your own work during setup
6. `/Users/$USER/local-agent-setup/references/compliance-primer.md` — KVKK/GDPR/HIPAA
7. `/Users/$USER/local-agent-setup/references/preflight-install-order.md` — the 5-step install order (you will execute it as Phase 0)

After reading: you understand that **you (the frontier model) will be uninstalled after setup**. The human's daily-use stack will be:
- `llama-server` (llama.cpp Metal) on `localhost:11434` serving Qwen 3.6 27B or 35B-A3B
- `llama-server` on `localhost:11436` serving LFM2.5-350M (always-warm tool-call router)
- Hermes Agent Desktop as the GUI
- The 78 SKILL.md files in `~/.agents/skills/`
- 11 hooks in `~/.agents/hooks/`
- 7 launchctl cron tasks
- Little Snitch "Research Mode" profile

Your job is to install all of that and verify it works before printing the hand-off message.

---

## PRE-FLIGHT — ASK THE HUMAN ONCE

Run these exact questions back-to-back. Capture answers; do not ask again.

```
1. Confirm hardware:
   $ system_profiler SPHardwareDataType | grep -E "Chip|Memory"
   Expected: Apple Silicon M3 or M4, 32 GB+ RAM. If <32 GB, warn user
   that 27B dense will be painful (<14 tok/s); 35B-A3B still usable.

2. Zotero library path:
   Default: ~/Zotero
   If different, ask user.

3. IRB project ID for audit folder naming:
   Format suggestion: IRB-YYYY-NNN
   If user has no active IRB, prompt for "RESEARCH-{free-text-tag}".

4. First-paper user?
   y/n. If yes, downstream skills will use --mode generic for style-calibration
   and --mode uncalibrated for devils-advocate.

5. Username for voice profile file:
   Default: $USER
   This becomes ~/.agents/system-prompts/{username}-voice.md

6. Sudo password ready:
   You will need it for: brew, launchctl, Little Snitch profile install.

7. Field for generic-mode style baseline (only if first-paper):
   Options: "pediatric endocrinology" | "oncology" | "internal medicine" | "surgery" | other

8. Hermes Agent Desktop OR Goose Desktop?
   Default: Hermes Agent Desktop (per harness_brief.md decision).
   Both are SKILL.md-compatible; pick Hermes unless user has a preference.
```

After this block, commit each answer to `~/.research/setup-answers.yaml` for audit.

---

## PHASE 0 — PRE-FLIGHT INFRASTRUCTURE (~5-15 min depending on tier choices)

**Tiered**, per `references/preflight-install-order.md`. Air-gapped medical research has no API keys to manage and no providers to route, so we install only what's strictly useful.

```bash
# Homebrew check
which brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# ─── MANDATORY ─────────────────────────────────────────────────────────
brew install uv pipx direnv
pipx ensurepath
grep -q 'direnv hook' ~/.zshrc || echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc

# Raindrop Workshop (local-first agent debugger by Ben Hylak — covers audit)
curl -fsSL https://raindrop.sh/install | bash

# Lessons file
mkdir -p ~/.research && touch ~/.research/lessons.md

# Per-project .envrc template for online lookups (used during brief Setup Mode lifts)
mkdir -p ~/.research/projects
cat > ~/.research/projects/.envrc.example <<'ENVRC'
# Place this as .envrc in your project folder; direnv auto-loads when you cd in.
# Then `direnv allow` once to authorize.
# These keys are INERT during air-gap Research Mode (Little Snitch blocks egress).
# They activate only during a momentary Setup-Mode lift.

export PUBMED_API_KEY="your-key-here"
export CROSSREF_USER_AGENT="ResearchPipeline/1.0 (mailto:you@example.edu)"
export OPENALEX_EMAIL="you@example.edu"
ENVRC

# ─── DEFERRED (install when user writes their first eval) ──────────────
# pipx install inspect-ai
# Skip during initial setup. Add the day you start measuring your skills.

# ─── FALLBACK (install only if we drop Raindrop) ──────────────────────
# mitmproxy is HTTP-level wiretap at localhost:11434.
# Raindrop Workshop already covers this semantically with richer structure
# (turn-level / tool-level / subagent spans). Don't run both — Raindrop is the pick.
# If Raindrop is ever dropped from the stack: `brew install mitmproxy` and
# point it at :11434 to keep KVKK Art. 12 HTTP audit coverage.

# ─── DROPPED (redundant for our use case) ──────────────────────────────
# litellm — no providers to route, no budget caps to enforce, audit covered.
# 1Password CLI / doppler — overkill for our threat model. FileVault + .envrc is enough.

# Verification
uv --version && which pipx && raindrop --version || \
    echo "WARN: Raindrop CLI not found; check ~/.local/bin in PATH"
direnv --version
```

Log to `~/.research/lessons.md` any package that failed and how you worked around it.

---

## PHASE 1 — INFERENCE LAYER (~30 min, mostly download time)

**Format auto-detected by device**. M-series Mac → MLX (Apple-native, ~60% faster). Everything else → GGUF via llama.cpp (universal).

```bash
# Detect device
CHIP=$(system_profiler SPHardwareDataType 2>/dev/null | grep "Chip:" | awk -F: '{print $2}' | xargs)
RAM_GB=$(($(sysctl -n hw.memsize 2>/dev/null || echo 0) / 1024 / 1024 / 1024))
echo "Device: ${CHIP:-non-Apple}, ${RAM_GB} GB RAM"

# Auto-pick format
if [[ "$CHIP" == *"M1"* || "$CHIP" == *"M2"* || "$CHIP" == *"M3"* || "$CHIP" == *"M4"* ]]; then
    INFERENCE_FORMAT="mlx"
    echo "✓ M-series detected → MLX (Apple-native, ~80 tok/s for Qwen 3.6 35B-A3B on M3 Max)"
else
    INFERENCE_FORMAT="gguf"
    echo "✓ Non-Apple-Silicon → GGUF via llama.cpp (universal, ~30-50 tok/s depending on hardware)"
fi

mkdir -p ~/.research/{models,logs,services}

# Install runtime
if [ "$INFERENCE_FORMAT" = "mlx" ]; then
    pipx install mlx-lm
    pipx install mlx-vlm   # for vision support (Qwen 3.6 35B-A3B has vision)

    # Download MLX-converted models
    huggingface-cli download \
        mlx-community/Qwen3.6-35B-A3B-4bit-MLX \
        --local-dir ~/.research/models/Qwen3.6-35B-A3B-MLX-4bit &

    huggingface-cli download \
        mlx-community/Qwen3.6-27B-4bit-MLX \
        --local-dir ~/.research/models/Qwen3.6-27B-MLX-4bit &

    # LFM2.5 + Turkish-Gemma may not yet have MLX variants; fall back to GGUF for these:
    huggingface-cli download \
        LiquidAI/LFM2.5-350M-tool-use-GGUF \
        LFM2.5-350M-tool-use-Q8_0.gguf \
        --local-dir ~/.research/models &
else
    brew install llama.cpp

    huggingface-cli download \
        unsloth/Qwen3.6-35B-A3B-GGUF \
        Qwen3.6-35B-A3B-Q4_K_M.gguf \
        --local-dir ~/.research/models &

    huggingface-cli download \
        unsloth/Qwen3.6-27B-GGUF \
        Qwen3.6-27B-Q4_K_M.gguf \
        --local-dir ~/.research/models &

    huggingface-cli download \
        LiquidAI/LFM2.5-350M-tool-use-GGUF \
        LFM2.5-350M-tool-use-Q8_0.gguf \
        --local-dir ~/.research/models &
fi

# Optional Turkish model — always GGUF (LFM2.5 + Turkish-Gemma not yet in MLX format as of May 2026)
if [ "$FIELD" = "pediatric endocrinology" ]; then
    huggingface-cli download \
        ytu-ce-cosmos/Turkish-Gemma-9b-T1-GGUF \
        Turkish-Gemma-9b-T1-Q4_K_M.gguf \
        --local-dir ~/.research/models &
fi

wait

# Verify download integrity
cd ~/.research/models && find . -name "*.gguf" -o -name "*.safetensors" -o -name "*.npz" | xargs sha256sum > checksums.txt 2>/dev/null

# Download GGUFs (in parallel where possible — wget in background)
huggingface-cli download \
    unsloth/Qwen3.6-35B-A3B-GGUF \
    Qwen3.6-35B-A3B-Q4_K_M.gguf \
    --local-dir ~/.research/models &

huggingface-cli download \
    unsloth/Qwen3.6-27B-GGUF \
    Qwen3.6-27B-Q4_K_M.gguf \
    --local-dir ~/.research/models &

huggingface-cli download \
    LiquidAI/LFM2.5-350M-tool-use-GGUF \
    LFM2.5-350M-tool-use-Q8_0.gguf \
    --local-dir ~/.research/models &

# If Turkish user
[ "$FIELD" = "pediatric endocrinology" ] && huggingface-cli download \
    ytu-ce-cosmos/Turkish-Gemma-9b-T1-GGUF \
    Turkish-Gemma-9b-T1-Q4_K_M.gguf \
    --local-dir ~/.research/models &

wait

# Verify download integrity
cd ~/.research/models && sha256sum *.gguf > checksums.txt
```

Write launchctl plists (two services). Server binary depends on inference format:

- `INFERENCE_FORMAT=mlx` → `mlx_lm.server` (from the mlx-lm pipx install)
- `INFERENCE_FORMAT=gguf` → `llama-server` (from llama.cpp brew install)

Both expose an OpenAI-compatible HTTP API on the same port — downstream skills don't care which.

```bash
# Resolve server binary path + model arg
if [ "$INFERENCE_FORMAT" = "mlx" ]; then
    SERVER_BIN=$(pipx environment --value PIPX_LOCAL_VENVS)/mlx-lm/bin/mlx_lm.server
    QWEN_MODEL_ARG="--model ~/.research/models/Qwen3.6-35B-A3B-MLX-4bit"
    LFM_MODEL_ARG="--model ~/.research/models/LFM2.5-350M-tool-use-Q8_0.gguf"  # fall back to GGUF via llama.cpp; install both runtimes if needed
    SERVER_FLAGS="--host 127.0.0.1 --trust-remote-code"
else
    SERVER_BIN=/opt/homebrew/bin/llama-server
    QWEN_MODEL_ARG="--model ~/.research/models/Qwen3.6-35B-A3B-Q4_K_M.gguf"
    LFM_MODEL_ARG="--model ~/.research/models/LFM2.5-350M-tool-use-Q8_0.gguf"
    SERVER_FLAGS="--ctx-size 32768 --n-gpu-layers 999 --host 127.0.0.1 --mlock --jinja --chat-template chatml --api-key local"
fi

# Service A: Qwen 3.6 35B-A3B on :11434 (default loaded model)
cat > ~/.research/services/com.bora.llama-server.qwen.plist <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.bora.llama-server.qwen</string>
  <key>ProgramArguments</key>
  <array>
    <string>/opt/homebrew/bin/llama-server</string>
    <string>--model</string>
    <string>/Users/_USER_/.research/models/Qwen3.6-35B-A3B-Q4_K_M.gguf</string>
    <string>--ctx-size</string><string>32768</string>
    <string>--n-gpu-layers</string><string>999</string>
    <string>--host</string><string>127.0.0.1</string>
    <string>--port</string><string>11434</string>
    <string>--mlock</string>
    <string>--jinja</string>
    <string>--chat-template</string><string>chatml</string>
    <string>--api-key</string><string>local</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardOutPath</key><string>/Users/_USER_/.research/logs/llama-server-qwen.log</string>
  <key>StandardErrorPath</key><string>/Users/_USER_/.research/logs/llama-server-qwen.err</string>
</dict>
</plist>
PLIST
sed -i '' "s|_USER_|$USER|g" ~/.research/services/com.bora.llama-server.qwen.plist

# Service B: LFM2.5-350M tool-call router on :11436 (always warm)
cat > ~/.research/services/com.bora.lfm-router.plist <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.bora.lfm-router</string>
  <key>ProgramArguments</key>
  <array>
    <string>/opt/homebrew/bin/llama-server</string>
    <string>--model</string>
    <string>/Users/_USER_/.research/models/LFM2.5-350M-tool-use-Q8_0.gguf</string>
    <string>--ctx-size</string><string>8192</string>
    <string>--n-gpu-layers</string><string>999</string>
    <string>--host</string><string>127.0.0.1</string>
    <string>--port</string><string>11436</string>
    <string>--mlock</string>
    <string>--api-key</string><string>local</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
</dict>
</plist>
PLIST
sed -i '' "s|_USER_|$USER|g" ~/.research/services/com.bora.lfm-router.plist

# Load both
launchctl bootstrap gui/$(id -u) ~/.research/services/com.bora.llama-server.qwen.plist
launchctl bootstrap gui/$(id -u) ~/.research/services/com.bora.lfm-router.plist

# Wait for services to warm up
sleep 15

# Verify
curl -s http://localhost:11434/v1/models | jq -e '.data[0].id' || { echo "FAIL: Qwen not responding"; exit 1; }
curl -s http://localhost:11436/v1/models | jq -e '.data[0].id' || { echo "FAIL: LFM2.5 not responding"; exit 1; }

# Quick inference smoke test
curl -s http://localhost:11434/v1/chat/completions \
    -H "Authorization: Bearer local" \
    -d '{"messages":[{"role":"user","content":"Reply with exactly: OK"}],"max_tokens":5}' \
    | jq -r '.choices[0].message.content'
# Expected: "OK" (or close — model may add punctuation)
```

If both services respond: Phase 1 complete.

---

## PHASE 2 — SKILLS + HOOKS + SYSTEM PROMPTS (~5 min)

```bash
mkdir -p ~/.agents/{skills,hooks,system-prompts,state}

# System prompts — concatenate Karpathy + air-gap preamble
cp ~/local-agent-setup/system-prompts/karpathy-12-rules.md ~/.agents/system-prompts/
cat > ~/.agents/system-prompts/air-gap-preamble.md <<'PROMPT'
## Air-gap mode preamble

You are running on a Turkish pediatric endocrinologist's local Qwen 3.6 model.
This machine is currently air-gapped (Little Snitch Research Mode).

Rules in addition to Karpathy 12:
1. Patient data NEVER appears in your response in a form that could identify them.
   Use TCKN→[TCKN], MRN→[MRN], "April 14"→"week 12 of treatment".
2. If a tool you'd normally use needs internet, ask the user via the
   `request-momentary-internet` skill — do NOT silently fail.
3. Cite every research claim with [bibkey:page] — these get verified against
   the local Zotero corpus via paperqa-verify-citation.
4. If you fabricate a method or claim, expect anti-leakage skill to flag it
   with [MATERIAL GAP] tags. Avoid the embarrassment — only state what you
   can ground.
5. When in doubt about whether to act, emit a Material Passport and ask.
PROMPT

# Skills — copy entire bundle
cp -r ~/local-agent-setup/skills/* ~/.agents/skills/

# Hooks — copy and ensure executable
cp ~/local-agent-setup/hooks/*.sh ~/.agents/hooks/
chmod +x ~/.agents/hooks/*.sh

# Voice profile placeholder (will be filled in Phase 5)
touch ~/.agents/system-prompts/${USERNAME}-voice.md

# Pin upstream cherry-pick commits
# (For each coding/{google,mattpocock,vercel,shadcn} skill, fetch the pinned content)
# We do this as a separate script ~/local-agent-setup/scripts/pin-cherry-picks.sh
bash ~/local-agent-setup/scripts/pin-cherry-picks.sh
```

---

## PHASE 3 — PYTHON + R + QUARTO + TEX (~20 min)

```bash
# System deps
brew install python@3.13 R quarto pandoc imagemagick inkscape
brew install --cask basictex  # smaller TeX install; sufficient for Quarto/journal PDF

# Python venv via uv
python3.13 -m venv ~/.research/venv
source ~/.research/venv/bin/activate
uv pip install -r ~/local-agent-setup/setup-prompts/medical-research-requirements.txt

# Verify Python stack
python -c "import pandas, numpy, scipy, statsmodels, lifelines, pingouin, matplotlib, seaborn; print('Python OK')"

# Wheelhouse fallback for offline future installs
mkdir -p ~/.research/wheelhouse
uv pip download -r ~/local-agent-setup/setup-prompts/medical-research-requirements.txt -d ~/.research/wheelhouse/

# R via renv
R --vanilla -e 'install.packages("renv", repos="https://cran.rstudio.com")'
Rscript ~/local-agent-setup/setup-prompts/medical-research-renv.R

# Verify R stack
R --vanilla -e 'library(tidyverse); library(gtsummary); library(survival); library(meta); cat("R OK\n")'

# Quarto extensions cache (offline-ready)
quarto install extension quarto-journals/jama --no-prompt
quarto install extension quarto-journals/nejm --no-prompt
quarto install extension quarto-journals/lancet --no-prompt
quarto install extension quarto-journals/elsevier --no-prompt
```

---

## PHASE 4 — CACHES + ZOTERO INDEX (~30 min, mostly download)

```bash
mkdir -p ~/Research/cache/{guidelines,references,templates,wheelhouse}

# LEANN index from Zotero
pipx install leann-core leann-backend-hnsw leann
leann build \
    --source ${ZOTERO_PATH:-~/Zotero/storage} \
    --embed-model bge-m3 \
    --output ~/.leann/peds-endo-corpus

# Pull bge-m3 embeddings into llama-server (separate small service)
huggingface-cli download \
    BAAI/bge-m3-gguf \
    bge-m3-q4_K.gguf \
    --local-dir ~/.research/models

# Guideline caches (the slow part — but worth it)
# We curate a list per society in ~/local-agent-setup/scripts/download-guidelines.sh
bash ~/local-agent-setup/scripts/download-guidelines.sh \
    --societies "magicapp,ispad,espe,cedd,aap,ata" \
    --output ~/Research/cache/guidelines/

# Normative reference data (growth charts, lab refs)
# Strategy: prefer Bora's existing ceddcozum NPM package (most curated peds-endo
# references already exist there); fall back to scripts/download-references.sh
# for sources not in ceddcozum (WHO/CDC).

if [ "$FIELD_SLUG" = "pediatric-endocrinology" ] || [ "${USE_CEDDCOZUM:-yes}" = "yes" ]; then
    if command -v npx >/dev/null 2>&1; then
        # ceddcozum has Neyzi LMS + other Turkish peds-endo references curated.
        # If --export-references is not yet available in the package, this is
        # a TODO for Bora to add it. Best-effort:
        npx -y ceddcozum@latest --export-references --output ~/Research/cache/references/ 2>/dev/null || {
            echo "  ℹ️  ceddcozum --export-references not available."
            echo "     TODO for Bora: add 'export-references' command to ceddcozum CLI."
            echo "     For now: clone the source + copy data files manually:"
            echo "       git clone https://github.com/borean/ceddcozum /tmp/ceddcozum-src"
            echo "       cp -r /tmp/ceddcozum-src/src/data/* ~/Research/cache/references/"
            echo "       (verify the path; tool may have refactored)"
        }
    fi
fi

# Generic fallback — runs always to fill WHO/CDC and pointer files
bash ~/local-agent-setup/scripts/download-references.sh \
    --output ~/Research/cache/references/

# Journal LaTeX templates
git clone --depth=1 https://github.com/quarto-journals/jama ~/Research/cache/templates/jama
git clone --depth=1 https://github.com/quarto-journals/nejm ~/Research/cache/templates/nejm
git clone --depth=1 https://github.com/quarto-journals/lancet ~/Research/cache/templates/lancet
git clone --depth=1 https://github.com/quarto-journals/elsevier ~/Research/cache/templates/elsevier
```

---

## PHASE 4.5 — FIELD PRESET GENERATION (~10 min, requires brief online window)

Generate the user's field-specific voice baseline **fresh from current author guidelines**, not from hardcoded stubs. This is "real-time" generation:

```bash
# Determine field slug from earlier preflight Q&A
FIELD_SLUG=$(echo "$FIELD" | tr ' /' '-' | tr 'A-Z' 'a-z')

# 1. Check if we have a reference example to use as a structural template
EXAMPLE=~/local-agent-setup/references/field-preset-examples/${FIELD_SLUG}.md
if [ ! -f "$EXAMPLE" ]; then
    # Fall back to peds-endo example as structure (its sections generalize)
    EXAMPLE=~/local-agent-setup/references/field-preset-examples/pediatric-endocrinology.md
    echo "  ℹ️  No example for '$FIELD'; using peds-endo as structural template"
fi

# 2. Identify target journals for this field (ask user or default to common picks)
# Default mapping (user can override during pre-flight Q&A)
case "$FIELD_SLUG" in
    pediatric-endocrinology) TARGET_JOURNALS=("JCEM" "JPEM" "Diabetes Care" "Frontiers Endocrinology" "Lancet D&E") ;;
    oncology)                TARGET_JOURNALS=("JCO" "Lancet Oncology" "Cancer" "JAMA Oncology" "Annals of Oncology") ;;
    internal-medicine)       TARGET_JOURNALS=("NEJM" "JAMA Internal Medicine" "Annals of Internal Medicine" "BMJ" "JGIM") ;;
    surgery)                 TARGET_JOURNALS=("Annals of Surgery" "JAMA Surgery" "BJS" "Ann Surg Oncol" "Surgery") ;;
    *) TARGET_JOURNALS=()   # user will provide via interactive prompt
esac

# 3. Lift Research Mode briefly to fetch each journal's current author guidelines
# (Research Mode not yet active during setup; this works inline)
mkdir -p ~/Research/cache/journal-guidelines
for journal in "${TARGET_JOURNALS[@]}"; do
    JSLUG=$(echo "$journal" | tr ' /' '-' | tr 'A-Z' 'a-z')
    echo "  → fetching author guidelines for $journal..."
    # Each journal needs its own fetch URL — frontier LLM running this script
    # should look up the current URL and fetch the page, parse, save as YAML
    # See skills/shared/07-online-lookup/SKILL.md for the schema
    # Placeholder — frontier LLM fills in:
    # curl -sL "<journal-guideline-url>" -o "/tmp/${JSLUG}-raw.html"
    # parse to YAML per the schema in online-lookup
    # save to ~/Research/cache/journal-guidelines/${JSLUG}.yaml
done

# 4. Synthesize field preset from template + fetched guidelines
# The setup-time frontier LLM (Claude Code / ChatGPT-via-browser / etc.) does this:
# - Read the example at $EXAMPLE
# - Read all the journal guideline YAMLs
# - Synthesize a coherent voice baseline for THIS user's exact field + target journals
# - Include their preferred language (TR/EN code-switch ratio, if applicable)
# - Write to ~/.agents/system-prompts/field-presets/${FIELD_SLUG}.md

PRESET_PATH=~/.agents/system-prompts/field-presets/${FIELD_SLUG}.md
# The frontier LLM doing setup writes this file based on $EXAMPLE + fetched guidelines.
# Final file should follow the structure of references/field-preset-examples/pediatric-endocrinology.md

# 5. Verify the preset was written
[ -f "$PRESET_PATH" ] || { echo "FAIL: field preset not generated at $PRESET_PATH"; exit 1; }
echo "✓ Field preset generated: $PRESET_PATH ($(wc -l < $PRESET_PATH) lines)"
```

**Note for the frontier LLM running setup**: this phase requires you to actually fetch current author guidelines from journal websites and synthesize a field-specific preset. Don't skip; don't fall back to the example verbatim. The whole point of doing this at setup time is to get current information.

If the user's field isn't in the case statement above, prompt: "What 3-5 journals do you target most often? I'll fetch their current author guidelines."

---

## PHASE 5 — STYLE CALIBRATION (one-shot, ~5 min)

```bash
# If first_paper: false, ask user for paths to 3-5 of their published papers
if [ "$FIRST_PAPER" = "false" ]; then
    # Run skill in calibrate mode
    bash ~/.agents/skills/research/manuscript/style-calibration/invoke.sh \
        --mode calibrate \
        --papers "${USER_PAPERS[@]}" \
        --username "$USERNAME"
else
    # First-paper user — generic baseline
    bash ~/.agents/skills/research/manuscript/style-calibration/invoke.sh \
        --mode generic \
        --field "$FIELD" \
        --username "$USERNAME"
fi

# Verify voice profile was written
cat ~/.agents/system-prompts/${USERNAME}-voice.md | head -20
```

---

## PHASE 6 — DAILY-USE GUI (Hermes Agent Desktop, ~5 min)

```bash
# Install Hermes Agent Desktop
brew install --cask hermes-agent

# Or via direct download if cask not available:
# curl -L https://hermesatlas.com/hermes-agent-desktop.dmg -o /tmp/hermes.dmg
# hdiutil attach /tmp/hermes.dmg && cp -r /Volumes/Hermes/Hermes\ Agent.app /Applications/

# Configure via plist (avoid first-run wizard for headless setup)
defaults write com.nousresearch.hermes-agent provider "openai-compatible"
defaults write com.nousresearch.hermes-agent base_url "http://localhost:11434/v1"
defaults write com.nousresearch.hermes-agent api_key "local"
defaults write com.nousresearch.hermes-agent default_model "qwen3.6:35b-a3b-q4_K_M"
defaults write com.nousresearch.hermes-agent skills_path "$HOME/.agents/skills"
defaults write com.nousresearch.hermes-agent hooks_path "$HOME/.agents/hooks"
defaults write com.nousresearch.hermes-agent self_evolving_skills_enabled -bool true
defaults write com.nousresearch.hermes-agent raindrop_local_debugger "http://localhost:5899"

# Open it once to confirm it launches and finds the local model
open -g /Applications/Hermes\ Agent.app
sleep 5
# Check it didn't error
osascript -e 'tell application "System Events" to get name of every process' | grep -q "Hermes Agent" \
    || { echo "FAIL: Hermes Agent did not launch"; exit 1; }
```

---

## PHASE 7 — AIR-GAP CONFIGURATION (~10 min)

```bash
# Little Snitch — install if not present
brew install --cask little-snitch
open /Applications/Little\ Snitch\ Configuration.app

# Tell user to install the Research Mode profile manually
cat <<EOF
ACTION REQUIRED — install Little Snitch profile:

1. Little Snitch Configuration is open.
2. File → Import Rules…
3. Pick: ~/local-agent-setup/setup-prompts/little-snitch-research-mode.lsrules
4. In the toolbar, switch profile dropdown to "Research Mode"
5. Confirm by checking the menu-bar icon shows "Research Mode" active.

Reply with "snitch-installed" when done.
EOF

# Wait for user confirmation
read -r CONFIRMATION
[ "$CONFIRMATION" = "snitch-installed" ] || { echo "FAIL: Little Snitch not confirmed"; exit 1; }

# Other air-gap hygiene
# Disable iCloud Desktop & Documents sync
defaults write com.apple.bird CloudDocsEnabled -bool false 2>/dev/null || true

# Exclude ~/Research from Time Machine
sudo tmutil addexclusion -p ~/Research

# Disable Spotlight web suggestions
defaults write com.apple.lookup.shared LookupSuggestionsDisabled -bool true

# Audit folder skeleton
mkdir -p ~/Research/audit/$(date +%F)
echo "$(date)  setup-complete-by-frontier-llm" > ~/Research/audit/$(date +%F)/setup.log
echo "${IRB_ID}" > ~/Research/audit/$(date +%F)/irb-id.txt
```

---

## PHASE 8 — CRON / LAUNCHD SCHEDULED TASKS (~5 min)

```bash
# 7 air-gap cron tasks per docs/v3_changes.md
mkdir -p ~/Library/LaunchAgents

for task in airgap-nightly-handoff llama-server-health audit-rotate leann-index-refresh; do
    # Daily tasks at 03:00-03:45
    bash ~/local-agent-setup/scripts/install-cron.sh --task "$task" --schedule "daily-03"
done

for task in manuscript-snapshot passport-cleanup skill-usage-report; do
    # Weekly tasks Sunday 04:00-05:00
    bash ~/local-agent-setup/scripts/install-cron.sh --task "$task" --schedule "weekly-sun-04"
done

# Verify
launchctl list | grep -E 'airgap-nightly-handoff|llama-server-health|audit-rotate|leann-index-refresh|manuscript-snapshot|passport-cleanup|skill-usage-report' | wc -l
# Expected: 7
```

---

## PHASE 9 — VERIFICATION SUITE (~10 min)

Run these in order; halt on any failure.

```bash
# Test 1: llama-server endpoint
curl -s http://localhost:11434/v1/chat/completions \
    -H "Authorization: Bearer local" \
    -d '{"messages":[{"role":"user","content":"What is 2+2? One word."}],"max_tokens":10}' \
    | jq -e '.choices[0].message.content' || { echo "TEST 1 FAIL"; exit 1; }

# Test 2: Activate Little Snitch Research Mode (user already did in Phase 7)
# Verify via tcpdump that no external traffic during a 10-sec window
# (note: tcpdump needs sudo)
TRAFFIC=$(sudo tcpdump -i any -c 50 -n 'not host 127.0.0.1 and not host ::1' 2>/dev/null | wc -l)
[ "$TRAFFIC" -eq 0 ] || { echo "TEST 2 FAIL: external traffic during air-gap"; exit 1; }

# Test 3: Wi-Fi airplane test
networksetup -setairportpower en0 off
sleep 3
curl -s http://localhost:11434/v1/chat/completions \
    -H "Authorization: Bearer local" \
    -d '{"messages":[{"role":"user","content":"Reply: ok"}],"max_tokens":5}' \
    | jq -e '.choices[0].message.content' || { echo "TEST 3 FAIL: chat broken in airplane mode"; exit 1; }
networksetup -setairportpower en0 on
echo "TEST 3 PASS: chat works offline ✓"

# Test 4: skill discovery
SKILL_COUNT=$(find ~/.agents/skills -name "SKILL.md" | wc -l)
[ "$SKILL_COUNT" -ge 70 ] || { echo "TEST 4 FAIL: only $SKILL_COUNT skills discovered, expected ≥70"; exit 1; }

# Test 5: hook fire — simulate session start
echo '{"session_id":"verify-test","cwd":"/tmp"}' | bash ~/.agents/hooks/session-start-airgap.sh | head -5

# Test 6: audit log creation
ls -la ~/Research/audit/$(date +%F)/ || { echo "TEST 6 FAIL: audit folder missing"; exit 1; }

# Test 7: Hermes Desktop is running with correct config
defaults read com.nousresearch.hermes-agent base_url | grep -q "localhost:11434" \
    || { echo "TEST 7 FAIL: Hermes config wrong"; exit 1; }

# Test 8: R + ellmer can talk to local llama-server
R --vanilla -e 'library(ellmer); chat <- chat_openai(base_url="http://localhost:11434/v1", api_key="local", model="qwen3.6:35b-a3b-q4_K_M"); cat(chat$chat("Reply OK"))' \
    | grep -q "OK" || { echo "TEST 8 FAIL: R bridge broken"; exit 1; }

# Test 9: Sample literature query through LEANN
leann query ~/.leann/peds-endo-corpus --q "type 1 diabetes pediatric" --top 3 --json \
    | jq -e '.results | length > 0' || { echo "TEST 9 FAIL: LEANN returned no results"; exit 1; }

# Test 10: Material Passport emit + resume round-trip
echo '{"stage":"verify-test","ledger_path":"/tmp/verify-ledger.jsonl"}' > /tmp/verify-input.json
echo '{"ts":"2026-05-18T00:00:00","event":"test","content":"hello"}' > /tmp/verify-ledger.jsonl
bash ~/.agents/skills/shared/02-material-passport-emit/invoke.sh < /tmp/verify-input.json \
    | jq -e '.passport_hash' || { echo "TEST 10 FAIL: passport emit broken"; exit 1; }

echo ""
echo "==============================================="
echo "  VERIFICATION SUITE: 10/10 PASSED"
echo "==============================================="
```

---

## HAND-OFF — PRINT THIS TO THE HUMAN

After all 10 tests pass:

```
✅ Setup complete. Results:

  • llama-server running on :11434 (Qwen 3.6 35B-A3B)
  • LFM2.5-350M router on :11436 (always warm)
  • 78 skills installed at ~/.agents/skills/
  • 11 hooks at ~/.agents/hooks/
  • 7 cron tasks scheduled
  • Voice profile: $([ "$FIRST_PAPER" = "true" ] && echo "GENERIC ($FIELD)" || echo "CALIBRATED from your papers")
  • Audit folder: ~/Research/audit/$(date +%F)/
  • Verification suite: 10/10 passed

🔒 To activate air-gap mode and start working:

  1. Quit me (the frontier LLM you're talking to). Then:
     System Settings → General → Apps → Uninstall:
     □ Claude Code
     □ OpenAI Codex
     □ Gemini CLI
     (Whichever one I am.)

  2. Little Snitch menu icon → confirm profile shows "Research Mode"

  3. Launch Hermes Agent Desktop from /Applications/

  4. In Hermes, type your first session opener:
        session-launch <task description>
     e.g. "session-launch I want to write the introduction of my GLP-1 paper"

  5. Optional but recommended on day 1:
        - Read references/first-paper-onboarding.md (if you're new)
        - Read references/colleague-onboarding-tutorial.md
        - Try the verification suite again in 24h to confirm cron tasks fired

Your local Qwen 3.6 is now your research assistant. Audit log is in
~/Research/audit/. KVKK Art. 12 trail starts now.

That's it. I'm leaving. Good luck.

📚 If you ever need to refresh caches (guidelines, references, templates),
   invoke the `request-momentary-internet` skill — it walks you through
   the audit-logged brief lift of Research Mode.

📝 If something breaks: ~/.research/lessons.md captures my install notes.
   Last 50 lines of llama-server logs: tail ~/.research/logs/llama-server-qwen.log
```

---

## Notes for the frontier LLM running this

- **Apply Karpathy 12 rules to your OWN setup work.** Especially:
  - Rule 4: define success = all 10 verification tests pass
  - Rule 9: tests verify intent (model responds offline) not just behavior (process is running)
  - Rule 10: checkpoint after each Phase — write a brief status to `~/.research/setup-progress.md`
  - Rule 12: fail loud — if Phase 4 only got 3 of 6 society guideline caches, say so explicitly

- **Material Passport for setup itself**: after each Phase, append a JSON line to `~/.research/setup-ledger.jsonl` with phase, status, key choices. If you get killed mid-setup, the user can paste the latest hash to a new agent session to resume.

- **Do not skip Phase 9 verification.** A "setup complete" claim without 10/10 tests is a Rule-12 violation.

- **Write to `~/.research/lessons.md`** as you go. Every workaround. Every package that wasn't where you expected. Every brew formula that conflicted. Future setups across the user's team will reference this.

- **Don't paste raw patient data into your own context.** This setup is about preparing the user's machine to handle PHI, not about you handling it. If asked to "test the setup with some real patient data," refuse and use a synthetic fixture.

- **Approve big choices via human.** Default to what the README says, but the user has veto on: daily-use GUI, model variant, R vs Python emphasis, journal LaTeX templates pulled.

---

## If you fail

- Halt at the failed Phase
- Emit a Material Passport for setup progress so far
- Print clearly:
  - Which Phase failed
  - What test failed within that Phase
  - The last 20 lines of relevant log
  - Three suggested next actions
- Do NOT try to "patch around" a fundamental failure (e.g., if Metal isn't working, don't fall back to CPU silently — tell the user)

## Estimated total time

~2 hours wall-clock with active supervision, of which ~1 hour is download time (parallelizable) and ~10 min is human input time.

For a colleague rollout: this whole prompt + supervision = 2 hours per person. Versus the 12-25 hours saved on their first manuscript with a properly-set-up system. Net win after one manuscript.
