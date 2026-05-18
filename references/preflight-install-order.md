# Pre-flight Install Order — the 5 Things to Lock Before Any Agentic Project

**Source**: Karpathy (per @DeRonin_ thread, May 2026): *"anybody who uses or learns agentic systems, SHOULD READ THIS — the install order I run before any new agentic project."*

Five tools, in order. They cost a few hours to set up; you save weeks of pain.

---

## 1. PRIVACY — `direnv` + a real secrets manager

**Install**: `direnv`, then wire it into your team's password manager — 1Password CLI (`op run`), Doppler, Infisical, or Vault. Pick one.

**What direnv does**: loads per-folder environment variables when you `cd` in, unloads when you `cd` out. The real move is wiring it into your secrets manager so credentials NEVER live in plain text on disk.

**What this stops**:
- API keys accidentally committed to git history — the most common AI agent breach pattern in 2026
- Credentials leaking from one project into another through your shell history
- Shared `.env` files that one teammate quietly backs up to Dropbox
- Secrets that survive a laptop theft because they were sitting in `/Users/you/projects`

**The part nobody mentions**: most *"my agent got jailbroken"* stories actually trace back to one credential the agent had access to that it shouldn't have. **Scope keys to projects, scope projects to folders, and the blast radius of any single compromise drops dramatically.**

*For our air-gapped medical-research context: this matters during the SETUP phase (when the frontier LLM is running). Post-setup the air-gap reduces the surface drastically, but you still want direnv for the rare brief Research-Mode lifts.*

---

## 2. TOKENS — `litellm` or `portkey` as your model proxy

One URL that fronts every AI provider (Anthropic, OpenAI, Google, Mistral, local models). All your spend flows through one place.

**What it saves you**:
- **Response caching** keyed by prompt hash — cuts your bill 30-60% on repeat tasks
- **Automatic fallback on rate limits** — Sonnet hits a 429? Falls to Opus, then GPT, then your local backup. No broken users
- **Per-feature and per-user budget caps** — block the call before it costs $200 instead of auditing it after
- **Model routing rules** — cheap tasks to Haiku, expensive ones to Opus, never the wrong way
- **PII redaction before requests leave your network** — security side benefit

**The part nobody mentions**: every *"$4k AI bill"* story ends with *"we didn't have a proxy in front."* This is where you put guardrails around spend BEFORE the spend happens.

*For our air-gapped context: litellm runs locally as the proxy in front of `llama-server`. It gives us caching, budget caps, and PII redaction even though we have no remote provider. Daily cost visibility = 0 (local) but the audit logging is what we want.*

---

## 3. CONTEXT — `uv` + git commit on every passing eval

Install `uv` (the Astral team behind `ruff`; 10-100× faster than pip+venv). Then commit every time an eval suite PASSES, with the **model version and pass rate** in the commit message.

**What this preserves**:
- Exact dependency set via `uv.lock` — no nasty surprises from a quiet update
- Exact prompt + code state — you can reproduce any past run from a single git hash
- Exact model version paired to exact pass rate — paper trail when prod breaks weeks later
- One-command rollback to a known-working state when a refactor goes sideways
- A compliance story — every prompt version tied to a model version in your commit log

**The security side**: when something blows up in prod, you want to say *"the prompt was version X, model was Sonnet 4.6.1, last eval pass rate was 94%."* Not *"I think we deployed on Tuesday?"* The first is an incident report. The second is a resignation letter.

*For our air-gapped medical-research context: this is the perfect audit trail for KVKK Art. 12. The commit message becomes part of the audit log. Pin Qwen 3.6 version + GGUF quant hash in every passing-eval commit.*

---

## 4. VISIBILITY — `mitmproxy` in front of every LLM call

It's basically a wiretap for your agent. Install it, point your agent through it, and now you see every conversation your agent has with the model in real time.

**What actually shows up**:
- Every silent retry your SDK sneaks in when a call fails
- The full prompt being sent (including any creds you accidentally embedded)
- What the model returns BEFORE your code reacts to it
- Exact token cost per call, per tool, per loop iteration
- Responses that quietly trigger your code into doing something you didn't intend — **this is where prompt injection lives**

**The part nobody talks about**: if a website your agent scraped slipped instructions into its data, mitmproxy is how you SEE the moment your agent decides to follow them. Without this layer, you're trusting your agent did the right thing, not verifying.

*For our air-gapped context: mitmproxy on `localhost:11434` for all llama-server calls. Logs go straight into `~/Research/audit/YYYY-MM-DD/`. KVKK Art. 12 audit trail with prompt-level granularity.*

---

## 5. EVALS — `inspect-ai` (the framework the labs actually use)

The eval framework Anthropic, DeepMind, and the UK AI Safety Institute use for the eval reports in their papers. Open source, MIT licensed.

**What your homegrown version won't have**:
- Run the same task across 5 different models and compare scores side-by-side
- Pre-built tests for risky agent behavior (lying, manipulating, misusing tools)
- Proper structure for evaluating tool-using agents, not just chat
- Repeatable scoring — same input always gets graded the same way
- Reproducible eval seeds — a flaky test is actually flaky, not just unlucky

If you ever want to say *"my agent passes safety checks"* out loud, the check has to come from a framework someone else can re-run. **This is that framework.**

*For our air-gapped medical-research context: build `inspect-ai` tasks for each skill. e.g., `evidence-synthesize` eval = 10 paper-summaries + a question, scored on citation accuracy + claim coverage. Run before any skill change. Commit the pass-rate to git per #3 above.*

---

## Plus: keep `/lessons.md` in every repo

Every weird agent behavior, every edge case, every config change you find at 2am — write it down.

You will not remember it. You'll come back in 3 weeks and the lessons file is the only reason you still know what's going on.

---

## Bottom line

*"Lock these 5, keep the lessons file, your next agentic system takes 2 days instead of 2 months."*

For our air-gapped medical-research stack, all 5 install during setup phase. Once setup is done, they keep running locally — direnv for the rare credential needed during brief Research-Mode lifts; litellm + mitmproxy as the always-on local proxy/wiretap; uv + git + inspect-ai as the dev-loop trio for skill iteration.

The 5 tools become part of the `Phase 0` block in `SETUP_PROMPT.md` — they install before anything else.

> *p.s. half of "AI agent" content online is people who've never run mitmproxy on their own loop. They don't actually know what their agent is doing. They're shipping demo videos. Don't be that guy.*
