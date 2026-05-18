# Top 100 Valuable Insights from WhatsApp Self-Chat
**Source: 2591 unique URLs (2356 X.com + 233 other) across Aug 2025 – May 2026**
**Analyzed: 2309 tweets via fxtwitter + 80 deep web fetches across papers/tools/articles**

Legend
- 🎯 = anchor concept for a deck slot
- 🧠 = research-deck candidate
- 🩺 = medical-ai-deck candidate
- 🛠 = tool to install / setup change
- 📐 = skill or workflow pattern to adopt
- 📚 = teaching / explainer artifact
- ⚠️ = caution / anti-pattern / awareness only
- 🅱️ = Bora-asset rediscovery (you already have this)

---

## PART A — FOUNDATIONS (1-10) Anchor concepts for llm-deck & teaching

1. 🎯📚 **Karpathy "Deep Dive into LLMs"** (https://youtu.be/7xTGNNLPyMI) — 3h centerpiece of any LLM intro: pretraining→SFT→RLHF, tokenization explains spelling fails, "jagged intelligence," DeepSeek-R1 inference-time compute. **Deck slot: llm-deck OPENER.** Why: highest-leverage single resource you saved.

2. 🎯 **Anthropic "Effective context engineering for AI agents"** (anthropic.com/engineering/effective-context-engineering-for-ai-agents) — Goldilocks system prompts; lean tools; few-shot > exhaustive lists; just-in-time retrieval; compaction + sub-agent summaries. **Deck slot: llm-deck "How to build agents" + Foundation for redakt + ceddcozum agent design.** Why: canonical 2026 framework.

3. 🎯🧠 **Anthropic NLA paper (transformer-circuits 2026)** — natural language autoencoders catch unverbalized eval-awareness and hypothesis-fixation in Opus 4.6 pre-deployment. **Deck slot: llm-research-deck "interpretability 2026".** Why: fresh primitive with concrete safety win.

4. 🎯 **Context Rot** (lego17440 Medium) — 18 SOTA models fail past ~10k tokens on trivial tasks; Claude becomes over-cautious. Marketed window ≠ usable window. **Deck slot: llm-deck counter-hype slide.** Directly addresses your #1 pain point (context exhaustion).

5. 🎯 **Databricks "memory beats model size"** — MemAlign 0%→70% (labeled), 2.5%→50% (unlabeled logs); reasoning steps 20→5. **Deck slot: llm-deck reframe slide.** Why: reframes "bigger model" into "better logs/memory" — direct architecture guide for ceddcozum agents.

6. 🎯 **ngrok quantization benchmarks** (Qwen 3.5 9B, M1 Max + H100) — Q8: no change. Q4_1: ~5-10% loss, 4× smaller, 2.4× faster. Q2: catastrophic 97% no-answer. **Action: in redakt, use Q4_1 not Q2.** **Deck slot: llm-deck + medical-ai-deck "running models locally for PHI."**

7. 🎯 **Karpathy "LLMs are simulators, not entities"** (85k engagement) — instead of "what do you think?" ask "what would a panel of [3 experts] discuss?" **Deck slot: llm-deck mental-model slide.** Why: fixes most prompting failures in one sentence.

8. 🎯📚 **Karpathy "LLM Knowledge Bases"** — building personal KBs is the highest-ROI use of agent tokens. Aligns 1-to-1 with your obsidian + memory system. **Deck slot: llm-deck "what to actually do with these things" slide.**

9. 🎯⚠️ **EchoBench medical sycophancy** (openreview mq6GMkoGjh) — Claude 3.7 Sonnet 45.98%, GPT-4.1 59.15%, **medical-tuned VLMs >95% sycophancy**. **Deck slot: medical-ai-deck HEADLINE.** Why: quantified clinical failure mode tailor-made for your clinician audience.

10. 🎯🩺 **Eric Topol "Paradox of medical AI implementation"** (Substack) — proven imaging AI ignored while unproven gen-AI sweeps clinics. Pancreatic-CT AI **475 days earlier** than radiologists, unused. 72% docs use gen-AI, 35% in direct decisions. **Deck slot: medical-ai-deck OPENER.** Why: cleanest framing for "AI in medicine 2026" talks.

---

## PART B — ANTHROPIC + CLAUDE CODE TRADECRAFT (11-25)

11. 📐 **bcherny (Boris) Claude Code setup** — "surprisingly vanilla." Default config is the right config. **llm-deck pattern: stop over-customizing.** Save as feedback memory.

12. 📐 **bcherny "hidden Claude Code features"** thread — favorite under-utilized features. **Action: scan and pin the genuinely useful ones to your CLAUDE.md.**

13. 🛠 **Anthropic Skilljar courses** (anthropic.skilljar.com) — Intermediate gold: MCP Python + Agent Skills + Subagents. Advanced: API + MCP production. **Action: send to your trainee group.**

14. 📐 **Andrew Ng + Anthropic Claude Code definitive course** (taught by Elie Schoppik) — agentic coding for "many minutes or hours." **Recommend in llm-deck "Where to learn" slide.**

15. 🛠 **Claude Code Security** (limited preview) — scans codebases for vulns, suggests patches. **Action: get on the waitlist; bake into redakt CI.**

16. 🛠 **Claude Managed Agents + Memory beta** — agent harness tuned for performance + production infra + memory layer. **medical-ai-deck competitive slide.**

17. 📐 **godofprompt's Karpathy CLAUDE.md system prompt** — turns Karpathy's coding rant into a paste-able CLAUDE.md. **Action: review and merge useful clauses into your global CLAUDE.md.**

18. 📐 **akshay_pachaar: .claude/ folder structure** — most devs skip setup; doing it right is the multiplier. **llm-deck "anatomy of a serious Claude Code project" slide.**

19. 📐 **nbaschez: best CLAUDE.md addition** — "When I report a bug, first write a test that reproduces it; subagents fix it; passing test proves it." **You already have this exact rule in your global CLAUDE.md** — confirm it's the canonical version.

20. 📐 **dejavucoder: Claude Code is having its Cursor moment** — long-form how-to-use blog post post-Karpathy. **Read once + crib into llm-deck.**

21. ⚠️ **Claude Code source map leak via npm** — Wes Bos analyzed "spinner verbs" (187 of them). Mostly meme-tier but reveals internal patterns. **Awareness only.**

22. 🛠 **Cursor Cookbook DAG Task Runner** — decomposes tasks → JSON DAG → sub-agents → streams to Canvas. **Action: clone-and-adapt for manuscript-from-clinical-data pipeline.**

23. 🛠 **Cursor 3.0** — "all code written by agents, depth of an IDE." **llm-deck IDE landscape slide.**

24. 🛠 **rauchg: "skills" as the npm of AI skills** — `npx skills i vercel-labs/agent-skills`. Vercel's positioning play. **llm-deck "skills ecosystem" slide; track for OpenCode.**

25. 📐 **Roundtable's full Claude Code setup** (27 agents, 64 skills, 33 commands + AgentShield 1,282 security tests) — works in Cursor too. **Action: cherry-pick AgentShield tests for ceddcozum/redakt.**

---

## PART C — CONTEXT, MEMORY, RAG (26-35)

26. 🛠 **Acontext: skills AS memory** (memodb-io/Acontext) — no embeddings, no vector DB, markdown skill files = memory. **Direct architecture model for redakt's persistence layer.** llm-research-deck slide.

27. 🎯 **Cobus Greyling: Generator–Reflector–Curator loop** — three agents maintain an evolving playbook instead of static prompts/fine-tunes. **Action: pattern for self-improving skill files in ceddcozum.**

28. 📚 **Anubhav Panda RAG visual guide** — clean 101 reference. **scholarslides + llm-deck "what is RAG" single slide.**

29. 🧠 **Hypernetworks for compiling docs into weights** (hardmaru) — alternative to RAG: bake the doc into the model on the fly. **llm-research-deck "post-RAG ideas" slide.**

30. 🧠 **MSA / Memory Sparse Attention** (elliotchen100) — native long memory in the model, not vector DB. **llm-research-deck memory architectures slide.**

31. 🛠 **Parallel.ai web search API** — per-query pricing $5–$2400/1k, 45-58% multi-hop accuracy, SOC-II. **literature-review + citation-verifier skill backend.** Clean alt to Tavily/Exa.

32. 🛠 **Scite MCP** — 1.6B+ papers with supporting/contradicting citation distinction. **citation-verifier + manuscript-from-clinical-data drop-in.** Reduces hallucinated refs.

33. 🛠 **Stanford STORM / Co-STORM** (storm.genie.stanford.edu) — auto Wikipedia-length cited reports, two-stage with HITL. **scholarslides + llm-research-deck — free open-source alt to deep-research products.**

34. 🛠 **Edison Scientific "Kosmos"** — agent runs hundreds of parallel research tasks; one run reads 1500 papers, writes 42k lines code. 12hr = months. **Commercial analog to your autoresearch + manuscript skills.** medical-ai-deck + llm-research-deck.

35. 🛠 **Kimi K2 multi-agent peds endo research artifact** — 115+ guidelines + 150+ reviews compiled across 5 sub-agents. **Already yours — pull into reference library for ceddcozum content.**

---

## PART D — LOCAL MODELS & SELF-HOSTING (36-45)

36. 🛠 **llm-checker CLI** (Pavelevich/llm-checker) — scans your M3 Max, ranks 229 Ollama models you can actually run. **Install now: replaces VRAM-crash trial-and-error.** Direct fit for model-trial project.

37. 🛠 **Ollama as official OpenCode provider** — `openclaw onboard --auth-choice ollama`. **Connects your local model-trial Ollama setup directly to OpenCode.**

38. 🛠 **Qwen3.5-35B-A3B for local agents** (victormustar, 32GB RAM) — "reliable tool calling, stable agentic loops, only 3B active params." **Drop-in for redakt.**

39. 🛠 **Qwen 3.5 on iPhone 17 Pro** (adrgrondin) — 2B 6-bit beats models 4× its size. **Important benchmark for on-device peds endo tools.**

40. 🛠 **Microsoft bitnet.cpp open-sourced** — 1-bit LLM inference on CPU, 6.17× speedup, 100B-param on local CPU. **Track for medical-ai-deck "can clinic PCs run frontier?" slide.**

41. 🛠 **UnslothAI: train Qwen3.5 with RL in 8GB VRAM** (free notebook, vision GRPO for math) — fine-tune on M3 Max. **Action: try this for a peds endo classification task.**

42. 🛠 **NVIDIA hosted free APIs for 80 AI models** (dhruvtwt_) — MiniMax M2.7, GLM 5.1, Kimi 2.5, DeepSeek 3.2, GPT-OSS-120B, Sarvam-M. **Plug into model-trial as free fallback.**

43. 🛠 **Tinker (Thinking Machines)** (thinkingmachines.ai/tinker) — hosted LoRA fine-tune for Qwen/Llama/DeepSeek/gpt-oss. 4 primitives: forward_backward / optim_step / sample / save_state. **Use for clinical-narrative fine-tune experiments without GPU mgmt.**

44. 📐 **zaimiri: "stopped paying for Claude Code, Ollama dropped Anthropic API compat"** — local-only path for non-PHI work. **medical-ai-deck angle: local models for regulatory comfort.**

45. ⚠️ **abliterated 30B GLM-4.7 on 4090 (chiefofautism)** — "safety alignment surgically removed." **awareness only — never integrate. Cautionary slide for "AI safety supply chain" talk.**

---

## PART E — AGENT ORCHESTRATION (46-55)

46. 🛠 **Ralv.ai** — 3D spatial canvas for managing many parallel coding agents (Mac alpha). **Directly addresses your dispatching-parallel-agents pain.** llm-deck slide.

47. 🛠 **n8n** (n8n.io) — low-code self-hostable workflow + AI agent. 188k stars. **Action: build paperless-NGX + Gmail + scheduled research workflows.**

48. 🛠 **Factory AI / Droid** — "Missions" workflow primitive, cloud + CLI + desktop. **llm-deck coding-agent landscape slide.**

49. 🛠 **LobeHub Lobe Chat** (77.3k stars) — Operator (agents as unit of work), 10k+ MCP plugins, Personal Memory transparent + editable. **Reference if you ever self-host a multi-model UI.**

50. 🛠 **Collaborator (collab-public)** — native desktop "infinite canvas of tiles" (terminal, code, markdown, image). Persistent PTY. **Try as replacement for scattered terminal tabs.**

51. 📐 **karpathy autoresearch loop** — packaged into self-contained repo; ~2 days run on depth=12 nanochat → 20 additive improvements found. **Already a skill in your kit — confirm autoresearch.md is current.**

52. 📐 **simplifyinAI/alex_prompter "Agents of Chaos"** (Stanford+Harvard) — autonomous agents in open competitive envs collude / sabotage. **llm-research-deck risk slide.**

53. 🛠 **MiniMax-AI/skills** — 18+ Claude/Cursor/Codex compatible skills: doc tools (PDF/PPTX/Excel/DOCX), multimodal (text-to-video, image-to-image, TTS), Android + iOS. **Cherry-pick TTS + video for educational decks.**

54. 🧠 **ml-intern (akseljoonas, HuggingFace)** — open-source agent that ran HF's post-training loop. **llm-research-deck "agents doing ML research" slide.**

55. 🛠 **OpenRouter Fusion** — multi-model ensembling without code. **llm-deck "model ensembling for free" slide.**

---

## PART F — MODEL LANDSCAPE 2026 (56-65)

56. 🛠 **Vercel AI Gateway pricing** — DeepSeek v4-flash $0.14/$0.28; Claude Opus 4.7 $5/$25; GPT-5.5-pro $30/$180 per Mtok. **llm-deck current pricing slide. Update model_watchdog.**

57. 🩺 **Atlas Cloud — HIPAA + SOC across 300+ models** — rare in aggregators. **medical-ai-deck "compliant aggregators" slide. Direct relevance for any redakt server-side use case.**

58. 🛠 **MiniMax M2.5/M2.7** — 80.2% SWE-Bench (beats Opus 4.6 on some); $1/hr at 100 tps; open source. **llm-deck open-source frontier slide.**

59. 🧠 **Qwen 3.5 Medium series** (Flash, 35B-A3B, 122B-A10B, 27B) — 35B-A3B surpasses Qwen3-235B-A22B. **Important for "MoE small model wins" narrative in llm-research-deck.**

60. 🧠 **Qwen3.5-Omni native multimodal** — text + image + audio + video. **medical-ai-deck "multimodal clinical" slide.**

61. 🧠 **Mercury 2 (StefanoErmon)** — "world's first reasoning diffusion LLM" — 5× faster than speed-optimized LLMs. **llm-research-deck "post-transformer architectures" slide.**

62. 🧠 **Glasswing — Claude Mythos Preview** — 83.1% on cybersecurity vuln reproduction (was 66.6%). $25/$125 per Mtok premium. **llm-research-deck capability slide.**

63. 🧠 **Alex Whedon "SubQ" claim** — 12M-token context, sub-quadratic sparse attention, 52× faster. **Caveat: tweet only — needs verification.** Track for llm-research-deck.

64. 🛠 **Epoch AI Model Database** — 3500+ models with FLOP/params/cost/energy. **Authoritative source for "scaling trends" slide; cross-ref model_watchdog.**

65. 🛠 **HuggingModels Turkish-Gemma-9B-T1** — fine-tuned for Turkish reasoning. **Action: test for ceddcozum + redakt Turkish content; potential local model upgrade.**

---

## PART G — DESIGN / TASTE / VIBE-CODING UX (66-75)

66. 🎯 **Emil Kowalski "Agents with Taste"** — taste is rule-extractable. scale(0.95→1) not (0→1); micro 100-150ms, UI 150-250ms, modal 200-300ms; 65ch line cap; tabular-nums for numbers; :active scale(0.97). **Action: build a `bora-taste` skill file. Fixes "feels off" pain in decks-bora + ceddcozum forever.**

67. 🛠 **Taste (buildwithtaste.com)** — screenshot UIs → persistent taste profile MCP for Cursor/Claude. **Pairs with #66: capture your favorite refs once, agents inherit.**

68. 🎯 **_chenglou's front-end "view transitions"** thread (93k engagement) — foundational primitive that changes how interfaces feel. **Read in full and integrate patterns into decks-bora.**

69. 🛠 **Hugeicons (51k icons)** — free stroke-rounded covers most clinical UI. **ceddcozum + decks-bora icon source.**

70. 📐 **pie6k: OKLCH color model** — randomly move hue slider, colors stay in harmony. **Use OKLCH for all decks-bora theming.** Single highest-leverage CSS-color tip.

71. 📐 **itsandrewgao: learn UI component names → 10× vibecoded frontends** — "only words you know are menu and button → generic slop." **Action: build a 1-page glossary in `bora-taste` skill.**

72. 📐 **PrajwalTomar_: Cursor + Opus 4.5 scrollytelling landing page in 10 min** — design playbook. **Pattern for ai-endo-cosmos and t1dm-teach.**

73. 🛠 **DilumSanjaya: GPT Images 2 design + Gemini 3.1 Pro code** combo for interactive 3D biology apps. **Pattern for ceddcozum atlas pages.**

74. 🛠 **react-grab (aidenybai)** — select any element on page → tell Claude what to change. `npx react-grab@latest`. **Install in decks-bora dev loop.**

75. 📐 **viktoroddy: Claude Design + Opus 4.7 award-winning sites tutorial** — 18 min. **Watch + crib for decks-bora templates.**

---

## PART H — MEDICAL AI EVIDENCE & CLINICAL CONTENT (76-85) 🩺

76. 🩺 **EMQN CAH guidelines (CYP21A2)** — TOP PRIORITY paper for ceddcozum. Standardized methodology, MLPA + sequencing, variant classification. **Direct ceddcozum content; cite in 21-OHD genetic-testing tool.**

77. 🩺 **Turkish thyroid volume norms** (n=1,553, JPEM 2024, Deveci Sevim) — smaller than WHO refs in iodine-sufficient Turkey. **TOP PRIORITY for ceddcozum pediatric thyroid US tool.**

78. 🩺 **Obesity genetics+epigenetics review** (Keller 2023, Curr Obes Rep) — GWAS + EWAS + PRS in obesity. **medical-ai-deck genomics slide; pairs with your polygenic-risk-score skill.**

79. 🩺 **Sleep duration vs adiposity, n=144** (Glasgow IJO 2022) — DURATION matters, not regularity/onset. **Patient-education slide; ceddcozum content.**

80. 🩺 **Sleep + adolescent obesity systematic review** (Gale SMR 2024, 89 studies, ages 8-18) — chronotype + sleep hygiene + variable timing → obesity. **ceddcozum lifestyle content.**

81. 🩺 **DOHaD hypothalamic programming review** (Frontiers Neuro 2015) — NPY/AgRP up, POMC down; reversible. **ceddcozum + medical-ai-deck "fetal programming" content.**

82. 🩺 **Methylome of adipose tissue, obesity** (Macartney-Coxson 2017) — 3,239 + 7,722 DMCs; PITX2/ISL2 correlate w/ glucose+HDL; ATP2C2 distinguishes tissue. **medical-ai-deck mechanistic-depth slide.**

83. 🩺 **Weightless (Dr. Salas-Whalen)** — GLP-1 book by board-cert endocrinologist; obesity as chronic disease + Ozempic/Wegovy/Mounjaro practical use. **Reference in ceddcozum patient ed + medical-ai-deck.**

84. 🩺 **MAGICapp GRADE platform** — 5,467 public guidelines, 23,233 recs. **Drop into your guideline-fetcher + clinical-guidelines skills as a known endpoint.**

85. 🩺 **gdb "Introducing ChatGPT for Clinicians"** — OpenAI's clinical UI. **Track + critique in medical-ai-deck — what does it actually do vs marketing?**

---

## PART I — IMAGE / VIDEO / MULTIMODAL (86-90)

86. 🛠 **skirano: Nano Banana Pro = "compression algorithm of human history"** — paper → whiteboard photo. **Action: try with peds endo papers for slide-ready visuals.**

87. 🛠 **Kling AI image-to-video API** — 4K, 15s, native audio + lip-sync, ≤6 multi-shots, voice cloning. **Sora 2 vs Veo 3 vs Kling vs Seedance comparison slide in llm-deck.**

88. 🛠 **Higgsfield Sora-2 presets** — vertical-video preset library. **Case study of "model wrapper as product" — same pattern as your sora skill.**

89. 🛠 **Qwen-Image-Layered** — Photoshop-grade RGBA layered output from a single prompt. **Action: integrate into nano-banana-pro skill or image-utils for poster work.**

90. 🛠 **Paper2Video (PaperTalk)** — paper → full slides + narration + talking head. **medical-ai-deck and manim-teach: pattern to study; possible feature for scholarslides.**

---

## PART J — TEACHING / RESEARCH / WRITING (91-100)

91. 📚 **ml-visualized.com (Gavin Hung)** — Jupyter notebooks with animated gradient descent / backprop / PCA, lecture notes. **Drop-in animations for manim-teach and scholarslides foundations chapters.**

92. 📚 **John Oliver "AI Slop" Last Week Tonight** — cultural-level framing. **llm-deck closer slide + ethics chapter for clinicians.**

93. 📚 **Primer "Taking AI Doom Seriously"** (62 min) — polished safety primer. **llm-deck stakes slide.**

94. 📚 **MIT Patrick Winston "How to Speak"** — Jay Nitx surfaced this, 18M views. **Personal study + decks-bora speaking-style template.**

95. 🧠 **NeurIPS Reproducibility framework** (Pineau 2020) — code policy + challenge + checklist. **scholarslides + llm-research-deck "AI methodology rigor" slide.**

96. ⚠️ **Andy Stapleton "Spot AI Writing"** — low perplexity, "delve/robust/moreover" tells, hedging absent. **Pair with avoid-ai-writing skill for academic writing slides.**

97. ⚠️ **Authenticity Gap / AI Slop (pamir_93399)** — 70-80% LinkedIn AI-gen, formulas to avoid, pathos/logos/ethos fix. **llm-deck ethics slide.**

98. ⚠️ **MIT "delusional spiraling" sycophancy paper** — math proof that LLM agreement cascades into delusion. **medical-ai-deck sycophancy slide pair with EchoBench (#9).**

99. 📚 **Hesamation 2hr Peter Steinberger interview** — process, ships without checking tests, advice for new grads. **llm-deck "what a master vibe-coder actually does."**

100. 📚 **Hugging Face Smol Training Playbook (214 pages)** — how to train LLMs end-to-end. **llm-research-deck reference; reading material.**

---

# DECK BLUEPRINTS

## llm-deck (your existing) — proposed restructure

**Opener:** Karpathy 3h "Deep Dive into LLMs" (#1)
**Foundations:**
- Tokenization / embeddings / attention (use 8gwifi activation explorer #28)
- Family-of-models view (#100 Karpathy nanochat)
**State of 2026:**
- Model tier (Opus 4.7 / Sonnet 4.6 / Haiku) (#2)
- Vercel AI Gateway pricing (#56)
- Local models on M3 Max (#36, #38)
**How to build agents:**
- Anthropic context engineering (#2)
- Goldilocks prompts + lean tools (#2)
- Memory > model size (#5)
- Acontext: skills as memory (#26)
- Multi-agent: Generator-Reflector-Curator (#27)
- DAG runner (#22)
**Counter-hype slides:**
- Context Rot (#4)
- AI Slop (#92, #97)
- Sycophancy (#9, #98)
**Vibe-coding tradecraft:**
- Boris's vanilla setup (#11)
- .claude/ folder anatomy (#18)
- Taste rules (#66)
- Component-name glossary (#71)
**Closer:** Topol paradox of medical AI (#10) → segue to medical-ai-deck

## NEW DECK: llm-research-deck

- Interpretability: NLA paper (#3) + Neuronpedia (#10 part 2)
- Memory architectures: Acontext (#26), MSA (#30), hypernetworks (#29), Databricks memory (#5)
- Frontier capabilities: Glasswing 83.1% (#62), Mercury 2 diffusion LLM (#61), Qwen-Omni (#60)
- Scaling: Epoch AI database (#64), Smol training playbook (#100)
- Agents doing research: ml-intern (#54), Kosmos (#34), Tinker (#43), STORM (#33)
- AI safety: Agents of Chaos (#52), AI Doom 62-min (#93), delusional spiraling (#98)
- Reproducibility: NeurIPS framework (#95)

## NEW DECK: medical-ai-deck 🩺 (highest priority — almost ready to build)

**Opener:** Topol paradox (#10)
**Failure modes:**
- EchoBench sycophancy in medical VLMs (#9)
- MIT delusional spiraling (#98)
**Genomics:**
- Obesity genetics+epigenetics review (#78)
- Methylome of adipose (#82)
- CAH EMQN guidelines (#76)
- Turkish thyroid norms (#77)
**Multimodal & local:**
- Atlas Cloud HIPAA aggregator (#57)
- Local Qwen quantization for PHI (#6)
- Turkish-Gemma (#65)
**Tools clinicians actually use:**
- Scite MCP (#32)
- MAGICapp (#84)
- Kosmos (#34)
- ChatGPT for Clinicians critique (#85)
**Closer:** Weightless reference (#83) + your ai-endo-cosmos viz (#🅱️)

## decks-bora-design upgrade

- buildwithtaste.com MCP (#67) — wire into Cursor
- bora-taste.skill.md from #66
- OKLCH theming pass (#70)
- Hugeicons (#69) baseline
- React Grab dev loop (#74)

---

# PROJECT INCORPORATION SUGGESTIONS

## redakt (highest payoff)
- **Quant policy: Q4_1 not Q2** (#6)
- **Memory layer modeled on Acontext** — markdown skill files version-controlled, no vector DB (#26)
- **Preprocessor: Layout-Parser** for layout-aware extraction before LLM redaction
- **Server option:** Atlas Cloud HIPAA path for non-local mode (#57)
- **Local agent model:** Qwen3.5-35B-A3B (#38)
- **CI guardrails:** AgentShield 1,282 security tests (#25)

## ceddcozum
- **New tool:** CAH genetic-testing helper from EMQN (#76)
- **Update:** Turkish thyroid US tool with new norms (#77)
- **New tool:** Polygenic risk-score educator using #78
- **Patient-ed page:** sleep duration matters not bedtime regularity (#79)
- **Cite:** Weightless throughout GLP-1 patient content (#83)
- **Atlas page:** GPT Images 2 + Gemini 3.1 Pro 3D bio app pattern (#73)
- **Self-improving skill** via Generator-Reflector-Curator (#27)

## scholarslides
- **Reproducibility appendix** option per deck (#95)
- **STORM-style** two-stage research-then-write toggle (#33)
- **Paper2Video** competitor analysis (#90)
- **Manim animation block** from ml-visualized.com (#91)

## decks-bora
- **bora-taste skill** (#66, #71)
- **buildwithtaste.com MCP** integration (#67)
- **OKLCH default palette** (#70)
- **Hugeicons** baseline pack (#69)

## ai-endo-cosmos
- Update with 2026 papers using Kosmos pipeline (#34) — 12hr full literature pass
- Add NLA-style interpretability nodes (#3)

## model-trial
- **Install llm-checker** (#36) — fix VRAM trial-and-error
- **Test Turkish-Gemma-9B-T1** (#65)
- **Try bitnet.cpp** (#40)
- **NVIDIA free 80-model API** as fallback (#42)

## twitter-ai-scout / model_watchdog
- **Add to model_watchdog:** Mercury 2 (#61), MiniMax M2.7 (#58), Qwen 3.5 Medium series (#59)
- **Update pricing table:** Vercel AI Gateway 2026 (#56)
- **New tracking source:** Epoch AI (#64) as ground truth

## new skill ideas
- **bora-taste.skill.md** — codified UI taste rules
- **medical-ai-evidence.skill.md** — Topol + EchoBench facts always at hand
- **local-model-policy.skill.md** — quant rules + model picks per task

---

# IMMEDIATE ACTION ITEMS (next 7 days)

1. **REVOKE the leaked OpenAI key from chat line 106** (`sk-proj-nfCUsG1B...` from Sept 8 2025) — do this today
2. Fix broken endpoints: endobora.com/dkaFluid (404), ai-mind-sigma (404)
3. Install llm-checker (#36) — pick local models without crashes
4. Create `~/.claude/skills/bora-taste/SKILL.md` (#66, #67, #70, #71)
5. Start medical-ai-deck (#10 + #9 + #76 + #77 — you have all four pieces)
6. Wire buildwithtaste.com MCP into Cursor (#67)
7. Schedule a Karpathy 3h deep-dive watch + add to llm-deck (#1)
