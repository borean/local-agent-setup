# Changelog

## [0.9.5] — 2026-05-19 — Existing-assets audit + headless wording sweep

Two converged review findings: (1) every external auditor flagged that the repo assumes a greenfield Mac and would blindly redownload 35–64 GB of models the user may already have; (2) the repo carried personal wording (`bora` paths, "Bora's adaptation", "Turkish pediatric endocrinologist" persona) that's noise for non-author users. Both addressed in this release.

### Added — existing-assets audit in PRE-CHECK

PRE-CHECK now scans the machine before any download and writes a manifest to `~/.research/setup-existing-assets.txt`. Catalogued:

- Ollama installations + model list (`ollama list`)
- LM Studio model cache (`~/.lmstudio/models/`)
- HuggingFace cache (`~/.cache/huggingface/hub/`)
- Existing Hermes config (`~/.hermes/config.yaml` — includes its current `base_url` so the agent knows if it's pointed at a cloud provider)
- Hermes binary on PATH
- Existing `~/.agents/skills/` tree (with skill count)
- Existing `~/.agents/hooks/` (with hook count)
- pipx-installed packages (`pipx list --short`)
- npm globals (`npm ls -g`)

The audit is persisted as `$EXISTING_ASSETS` in `~/.research/setup-env`. Downstream phases consult it before downloading or overwriting.

### Added — reuse branches in Phases 1 / 2 / 5 / 7

Each phase now offers explicit reuse/skip/overwrite branches:

- **Phase 1 (models)**: detects existing Qwen 3.6 / LFM2.5 weights in Ollama / LM Studio / HF cache. Three options: `(r)` reuse via symlink into `~/.research/models/`, `(d)` download fresh (pin a specific revision), `(s)` skip Phase 1 model downloads entirely. The HF CLI download is idempotent anyway, but the symlink path saves 35-64 GB on power-user Macs.
- **Phase 2 (skills)**: detects an existing `~/.agents/skills/` tree (130+ skills is typical for a power-user coding-agent setup). Three options: `(m)` merge with `cp -Rn` (existing wins on collision), `(n)` namespace install to `~/.agents/skills-local-agent/` (keep separate), `(o)` overwrite (destructive). New `$SKILLS_TARGET` variable threads through to Hermes config in Phase 7.
- **Phase 5 (ceddcozum)**: gated on `$INSTALL_CEDDCOZUM` from pre-flight Q9 (defaults to skip for non-pediatric fields). Phase 5 also reuses an existing global `ceddcozum` install rather than reinstalling.
- **Phase 7 (Hermes)**: detects an existing `~/.hermes/config.yaml` and offers `(b)` backup-then-write (default), `(s)` skip (keep existing config, user must manually point skills/hooks paths), `(o)` overwrite. Reuses the `hermes` binary if already on PATH.

### Added — Turkish-Gemma is now language-gated, not field-gated

Phase 1 Turkish-Gemma download was previously triggered by `$FIELD = "pediatric endocrinology"` (weird coupling — non-medical Turkish writers got no Turkish model). Now gated on `$LANG_HINT = "tr"`, asked as the new pre-flight Q8.

### Changed — headless wording sweep (repo is now author-agnostic)

The repo was carrying personal wording inherited from the seed-user's setup. Stripped:

- `skills/coding/bora/` → `skills/coding/personal/` (renamed via `git mv`)
- All 20 `BORA-NOTES.md` files → `PERSONAL-NOTES.md` (renamed via `git mv`)
- `sub-category: bora` → `sub-category: personal` in 3 SKILL.md frontmatters
- `com.bora.*` launchd labels → `com.local-agent.*` in both `SETUP_PROMPT.md` plists and `scripts/install-cron.sh`
- `bora-voice.md` voice profile filename → `voice.md` (still parameterized as `${USERNAME}-voice.md` at install)
- "Bora's Notes —" header → "Personal Notes —" across all PERSONAL-NOTES.md
- "Bora is a Turkish pediatric endocrinologist; this is built for his workflow" → "Built around a clinical-research workflow (peds endocrinology was the seed, but the design generalizes to oncology, cardiology, rheumatology, internal medicine, etc.)"
- "You are setting up a medical research workstation for a Turkish pediatric endocrinologist" → "You are setting up a medical-research workstation for a clinical researcher"
- Air-gap preamble: "You are running on a Turkish pediatric endocrinologist's local Qwen 3.6 model." → "You are running on the user's local Qwen 3.6 model."
- "For Bora's setup we use llama-server direct" → "Default path is llama-server / mlx_lm.server direct"
- "Bora's existing infrastructure" / "Bora's existing 130+ Claude Code skills" / "Bora vibes React" / "decks-bora animations" / etc. — generalized in `references/`
- README tree diagram: `└── bora/` → `└── personal/`
- README "Skills: 43-skill medical-research bundle" → "74 SKILL.md files in three bundles"; Hooks count corrected to 11

What's preserved: `CREDITS.md` attribution (Bora as author/curator), `CHANGELOG.md` history (records of past decisions), `DECISIONS.md` (local-machine state file), `docs/` historical planning artifacts, GitHub URL `github.com/borean/local-agent-setup` (repo owner is `borean` — that's the GitHub handle, not personal noise).

### Changed — pre-flight Q&A expanded to 10 questions

Was 8, now 10. New questions:

- **Q7 (was first-paper-only)**: Clinical field / research domain — now universal. Drives field-preset generation, style-calibration generic mode, downstream skill defaults.
- **Q8 (new)**: Primary clinical writing language (en / tr / other). Drives Turkish-Gemma download decision.
- **Q9 (new)**: Install ceddcozum? (y/n). Recommended y only if field involves pediatrics.
- **Q10 (was Q8)**: Confirm Hermes Agent — now phrased "TUI today, Desktop arrives later" (was incorrectly "Hermes Agent Desktop").

### Changed — Hermes Agent Desktop stale references removed

Phase 7 was already correct (v0.9.2 fix). Mopped up stale "Hermes Agent Desktop" mentions in README, AGENTS.md, and the SETUP_PROMPT.md INITIAL CONTEXT block. The repo now consistently says "Hermes Agent (TUI today, Desktop later)" everywhere user-facing.

### Changed — README Status section refreshed

Was stale since v0.3.0 (claimed 0/43 skill files written, 0/10 hooks). Updated to v0.9.5 reality: 74 SKILL.md files, 11 hooks, 7 cron tasks, 11-phase SETUP_PROMPT, verification suite, existing-assets audit. Open items: real-machine install validation (Phase A first), Linux/Windows walk-throughs, public release post-validation.

### Open (carried from prior versions)

- Real-machine install validation: Phase A spine smoke test (1-2 h) recommended before full install (~2 h, 64 GB downloads). See `references/phase-a-smoke-test.md`.
- Linux + Windows full setup walk-throughs (deferred; cross-platform notes exist)
- Field preset population for non-peds-endo fields (oncology / IM / surgery stubs in `references/field-preset-examples/`)
- Hermes-Raindrop OTLP bridge smoke test (untested)
- Public release post real-install validation

---

