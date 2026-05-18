# SETUP_PROMPT.md

**For**: a frontier AI agent (Claude Code, OpenAI Codex, Gemini CLI) running on the human's laptop with shell + filesystem access, currently online.

**Goal**: leave the laptop with a fully-local, air-gapped, medical-research LLM environment. After your setup completes, the human will uninstall you and cut internet for clinical work.

**Paste this entire file as your initial prompt to Claude Code / Codex / Gemini CLI from inside `~/local-agent-setup/`** (after `git clone https://github.com/borean/local-agent-setup ~/local-agent-setup`).

---

## INITIAL CONTEXT (read me first)

You are setting up a medical research workstation for a Turkish pediatric endocrinologist (or their colleague). Read these BEFORE touching the system:

1. `$LOCAL_AGENT_SETUP/README.md` — overview
2. `$LOCAL_AGENT_SETUP/docs/local_llm_plan.md` — architecture + compliance
3. `$LOCAL_AGENT_SETUP/docs/v3_changes.md` — latest design decisions
4. `$LOCAL_AGENT_SETUP/docs/harness_brief.md` — why Hermes Agent Desktop won
5. `$LOCAL_AGENT_SETUP/system-prompts/karpathy-12-rules.md` — apply these rules to your own work during setup
6. `$LOCAL_AGENT_SETUP/references/compliance-primer.md` — KVKK/GDPR/HIPAA
7. `$LOCAL_AGENT_SETUP/references/preflight-install-order.md` — the 5-step install order (you will execute it as Phase 0)
8. `$LOCAL_AGENT_SETUP/references/storage-requirements.md` — disk space breakdown (verified May 2026)
9. `$LOCAL_AGENT_SETUP/lessons.md` — append every workaround you discover to BOTH this repo file AND `~/.research/lessons.md`

After reading: you understand that **you (the frontier model) will be uninstalled after setup**. The human's daily-use stack will be:
- `llama-server` (llama.cpp Metal) on `localhost:11434` serving Qwen 3.6 27B or 35B-A3B
- `llama-server` on `localhost:11436` serving LFM2.5-350M (always-warm tool-call router)
- Hermes Agent Desktop as the GUI
- The ~74 SKILL.md files in `~/.agents/skills/`
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

8. Confirm Hermes Agent Desktop as the daily-use GUI.
   This is the only supported harness in v0.x — see harness_brief.md.
   If user has a hard preference for something else (Cline, Continue, etc.):
   note it and flag as out-of-scope; they install separately after this setup.
```

After this block, commit each answer to `~/.research/setup-answers.yaml` for audit.

---

## PRE-CHECK — port collision + clone-path env var

Before Phase 0, two quick checks to avoid downstream pain:

```bash
# 1. Port 11434 collision check
# Ollama uses :11434 by default. If user has Ollama running, decide:
#   (a) stop Ollama (preferred — single inference backend)
#   (b) remap our llama-server to :11444 (skill defaults work; downstream needs update)
#   (c) accept Ollama as the inference backend (sk-everything-else; complex)
if lsof -i :11434 >/dev/null 2>&1; then
    PID=$(lsof -t -i :11434 | head -1)
    BIN=$(ps -p $PID -o comm= 2>/dev/null)
    echo "⚠️ Port 11434 already in use by: $BIN (pid $PID)"
    echo "Options:"
    echo "  (a) Stop the process — recommended if it's Ollama. Run: 'ollama serve stop' or 'kill $PID'"
    echo "  (b) Remap llama-server to :11444 — set LLAMA_PORT=11444 before continuing"
    echo "  (c) Use the existing :11434 inference backend (manual config; advanced)"
    echo ""
    read -p "Pick a (stop), b (remap), or c (accept) — or quit (q): " choice
    case "$choice" in
        a) kill $PID ; sleep 2 ;;
        b) export LLAMA_PORT=11444 ; export LFM_PORT=11446 ;;
        c) export USE_EXISTING_INFERENCE=true ; echo "Manual config — TODO in lessons.md" ;;
        *) exit 1 ;;
    esac
