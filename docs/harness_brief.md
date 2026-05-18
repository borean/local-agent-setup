# Harness Verdict — May 2026

## TL;DR Stack

| Layer | Pick | Version | License | Why won |
|---|---|---|---|---|
| **Inference (always)** | **LM Studio** | 0.4.13 | proprietary free | MLX engine (best Mac inference), built-in GBNF/tool-use, MCP server+client, OAI-compat endpoint, one-click model swap |
| **Tool-call robustness** | LM Studio GBNF + **LFM2.5-350M** sidecar | LFM2.5: latest | MIT | GBNF is free with LM Studio; LFM2.5 hits 96-98% tool-call accuracy at 350M params (313 tok/s CPU) |
| **Bora power user** | **OpenCode** v1.15.4 + **Hermes Agent** v0.14.0 | latest | MIT | OpenCode = 162k⭐ terminal harness, native SKILL.md. Hermes = 156k⭐, self-evolving skills, agentskills.io hub |
| **Colleague GUI** | **Goose** v1.34.1 desktop | latest | Apache-2.0 (Linux Foundation) | Native desktop Mac/Win/Linux, SKILL.md dual-loader (`.agents/skills/` portable + `.goose/skills/` own), MCP, one-dropdown LM Studio binding |
| **GUI fallback** | Jan v0.7.9 | latest | Apache-2.0 | Simpler than Goose if "developer-flavored" too busy |
| **Medical literature** | **PaperQA2** v2026.03.18 | Future House, Apache-2.0 | The only peer-reviewed mature scientific-RAG agent; multimodal tables/figures, Docling parser, LiteLLM → local Ollama/LM Studio |
| **Systematic review depth** | **Local Deep Research** v1.6.6 | open | ~95% SimpleQA on Qwen 3.6-27B, arXiv+PubMed connectors, AES-256 local DB |
| **Topic synthesis** | **STORM/Co-STORM** | Stanford OVAL, MIT | Wikipedia-style cited reports; OllamaClient + VectorRM for local |
| **Skill format** | **SKILL.md** | open standard (Anthropic, Dec 18 2025) | adopted by 32 tools; YAML frontmatter + Markdown + optional `scripts/references/assets/` |

## What we explicitly rejected, and why

- ❌ **Claude Code** — phone-home, requires auth dance, vendor lock-in despite SKILL.md openness
- ❌ **Cline** — documented Qwen3.5 thinking-block bugs (likely 3.6 too); needs VS Code (non-clinician)
- ❌ **Aider** — *silent* 2k-context truncation with Ollama if you don't set `num_ctx` — dangerous default; terminal-only
- ❌ **Open WebUI** — license change April 2025: ≥50 users requires enterprise license, no longer OSI-approved → avoid institutional rollout
- ❌ **smolagents / LangGraph / CrewAI / Magentic-One** — dev frameworks, not end-user harnesses
- ❌ **AgentScope** — Python framework, dev-y, no end-user GUI
- ❌ **Continue.dev** — IDE-bound, format not portable
- ❌ **Qwen-Agent (standalone)** — best for tool-call parsing but weak skills story; we get its parser benefit via LM Studio backend without adopting its framework
- ❌ **AnythingLLM** — strong contender but documented agent-skill-UI bugs late 2025, custom JS plugin format not portable
- ❌ **LibreChat** — multi-user, requires Docker, agent skills feature still on 2026 roadmap

## Tool-call robustness — the actual best practice

Three layers, listed by where they sit:

1. **Inference-layer (what you actually want)** — XGrammar (vLLM/SGLang/TRT-LLM default in 2026, ~40μs/tok) OR llama.cpp GBNF + LLguidance (the Mac path, under LM Studio/Jan/Ollama hood, ~50μs/tok via LLguidance's Rust Earley parser). **LM Studio uses GBNF natively when you turn tool-use on. You get this for free.**
2. **Client-layer (if you don't control inference)** — BAML for "parse messy outputs gracefully," Instructor for OpenAI/Ollama client patching (auto-selects TOOLS vs JSON for Qwen 2.5/3), Pydantic AI for type-safe agents.
3. **Sidecar router** — LFM2.5-350M, MIT, on HF/LM Studio/Ollama. Fine-tuned variant hits 96-98% tool-call accuracy matching its 120B teacher. 313 tok/s on CPU. **Use this for skill #01-session-launch's routing decision**.

For our stack: **LM Studio's built-in GBNF + LFM2.5-350M sidecar.** No client-layer libraries needed unless we add a Python data pipeline (then Instructor).

## What this means for the v1 skill set

No structural changes — SKILL.md was the right bet from frontmatter day one. Three small additions:

1. **Add `compatibility:` field** to every skill's frontmatter — OpenCode reads this.
2. **Add `metadata:` block** — OpenCode and Hermes both look here for skill-hub publishing.
3. **Place skills at `~/.agents/skills/`** (portable path) — Goose, OpenCode, and Hermes all auto-discover.
4. **Wire PaperQA2 as the engine behind Pillar 2 skills #07-09** — `paper-summarize`, `evidence-synthesize`, `citation-verify` all call `pqa` CLI under the hood instead of raw LEANN. LEANN stays as fast raw retrieval (#06-leann-search) for non-cited semantic search.
5. **Wire STORM as backend for #11-systematic-review-screen** — Co-STORM's dynamic mind-map is genuinely the right primitive for review writing.
6. **Wire Local Deep Research as backend for #10-guideline-lookup + #11-screen** — has arXiv+PubMed connectors that work fully offline once cached.

Everything else stays.
