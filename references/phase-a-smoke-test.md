# Phase A — Spine Smoke Test (1-2 hours)

**Idea (from Claude's review)**: instead of running the full 11-phase setup blind, spend an hour validating the **whole workflow loop** at minimum viable depth. If any link breaks, you catch it before downloading 21 GB of model weights.

The spine is: **find → analyze → write → audit**. Each link gets a single test that exercises it end-to-end.

---

## The four tests

### 1. Find (literature pillar)
- **Input**: 5 short test PDFs in a folder (Google Scholar's "free preview" PDFs work fine for this)
- **Skill**: `research/literature/paperqa-summarize` + `paperqa-synthesize`
- **Pass condition**: model returns a narrative synthesis with `[bibkey:page]` citations for every claim
- **Why this test**: paperqa-query has the most external-dependency risk (PaperQA2 install + PDF parsing + embedding model + retrieval + generation). If anything is wrong with the install, this surfaces it.

### 2. Analyze (statistics pillar)
- **Input**: 20-row synthetic CSV with sex, age, height, weight (no PHI — completely fake)
- **Skill**: `research/statistics/data-dictionary` → `table-one-build`
- **Pass condition**: produces a publication-ready Table 1 in markdown
- **Why this test**: exercises Python/R bridge (mall, gtsummary), Quarto rendering, and the agent's structured-output handling.

### 3. Write (manuscript pillar)
- **Input**: One paragraph of synthetic clinical narrative + 3 citations from test 1
- **Skill**: `research/manuscript/draft-write` → `claim-check`
- **Pass condition**: drafted text with citations placed correctly; claim-check identifies which sentences need citations and matches them
- **Why this test**: validates voice profile loading + structured drafting + verification loop.

### 4. Audit (the live wire)
- **All three tests above run with hooks active**:
  - `user-prompt-phi-warn.sh` flags any PHI-pattern in your prompts (test it: deliberately include "MRN 12345678" in one prompt)
  - `post-tool-audit-jsonl.sh` writes every tool call to `~/Research/audit/$(date +%F)/`
  - `output-scrub.sh` runs on the last assistant turn before display (deliberately have the model output a TC kimlik-shaped number; check it gets `[REDACTED-TCKN]`)
- **Pass condition**: PHI warnings fire, audit log accumulates, output gets scrubbed. If any of these silently fail, the compliance story is broken.

---

## Setup-light path for Phase A

**Don't run Phases 0-10 of SETUP_PROMPT.md**. Run this minimal subset:

```bash
# Pre-check (port + clone path)
# ... (PRE-CHECK block from SETUP_PROMPT.md)

# Phase 0 minimal — just direnv + uv + Raindrop
brew install uv pipx direnv
pipx ensurepath
curl -fsSL https://raindrop.sh/install | bash

# Phase 1 minimal — Qwen 27B dense ONLY (skip 35B-A3B + LFM + Turkish)
# Reason: 27B dense @ Q4_K_M = ~16 GB (vs 21+ for 35B-A3B). We'll A/B test later.
brew install llama.cpp
mkdir -p ~/.research/{models,logs,services}
huggingface-cli download \
    unsloth/Qwen3.6-27B-GGUF \
    Qwen3.6-27B-Q4_K_M.gguf \
    --local-dir ~/.research/models

# Start llama-server in foreground (no launchctl yet — keep it interactive)
llama-server \
    --model ~/.research/models/Qwen3.6-27B-Q4_K_M.gguf \
    --host 127.0.0.1 --port 11434 \
    --ctx-size 16384 --n-gpu-layers 999 \
    --mlock --api-key local &

# Phase 2 minimal — copy ONLY the 8 critical skills + 5 hooks for the spine
mkdir -p ~/.agents/{skills,hooks}
SKILLS_NEEDED=(
    shared/session-launch
    shared/output-scrub
    research/literature/paperqa-summarize
    research/literature/paperqa-synthesize
    research/statistics/data-dictionary
    research/statistics/table-one-build
    research/manuscript/draft-write
    research/manuscript/claim-check
)
for s in "${SKILLS_NEEDED[@]}"; do
    mkdir -p ~/.agents/skills/$s
    cp -r $LOCAL_AGENT_SETUP/skills/$s/* ~/.agents/skills/$s/
done

HOOKS_NEEDED=(
    user-prompt-phi-warn.sh
    post-tool-audit-jsonl.sh
    stop-output-scrub.sh
    session-start-airgap.sh
    session-end-passport.sh
)
for h in "${HOOKS_NEEDED[@]}"; do
    cp $LOCAL_AGENT_SETUP/hooks/$h ~/.agents/hooks/
    chmod +x ~/.agents/hooks/$h
done

# Phase 3 minimal — Python venv with PaperQA2 only (skip R, Quarto, TeX)
python3 -m venv ~/.research/venv
source ~/.research/venv/bin/activate
uv pip install paper-qa pandas

# Phase 7 minimal — Hermes CLI
pipx install hermes-agent
mkdir -p ~/.hermes
cat > ~/.hermes/config.yaml <<EOF
provider:
  type: openai-compatible
  base_url: http://localhost:11434/v1
  api_key: local
  default_model: qwen3.6-27b
skills_path: $HOME/.agents/skills
hooks_path: $HOME/.agents/hooks
EOF
```

That's ~30 minutes if downloads are fast. The 16 GB Qwen 27B download dominates.

---

## Running the four tests

Open Hermes:

```bash
hermes
```

In Hermes, run each test as a prompt:

### Test 1 (find):
```
session-launch literature-review
I have 5 PDFs in ~/Desktop/test-pdfs/. Use paperqa-summarize on each, then
paperqa-synthesize to give me a 200-word synthesis answering: "What are the
common limitations of pediatric GLP-1 studies?"
```

Expected: ~30 sec to summarize 5 PDFs, then synthesis with `[bibkey:page]` citations.

### Test 2 (analyze):
```
session-launch statistics
Take ~/Desktop/test-cohort.csv. Run data-dictionary then table-one-build
grouped by `sex`. Save the table as ~/Desktop/test-table-one.md.
```

Expected: markdown table with mean±SD for continuous variables, n(%) for categorical.

### Test 3 (write):
```
session-launch write
Draft an Introduction paragraph for a paper on GLP-1 in pediatric T2D using
these 3 references: [paste 3 from test 1]. Then run claim-check on the draft.
```

Expected: paragraph with placeholder citations, then a list of "needs-citation"
sentences flagged by claim-check.

### Test 4 (audit — runs throughout):
Deliberately include in one of the prompts above: "Patient with MRN 12345678 had..."
Expected: `user-prompt-phi-warn.sh` fires before submission. Audit log at
`~/Research/audit/$(date +%F)/` accumulates tool calls.

After all four tests, `cat ~/Research/audit/$(date +%F)/*.jsonl | wc -l` should
show ≥20 audit entries.

---

## A/B test inside Phase A: 27B dense vs 35B-A3B for write-mode

Claude's hunch: 27B dense (all params active) feels more coherent for first-draft
prose than 35B-A3B MoE (only 3B active per token).

Worth testing while you're here:

1. Run Test 3 (write) with Qwen 27B dense (default in this Phase A — already loaded)
2. Stop llama-server, swap to 35B-A3B (`ollama pull qwen3.6:35b-a3b` and `ollama run`, OR re-launch llama-server with the bigger model)
3. Run Test 3 again with the same input
4. Compare output quality — coherence, citation handling, Turkish-character render if you write in Turkish

If 27B dense wins: keep our current routing (27B for write-mode).
If 35B-A3B wins or ties: simplify to one model always loaded (just 35B-A3B).
If neither wins clearly: the routing is fine; the conviction comes from real use.

---

## What you skip in Phase A

Deferred to Phase B (full install):
- LFM2.5-350M router (not needed when only one Qwen is loaded)
- Turkish-Gemma (unless your test corpus is Turkish)
- R + Quarto + TeX (statistics pillar minimum runs in pure Python)
- LEANN index (Test 1 works with PaperQA's built-in retrieval on a tiny corpus)
- Little Snitch / launchctl / cron — keep Wi-Fi on for now, no air-gap pretense
- ceddcozum integration (Phase 5)
- Style calibration (use the generic prompt)
- All cherry-pick skills (just the 8 listed)

You're testing the **architecture**, not the **product**. Phase B fills in.

---

## What you learn from Phase A

After ~2 hours you know:
- Whether llama-server runs reliably with the chosen model + flags on your hardware
- Whether Hermes CLI/TUI actually dispatches skills correctly
- Whether the hook chain (PHI-warn → audit-log → output-scrub) fires in the right order
- Whether PaperQA2 install works (most external-dep risk)
- Whether the local model handles Turkish text well enough (if you tested)
- Whether 27B dense or 35B-A3B feels better for prose (A/B above)
- What blew up that we didn't predict (write to `~/Research/lessons.md` immediately)

If Phase A passes, run Phase B (full SETUP_PROMPT.md) with high confidence.
If Phase A fails at any of the four tests, fix that link before doing Phase B —
otherwise you'll lose time downloading the full stack onto a broken loop.

---

## When NOT to do Phase A

- If you've already done a full SETUP_PROMPT.md install successfully and just want to install on a new colleague's machine — skip; go full install
- If your test PDFs / synthetic CSV / draft paragraph aren't ready — do those first, then come back
- If you're not actually planning to use the stack daily — Phase A is for users who'll use it

---

## Credit

Phase-A-as-spine reframing from Claude (incognito) review, May 19 2026.
Specific test ideas (5 PDFs / 20-row CSV / paragraph + claim-check) from same.
A/B test on 27B vs 35B-A3B for write-mode from Claude's "the active params
matter for prose coherence" observation.