fi
LLAMA_PORT=${LLAMA_PORT:-11434}
LFM_PORT=${LFM_PORT:-11436}

# 2. LOCAL_AGENT_SETUP env var — the repo location
# Don't hardcode ~/local-agent-setup; let user clone anywhere
if [ -z "${LOCAL_AGENT_SETUP:-}" ]; then
    # Try common locations
    for candidate in ~/local-agent-setup ~/Projects/local-agent-setup ~/code/local-agent-setup ~/Documents/local-agent-setup .; do
        if [ -f "$candidate/SETUP_PROMPT.md" ]; then
            export LOCAL_AGENT_SETUP=$(cd "$candidate" && pwd)
            echo "✓ Repo found at: $LOCAL_AGENT_SETUP"
            break
        fi
    done
    if [ -z "$LOCAL_AGENT_SETUP" ]; then
        echo "FAIL: cannot find the local-agent-setup repo."
        echo "Either clone it: git clone https://github.com/borean/local-agent-setup ~/local-agent-setup"
        echo "Or set LOCAL_AGENT_SETUP=/path/to/your/clone explicitly."
        exit 1
    fi
fi

# Persist these to ~/.research/setup-env for downstream phases
mkdir -p ~/.research
cat > ~/.research/setup-env <<EOF
export LOCAL_AGENT_SETUP=$LOCAL_AGENT_SETUP
export LLAMA_PORT=$LLAMA_PORT
export LFM_PORT=$LFM_PORT
EOF
echo "✓ Setup env saved to ~/.research/setup-env"
```

After the pre-check: all later phases use `$LOCAL_AGENT_SETUP`, `$LLAMA_PORT`, and `$LFM_PORT` instead of hardcoded `~/local-agent-setup` / `11434` / `11436`. Source `~/.research/setup-env` if running phases in a new shell.

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

**Alternative: Ollama** — simpler one-line install, same OAI-compat endpoint:
```bash
brew install ollama
ollama serve &
ollama pull qwen3.6:35b-a3b
# Endpoint: http://localhost:11434/v1 (same as llama-server)
```
If you choose Ollama, **skip the launchctl plist work in this Phase** — Ollama manages its own daemon. The Phase 0 PRE-CHECK detects an existing Ollama on :11434 and offers to accept it as the inference backend. Trade-off: Ollama abstracts the underlying llama.cpp; we lose direct control over `--mlock`, `--ctx-size`, etc. (you set these via Ollama's `Modelfile`).

For Bora's setup we use llama-server/mlx_lm.server direct because we've designed around explicit flags. For colleagues who want the simplest path, **Ollama is fine** and the downstream skills don't notice the difference.

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
cd ~/.research/models && find . -name "*.gguf" -o -name "*.safetensors" -o -name "*.npz" 2>/dev/null | xargs sha256sum > checksums.txt 2>/dev/null
```

**Important — model repo names drift.** Before running the `huggingface-cli download` lines above, **the setup AI must verify each repo exists** by running:

```bash
huggingface-cli scan-cache  # what's already cached
# Then for each candidate repo name, e.g.:
huggingface-cli download --revision=main mlx-community/Qwen3.6-35B-A3B-4bit --max-files=1
```

The names in this prompt (`mlx-community/Qwen3.6-35B-A3B-4bit-MLX`, `LiquidAI/LFM2.5-350M-tool-use-GGUF`, etc.) reflect May 2026 best-guess. They may have been renamed since. If a 404 hits, **search HuggingFace**:

```bash
# Search HF for current canonical names before downloading
huggingface-cli search "Qwen3.6 35B A3B" --limit 10
huggingface-cli search "LFM2.5 350M GGUF" --limit 5
huggingface-cli search "Turkish Gemma" --limit 5
```

Pick the highest-download official repo; pin the commit SHA in `~/.research/lessons.md` for reproducibility.

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

# Build plists from variables (no hardcoded paths).
# Set ProgramArguments differently for MLX vs GGUF.

# Resolve user home
USER_HOME=$HOME

