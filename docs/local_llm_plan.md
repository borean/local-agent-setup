# Fully-Local, Air-Gapped LLM Setup for Medical Research
**HIPAA / GDPR / KVKK compliant • Two tracks: Clinician path (GUI, no terminal) + Bora path (CLI + skills)**
**Model duo: Qwen 3.6 27B dense (writing/reasoning) + Qwen 3.6 35B-A3B MoE (coding/agentic) — session-locked, no mid-session swap**
**Tested-against intel: 108 local-model tweets from your WhatsApp dataset + May 2026 web verification**

---

## SCOPE: WHAT "AIR-GAPPED" MEANS HERE

- After setup, the machine **blocks all outbound network** except localhost (enforced by Little Snitch / LuLu)
- "Research Mode" toggle — flips network egress off for the duration of a session
- Setup phase (model downloads, brew installs) happens online; once done, you toggle to air-gap and stay there
- iCloud / Time Machine for `~/Research/` is OFF — local-only persistence
- **PII redaction is OPTIONAL, not mandatory.** Air-gap removes the exfiltration channel. Hygiene applies only to outputs that leave the laptop (email, exports, slides).

---

---

## PART 0 — WHY LOCAL, IN ONE PAGE (this is the slide you show colleagues)

**The compliance reality check for AI in clinical research:**

| Law | What "local-only" *eliminates* | What it does **NOT** eliminate |
|---|---|---|
| **KVKK** (Turkey, Law 6698 + Apr-15-2026 DPA Agentic AI guidance) | Third-party processor agreements; cross-border transfer issue; vendor-training-on-your-data risk | **VERBIS controller registration**; lawful-basis requirement; explicit consent for "özel nitelikli" health data; data-subject rights; DPIA; audit trail |
| **GDPR** Art. 9 (special-category health) | DPA with model vendor; third-country transfer; vendor breach risk | Controller obligations; **DPIA still required** for large-scale special-category processing; documentation; retention policy |
| **HIPAA** (US — only relevant if collaborating with US institutions) | BAA with model vendor | If you use *identifiable* PHI: IRB approval + Privacy Rule authorization. **De-identified research is outside HIPAA entirely.** |

**Turkish DPA, April 15 2026 — KEY**: their new Agentic AI guidance treats AI-derived/inferred outputs as personal data subject to full KVKK compliance. **There is no "on-device exemption" — local processing still requires lawful basis, purpose limitation, data minimization, and risk-based governance with privacy-by-design.**

So: local-only is **necessary but not sufficient**. It collapses the technical attack surface dramatically. The legal/process surface (VERBIS, DPIA, consent, audit, retention) still exists.

**What "local-only" still does NOT solve** (your honest list for colleagues):
1. **Device security** — your laptop is the new threat surface. FileVault + lock screen + dedicated account.
2. **De-identification quality** — raw PHI in = PHI-tainted outputs. Treat outputs as identifiable until proven otherwise.
3. **Audit trail** — KVKK Art. 12 wants logs. Plan for them from day 1, not when audited.
4. **Right to erasure** — patient revokes consent → you must delete *all* derivatives. Filename conventions matter.
5. **Backup hygiene** — iCloud / Time Machine syncing your model conversations is a leak. Exclude research folders explicitly.

**The persuasive frame for colleagues**: every time your data leaves your laptop — any API call, any cloud upload, any "AI feature" in Notion/Word — you become a data *exporter* under GDPR/KVKK and trigger contractual + DPIA + cross-border obligations. Local-only is the only design that is *categorically* clean on the technical axis, even though you still owe the paperwork.

---

## PART 1 — HARDWARE CHECK + THROUGHPUT (5 min)

Before anything else, **tell your colleague to run this**:

**On Mac:** Apple menu → About This Mac → check "Memory" (RAM) and chip name.
**On Windows:** Settings → System → About → "Installed RAM".

### Token/sec by RAM tier (Apple Silicon, Q4_K_M, MLX runtime)

| RAM | Mac tier | Mem b/w | Qwen 3.6 27B dense Q4 | Qwen 3.6 35B-A3B Q4 (MoE) | Verdict |
|---|---|---|---|---|---|
| 16 GB | M1/M2/M3 base | 100 GB/s | won't fit | won't fit (~21 GB weights) | Drop to Qwen 3.6 8B/14B |
| 24 GB | M3 Pro base | 150 GB/s | ~10-14 tok/s (painful) | ~28-38 tok/s | Marginal; 35B-A3B only |
| **32 GB** | **M3/M4 Pro** | **200-273 GB/s** | **~18-22 tok/s** | **~45-65 tok/s** | **FLOOR — recommended minimum** |
| 36-48 GB | M3 Pro / M4 Pro | 200-273 GB/s | ~20-26 tok/s | ~50-75 tok/s | Comfortable |
| 64 GB | M3 Max / M4 Max | 400 GB/s | ~25-32 tok/s | ~60-90 tok/s | Production tier |
| 96-128 GB | M3 Max / M4 Max / Ultra | 400-546 GB/s | ~28-35 tok/s | ~70-110 tok/s | + headroom for full 256K context |