## [0.9.4] — 2026-05-19 — Round-3 review fixes: dispatcher scripts, filenames, generalize literature path

Round-3 5-way review (Grok + Claude + Composer + ChatGPT + Minimax) surfaced six real bugs + one user question. Fixing.

### Fixed — missing dispatcher scripts

Composer caught: `install-cron.sh` writes plists that call `~/.agents/bin/run-cron-task.sh`, but that script didn't exist. Same with `invoke.sh` references in verification tests + style-calibration phase.

Wrote two dispatchers under `bin/`:

- **`bin/run-cron-task.sh`** — reads a cron task's `SKILL.md`, extracts bash code blocks from the `## Procedure` section, executes them, logs stdout+stderr to `~/.research/logs/cron-{task}-{date}.log`, appends to `~/Research/audit/{date}/events.jsonl`. Used by every launchctl-installed cron plist.
- **`bin/invoke-skill.sh`** — generic dispatcher for any SKILL.md. Reads from `~/.agents/skills/<path>/SKILL.md` (installed) or `$LOCAL_AGENT_SETUP/skills/<path>/SKILL.md` (repo). Extracts bash blocks; if none, dumps the SKILL.md for LLM consumption. Accepts `--args '<json>'` for skill input.

Phase 2 in `SETUP_PROMPT.md` now copies `$LOCAL_AGENT_SETUP/bin/*.sh` → `~/.agents/bin/`. Tests 8 + 10 + Phase 6 style-calibration calls updated to use `~/.agents/bin/invoke-skill.sh <skill-path>` rather than non-existent `<skill>/invoke.sh`.

### Fixed — model filename drift

Composer caught:

