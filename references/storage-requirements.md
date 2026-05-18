# Storage Requirements

Verified May 19, 2026 against Hugging Face file sizes. **Bookmark this — it's the truth, not a guess.**

## Minimum vs recommended free disk

| Tier | Free disk | What you get |
|---|---|---|
| **Minimum** | 30 GB | One Qwen model (35B-A3B GGUF) + LFM router + Python venv + R + skills + audit folder. No 27B alternative, no Turkish model, no LEANN index. |
| **Recommended** | 80 GB | Both Qwen variants + LFM + Turkish-Gemma + bge-m3 embeddings + LEANN index + full Python venv with wheelhouse fallback + R + BasicTeX + journal templates. |
| **Comfortable** | 150 GB | Above + multiple quant variants of each model for testing + extended LEANN corpus + multiple manuscript snapshots + Q5_K_M / Q6_K variants for quality comparisons. |

## Per-model breakdown (Q4_K_M unless noted)

### Primary models

| Model | Format | Size | Use |
|---|---|---|---|
| **Qwen 3.6 35B-A3B** UD-Q4_K_M | GGUF | **20.61 GB** | Main: coding, agentic, tool use, vision. MoE — only 3B active per token. |
| **Qwen 3.6 35B-A3B** 4bit MLX | MLX | **19.03 GB** | Apple Silicon native, ~60% faster than GGUF |
| **Qwen 3.6 27B dense** Q4_K_M | GGUF | **15.66 GB** | Writing, long-form reasoning. All 27B active per token (slower). |
| **Qwen 3.6 27B dense** 4bit MLX | MLX | ~15 GB | Apple Silicon native (Qwen 3.5 was 14.98 GB; 3.6 similar) |
| **LFM2.5-350M** Q8_0 | GGUF | **362 MB** | Always-warm tool-call router on port 11436 |
| **LFM2.5-350M** Q4_K_M | GGUF | 219 MB | If you want even smaller; minimal quality loss for routing |

### Optional models

| Model | Format | Size | Use |
|---|---|---|---|
| **Turkish-Gemma-9b-T1** Q4_K_M | GGUF | **5.37 GB** | Only if working in Turkish (TR↔EN clinical translation) |
| **bge-m3** | safetensors | **2.14 GB** | Multilingual embeddings for LEANN index |
| **GLM-OCR** (0.9B) | GGUF | ~1.5 GB | Local document OCR — if you have many scans |
| **MedGemma 1.5 27B** | safetensors | ~50 GB (skip Q4 not yet available) | English medical reasoning — defer to v0.x.x |

### Model storage scenarios

```
Pediatric endocrinology (example case), full install:
  Qwen 3.6 35B-A3B GGUF UD-Q4_K_M    20.61 GB
  Qwen 3.6 27B dense Q4_K_M           15.66 GB
  LFM2.5-350M Q8_0                     0.36 GB
  Turkish-Gemma-9b-T1 Q4_K_M           5.37 GB
  bge-m3                               2.14 GB
                                     ────────
  Models subtotal:                    44.14 GB

English-only researcher (no Turkish, MLX path):
  Qwen 3.6 35B-A3B MLX 4bit           19.03 GB
  Qwen 3.6 27B MLX 4bit               15.00 GB
  LFM2.5-350M Q8_0                     0.36 GB
  bge-m3                               2.14 GB
                                     ────────
  Models subtotal:                    36.53 GB

Minimum viable (one Qwen, English):
  Qwen 3.6 35B-A3B UD-Q4_K_M          20.61 GB
  LFM2.5-350M Q8_0                     0.36 GB
                                     ────────
  Subtotal:                           20.97 GB
```

## Non-model storage