**Reference points for colleagues:** ~10 tok/s = comfortable reading speed; 30 tok/s = feels instant; 60+ tok/s = faster than you read. Below 10 tok/s = frustrating.

**Why MoE is so much faster:** Qwen 3.6 35B-A3B only reads ~3B "active" parameters per token. 27B dense reads all 27B. On a 400 GB/s M3 Max: theoretical max is ~267 tok/s for MoE vs ~30 tok/s for dense. Real ~50-80 vs ~25-30 after overhead.

**32 GB is our floor.** Below that, 27B dense becomes painful and 35B-A3B doesn't fit. **Apple Silicon is dramatically better than Intel/AMD/NVIDIA-with-equivalent-RAM** because of unified memory. An M3 Pro 32 GB beats most desktops at this workload.

---

## PART 2 — TRACK A: CLINICIAN PATH (no terminal, ~45 minutes)

**Goal:** Your colleague can chat with a local model and ask questions about their PDFs by end of session. Nothing leaves the machine.

### Step 1 — Install LM Studio (10 min)

1. Go to **lmstudio.ai** in a browser
2. Click "Download for Mac" (or Windows / Linux)
3. Open the downloaded file. Drag to Applications. Open it.
4. On first launch, click through the welcome screens. **Choose "Power User" mode** (it unlocks needed features but is still GUI).

**Why LM Studio not Ollama for colleagues:** Ollama needs the terminal. LM Studio is point-and-click. It's "just `llama.cpp`" under the hood — same quality, friendlier face. Per @leopardracer in your data: *"LM Studio is just llama.cpp. Ollama is just llama.cpp."*

### Step 2 — Download the model (10-25 min depending on RAM tier)

1. In LM Studio, click the **🔍 search icon** (top-left, "Discover")
2. Type **`Qwen3.6-35B-A3B`** (or `Qwen3.6-8B` for 16 GB Macs)
3. You'll see Unsloth or LM Studio Community versions. **Pick the one labeled `Q4_K_M`** (or `MLX 4-bit` for Mac).
4. Click "Download". This is ~21 GB for the 35B model. Coffee break.

**Why Q4_K_M, not Q2 or Q8:** From your saved ngrok tweet — Q8 is "no quality loss but huge"; Q4 is "5-10% loss, 4× smaller, 2.4× faster"; Q2 is "catastrophic 97% no-answer rate." Q4_K_M is the sweet spot. **Do not go below Q4 for medical work.**

### Step 3 — Verify it works offline (5 min) — **THIS IS THE COMPLIANCE STEP**

1. Click 💬 **Chat** icon in LM Studio
2. Select your downloaded model from the top dropdown
3. **Turn off Wi-Fi** (Mac: menu bar → Wi-Fi off; Windows: Settings → Network → disable)
4. Type: *"Summarize the diagnostic criteria for type 1 diabetes mellitus in pediatrics."*
5. If it responds — **you are now running a state-of-the-art LLM with no internet**. This is the compliance proof.
6. Turn Wi-Fi back on for the next steps.

### Step 4 — Install AnythingLLM for document chat (15 min)

This is the layer that lets your colleague drop a folder of PDFs and ask questions about them.

1. Go to **useanything.com** → Download for Mac/Windows
2. Install + open
3. First-run wizard:
   - **LLM Provider**: pick **"LM Studio"** → it auto-detects on localhost:1234
   - **Embedding Provider**: pick **"Built-in (AnythingLLM Native)"** — runs fully offline
   - **Vector Database**: pick **"LanceDB"** (default) — stores everything in a local file
   - **Skip cloud setup** when it asks
4. Click "Create new workspace" → name it e.g. *"Pediatric Endocrine Literature"*
5. Click the upload icon → drag in **de-identified** PDFs (see Step 6)

### Step 5 — Set up Zotero for reference management (10 min) — colleagues need this

1. Go to **zotero.org** → Download Zotero 7
2. Install the **Zotero Connector** browser extension
3. Create a Zotero account *for syncing metadata only* — turn off file syncing in Preferences → Sync (keep PDFs local)
4. Now any PubMed / journal page → click Connector icon → reference + PDF saved locally
5. Reading: open the PDF, highlight, take notes. All offline.

### Step 6 — De-identification policy (NON-NEGOTIABLE)

**Before any document with patient data enters AnythingLLM or LM Studio chat:**