1. **Qwen 3.6 35B-A3B**: download was `Qwen3.6-35B-A3B-Q4_K_M.gguf`. Actual filename per HF API (verified May 19 2026 in `references/storage-requirements.md`) is `Qwen3.6-35B-A3B-UD-Q4_K_M.gguf` (Unsloth's dynamic-quant variant, ~5% smaller and the one their docs point to). Updated download command.

2. **LFM2.5-350M**: download was `LiquidAI/LFM2.5-350M-tool-use-GGUF` / `LFM2.5-350M-tool-use-Q8_0.gguf`. Actual repo is `LiquidAI/LFM2.5-350M-GGUF` and filename `LFM2.5-350M-Q8_0.gguf`. The "tool-use" suffix in our paths didn't match HF. Updated both download command and plist references.

### Fixed — Phase A skill paths

ChatGPT caught: `references/phase-a-smoke-test.md` referenced `shared/session-launch` and `shared/output-scrub`, but the actual directories are numerically prefixed: `shared/01-session-launch` and `shared/04-output-scrub`. Updated.

### Generalized — Zotero is no longer mandatory

User feedback: "why do we need zotero again?" Answer: we don't. The LEANN index in Phase 4 needs **a folder of PDFs**, not Zotero specifically.

- Pre-flight Q&A now asks for "Literature corpus path" with defaults: `~/Zotero/storage` → `~/Documents/Papers` → user-provided → skip entirely
- Phase 4 LEANN build auto-detects across common paths, falls back to "skip with note explaining how to build later"
- New env var `$LEANN_SOURCE` (persisted to `~/.research/setup-env`)
- The `leann-search` + `paperqa-*` skills work against an empty index until you have a corpus

### Not addressed (correctly identified false signals)

- Claude: "the 43 skill .md files don't exist yet" — wrong; we have 74 SKILL.md files. Same for hooks (11) and cron tasks (7). Misread the repo.
- ChatGPT: "scripts are flattened into single long lines" — looks like a viewer artifact in their fetch; files in the repo are multi-line and correct.

### Open (carried from prior versions)

- Hermes Desktop arrival (passive — swap when it ships; `~/Desktop/Hermes.command` shortcut bridges the gap)
- Linux + Windows setup walk-throughs (deferred)
- Field preset population for non-peds-endo fields (Phase 4.5 synthesizes at setup time)

---

## [0.9.3] — 2026-05-19 — Cut moat from changelog + Phase A spine smoke test + Hermes strategy explicit

### Removed — defensive "false positives" subsection in v0.9.2

Per user: documenting "reviewer X was wrong about Y" is moat — defensive noise that crowds the changelog. Cut. Going forward: CHANGELOG records what changed, not what reviewers got wrong.

### Added — `references/phase-a-smoke-test.md`

Claude's spine-not-fat-skill reframe written up as a concrete 1-2-hour Phase A:

- **4 minimum-viable-depth tests across the workflow loop**:
  1. **Find**: 5 test PDFs → paperqa-summarize + paperqa-synthesize
  2. **Analyze**: 20-row synthetic CSV → data-dictionary + table-one-build
  3. **Write**: paragraph → draft-write + claim-check
  4. **Audit (live wire)**: PHI-warn fires on deliberately PHI-shaped prompt, audit log accumulates, output-scrub catches a deliberately TC-kimlik-shaped number
- **Setup-light path**: skip 8 of 10 phases. Just Qwen 27B dense (one model, ~16 GB), 8 skills, 5 hooks, Hermes CLI, PaperQA2-only Python deps. ~30 min install.
- **A/B test embedded**: while you have 27B dense loaded, swap to 35B-A3B and compare prose coherence on the same paragraph. Decide our session-launch routing default.
- **What you learn**: whether the architecture actually closes the loop before spending 2 hours on the full install
- **What you skip**: LFM router, Turkish-Gemma, R+Quarto+TeX, LEANN, Little Snitch, launchctl, cron, ceddcozum, style-calibration, cherry-pick skills

### Decided — Hermes strategy: stay on TUI, don't pair

Per user feedback: pairing Hermes with OpenCode or switching to Ollama re-adds moat we cut earlier. Hermes Desktop is "coming soon" per Nous Research (`desktop-pr20059-installers` tag); when it ships, the swap is just replacing `~/Desktop/Hermes.command` with the Desktop launcher. Skills, hooks, audit, system prompts don't change.

`SETUP_PROMPT.md` Phase 7 now has a "Why we stay on Hermes TUI today" note explaining the deliberate thinness of the harness layer:
- `~/.hermes/config.yaml` is ~10 lines
- `Hermes.command` is 3 lines
- Skills + hooks + audit are harness-agnostic
- Swap-cost when Desktop ships: ~5 minutes

### Decisions on 27B vs 35B-A3B for write-mode

**Hold the routing as-is** (27B dense → write/review/long/critique; 35B-A3B MoE → code/agent/quick/vision/stats). A/B test embedded in Phase A; revisit after real use surfaces actual coherence differences on Turkish text. No code change.

---

## [0.9.2] — 2026-05-19 — Round-2 review bug fixes (Cursor + ChatGPT + Claude)

After v0.9.1, a second-round 4-way review (Cursor Composer 2.5 + ChatGPT + Claude incognito + Grok) surfaced three real bugs that survived v0.9.0 + v0.9.1 and one architectural reframe.

### Bugs fixed

1. **MLX plist heredoc still hardcoded `/opt/homebrew/bin/llama-server`** (ChatGPT + Cursor caught) — `SERVER_BIN` variable was set in Phase 1 but plist `<string>` blocks ignored it. Reverted the heredoc to use `cat > ... <<PLIST` (not `<<'PLIST'` — quoted heredoc) so `$SERVER_BIN`, `$USER_HOME`, `$LLAMA_PORT`, `$LFM_PORT` interpolate. Qwen plist now branches on `$INFERENCE_FORMAT` for MLX vs GGUF. LFM service stays GGUF regardless (no MLX variant ships).

2. **`scripts/install-cron.sh` hardcoded `~/local-agent-setup/cron/...`** (Cursor caught) — line 23 ignored the `$LOCAL_AGENT_SETUP` env var introduced in v0.9.1. Now sources `~/.research/setup-env` if available, falls back to auto-detection across common clone paths, fails loud if neither resolves.

3. **`docs/harness_brief.md` drifted from current state** (Cursor caught) — doc still emphasized LM Studio + Goose + OpenCode picks that were superseded in v0.4.0–v0.6.1. Added a **historical-document header** explaining that the doc captures v0.2.0 comparison work and pointing readers to `SETUP_PROMPT.md` + `CHANGELOG.md` for current state. Old content kept as a reference for *why* the picks evolved.

### Architectural reframe — Hermes Desktop doesn't exist (yet)

Claude (incognito) caught this and it's the most important finding from the round-2 review:

- **Hermes Agent v0.14.0 (May 16, 2026)** ships as a **PyPI package** (`pip install hermes-agent`) with an **Ink-based TUI** + CLI. Verified via [release notes](https://github.com/NousResearch/hermes-agent/releases/tag/v2026.5.16) and [docs](https://hermes-agent.nousresearch.com/).
- There is **no standalone "Hermes Agent Desktop" .app bundle** today. A `desktop-pr20059-installers` tag exists in the repo but Desktop is not stable / not released.
- Our v0.2.0–v0.9.1 framing of "Hermes Agent Desktop = daily-use GUI" was wrong.

**Phase 7 rewritten**:
- Install via `pipx install hermes-agent` (not `brew install --cask hermes-agent`)
- Config via `~/.hermes/config.yaml` (not `defaults write com.nousresearch.hermes-agent`)
- Daily-use flow: double-click `~/Desktop/Hermes.command` → opens Terminal.app → Hermes TUI runs → user is in the TUI immediately, never types terminal commands
- Verification Test 7 updated to check `which hermes` + `grep config.yaml` instead of macOS defaults

The TUI is GUI-feeling once you're in it — keyboard-driven, structured panels, chat box. Functionally equivalent for non-technical clinicians. When Desktop ships, swap the `.command` shortcut for the native app launcher.

### Added — Ollama as simpler alternative path

Per Claude's observation: `ollama run qwen3.6:35b-a3b` is dramatically simpler than building llama-server + writing launchctl plists. Phase 1 now documents Ollama as a **valid alternative path** for colleagues who want the smallest possible setup:

```bash
brew install ollama
ollama serve &
ollama pull qwen3.6:35b-a3b
# Endpoint http://localhost:11434/v1 — identical OAI-compat
```

Trade-offs: lose explicit `--mlock` / `--ctx-size` control (set via Ollama's `Modelfile` instead); Ollama abstracts llama.cpp; Phase 0 PRE-CHECK already detects existing Ollama on :11434 and handles the collision.

For Bora's tier: llama-server direct (more control). For colleagues with no preferences: Ollama is fine; downstream skills don't notice.

### Open

- Field preset journals not in built-in case branches still require user to supply 3-5 journals
- `pin-cherry-picks.sh --refresh` workflow needs quarterly schedule documentation
- Linux + Windows setup walk-throughs still deferred

---

## [0.9.1] — 2026-05-19 — Storage table, lessons.md, three deferred items

### Added — verified storage requirements

[`references/storage-requirements.md`](references/storage-requirements.md) — pulled actual sizes from Hugging Face API May 19, 2026:

- **Qwen 3.6 35B-A3B GGUF UD-Q4_K_M: 20.61 GB** (Unsloth's "UD" dynamic quant variant — the right one to pick)
- **Qwen 3.6 35B-A3B MLX 4bit: 19.03 GB**
- **Qwen 3.6 27B dense GGUF Q4_K_M: 15.66 GB**
- **Qwen 3.6 27B dense MLX 4bit: ~15 GB**
- **LFM2.5-350M Q8_0 GGUF: 362 MB** (Q4_K_M: 219 MB)
- **Turkish-Gemma-9b-T1 Q4_K_M GGUF: 5.37 GB**
- **bge-m3 embedding: 2.14 GB**

Plus non-model storage breakdown: Python venv (3-5 GB), wheelhouse (3-5 GB), R packages (~2 GB), BasicTeX (~100 MB), LEANN index (6-12 GB), Quarto extensions, journal templates, audit logs, manuscript snapshots.

**Bora's full install (peds endo, both models, Turkish, full venv, LEANN)**: ~64 GB.
**Recommended free disk**: 80 GB.
**Comfortable**: 100+ GB.
**Minimum viable (one Qwen, English, no extras)**: ~30 GB.

README hardware section updated with these numbers + clear "32 GB RAM minimum / 80 GB disk recommended" framing — chip/OS is platform-specific advice, not a hard gate.

### Added — `lessons.md` (live install-friction changelog)

Top-level file. Pre-populated with the v0.9.0 known issues + slots for real-install entries.

The `SETUP_PROMPT.md` instructs the frontier LLM doing setup to **append to both** `lessons.md` (in the repo, gets PR'd back for shared benefit) AND `~/.research/lessons.md` (local, machine-specific). Format per entry: Machine / Phase / Symptom / Cause / Fix / Repo change.

### Fixed — port 11434 collision with Ollama

`SETUP_PROMPT.md` now has a **PRE-CHECK** block before Phase 0:

```bash
if lsof -i :11434 >/dev/null 2>&1; then
    # Detect Ollama or other; prompt user: (a) stop, (b) remap, (c) accept
fi
LLAMA_PORT=${LLAMA_PORT:-11434}
LFM_PORT=${LFM_PORT:-11436}
```

If user has Ollama running, they pick: stop / remap our llama-server to :11444 / accept existing as backend. Choice persisted to `~/.research/setup-env` for downstream phases.

### Fixed — `$LOCAL_AGENT_SETUP` env var replaces hardcoded clone path

All references in `SETUP_PROMPT.md` to `~/local-agent-setup/<path>` replaced with `$LOCAL_AGENT_SETUP/<path>`. Auto-detection in PRE-CHECK tries `~/local-agent-setup`, `~/Projects/local-agent-setup`, `~/code/local-agent-setup`, `~/Documents/local-agent-setup`, `.` — whichever has `SETUP_PROMPT.md`. User can override by setting `LOCAL_AGENT_SETUP=/path/to/clone` before pasting the prompt.

Initial Context references (`/Users/$USER/local-agent-setup/...`) also updated to `$LOCAL_AGENT_SETUP/...`.

### Fixed — `pin-cherry-picks.sh` now persists resolved SHAs

Previously: resolved `main` to SHA at run-time, fetched, but didn't write SHA back. Next run re-resolved `main` and pulled different commits.

Now: writes resolved pins to `~/.agents/state/cherry-pick-pins.yaml`. On subsequent runs, reads from there (skips re-resolve unless `--refresh` flag passed). Each skill's `SKILL.md` frontmatter also gets `upstream.commit: <sha>` + `upstream.fetched_at: <iso>` for per-skill audit.

```yaml
# ~/.agents/state/cherry-pick-pins.yaml (auto-generated)
addyosmani/agent-skills: 7a3f9e1c0a89b6e8f4d2a1b9c8d7e6f5a4b3c2d1
mattpocock/skills:       b8c4d2a1e9f8a7b6c5d4e3f2a1b9c8d7e6f5a4b3
vercel-labs/agent-skills: c2d1b9c8d7e6f5a4b3c2d1b9c8d7e6f5a4b3c2d1
shadcn-ui/ui:            d3e2c1b0a9f8e7d6c5b4a3928e7d6c5b4a3928e7
```

Refresh via `pin-cherry-picks.sh --refresh`. Quarterly cadence + run eval suite before merging the bump.

### Updated — confirmed Unsloth's UD-Q4_K_M is the right variant

ChatGPT v0.8.0 review note: the model name uses Unsloth's "UD" (Unsloth Dynamic) prefix. Confirmed by HF API — `Qwen3.6-35B-A3B-UD-Q4_K_M.gguf` is the correct download name (20.61 GB), not the plain `Qwen3.6-35B-A3B-Q4_K_M.gguf` I had assumed earlier. Phase 1 download commands + storage doc updated.

---

## [0.9.0] — 2026-05-19 — Hotfix: bugs caught by ChatGPT/Cursor/Grok 3-way review

After the user pasted the v0.8.0 repo URL into ChatGPT, Cursor Composer 2.5, and Grok for an implementation feasibility review, all three reviews converged on the same handful of real bugs. Fixing.

### Bugs fixed

1. **Goose option residual in pre-flight Q&A** — we decided in v0.4.0 that Hermes is the sole harness, but SETUP_PROMPT.md's pre-flight question 8 still asked "Hermes vs Goose." Removed; question now just confirms Hermes.

2. **`en0` hardcoded for Wi-Fi airplane test** — many Macs have Wi-Fi on `en1` or other interfaces. Replaced with auto-detection:
   ```bash
   WIFI_IFACE=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $2; exit}')
   ```
   If no Wi-Fi detected (Ethernet-only, Linux, Windows), the test skips rather than fails.

3. **Skill count claim of 78** — actual count is 74. Updated hand-off and pre-flight messages to `~74` and verification Test 4 threshold to `≥60` (allows for installer to skip optional cherry-picks).

4. **Hermes install command unverified** — original was `brew install --cask hermes-agent`, but ChatGPT noted Homebrew may list it as a formula. Replaced with explicit `brew search hermes-agent` step + comments on both formula and cask paths.

5. **Duplicate model-download blocks in Phase 1** — lines 207-228 were leftover dead code from before the MLX/GGUF auto-detect branch was added. Removed. Added a note that **setup AI must verify current repo names via `huggingface-cli search`** before downloading — names like `mlx-community/Qwen3.6-35B-A3B-4bit-MLX` reflect May 2026 best-guess and drift over time.

6. **PLAN.md reference removed** — README's repo layout diagram listed `PLAN.md` but the file doesn't exist. Replaced reference with `CREDITS.md` (which does exist).

7. **`setup-prompts/macos-apple-silicon.md` reference** — README listed it; it doesn't exist. Replaced the implied "Mac-only" framing with cross-platform notes.

### Added — cross-platform clarity

User feedback: "should be implementable on Windows and Linux too. just tell the 32 GM ram requirement?"

Right. The stack is mostly cross-platform; only the Little Snitch / launchctl / MLX pieces are Mac-specific.

- **`references/cross-platform-notes.md`** — maps every Mac-specific piece to its Linux (systemd, ufw, nmcli) and Windows (Task Scheduler, Defender Firewall, WSL2-preferred) equivalent
- **README hardware framing updated**: "32 GB RAM minimum. Apple Silicon recommended. Linux (CUDA/ROCm) and Windows (WSL2 preferred) supported via GGUF + llama.cpp path."
- Truly Mac-only pieces called out explicitly: Little Snitch, launchctl, MLX, `/opt/homebrew/bin` hardcodes

### Open

- Linux setup walk-through (`setup-prompts/linux-x86.md`) — deferred
- Windows native walk-through (`setup-prompts/windows.md`) — deferred (WSL2 is the realistic path for now)
- Port 11434 collision with Ollama (Cursor flagged) — needs a Phase 0 detection: if Ollama running on :11434, prompt user to stop it or remap one
- `~/local-agent-setup` hardcoded clone path (Cursor flagged) — should use a `$LOCAL_AGENT_SETUP` env var; fixed callers
- `pin-cherry-picks.sh` resolves `main` → SHA but doesn't persist to the script for next run

These are real but smaller. Will pick up in v0.9.1 if needed.

---

## [0.8.0] — 2026-05-18 — Phase renumber + real ceddcozum integration (tools, not data)

### Changed — phases renumbered (no decimals)

Per Bora: "do not do decimal phases. rename them if needed. no moat. no backwards compat."

Old → New:

| Old | New | Phase |
|---|---|---|
| 0 | 0 | Pre-flight Infrastructure |
| 1 | 1 | Inference Layer |
| 2 | 2 | Skills + Hooks + System Prompts |
| 3 | 3 | Python + R + Quarto + TeX |
| 4 + 4.5 (merged) | 4 | Caches + Zotero + Journal Guidelines + Field Preset |
| — | **5** | **ceddcozum Tool Integration** (NEW) |
| 5 | 6 | Style Calibration |
| 6 | 7 | Daily-Use GUI |
| 7 | 8 | Air-gap Configuration |
| 8 | 9 | Cron / Scheduled Tasks |
| 9 | 10 | Verification Suite |

Total: 11 phases (0-10). All references in README, AGENTS.md, and SETUP_PROMPT.md updated.

### Fixed — ceddcozum integration: it's a CLI for 33 calculators, not a data export tool

Looked at the actual published package (`ceddcozum@0.2.2`, `npm install -g ceddcozum`). The `--export-references` command I'd assumed in v0.7.0 doesn't exist and **shouldn't exist** — the package is a CLI dispatch for 33 pediatric clinical calculators, with Neyzi LMS data baked INSIDE the calculator functions. The right integration is exposing the 33 calculators as **agent-callable tools**, not extracting their data.

The package already designed for LLM-agent use:
- `ceddcozum --schemas` dumps all 33 tool schemas in OpenAI function-calling format
- `ceddcozum <tool> --args '{"...":"..."}'` invokes with JSON args
- `ceddcozum <tool> --format json` returns parsed output

New Phase 5 implementation:
```bash
npm install -g ceddcozum
mkdir -p ~/.agents/tools
ceddcozum --schemas > ~/.agents/tools/ceddcozum-schemas.json
cp -r ~/local-agent-setup/skills/coding/bora/ceddcozum-tools ~/.agents/skills/coding/bora/
```

New skill `skills/coding/bora/ceddcozum-tools/SKILL.md` is a schema-driven dispatcher that:
- Looks up tool from `ceddcozum-schemas.json`
- Validates args against the tool's JSON Schema (fail-loud per Karpathy rule #12)
- Invokes `ceddcozum <tool> --args '...' --format json`
- Returns parsed result

**Result**: the local Qwen gets 33 live calculators in its tool palette — auxology, IGF SDS, BMD SDS+vBMD, HbA1c↔glucose conversion, HOMA-IR/QUICKI, steroid equivalents, blood pressure percentiles, thyroid volume SDS, etc. All local, no network.

Removed the broken Phase 4 `npx ceddcozum --export-references` block; replaced with a comment pointing at Phase 5.

### Decisions

- No backwards-compatibility shims for the renumbering (nothing is released yet, no users to break)
- The schema-driven dispatch in ceddcozum-tools auto-picks up new calculators when Bora ships `ceddcozum@0.3+`
- Lazy-load of tools: session-launch decides which subset of 33 schemas to inject (default: Growth + Diabetes most common)

### Open

- Hermes Agent + `ceddcozum-tools` skill: needs actual integration test (`ceddcozum auxology` from inside a Hermes session)
- Documentation pointing AGENTS.md / browser-AI flow at the 33-tool palette so they know to suggest these tools instead of asking the model to compute SDS manually

---

## [0.7.0] — 2026-05-18 — Browser-AI-first setup flow + field-preset generation at setup time + npx ceddcozum + direnv mandatory

### Changed — setup audience expanded to browser AIs

Per Bora: most users will paste the repo URL into ChatGPT or Claude.ai (browser), NOT install a CLI coding agent. README rewritten to make browser path the **default**:

- **🟢 Browser path**: paste repo URL into ChatGPT/Claude.ai, the AI reads the repo and walks you through Phases 0-9 command-by-command, you paste each command into Terminal yourself. No CLI install needed.
- **🔵 Power-user path**: Claude Code / Codex / Gemini CLI users get the same setup ~30% faster because the agent runs commands directly.

`AGENTS.md` rewritten to handle both scenarios — browser AI walks through one command at a time, CLI agent runs phases directly. Both end at the same hand-off message.

### Changed — direnv promoted to MANDATORY

Per Bora: "temporary online setup is a real and gonna-be-used thing anyway." Moving direnv from RECOMMENDED to MANDATORY means it gets installed during the one-time setup, not as friction later. PubMed/Crossref/OpenAlex keys go in per-folder `.envrc`, plain FileVault encryption is enough — no 1Password/doppler.

`preflight-install-order.md` and `SETUP_PROMPT.md` Phase 0 updated.

### Changed — field presets generated during setup, not hardcoded

Per Bora: "Full population of oncology/IM/surgery presets and US-specific peds-endo variant should be on the initial online setup phase imho. not hardcoded."

- **Moved** all 4 field presets (peds-endo, oncology, IM, surgery) from `system-prompts/field-presets/` to `references/field-preset-examples/`
- **New** `system-prompts/field-presets/README.md` explains the model: examples in `references/` are structural templates; setup generates the actual loaded preset per user
- **New Phase 4.5** in `SETUP_PROMPT.md`: synthesize field preset from template + current author guidelines fetched via `online-lookup` for the user's target journals. Cached to `~/Research/cache/journal-guidelines/`.
- For the user's exact field/locale combination (e.g., "pediatric endocrinology in US"), the setup generates a fresh customized preset. No stale stubs.

### Added — `npx ceddcozum` integration in Phase 4

Per Bora: "lets include npx ceddcozum on initial setup?" Adding to the references-cache step:

```bash
# In Phase 4 — caches
if [ "$FIELD_SLUG" = "pediatric-endocrinology" ]; then
    npx -y ceddcozum@latest --export-references --output ~/Research/cache/references/
fi
```

If `--export-references` isn't yet a command in his NPM package, the SETUP_PROMPT logs a TODO for him + falls back to cloning the package source.

Generalizable pattern: if a user has their own data tool (CSV exports, reference packages, etc.), Phase 4 invites them to invoke it during setup to seed the local cache.

### Open

- `npx ceddcozum --export-references` command itself doesn't exist yet — TODO for Bora to add to the ceddcozum package
- Browser-AI Phase 4.5 generation needs the setup AI to actually fetch live journal sites (might fail for paywalled sites)
- README quick-start tested only in a copy-paste sense; the actual "paste repo URL into ChatGPT" workflow needs a real test
- Field preset generation in Phase 4.5 may be slow with browser AIs that can't fetch multiple URLs in parallel

---

## [0.6.1] — 2026-05-18 — Preflight refinement based on Bora's "what is doppler/direnv?" pass

### Changed — Phase 0 preflight further simplified

- **direnv**: moved from OPTIONAL → RECOMMENDED. Reason: PubMed/Crossref/OpenAlex API keys for momentary-online lookups need a clean per-folder loader. Plain `.envrc` on a FileVault disk is fine for low-cosmic secrets like open API keys. ~30 LOC shell setup.
- **1Password CLI / doppler / vault**: moved from OPTIONAL → DROPPED. Reason: overkill for our threat model. The secrets we have (open APIs) don't justify a separate password manager.
- **mitmproxy**: moved from RECOMMENDED → **FALLBACK** tier. Reason: Raindrop Workshop covers semantic HTTP audit better. Don't run both. Note kept in preflight doc: install mitmproxy ONLY if Raindrop is ever dropped from the stack.
- **litellm**: confirmed DROPPED (was already).
- **inspect-ai**: confirmed DEFERRED (install when user writes first eval).

`SETUP_PROMPT.md` Phase 0 rewritten to match. Includes a working `.envrc.example` for the project folder pattern.

### Changed — Phase 1 inference format auto-detected, no prompt

- Per Bora's call: **auto-pick by device, no user prompt**
- M-series Mac → `mlx-lm.server` + MLX models from `mlx-community/...`
- Non-Apple-Silicon → `llama.cpp` + GGUF
- Both expose OpenAI-compatible HTTP — downstream skills don't care which
- LFM2.5 + Turkish-Gemma stay GGUF regardless (no MLX variants as of May 2026)
- Server-binary path + model args + flags branch on `INFERENCE_FORMAT` env var

### Why this is "0.6.1" not "0.7.0"

These are refinements to v0.6 decisions, not new features. The user's questions exposed places where I'd over-engineered (1Password) or under-decided (MLX/GGUF as user prompt vs auto-pick).

---

## [0.6.0] — 2026-05-18 — Preflight rationalized, MLX/GGUF choice, clean-session online lookup, setup scripts, Little Snitch profile, 3 stub field presets

### Rationalized — preflight tools

User asked: "why are these needed?" Honest audit dropped/deferred several tools that don't fit air-gap use:

- `references/preflight-install-order.md` now tiered:
  - **MANDATORY**: uv, pipx, llama.cpp, Raindrop Workshop
  - **RECOMMENDED**: mitmproxy (HTTP-level audit; Raindrop covers semantic spans — pick one)
  - **DEFERRED**: inspect-ai (install when user writes evals, not day 1)
  - **OPTIONAL**: direnv + 1Password CLI/doppler (only if user does cross-project secret work outside air-gap)
  - **DROPPED**: litellm (redundant — no providers to route, no budget caps for local model, audit covered by hooks + Raindrop)
- `SETUP_PROMPT.md` Phase 0 rewritten to match the new tiering; env vars control opt-ins

### Added — MLX vs GGUF device detection

`SETUP_PROMPT.md` Phase 1 now detects M-series chip and asks:
- **GGUF (default)**: universal, ~50 tok/s for Qwen 3.6 35B-A3B Q4_K_M on M3 Max, portable to Linux/Windows colleagues
- **MLX (opt-in)**: Apple Silicon only, ~80 tok/s (~60% faster), but can't share install instructions with non-Mac colleagues
- Per-user choice; default keeps colleagues portable

### Added — clean-session online-lookup pattern

User flagged: "lifting air-gap while patient data is in context is a leak risk; do journal lookups in a clean session."

- New skill: `skills/shared/07-online-lookup/SKILL.md`
- Two-phase pattern:
  - **Phase A** (current session with PHI): emit Material Passport, halt, tell user to open fresh Hermes window
  - **Phase B** (new clean session): defensive check (verify no PHI in context), invoke `request-momentary-internet`, fetch, cache to `~/Research/cache/{slug}.yaml`, tell user to resume original session via passport
- Schemas defined for: journal-guidelines, reporting-checklist, package-version, public-dataset
- Cache refresh policy: journal guidelines monthly, reporting checklists quarterly, package versions on-demand

### Changed — peds-endo preset: removed hardcoded length limits

Per user feedback, length limits in `pediatric-endocrinology.md` were rotting bait. Replaced with:
- **Cache-consult pattern**: skills read `~/Research/cache/journal-guidelines/{slug}.yaml`; if missing or >30 days old, invoke `online-lookup` skill
- Rough current ranges kept as fallback guidance, explicitly labeled stale-risk
- `seven-mode-failure-check` mode 5 (citation drift) now applies to using hardcoded limits without cache refresh

### Added — 4 setup scripts

- `scripts/install-cron.sh` — installs a cron task as launchctl plist (daily-03 or weekly-sun-04); randomizes minute within window to spread load
- `scripts/pin-cherry-picks.sh` — fetches upstream cherry-picks (addyosmani, mattpocock, vercel-labs, shadcn-ui) at resolved-from-main SHAs, writes pinned-commit to frontmatter
- `scripts/download-guidelines.sh` — best-effort scaffold for MAGICapp/ISPAD/ESPE/ÇEDD/AAP/ATA caches (most societies don't have stable open APIs; falls back to manual fetch instructions)
- `scripts/download-references.sh` — WHO + CDC growth chart fetchers (open URLs); Neyzi + IAP pointer files (manual fetch — not openly available)

### Added — Little Snitch profile

`setup-prompts/little-snitch-research-mode.lsrules` — strict localhost-only egress:
- Allow 127.0.0.0/8 + ::1/128
- Explicit deny for major leak vectors (.anthropic.com, .openai.com, .googleapis.com, .azure.com, .icloud.com, .apple.com, .zotero.org, .dropbox.com, .huggingface.co, .pythonhosted.org, .github.com)
- Default-deny 0.0.0.0/0 + ::/0 catch-all
- Import via Little Snitch Configuration → File → Import Rules

### Added — 3 stub field presets

For users not in pediatric endocrinology:
- `system-prompts/field-presets/oncology.md` (skeleton: AMA citation, RECIST/iRECIST, CTCAE v5.0, KM+Cox, ~5-7 hedges/1000w)
- `system-prompts/field-presets/internal-medicine.md` (skeleton: NEJM structured abstract, propensity scores, ~1.5:1 active:passive)
- `system-prompts/field-presets/surgery.md` (skeleton: Annals of Surgery style, Clavien-Dindo, present-tense operative descriptions, ~3-5 hedges/1000w)

Each is a stub awaiting first-use population. PRs welcome.

### Open

- Bridge smoke test: still pending real installation
- Field presets above are stubs; full population per real submission needs
- US-specific peds-endo variant (vs European default)
- ÇEDD/ISPAD/ESPE programmatic guideline fetchers (most are manual today)
- Neyzi 2015 LMS transcription (Bora's existing ceddcozum auxology tool has the data — could export to CSV)

---

## [0.5.0] — 2026-05-18 — Setup prompt + lockfiles + field preset + Hermes-Raindrop bridge

### Added — the pasteable SETUP_PROMPT

`SETUP_PROMPT.md` expanded from outline to a real pasteable prompt (~16 KB). 9 phases:
- Phase 0: preflight (direnv, mitmproxy, uv, pipx, inspect-ai, litellm, Raindrop Workshop)
- Phase 1: inference (llama.cpp Metal, 3 GGUFs, 2 launchctl services)
- Phase 2: skills + hooks + system prompts
- Phase 3: Python venv (50+ packages) + R (~40 packages) + Quarto + TeX
- Phase 4: caches + Zotero index
- Phase 5: style-calibration one-shot (calibrate OR generic)
- Phase 6: Hermes Agent Desktop install + config
- Phase 7: air-gap configuration (Little Snitch + iCloud + Time Machine)
- Phase 8: 7 cron tasks via launchctl
- Phase 9: 10-test verification suite

Plus full hand-off message + notes for the frontier LLM doing the install.

### Added — lockfiles

- `setup-prompts/medical-research-requirements.txt` — Python: ~50 packages curated for the air-gapped stack (pandas, numpy, scipy, statsmodels, pingouin, lifelines, pymc, paper-qa, leann, presidio, docling, ollama, pydantic-ai, opentelemetry exporters, inspect-ai)
- `setup-prompts/medical-research-renv.R` — R: ~40 packages across tidy/stats/meta/power/viz/Bayes/LLM-bridge/reporting, installs via renv, generates renv.lock

### Added — field preset

- `system-prompts/field-presets/pediatric-endocrinology.md` — generic voice baseline loaded when first-paper users run `style-calibration --mode generic --field "pediatric endocrinology"`. Covers:
  - Citation style (Vancouver, JCEM/JPEM/Diabetes Care conventions)
  - Section structure (IMRaD per STROBE; case-report variant; review variant)
  - Length limits per journal (JCEM, JPEM, Diabetes Care, Frontiers, Lancet D&E)
  - Tense+voice conventions (1.3:1 active:passive default)
  - Hedging vocabulary (strong/moderate/weak claim verbs; 4-6 hedges per 1000 words)
  - Standard abbreviations (T1D, HbA1c, GHD, CAH, DSD, MODY, etc.)
  - AI-tells to avoid ("delve", "underscore", "robust", "moreover")
  - Statistics reporting (CI primary, p secondary; missing data; subgroups pre-specified)
  - Pediatric-specific conventions (Tanner staging, bone age, BMI z-score, DXA volumetric correction)
  - Ethics statement template (KVKK + Helsinki + assent ≥7yo)

### Added — Hermes-Raindrop bridge

- `references/hermes-raindrop-bridge.md` — verdict + bridge plan.
  - **Native compat: NO** (Hermes uses openai==2.24.0 directly; Raindrop's auto-instrumentation hooks LLM client libs but misses Hermes's turn/tool/subagent structure)
  - **Recommended bridge** (~30 min): `briancaffey/hermes-otel` plugin → Workshop's OTLP `/v1/traces` endpoint at `http://localhost:5899`
  - Fallback (~50 LOC Python plugin) if OTLP rejects unauthenticated
  - Worst-case (~1 day, NOT recommended): localhost HTTP MITM at :11434
  - Two unverified assumptions called out (Workshop OTLP receiver accepting generic OTel; hermes-otel config syntax)

### Decisions

- **Voice baseline by field**: peds-endo first; oncology / IM / surgery presets stub-only for now (extend on demand)
- **Bridge before native**: don't wait for upstream support; the hermes-otel path works today
- **Phase 5 timing**: style-calibration is in-setup, not deferred to first session — gets a baseline written before user starts using Hermes

### Open

- Bridge test: run after Phase 6 (Hermes install); the verification suite Test 11 (manuscript-pipeline replay) should confirm
- Oncology / IM / surgery field presets: not yet written
- Generic field preset for non-Turkish locales (US peds endo style differs subtly from European)
- `scripts/install-cron.sh`, `scripts/pin-cherry-picks.sh`, `scripts/download-guidelines.sh`, `scripts/download-references.sh` — referenced in SETUP_PROMPT but not yet written (frontier LLM will need to author or fall back to inline bash during setup)

---

## [0.4.0] — 2026-05-18 — First-paper users + orchestrator

### Added

- **`research/manuscript/clinical-data-to-manuscript`** — 15-phase orchestrator skill that composes ~20 of our skills from raw dataset → submission-ready manuscript. Adapted from Bora's existing `manuscript-from-clinical-data`, optimized for air-gapped Qwen 3.6 with Material Passport at every major breakpoint. Two modes (`guided` for first-paper users, `express` for experienced). Resumable from any passport.
- **`references/first-paper-onboarding.md`** — explainer for users writing their first manuscript. Expected timeline (12-25 hours across 8 sessions). What to skip until later. What NOT to do.

### Changed

- **`style-calibration`** rewritten to be deferrable. Three modes:
  - `calibrate` (default for users with ≥3 published papers)
  - `generic` (loads field-specific baseline — pediatric endo / oncology / IM / surgery — for first-paper users)
  - `defer` (skip entirely; reminder every 10 sessions)
  - Frontmatter: `optional: true, deferrable: true`
- **`devils-advocate`** rewritten to be deferrable. Three modes:
  - `calibrated` (default for users with ≥5 accepted papers)
  - `uncalibrated` (first-paper users — generic Cochrane/STROBE/CONSORT reviewer patterns; output stamped with explicit caveat)
  - `defer` (skip entirely; reminder every 20 sessions)
  - Frontmatter: `optional: true, deferrable: true`

### Why these changes

User feedback: "what if the user is gonna write their first paper in life?" Both skills assume a corpus of the user's own published work. We needed graceful degradation paths so first-paper users can still benefit from the writing/critique infrastructure.

### Decisions

- **Generic-mode field presets**: pediatric endocrinology (ESPE Yearbook + JCEM), oncology (Lancet Oncology), internal medicine (NEJM), surgery (Annals of Surgery). Easily extensible.
- **Devil's Advocate uncalibrated mode** uses Cochrane methodological critiques + STROBE/CONSORT supplementary materials + EQUATOR Network reporting guidelines as its generic-reviewer corpus.
- **Orchestrator delegates, never duplicates**: every phase calls a single-purpose skill we already have. Material Passport at 6 major breakpoints means any phase failure is recoverable.

### Open

- Generic-mode field presets are placeholders; real journal-specific style sheets need population
- `clinical-data-to-manuscript` has 15 phases; the Phase-N implementations are wrappers around existing skills, no new code needed, but the orchestrator state machine itself needs implementation
- First-paper-onboarding reminders fire from `session-start-airgap.sh` — needs the hook update

---

## [0.3.0] — 2026-05-18 — Bulk skill+hook+cron implementation

### Added — meta/reference files

- `CREDITS.md` — comprehensive credit list for every idea, library, tweet author, and pattern used
- `references/compliance-primer.md` — KVKK Art. 6/12/35, GDPR Art. 9/32/35/89, HIPAA explained
- `references/devils-advocate-explained.md` — plain-language explainer of the two-phase pattern
- `references/data-viz-upgrade-PR.md` — PR-style spec for upgrading Bora's existing data-viz skill (OKLCH + Wong + Emil + nature-figure + tabular-nums + figure-validate)

### Added — skills

- **6 shared/ skills full SKILL.md**: session-launch, material-passport-emit, material-passport-resume, output-scrub, network-mode-toggle, request-momentary-internet
- **40 research/ skills** (in 6 sub-pillars):
  - literature (7): leann-search, paperqa-summarize, paperqa-synthesize, paperqa-verify-citation, storm-systematic-review, guideline-cache-query, grill-with-docs
  - statistics (7): data-dictionary, statistical-test-picker, power-analysis, analysis-plan, analysis-run, result-interpret, table-one-build
  - manuscript (10): outline-build, draft-write, claim-check, anti-leakage, writing-quality-check, style-calibration (now generic per-user), score-trajectory, prisma-trAIce-disclosure, response-to-reviewer, abstract-format
  - visualization (10): chart-spec, nature-figure, forest-plot, km-curve, patient-flow-sankey, color-palette, figure-validate + 3 vercel-labs cherry-picks (react-best-practices, react-view-transitions, web-design-guidelines)
  - medical-domain (4): pediatric-references, dosing-converter, guideline-snapshot, tr-medical-translate
  - peer-review (5): rob-assessor, grade-evidence, devils-advocate, seven-mode-failure-check, peer-review-checklist
- **21 coding/ skills**:
  - karpathy/ (3 full): fail-loud, surgical-changes, read-before-write
  - google/ (11 stubs + BORA-NOTES): from addyosmani/agent-skills
  - mattpocock/ (4 stubs + BORA-NOTES)
  - vercel/ (1 stub + BORA-NOTES): composition-patterns (the 3 visualization ones moved to research/visualization)
  - shadcn/ (1 stub + BORA-NOTES)
  - bora/ (2 full): zero-tech-debt, clawpatch-wrapper

### Added — hooks (10 shell scripts)

- `session-start-airgap.sh` — verify air-gap, load voice profile, show resumable passport
- `session-end-passport.sh` — emit Material Passport, write meta.yaml
- `precompact-passport-emit.sh` — force passport before compaction
- `user-prompt-phi-warn.sh` — regex scan prompts for PHI; warn
- `pre-tool-network-deny.sh` — HARD BLOCK network tools in air-gap
- `post-tool-audit-jsonl.sh` — append every tool call to today's ledger
- `stop-output-scrub.sh` — auto-scrub last assistant turn before copy
- `stop-score-trajectory.sh` — if manuscript edited, snapshot for regression detection
- `skill-suggest-airgap.sh` — keyword routing filtered to airgap-ok skills
- `checkpoint-reminder.sh` — soft passport reminder every 20 tool calls
- `notchi-hook.sh` — air-gap-safe desktop notifier (kept Bora's existing)

### Added — cron tasks (7 SKILL.md files)

**Daily (launchctl 03:00-03:45):**
- airgap-nightly-handoff
- llama-server-health
- audit-rotate (with SHA-256 hash chain for KVKK tamper-evidence)
- leann-index-refresh

**Weekly (Sunday 04:00-05:00):**
- manuscript-snapshot (cap 12 per manuscript)
- passport-cleanup (delete >30d, keep hash index)
- skill-usage-report (which skills used/idle/prune candidates)

### Refinements

- **TOON dropped** (Bora flagged "proved bad in past") — JSON Schema for all skill I/O
- **`style-calibration` made generic** — user provides their own 3-5 papers at setup, not Bora-mandated
- **clawpatch added** as `coding/bora/clawpatch-wrapper`
- **Hermes self-evolving skills: embrace day 1** (per Bora's call)
- **Credit-in-place doctrine** — every SKILL.md has `## Credit` section; CREDITS.md aggregates all attributions

### Open

- BORA-NOTES.md per cherry-picked skill is a stub waiting for first-use population
- Setup prompt still outline; expand to pasteable next iteration
- Hermes-Raindrop compat: not yet verified; will test post-install
- `medical-research-venv.lock` + `renv.lock` files not yet generated
- The pasteable SETUP_PROMPT version

---

## [0.2.0] — 2026-05-18 — Skills restructure + Raindrop Workshop

### Restructured

- **Skills now split into three bundles**: `shared/`, `research/`, `coding/`. Each independently installable. Each has its own README explaining scope.
- `skills/meta/` → renamed and split: cross-cutting infrastructure went to `skills/shared/`; the coding-specific zero-tech-debt went to `skills/coding/bora/zero-tech-debt/`.
- Frontmatter convention updated: `domain: shared | research | coding` replaces `pillar:`. `pillar:` becomes a *sub-pillar* within research (literature/statistics/manuscript/visualization/medical-domain/peer-review).
- Added `skills/README.md` explaining the three-bundle architecture + how runtime filtering by `domain:` works
- Added per-bundle READMEs in `skills/shared/`, `skills/research/`, `skills/coding/`

### Added

- **Raindrop Workshop** (raindrop-ai/workshop) added to preflight install order as **Step 4b** alongside mitmproxy. Local-first agent debugger from Ben Hylak. MIT, 641⭐. Resolves the TODO from v0.1.0.
- Self-healing eval loop notes — Raindrop writes evals, runs agent, fixes failures, re-runs.
- Relationship to mitmproxy: HTTP-level wiretap vs agent-level semantic tracer. Both kept; complementary.
- Relationship to inspect-ai: offline batched evals vs in-the-loop tracing. Both kept; complementary.

### Decisions

- Three-bundle split for "ease of use and maintenance" per Bora's request
- Coding bundle is **optional** — clinicians who don't vibe-code install only `shared/` + `research/`
- Cherry-pick mapping refined: 3 of 7 vercel-labs skills moved from `coding/vercel/` to `research/visualization/` (react-best-practices stays in coding because it's about React itself; react-view-transitions, web-design-guidelines, composition-patterns → no wait, composition-patterns stays coding too. Only react-view-transitions and web-design-guidelines moved.) Actually corrected: see `skills/coding/README.md` for final mapping.

### Repository housekeeping

- Updated README repo-layout diagram to show three-bundle structure
- Pinned-commit policy added to coding/README — quarterly refresh cadence, eval-suite gate on bumps

---

## [0.1.0] — 2026-05-18 — Initial scaffolding

### Added

- `README.md` — repo overview
- `AGENTS.md` — entry point for AI agents
- `SETUP_PROMPT.md` — outline for the frontier-LLM setup phase (WIP, expand before use)
- `LICENSE` — Apache-2.0
- `docs/v3_changes.md` — consolidated changes after harness research, hook intel, cron classification
- `docs/local_llm_plan.md` — full architecture + compliance plan
- `docs/harness_brief.md` — May 2026 harness verdict
- `docs/skillset_v1.md` — base 36-skill design across 7 pillars
- `docs/skillset_v2_additions.md` — ARS-derived additions (Material Passport, anti-leakage, etc.)
- `docs/top_100_intel.md` — top-100 intel from WhatsApp self-chat analysis (2591 URLs)
- `system-prompts/karpathy-12-rules.md` — the 12-rule system prompt base
- `references/preflight-install-order.md` — direnv + litellm + uv + mitmproxy + inspect-ai
- `references/colleague-onboarding-tutorial.md` — air-gap-adapted from 5-part academic Claude Code tutorial
- `references/skill-libraries-survey.md` — cherry-pick analysis of addyosmani/mattpocock/vercel/shadcn
- `skills/meta/zero-tech-debt/SKILL.md` — first skill, the "rework from end-state" pattern

### Decisions made this version

- **Harness**: Hermes Agent Desktop (single pick — replaces OpenCode/Goose options for now)
- **Inference**: `llama-server` direct (NO Ollama, NO LM Studio middleman)
- **Models**: Qwen 3.6 27B dense + 35B-A3B MoE, **1 at a time** (per Bora's preference; not parallel even on 128 GB)
- **Sidecar**: LFM2.5-350M always-warm router on port 11436
- **Skill format**: SKILL.md (Anthropic open standard, 32-tool ecosystem)
- **Skill location**: `~/.agents/skills/` (portable, auto-discovered)
- **Internal I/O**: JSON Schema (TOON sacked — proved bad in past)
- **Setup runner**: User's frontier LLM (Claude Code / Codex / Gemini CLI), then uninstalled
- **Compliance**: Little Snitch "Research Mode" + Material Passport audit trail

### Status — what's still TODO

- [ ] 43 core skills as actual SKILL.md files (1 of 43 done: zero-tech-debt)
- [ ] 10 hook scripts (0 of 10)
- [ ] 7 cron task SKILL.md files (0 of 7)
- [ ] addyosmani/mattpocock/vercel cherry-picks lifted with BORA-NOTES.md per skill (0 of 19)
- [ ] `medical-research-venv.lock` (Python requirements)
- [ ] `renv.lock` (R requirements)
- [ ] Cached guideline corpus build script
- [ ] Setup prompt — final pasteable version (currently outline)
- [ ] Verification suite scripts (Test 1-10)
- [ ] Bora's M3 Max-specific notes (128 GB tier)

### Open questions

- Style Calibration corpus — which 3-5 papers?
- Devil's Advocate corpus — which 5 accepted papers?
- Hermes self-evolving skills — embrace or disable initially?
- benhylak's agent-trace tool from May 2026 tweet — need to identify the exact repo
- thisguyknowsai "Research Accelerator" 13 prompts thread — worth scanning for any grad-student tactics