# Service A: Qwen on $LLAMA_PORT
if [ "$INFERENCE_FORMAT" = "mlx" ]; then
    QWEN_PROGRAM_ARGS="
    <string>$SERVER_BIN</string>
    <string>--model</string>
    <string>$USER_HOME/.research/models/Qwen3.6-35B-A3B-MLX-4bit</string>
    <string>--host</string><string>127.0.0.1</string>
    <string>--port</string><string>$LLAMA_PORT</string>
    <string>--trust-remote-code</string>"
else
    QWEN_PROGRAM_ARGS="
    <string>$SERVER_BIN</string>
    <string>--model</string>
    <string>$USER_HOME/.research/models/Qwen3.6-35B-A3B-UD-Q4_K_M.gguf</string>
    <string>--ctx-size</string><string>32768</string>
    <string>--n-gpu-layers</string><string>999</string>
    <string>--host</string><string>127.0.0.1</string>
    <string>--port</string><string>$LLAMA_PORT</string>
    <string>--mlock</string>
    <string>--jinja</string>
    <string>--chat-template</string><string>chatml</string>
    <string>--api-key</string><string>local</string>"
fi

cat > ~/.research/services/com.bora.llama-server.qwen.plist <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.bora.llama-server.qwen</string>
  <key>ProgramArguments</key>
  <array>$QWEN_PROGRAM_ARGS
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardOutPath</key><string>$USER_HOME/.research/logs/llama-server-qwen.log</string>
  <key>StandardErrorPath</key><string>$USER_HOME/.research/logs/llama-server-qwen.err</string>
</dict>
</plist>
PLIST

# Service B: LFM2.5-350M tool-call router on $LFM_PORT (always GGUF; no MLX variant yet)
LLAMA_SERVER_BIN=$(which llama-server || echo "/opt/homebrew/bin/llama-server")
cat > ~/.research/services/com.bora.lfm-router.plist <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.bora.lfm-router</string>
  <key>ProgramArguments</key>
  <array>
    <string>$LLAMA_SERVER_BIN</string>
    <string>--model</string>
    <string>$USER_HOME/.research/models/LFM2.5-350M-Q8_0.gguf</string>
    <string>--ctx-size</string><string>8192</string>
    <string>--n-gpu-layers</string><string>999</string>
    <string>--host</string><string>127.0.0.1</string>
    <string>--port</string><string>$LFM_PORT</string>
    <string>--mlock</string>
    <string>--api-key</string><string>local</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
</dict>
</plist>
PLIST

# Load both
launchctl bootstrap gui/$(id -u) ~/.research/services/com.bora.llama-server.qwen.plist
launchctl bootstrap gui/$(id -u) ~/.research/services/com.bora.lfm-router.plist

# Wait for services to warm up
sleep 15