For the **clinician path**, the simplest workflow:
1. Open the PDF/Word doc
2. Use **redakt** (Bora's app — install it) → drag the file in → check the redacted output
3. *Only* the redacted version goes into AnythingLLM

If redakt is unavailable, fallback minimums:
- Remove patient name, MRN, full DOB (replace with "age X years"), exact addresses, family names, exact dates → use relative dates (POD 3, week 12)
- Verify no hospital name → identification through small dataset risk

**Rule for colleagues**: "If you wouldn't write it on a chart that leaves the hospital, don't paste it into the model."

### Step 7 — First real workflow (try this with your colleague)

**Task:** "Summarize 10 papers on pediatric GLP-1 use into a 1-page brief."

1. Download 10 OA PDFs into a folder via Zotero
2. Drag them all into your AnythingLLM workspace
3. In the chat: *"Read these 10 papers. Produce a 500-word synthesis with each claim cited as [Author Year]. Group by: efficacy, safety, dose-finding, off-label use in adolescents."*
4. Watch it work. Verify every citation by clicking through (AnythingLLM shows source chunks).

**If a citation doesn't check out, the answer is wrong.** Teach colleagues this verification step as the first habit.

---

## PART 3 — TRACK B: BORA PATH (advanced, full stack on M3 Max, ~3-4 hours)

You already have most of this. This is the integration upgrade.

### Step 1 — Pick your runtime (5 min decision)

Three viable options for M3 Max:

| Runtime | Strength | Use when |
|---|---|---|
| **MLX (mlx-lm)** | Fastest on Apple Silicon (~30-50% over llama.cpp) | Production inference, big context |
| **llama.cpp via Ollama** | Best ecosystem (Claude Code compat, OpenCode, OpenAI-API) | Agent layer / tool calling |
| **LM Studio** | GUI for quick swaps | Quick testing, comparing models |

**Recommendation: run both Ollama AND LM Studio.** They share GGUF files (point LM Studio at Ollama's `~/.ollama/models` dir). Use Ollama as your "server" for Claude Code + scripts, LM Studio when you want a chat GUI.

### Step 2 — Install Ollama + pull the right models (20 min)

```bash
# Install (Ollama 0.5+ has Anthropic-API compat — needed for Claude Code)
brew install --cask ollama

# Pull the core medical research stack
ollama pull qwen3.6:35b-a3b-q4_K_M       # main agent model, ~21 GB
ollama pull qwen3.6:27b-q4_K_M           # dense alternative, 14 GB, often better for narrow tasks
ollama pull qwen3.6-omni:7b-instruct     # multimodal: audio/image/video → text
ollama pull bge-m3                       # multilingual (incl. Turkish) embeddings for RAG
ollama pull glm-ocr                      # 0.9B SOTA local document OCR (in your data)

# Medical-specific (English/Chinese only — see routing rule below)
ollama pull hf.co/mradermacher/AntAngelMed-i1-GGUF:Q4_K_M  # 100B/6.1B MoE, Apache 2.0
ollama pull medgemma:27b-q4_K_M          # Google Jan 2026, ~91% MedQA

# Turkish: there is NO mature Turkish *medical* LLM yet (May 2026).
# Best Turkish reasoning base for clinic-language tasks:
ollama pull hf.co/ytu-ce-cosmos/Turkish-Gemma-9b-T1-GGUF:Q4_K_M
```

### Step 2.5 — Language routing rule (the most important rule for Bora specifically)

Because AntAngelMed and MedGemma are **English + Chinese only**, and your patient material is **Turkish**, route by language:

| Input language | Route to | Why |
|---|---|---|
| Turkish patient notes / Turkish papers | **Turkish-Gemma-9b-T1** (general) or translate→English→AntAngelMed | Avoids degraded reasoning on Turkish-medical concepts |
| English literature, Anglophone guidelines, your own English drafts | **AntAngelMed** or **MedGemma 1.5** | Best medical accuracy |
| Mixed (your typical case) | Stage: Turkish-Gemma summarizes Turkish chart → output in English → AntAngelMed reasons → result back to Turkish via Qwen 3.6 omni | Treat as a small pipeline, not a single model |

Build this into a `medical-language-routing.skill.md` so colleagues don't have to think about it.

### Step 3 — Session-locked orchestrator + harness choice

You said the magic word: **KV cache is preserved only as long as the model stays loaded.** Switching mid-session = blowing minutes of work. So the orchestrator picks once per session, then sticks.

**Decide one bit at session launch:** writing/reasoning OR coding/agentic?

| Task type | Model | Why |
|---|---|---|
| Writing, review, long-form reasoning, critique | **Qwen 3.6 27B dense** | Dense beats MoE on coherence over many turns |
| Coding, stats, agentic tool use, quick lookups, vision | **Qwen 3.6 35B-A3B (MoE)** | 3B active = fast tool-call loops; vision built in |

Implementation — single launcher script:

```bash
# ~/bin/research-session
#!/bin/bash
set -e
case "${1:-}" in
  code|stats|agent|tool|quick|vision)
    MODEL="qwen3.6:35b-a3b-q4_K_M"
    REASON="MoE — fast tool-call loops"
    ;;
  write|review|reason|long|critique)
    MODEL="qwen3.6:27b-q4_K_M"
    REASON="Dense — long-form coherence"
    ;;
  *)
    echo "Usage: research-session {code|stats|agent|write|review|reason} [task]"
    echo "Pick ONE model per session — switching blows KV cache."
    exit 1 ;;
esac
echo "→ $MODEL  ($REASON)"
ollama run "$MODEL" --keepalive 4h &
exec ${HARNESS:-claude} --model "$MODEL"
```

**Harness choice:**

| Harness | Pros | Cons | Use when |
|---|---|---|---|
| **Claude Code** | Your 130 skills work as-is, your muscle memory | Phones home for telemetry/updates (block `*.anthropic.com` in Little Snitch) | Daily work (non-sensitive) |
| **OpenCode** | Fully OSS, **zero phone-home**, reads same skills format | Less polished UI, fewer built-in tools | Air-gap / sensitive sessions / colleague rollout |

Set Ollama as the Anthropic-API endpoint (works for both harnesses):
```bash
export ANTHROPIC_BASE_URL=http://localhost:11434/v1
export ANTHROPIC_API_KEY=ollama          # any value
export DISABLE_TELEMETRY=1                # Claude Code only — extra paranoia
```

**Two-tab pattern for the 64GB+ case**: run a `research-session write` tab AND a `research-session code` tab in parallel. Both models stay warm. RAM permitting (need ~35 GB combined at Q4_K_M), you context-switch by switching terminal tab, not by swapping models.

### Step 3.5 — Skills compatibility audit (do this ONCE)

Your 130 skills fall into three buckets. Tag each in frontmatter so the harness can filter at air-gap launch:

```yaml
---
name: literature-review
network: local-with-cache   # one of: airgap-ok | local-with-cache | online-required
offline-source: ~/Research/cache/zotero-pdfs
---
```

| Bucket | Examples | Action |
|---|---|---|
| **airgap-ok** | statistical-analysis, manuscript-from-clinical-data, manuscript-linter, avoid-ai-writing, supervisor-feedback, data-integrity-check, peer-review-response, dead-code-surgeon, jupyter-notebook, doc, pdf, xlsx, pptx, docx | No change |
| **local-with-cache** | literature-review (→ LEANN over Zotero), citation-verifier (→ local BibTeX), guideline-fetcher (→ pre-downloaded folder), biorxiv-database, pubmed-database, clinicaltrials-database, gene-database, clinvar-database, fda-database | Add `offline-source:` path; periodic sync when briefly online |
| **online-required** | sora, nano-banana-pro, gem, defuddle, last30days, twitter-ai-scout, gog, linear, supabase, sentry, paperless, vercel-deploy, netlify-deploy, github actions | Tag and hide in air-gap mode |

One-time 10-min script: walk `~/.claude/skills/`, prompt yes/no/cache for each, write the frontmatter. Becomes a skill itself: `airgap-tag.skill.md`.

### Step 4 — Set up the RAG layer (20 min) — Docling for parsing, LEANN for the index

**Parser choice:** **Docling (IBM, MIT license)** is the 2026 default for medical PDFs — preserves table structure and extracts equations as LaTeX. Marker is faster but weaker on structure; use it only for clean preprints.

**Index choice:** LEANN (from your data, @LiorOnAI; MLsys 2026 paper; MIT) — indexes 60M text chunks in **6 GB** instead of 200 GB by storing a graph and recomputing embeddings on-the-fly. **macOS supported; no Windows yet** (May 2026). For Windows colleagues, fall back to **ChromaDB** (Apache 2.0, embedded, default in AnythingLLM).

```bash
# Install Docling for PDF parsing
pipx install docling

# Install LEANN (Mac-only, May 2026)
uv pip install leann-core leann-backend-hnsw leann

# Parse a folder of papers into clean markdown first
docling ~/Zotero/storage --output ~/Research/corpus-md --extract-tables --extract-equations

# Build LEANN index using BGE-M3 (multilingual — handles Turkish + English papers)
leann build \
  --source ~/Research/corpus-md \
  --embed-model bge-m3 \
  --output ~/.leann/peds-endo-corpus

# Query with citations
leann query ~/.leann/peds-endo-corpus \
  --q "GLP-1 receptor agonist effects on bone mineral density in adolescents" \
  --llm ollama/qwen3.6:35b-a3b-q4_K_M --top 8 --cite
```

This is the engine behind your `literature-review` skill — wire it in as the offline backend.

**Why BGE-M3 (not nomic-embed)**: BGE-M3 handles 100+ languages including Turkish *and* English in one model. For your bilingual peds-endo corpus this is the only right choice. Save nomic-embed-text for English-only colleagues.

For *English-only PubMed work* on Bora's side, you can route to **MedCPT** (NCBI, PubMed-trained, SOTA biomedical IR) instead of BGE-M3 — slightly better retrieval. Use a router script that picks BGE-M3 for Turkish/mixed, MedCPT for English-pure.

### Step 5 — Output hygiene (NOT input redaction — see why below)

**Decision: redaction is OPTIONAL, not part of the mandatory pipeline.** Once the laptop is air-gapped (Step 8 below), there is no exfiltration channel from the model. KVKK + GDPR require *lawful basis* and *purpose limitation* for processing identifiable data, not redaction. With IRB approval + patient consent, processing identifiable data inside the air-gap is legally clean.

The risk that remains is **outputs leaving the laptop** (email, paste into shared doc, screenshot in slides). So replace the 4-layer input pipeline with a 3-rule output hygiene policy:

1. **Audit at the door**: every chat transcript saved to `~/Research/audit/YYYY-MM-DD-{session}.jsonl` for KVKK Art. 12 logging.
2. **Scrub before export**: before any output leaves the laptop, Cmd-F the transcript for: first names, MRN `^[0-9]{6,8}$`, TCKN `^[1-9][0-9]{10}$`, day-precision dates. Either remove or generalize ("week 12" not "April 14").
3. **Generalize by default**: instruct the model in CLAUDE.md to use relative dates ("POD 3", "week 12 of treatment") and de-specified locations ("tertiary center" not "Ankara Etlik ŞH") in its outputs.

**redakt stays in your toolkit** as an *optional convenience* — useful when you want to share a chat transcript with a non-IRB colleague, or paste an excerpt into a slide that goes outside the team. Don't run it on every input.

Add a single skill: `output-scrub.skill.md` that runs the three rules above as a function the model can call before "saving for export."

### Step 6 — Statistical analysis bridge (Quarto + R + local LLM) — 30 min

This is the killer workflow for you specifically. Quarto + R + a local LLM agent that reads your data and proposes analyses.

```bash
# Install Quarto + R
brew install quarto r

# Install mall (mlverse) — the best R↔Ollama bridge in 2026
# Wraps ellmer/chatlas underneath. Built specifically for data-analysis loops.
R -e 'install.packages("mall"); install.packages("ellmer")'
```

In any Quarto/RStudio session:
```r
library(mall)
llm_use("ollama", "qwen3.6:35b-a3b-q4_K_M", seed = 42)

# Now mall verbs operate directly on data frames, locally:
df |> llm_summarize(text_col, "Summarize each visit note in one clinical sentence")
df |> llm_classify(text_col, c("DKA","new T1D","follow-up","other"))
df |> llm_extract(text_col, c("hba1c","insulin_units","weight_kg"))
```

For free-form analysis brainstorming:
```r
library(ellmer)
chat <- chat_ollama(model = "qwen3.6:35b-a3b-q4_K_M")
chat$chat("Given this data dictionary [paste], propose 5 analyses ranked by clinical relevance, including required assumptions and sample-size sensitivity.")
```

For Python users: `pandasai[ollama]` for "ask CSV questions" + Jupyter AI with Ollama provider. **MLJAR Studio v1.0.3 (March 2026)** is a desktop JupyterLab + AI agents + AutoML that runs entirely local — recommend for colleagues who like notebooks but not Python setup.

For Python users, replicate via `ollama` Python package + Jupyter. Bora — wire this into your existing `statistical-analysis` and `case-control-biomarker-analysis` skills as a local-fallback mode.

### Step 7 — Article writing pipeline (Quarto + Zotero + local model)

The full local article-writing stack:

```
Idea → Outline (local model brainstorm)
     → Lit review (LEANN over Zotero corpus)
     → Data analysis (Quarto + R + ellmer + local model)
     → Draft (Quarto markdown w/ {{< cite >}} from Zotero BibTeX)
     → Self-review (local model as critic — different model than the writer!)
     → Citation verification (your existing citation-verifier skill, offline mode)
     → Export to .docx with track changes for co-authors
```

Use **two different local models** for writing vs critiquing — Qwen 3.6 27B dense as writer, 35B-A3B as critic. This is the "Generator–Reflector–Curator" loop from your data (qizhengz_alex's ACE framework, +10.6% on agent tasks).

### Step 8 — Air-Gap Mode + verification + audit trail (this is THE compliance step)

Install **Little Snitch** (€49) or **LuLu** (free, Objective-See) on Mac.

Create a network profile called **"Research Mode"** that blocks **everything except localhost**:

```
Allow:  127.0.0.1/8  *  (all ports)
Allow:  ::1          *  (IPv6 loopback)
Deny:   anywhere     *  (everything else)
```

This is non-negotiable for the air-gap claim. Specifically blocks:
- `*.anthropic.com` (Claude Code telemetry)
- `*.openai.com`, `*.azure.com`, `*.googleapis.com`
- `*.apple.com` (iCloud, Spotlight web suggestions, software update)
- `*.zotero.org`, `*.dropbox.com`, etc.

Toggle Research Mode ON when starting any session with identifiable data; OFF only when you need to sync (and not while a chat session is open).

**Three verification steps colleagues must learn:**

1. **Cmd-Space → "Activity Monitor" → Network tab → sort by Sent Bytes.** During a chat session, Ollama should show some local traffic; nothing else should be sending. Screenshot this for your audit folder once per quarter.
2. **Wi-Fi airplane test**: turn off Wi-Fi entirely; ask the model a question; verify it still works. Run this test once a week. Keeps you honest.
3. **`tcpdump -i any -n not host 127.0.0.1 and not host ::1` in a terminal** for 5 minutes during a session. If anything appears, find what app and block it.

**Audit folder structure** for KVKK Art. 12:
```
~/Research/audit/
  2026-05-18/
    session-001.jsonl       # full chat transcript (input + output)
    session-001.meta.yaml   # model, harness, hash of inputs, IRB project ID
    network.log             # Little Snitch export, proves nothing left
    dataset-version.txt     # which de-id/IRB-approved dataset was used
```

For Linux colleagues: `ufw default deny outgoing` + allow `127.0.0.0/8`. For Windows: Windows Firewall outbound-deny default. For WSL: same iptables on the WSL2 side.

---

## PART 4 — WORKFLOWS (what each task looks like end-to-end)

### Workflow 4A — Statistical analysis on patient data (Bora's daily case)

1. Export anonymized CSV from hospital DB (already de-identified at source — confirm with IT)
2. Open RStudio/Quarto
3. `library(ellmer); chat <- chat_ollama("qwen3.6:35b-a3b-q4_K_M")`
4. Paste **column names + 5 rows + research question** into the chat (NEVER paste the full data)
5. Get analysis plan + R code stub
6. Run analysis yourself; ask LLM to interpret outputs (paste numbers, not raw rows)
7. Export results table + figure to `~/Research/projects/{project}/results/`
8. **Audit log**: copy entire chat transcript into `methods.md` for your archive

### Workflow 4B — Literature review

1. PubMed search → save to Zotero collection
2. `leann build` on the collection's PDFs
3. `leann query` with your research question + `--cite`
4. Verify every citation by opening the PDF page LEANN returns
5. Use Citation-verifier skill (your existing one) in offline mode against the cited claims
6. Synthesis → Quarto manuscript

### Workflow 4C — Article writing with reviewer-style critique

1. Draft section in Quarto
2. Open second LM Studio chat with a **different** model (e.g. Qwen 3.6 27B dense)
3. Paste section: *"You are a JCEM reviewer. Identify 5 specific weaknesses with line numbers and suggest exact rewrites."*
4. Incorporate. Repeat with a third model (Qwen-Omni) as "lay-reader checker."
5. Run your `manuscript-linter` + `avoid-ai-writing` skills.

### Workflow 4D — Clinical decision support during rounds (read-only use)

1. Open LM Studio with Qwen 3.6 27B
2. Use exclusively for **general medical knowledge questions** (not patient-specific):
   - "Latest 2025 ISPAD recommendations for DKA fluid management"
   - "Differential of hypoglycemia in 2-year-old"
3. NEVER paste patient identifiers or clinical specifics.
4. The Topol paradox (#10 from your top 100) applies — LLMs struggle with emergency triage. Use for reference recall, not decisions.

---

## PART 5 — COMPLIANCE VERIFICATION CHECKLIST (print and stick on monitor)

Use this before each session involving patient-derived material:

- [ ] Wi-Fi off OR Little Snitch "Research Mode" active
- [ ] Zotero file sync disabled in Preferences
- [ ] iCloud Desktop & Documents sync OFF (or research folder excluded)
- [ ] Time Machine: exclude `~/Research/PHI/` and `~/.ollama/models` only if disk space is tight
- [ ] Screen lock auto-engages in 1 minute
- [ ] FileVault (Mac) or BitLocker (Win) ENABLED
- [ ] Today's de-identified workfile saved with date prefix for audit log
- [ ] Conversations exported to `audit/` folder after session
- [ ] If shared workstation: separate macOS user account for research

---

## PART 6 — GLOSSARY FOR COLLEAGUES (the explainer)

Hand this to colleagues as a one-pager.

| Term | Plain meaning |
|---|---|
| **LLM** | The AI that writes text. Examples: ChatGPT, Claude, Qwen. |
| **Local model** | An LLM that runs on YOUR computer. Nothing leaves. |
| **Token** | Roughly one word or syllable. Models count input in tokens. |
| **Context window** | How much text the model can "see" at once. 256K tokens ≈ 500 pages. |
| **Quantization** (Q4, Q8) | Shrinking the model. Q8 = almost no quality loss. Q4 = good. Q2 = bad. |
| **RAG** | "Retrieval-Augmented Generation" — let the model read your PDFs. |
| **Embedding** | A number-list representation of text used to find similar passages. |
| **Vector database** | Where embeddings are stored. Local = LanceDB or ChromaDB. |
| **Ollama / LM Studio** | The "engine room" — software that runs the model. |
| **AnythingLLM** | The "front door" — a friendly GUI where you chat and load PDFs. |
| **MLX** | Apple's framework that makes Mac M-series chips faster for AI. |
| **GGUF** | The file format for quantized local models. |
| **API key** | A password to a paid cloud AI. **Local needs none — this is the whole point.** |
| **MCP** | A way for AI agents to use external tools. Worry about it later. |
| **De-identification** | Removing names/dates/IDs so a document can't be linked to a patient. |
| **PHI** | "Protected Health Information" — any data identifying a patient. |

---

## PART 7 — TROUBLESHOOTING (common colleague problems)

| Symptom | Cause | Fix |
|---|---|---|
| "Model too slow" | Too big for RAM, swapping to disk | Pick smaller variant (e.g. 8B instead of 35B) |
| "Out of memory" error | Same | Close other apps; try Q3_K_M if Q4_K_M fails |
| "Garbled text" output | Wrong quant chosen (Q2) | Re-download Q4_K_M version |
| "It hallucinated a citation" | Asked it to recall instead of read | Always provide PDF via AnythingLLM, never trust open-domain claims |
| "It refused to answer a medical question" | Safety-trained refusal | Reframe as "explain to a clinician" or "literature summary"; never as "what should I do with this patient" |
| "AnythingLLM can't find LM Studio" | LM Studio server not started | LM Studio → Developer tab → "Start Server" |
| "Slow on first question" | Model loading into RAM | Normal. Second question will be fast. |

---

## PART 8 — STAGED ROLLOUT FOR YOUR DEPARTMENT

If you're rolling this to colleagues, do it in waves:

**Wave 1 (week 1):** Yourself + one technically-comfortable colleague. Track A only. Validate workflow.

**Wave 2 (week 2):** 3-4 more colleagues. Run a 90-min hands-on session. Each leaves with LM Studio + AnythingLLM working + their first 5 PDFs loaded.

**Wave 3 (month 2):** Anyone interested. Use Track A. Publish your `pediatric-endo-local-llm.md` as a one-page handout with screenshots.

**Wave 4 (month 3+):** Optional Track B for 1-2 colleagues who are ready.

**What NOT to do**: don't try to teach git, the terminal, or Python first. The whole point of LM Studio + AnythingLLM is that they don't need any of those. Resistance to the terminal is a feature requirement, not a bug. Per @ihtesham2005-style observation: "Resistance is the user research."

---

## APPENDIX A — BUDGET-BY-COLLEAGUE-TIER

| Tier | Hardware | Software | Time investment |
|---|---|---|---|
| **Bronze** (existing Mac w/ 16+ GB) | Free (use existing) | LM Studio (free) + AnythingLLM (free) + Zotero (free) | 45 min setup, 2 hrs to feel fluent |
| **Silver** (new Mac for research) | M4 Mac mini 24 GB ~$1000 | Same + Little Snitch ~$50 | 1 day |
| **Gold** (heavy research / writing daily) | M4 Pro Mac mini 64 GB ~$2200 | Same + Quarto + R + redakt | 2-3 days to full workflow |
| **Platinum** (Bora's tier) | M3 Max 128 GB | Full Track B + custom skills | Already there |

For a **lab of 5 researchers** at Silver tier: **~€5000 total**. Compare to ChatGPT Team / Claude Enterprise: ~€600/user/year + BAA negotiations + DPO sign-off + cross-border DPIA. Local pays back in <2 years and the compliance posture is categorically different.

---

## APPENDIX B — WHAT YOU PERSONALLY (BORA) SHOULD DO BY FRIDAY

1. **Install llm-checker** (saved in your top 100, item #36): `npx llm-checker` — confirms which Qwen 3.6 variant your M3 Max can comfortably run before downloading 100 GB of model files
2. **Pull Qwen 3.6 35B-A3B GGUF** via Ollama: `ollama pull qwen3.6:35b-a3b-q4_K_M`
3. **Set up the Claude Code → Ollama bridge** (Step 3 above) — gives you a no-tokens-spent fallback for any non-sensitive work too
4. **Wire LEANN into your literature-review skill** as the offline backend (Step 4)
5. **Run a parallel sanity test**: take a finished manuscript draft of yours, run it through both Claude Opus 4.7 + local Qwen 3.6, and *measure the gap*. Bet: smaller than you'd expect. Worth a calibration data point.
6. **Write `local-model-policy.skill.md`** that codifies your Q4_K_M-not-Q2 rule, your three-layer de-id rule, and your "two-model writer/critic" rule. This is the artifact you hand colleagues.
7. **Build the medical-ai-deck slide pack** seeded by:
   - This compliance table → slide 2
   - Qwen 3.6 35B-A3B + AntAngelMed as "frontier-grade local options" → slide 6
   - Topol paradox + EchoBench sycophancy → slide 9-10
   - Your AnythingLLM workflow demo → slide 14
   - This page itself as the handout → slide 16

---

## APPENDIX B.5 — CURRENT-STATE CHEAT SHEET (verified May 14-18 2026)

Pin this to a sticky note:

- **Ollama v0.24.0** (May 14 2026). Anthropic-API compat since v0.14.0 → Claude Code works at `localhost:11434`. MLX backend, Claude Desktop launcher, Codex app launcher in latest.
- **LM Studio 0.4.13** (May 13 2026). Built-in RAG since v0.3.0 — drag-drop PDF/DOCX/TXT, auto-chunking. MLX engine v1.8.1.
- **Qwen 3.6 35B-A3B** (April 16 2026) and **Qwen 3.6 27B dense** (April 22 2026) — both with 256K context, vision, agentic coding, thinking-mode preservation. **MLX is 20-87% faster than llama.cpp on Apple Silicon** — use MLX.
- **AntAngelMed (MedAIBase)** — 100B/6.1B active MoE, Apache 2.0, GGUF on HF (`mradermacher/AntAngelMed-GGUF`). Tops MedAIBench/MedBench/HealthBench among open models. **English + Chinese only — not Turkish.** Practical on M3 Max with 64-128 GB at INT4.
- **MedGemma 1.5** (Google, Jan 2026) — ~91% MedQA, multimodal text+image, beats Med-PaLM 2 (86.5%).
- **Turkish-Gemma-9b-T1** (YTU CE Cosmos) — strongest *general* Turkish reasoning model. GGUF available. *Not medical-specific*; pair with English medical model via routing rule above.
- **AnythingLLM** — native Mac/Win installer, RAG built-in, **no Docker required**. Better for colleagues than Open WebUI.
- **Open WebUI** license changed April 2025 — 50+ user deployments must keep OWUI branding unless enterprise-licensed. **Not OSI-approved anymore.** Implication: probably fine for a single lab, do not push it institution-wide.
- **LEANN**: MIT, macOS only (no Win), `uv pip install leann-core leann-backend-hnsw leann`.
- **Docling** > Marker for medical PDFs (tables + equations as LaTeX).
- **mall** (mlverse) is the best R↔Ollama bridge in 2026; wraps ellmer/chatlas.
- **MLJAR Studio v1.0.3** (March 2026) — desktop JupyterLab + AI agents + AutoML, fully local. Best Python notebook path for non-developer colleagues.

---

## APPENDIX C — RISKS I'M NOT GOING TO HIDE FROM YOU

1. **Local models are 6-18 months behind frontier closed models**. The gap on simple tasks is invisible; on hard multi-hop clinical reasoning it can matter. Don't pretend it doesn't. Track #62 in your top 100 (Glasswing 83.1% vs prior 66.6%) shows how fast closed models move.

2. **The Karpathy "LLMs are simulators not entities" rule (#7)** applies doubly to local models. Frame everything as *"What would a panel of pediatric endo experts say about X"* rather than *"What do you think?"*

3. **Sycophancy in medical VLMs is 45-95%** (EchoBench, #9). Local models inherit this. Train yourself + colleagues to *prompt against your own hypothesis*, not for it. *"Argue against this diagnosis"* is a better prompt than *"Confirm this diagnosis."*

4. **The biggest leak vector isn't the model — it's the user.** A colleague who copy-pastes a chat answer into a hospital email has just exfiltrated whatever was in the prompt. Train the export hygiene as carefully as you train the import hygiene.

5. **Audit logs are your friend, not enemy.** Save every chat transcript related to research work. If you ever get a KVKK audit you want to show *"these are all the questions asked, here's the de-identified input data, here's the local-only proof, here's the disposition."*