| Component | Size | Note |
|---|---|---|
| **Python venv** (~50 packages from medical-research-requirements.txt) | 3-5 GB | Bigger if pymc/torch/transformers all pulled |
| **Python wheelhouse** (offline-install fallback) | 3-5 GB | Same packages cached as wheels |
| **R packages** (~40 packages via renv) | 1.5-2 GB | tidyverse + meta + survival + brms drives most of it |
| **BasicTeX** | ~100 MB | Minimum TeX install; sufficient for Quarto journal output |
| **Full MacTeX** | ~5 GB | Only if you need every LaTeX package; usually overkill |
| **Quarto + extensions** | ~200 MB | quarto binary + journal templates (jama, nejm, lancet, elsevier) |
| **Hermes Agent Desktop** | ~200 MB | Application bundle |
| **Raindrop Workshop** | ~100 MB | Bun binary + DB |
| **LEANN index** (Zotero corpus) | 6-12 GB | Roughly: 1 GB per 5M chunks. A typical Zotero (~2000 papers, ~5000 chunks/paper) lands ~10 GB. |
| **Audit logs** | 50-200 MB/year | JSONL append-only; gzip after 7 days reduces by ~80% |
| **Manuscript snapshots** | 100-500 MB | Cap of 12 snapshots/manuscript × your active manuscripts |
| **Cached journal templates** | ~100 MB | Cloned via git from quarto-journals/* |
| **Skills bundle** | <10 MB | 74 SKILL.md files are tiny |
| **Hooks + cron tasks** | <1 MB | Shell scripts |
| **NON-MODEL TOTAL** | **15-30 GB** | Most variation is in venv + LEANN |

## All-in totals

```
Full peds-endo install (both Qwen models, Turkish-Gemma, full venv, LEANN):
  Models:               44.14 GB
  Python venv:           4.00 GB
  Python wheelhouse:     4.00 GB
  R packages:            1.80 GB
  BasicTeX:              0.10 GB
  Hermes + Raindrop:     0.30 GB
  LEANN index (~10GB):  10.00 GB
  Journal templates:     0.10 GB
  Skills + hooks + cron: 0.01 GB
                       ────────
  Total:                64.45 GB

  Recommended free disk after install: 80 GB
  Comfortable: 100+ GB (gives room for new caches, audit growth, OS updates)
```

```
Colleague minimum (one model, English, no Turkish):
  Models:               20.97 GB
  Python venv:           3.50 GB
  R packages:            1.80 GB
  BasicTeX:              0.10 GB
  Hermes + Raindrop:     0.30 GB
  LEANN index (small):   3.00 GB
  Skills + hooks + cron: 0.01 GB
                       ────────
  Total:                29.68 GB

  Recommended free disk after install: 40 GB
```

## RAM and disk are different conversations

A common mistake: confusing model FILE SIZE (on disk) with RAM CONSUMPTION (when loaded). They're related but not identical:

- **Qwen 3.6 35B-A3B Q4_K_M file: 20.61 GB**. When loaded into memory, similar size (`--mlock` locks it in RAM at full size). Inference activates only 3B params per token, but the full model stays resident.
- **Qwen 3.6 27B dense Q4_K_M file: 15.66 GB**. Loaded similarly; all 27B active per token (slower inference but same RAM cost).
- **Running BOTH simultaneously** = ~36 GB RAM. Achievable on 64GB+ Mac. On 32GB Mac you swap (slow).

## What the SETUP_PROMPT actually downloads

Phase 1 default for an Apple Silicon Mac (MLX path):
- `mlx-community/Qwen3.6-35B-A3B-4bit` (~19 GB)
- `mlx-community/Qwen3.6-27B-4bit` (~15 GB)
- `LiquidAI/LFM2.5-350M-GGUF` Q8_0 (~362 MB)
- + Turkish-Gemma if Turkish field selected (~5 GB)

For a Linux/Windows/Intel-Mac (GGUF path):
- `unsloth/Qwen3.6-35B-A3B-GGUF` UD-Q4_K_M (~20.61 GB)
- `unsloth/Qwen3.6-27B-GGUF` Q4_K_M (~15.66 GB)
- Same LFM + Turkish

Plus Phase 4: bge-m3 (~2.14 GB) for the LEANN embedding model.

## Disk full during install — what's safe to clean

If you hit "disk full" mid-Phase 1:

- **Safe to clear**: `~/Downloads/`, browser caches, old Time Machine local snapshots (`sudo tmutil thinlocalsnapshots / 9999999999 4`)
- **Don't touch**: `~/Research/` (your work), `~/.research/models/` (mid-download GGUFs), `~/.agents/` (installed skills/hooks)
- **Last resort**: drop one of the two Qwen variants (you can re-download later)

---

## Credit

Sizes pulled from Hugging Face API May 19, 2026:
- `unsloth/Qwen3.6-35B-A3B-GGUF`
- `unsloth/Qwen3.6-27B-GGUF`
- `mlx-community/Qwen3.6-35B-A3B-4bit`
- `LiquidAI/LFM2.5-350M-GGUF`
- `ytu-ce-cosmos/Turkish-Gemma-9b-T1-GGUF`
- `BAAI/bge-m3`

Refresh quarterly — model file sizes change as quantization techniques improve (Unsloth's UD-Q4_K_M is ~5% smaller than the standard Q4_K_M from earlier).