# Verify
curl -s http://localhost:$LLAMA_PORT/v1/models | jq -e '.data[0].id' || { echo "FAIL: Qwen not responding on :$LLAMA_PORT"; exit 1; }
curl -s http://localhost:$LFM_PORT/v1/models | jq -e '.data[0].id' || { echo "FAIL: LFM2.5 not responding on :$LFM_PORT"; exit 1; }

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
cp $LOCAL_AGENT_SETUP/system-prompts/karpathy-12-rules.md ~/.agents/system-prompts/
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
cp -r $LOCAL_AGENT_SETUP/skills/* ~/.agents/skills/

# Hooks — copy and ensure executable
cp $LOCAL_AGENT_SETUP/hooks/*.sh ~/.agents/hooks/
chmod +x ~/.agents/hooks/*.sh

# Voice profile placeholder (will be filled in Phase 5)
touch ~/.agents/system-prompts/${USERNAME}-voice.md

# Pin upstream cherry-pick commits
# (For each coding/{google,mattpocock,vercel,shadcn} skill, fetch the pinned content)
# We do this as a separate script $LOCAL_AGENT_SETUP/scripts/pin-cherry-picks.sh
bash $LOCAL_AGENT_SETUP/scripts/pin-cherry-picks.sh
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
uv pip install -r $LOCAL_AGENT_SETUP/setup-prompts/medical-research-requirements.txt

# Verify Python stack
python -c "import pandas, numpy, scipy, statsmodels, lifelines, pingouin, matplotlib, seaborn; print('Python OK')"

# Wheelhouse fallback for offline future installs
mkdir -p ~/.research/wheelhouse
uv pip download -r $LOCAL_AGENT_SETUP/setup-prompts/medical-research-requirements.txt -d ~/.research/wheelhouse/

# R via renv
R --vanilla -e 'install.packages("renv", repos="https://cran.rstudio.com")'
Rscript $LOCAL_AGENT_SETUP/setup-prompts/medical-research-renv.R

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
# We curate a list per society in $LOCAL_AGENT_SETUP/scripts/download-guidelines.sh
bash $LOCAL_AGENT_SETUP/scripts/download-guidelines.sh \
    --societies "magicapp,ispad,espe,cedd,aap,ata" \
    --output ~/Research/cache/guidelines/

# Normative reference data (WHO/CDC growth charts, lab refs)
# Note: ceddcozum-style Neyzi LMS data lives INSIDE the ceddcozum CLI tool
# (33 calculator functions in v0.2.2). We integrate that in Phase 5 as
# live callable tools, not as exported data. Don't try to extract here.
bash $LOCAL_AGENT_SETUP/scripts/download-references.sh \
    --output ~/Research/cache/references/

# Journal LaTeX templates
git clone --depth=1 https://github.com/quarto-journals/jama ~/Research/cache/templates/jama
git clone --depth=1 https://github.com/quarto-journals/nejm ~/Research/cache/templates/nejm
git clone --depth=1 https://github.com/quarto-journals/lancet ~/Research/cache/templates/lancet
git clone --depth=1 https://github.com/quarto-journals/elsevier ~/Research/cache/templates/elsevier
```

---

### Field preset generation (continuation of Phase 4 — uses the journal-guidelines cache)

Generate the user's field-specific voice baseline **fresh from current author guidelines**, not from hardcoded stubs. This is "real-time" generation:

```bash
# Determine field slug from earlier preflight Q&A
FIELD_SLUG=$(echo "$FIELD" | tr ' /' '-' | tr 'A-Z' 'a-z')

# 1. Check if we have a reference example to use as a structural template
EXAMPLE=$LOCAL_AGENT_SETUP/references/field-preset-examples/${FIELD_SLUG}.md
if [ ! -f "$EXAMPLE" ]; then
    # Fall back to peds-endo example as structure (its sections generalize)
    EXAMPLE=$LOCAL_AGENT_SETUP/references/field-preset-examples/pediatric-endocrinology.md
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

## PHASE 5 — CEDDCOZUM TOOL INTEGRATION (~5 min)

Bora's `ceddcozum` NPM package (v0.2.2) exposes **33 pediatric clinical calculators as a CLI** with OpenAI-compatible tool schemas. It's already designed for LLM agent use — see `ceddcozum --help` output (`--schemas`, `--args '{"...":"..."}'`).

We integrate it as a **tool palette** for the local Qwen, not as a static data export. Every one of its 33 calculators becomes callable by the agent during a session.

```bash
# Install globally (works on Mac via Homebrew Node; on other systems via nvm)
npm install -g ceddcozum

# Verify
ceddcozum --version  # should print "0.2.2" or later
ceddcozum --list | head -5

# Dump all tool schemas to a location our agent harness can read
mkdir -p ~/.agents/tools
ceddcozum --schemas > ~/.agents/tools/ceddcozum-schemas.json
echo "✓ Dumped $(jq 'length' ~/.agents/tools/ceddcozum-schemas.json) tool schemas"

# Quick sanity test — invoke a calculator with JSON args
ceddcozum auxology --args '{"sex":"male","age":5.5,"height":110,"weight":19}' --format json | jq .

# Install the wrapper that Hermes Agent will use to dispatch calls
# (This skill becomes available immediately; details in skills/coding/bora/ceddcozum-tools/SKILL.md)
cp -r $LOCAL_AGENT_SETUP/skills/coding/bora/ceddcozum-tools ~/.agents/skills/coding/bora/
```

What the agent can do after this phase:

- Compute SDS / percentiles for height, weight, BMI, head circumference (Neyzi, WHO, CDC, IAP references)
- Compute IGF-1 SDS by age + sex
- Convert HbA1c ↔ glucose ↔ fructosamine
- Compute HOMA-IR, QUICKI, glucose:insulin ratio
- Compute BMD SDS + volumetric BMD correction
- Convert steroid doses (glucocorticoid equivalents)
- Compute pediatric blood pressure percentiles
- ...all 33 tools from `ceddcozum --list`

Every call runs **locally**. No network. No PHI leaves the laptop. The agent dispatches via the wrapper skill, which validates inputs against the schema before invoking the CLI.

---

## PHASE 6 — STYLE CALIBRATION (one-shot, ~5 min)

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

## PHASE 7 — HERMES AGENT (CLI + TUI, ~5 min)

**Reality check from v0.9.2 review**: Hermes Agent Desktop **doesn't ship today** (May 19, 2026 — verified). What ships:
- **Hermes Agent v0.14.0** as a PyPI package: `pip install hermes-agent`
- Ink-based **TUI** (terminal UI — still feels GUI-like, but runs inside Terminal.app)
- Shell launcher: just type `hermes`
- Native Desktop app is a TODO at Nous Research (`desktop-pr20059-installers` tag exists but not stable)

So we install the TUI today and bookmark Desktop for later.

```bash
# Install via pipx (isolated env; recommended over pip into system Python)
pipx install hermes-agent
pipx ensurepath

# Verify
hermes --version

# Configure via ~/.hermes/config.yaml (the standard Hermes config path)
mkdir -p ~/.hermes
cat > ~/.hermes/config.yaml <<EOF
provider:
  type: openai-compatible
  base_url: http://localhost:${LLAMA_PORT:-11434}/v1
  api_key: local
  default_model: qwen3.6-35b-a3b

skills_path: $HOME/.agents/skills
hooks_path: $HOME/.agents/hooks
system_prompts_path: $HOME/.agents/system-prompts

self_evolving_skills:
  enabled: true

raindrop:
  local_debugger: http://localhost:5899
  via_plugin: hermes-otel    # per references/hermes-raindrop-bridge.md
EOF

# Optional: install the hermes-otel plugin for Raindrop tracing
hermes plugins install briancaffey/hermes-otel || \
    echo "  ℹ️ hermes-otel install failed; Raindrop bridge optional"

# Make Hermes one-click launchable from Finder
# Create a .command file the user double-clicks (no Terminal commands needed by them after this)
mkdir -p ~/Desktop
cat > ~/Desktop/Hermes.command <<'CMD'
#!/bin/bash
cd "$HOME"
exec hermes
CMD
chmod +x ~/Desktop/Hermes.command

# Smoke test the connection
hermes --check  # should print: "Provider reachable: localhost:11434/v1 ✓"
```

**Daily-use flow**: user double-clicks `~/Desktop/Hermes.command`. Terminal opens with Hermes TUI running. They never type a terminal command — they're inside Hermes immediately.

**Why we stay on Hermes TUI today instead of pairing with another harness**:
- Hermes Desktop is on the Nous Research roadmap (`desktop-pr20059-installers` tag); shipping soon
- Re-adding OpenCode/Goose as parallel GUIs adds back the moat we cut in v0.4.0–v0.6.0
- Ollama Desktop has a chat UI but no skills/hooks support — losing the whole point of this stack
- Our harness layer is intentionally thin: `~/.hermes/config.yaml` + `Hermes.command` are ~5 lines total. When Desktop ships, the swap is replacing the `.command` shortcut with the native app launcher. Skills + hooks + audit don't change.

**Bookmarked for re-evaluation when Hermes Desktop releases**: SETUP_PROMPT Phase 7 + the `Hermes.command` line. Everything else stays.

---

## PHASE 8 — AIR-GAP CONFIGURATION (~10 min)

```bash
# Little Snitch — install if not present
brew install --cask little-snitch
open /Applications/Little\ Snitch\ Configuration.app

# Tell user to install the Research Mode profile manually
cat <<EOF
ACTION REQUIRED — install Little Snitch profile:

1. Little Snitch Configuration is open.
2. File → Import Rules…
3. Pick: $LOCAL_AGENT_SETUP/setup-prompts/little-snitch-research-mode.lsrules
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

## PHASE 9 — CRON / LAUNCHD SCHEDULED TASKS (~5 min)

```bash
# 7 air-gap cron tasks per docs/v3_changes.md
mkdir -p ~/Library/LaunchAgents

for task in airgap-nightly-handoff llama-server-health audit-rotate leann-index-refresh; do
    # Daily tasks at 03:00-03:45
    bash $LOCAL_AGENT_SETUP/scripts/install-cron.sh --task "$task" --schedule "daily-03"
done

for task in manuscript-snapshot passport-cleanup skill-usage-report; do
    # Weekly tasks Sunday 04:00-05:00
    bash $LOCAL_AGENT_SETUP/scripts/install-cron.sh --task "$task" --schedule "weekly-sun-04"
done

# Verify
launchctl list | grep -E 'airgap-nightly-handoff|llama-server-health|audit-rotate|leann-index-refresh|manuscript-snapshot|passport-cleanup|skill-usage-report' | wc -l
# Expected: 7
```

---

## PHASE 10 — VERIFICATION SUITE (~10 min)

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

# Test 3: Wi-Fi airplane test — auto-detect interface (en0 is not universal)
WIFI_IFACE=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $2; exit}')
if [ -z "$WIFI_IFACE" ]; then
    echo "TEST 3 SKIP: no Wi-Fi interface detected (Ethernet-only / Linux / Windows path)"
else
    networksetup -setairportpower "$WIFI_IFACE" off
    sleep 3
    curl -s http://localhost:11434/v1/chat/completions \
        -H "Authorization: Bearer local" \
        -d '{"messages":[{"role":"user","content":"Reply: ok"}],"max_tokens":5}' \
        | jq -e '.choices[0].message.content' || { echo "TEST 3 FAIL: chat broken in airplane mode"; exit 1; }
    networksetup -setairportpower "$WIFI_IFACE" on
    echo "TEST 3 PASS: chat works offline ✓"
fi

# Test 4: skill discovery (~70 expected after Phase 2 + Phase 5 ceddcozum-tools; allow some variance)
SKILL_COUNT=$(find ~/.agents/skills -name "SKILL.md" | wc -l)
[ "$SKILL_COUNT" -ge 60 ] || { echo "TEST 4 FAIL: only $SKILL_COUNT skills discovered, expected ≥60"; exit 1; }
echo "TEST 4 PASS: $SKILL_COUNT skills discovered ✓"

# Test 5: hook fire — simulate session start
echo '{"session_id":"verify-test","cwd":"/tmp"}' | bash ~/.agents/hooks/session-start-airgap.sh | head -5

# Test 6: audit log creation
ls -la ~/Research/audit/$(date +%F)/ || { echo "TEST 6 FAIL: audit folder missing"; exit 1; }

# Test 7: Hermes CLI is installed + config points to our local llama-server
which hermes >/dev/null || { echo "TEST 7 FAIL: hermes CLI not found"; exit 1; }
grep -q "base_url.*localhost:${LLAMA_PORT:-11434}" ~/.hermes/config.yaml \
    || { echo "TEST 7 FAIL: Hermes config wrong"; exit 1; }

# Test 8: R + ellmer can talk to local llama-server
R --vanilla -e "library(ellmer); chat <- chat_openai(base_url=\"http://localhost:${LLAMA_PORT:-11434}/v1\", api_key=\"local\", model=\"qwen3.6-35b-a3b\"); cat(chat\$chat(\"Reply OK\"))" \
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
  • ~74 skills installed at ~/.agents/skills/ (count: $(find ~/.agents/skills -name SKILL.md | wc -l))
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
