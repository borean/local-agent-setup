# lessons.md

**Live changelog of friction encountered during real-install attempts.** Every entry teaches the next install.

Format per entry:
```
## YYYY-MM-DD — short description
**Machine**: Apple Silicon M3 Max 128 GB / Linux RTX 4090 / Windows WSL2 / etc.
**Phase**: which SETUP_PROMPT phase
**Symptom**: what broke
**Cause**: root cause (if known)
**Fix**: exactly what worked
**Repo change**: which file/line in local-agent-setup should be updated (if applicable)
```

The setup AI is instructed in `SETUP_PROMPT.md` to **append to this file** whenever something doesn't go to plan. It's the bridge between "spec" and "actually-bootable."

---

## Pre-population — known issues from spec review (not yet from real install)

### 2026-05-18 — Hermes install method unverified
**Phase**: 7 (Daily-Use GUI)
**Symptom**: `brew install --cask hermes-agent` may not exist — Homebrew may list as formula.
**Cause**: Hermes Agent could be either; depends on whether Nous Research publishes as `.app` (cask) or CLI binary (formula).
**Fix**: Phase 7 now runs `brew search hermes-agent` first, then picks the right install form.
**Repo change**: SETUP_PROMPT.md Phase 7 (v0.9.0 fix)

### 2026-05-18 — Model repo names may have drifted
**Phase**: 1 (Inference Layer)
**Symptom**: `huggingface-cli download mlx-community/Qwen3.6-35B-A3B-4bit-MLX` may 404 — the actual repo may be `mlx-community/Qwen3.6-35B-A3B-4bit` (no `-MLX` suffix).
**Cause**: HuggingFace repo names not consistently versioned with the format suffix.
**Fix**: Phase 1 now instructs the setup AI to verify each repo via `huggingface-cli search` before download. Verified May 19 2026 sizes in `references/storage-requirements.md`.
**Repo change**: SETUP_PROMPT.md Phase 1 (v0.9.0 fix), storage-requirements.md (new in v0.9.1)

### 2026-05-18 — Wi-Fi interface `en0` is not universal
**Phase**: 10 Test 3 (offline test)
**Symptom**: `networksetup -setairportpower en0 off` fails on Macs where Wi-Fi is `en1` or other.
**Fix**: Auto-detect via `networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $2}'`. Skip test entirely if no Wi-Fi (Ethernet-only / Linux / Windows).
**Repo change**: SETUP_PROMPT.md Phase 10 Test 3 (v0.9.0 fix)

### 2026-05-18 — Port 11434 collides with Ollama
**Phase**: 1 (Inference Layer)
**Symptom**: If user has Ollama already installed and running, both will fight for port 11434.
**Fix**: Phase 0 now detects existing `:11434` listener and prompts user to: (a) stop Ollama, (b) remap our llama-server to `:11444`, or (c) accept Ollama as the inference backend.
**Repo change**: SETUP_PROMPT.md Phase 0 (v0.9.1 fix)

### 2026-05-18 — `~/local-agent-setup` path hardcoded
**Phase**: All
**Symptom**: User who clones to a different path (e.g. `~/code/local-agent-setup`) hits "file not found."
**Fix**: All references use `$LOCAL_AGENT_SETUP` env var (defaults to `~/local-agent-setup` if unset). Setup AI sets this once at Phase 0.
**Repo change**: SETUP_PROMPT.md (v0.9.1 fix)

### 2026-05-18 — `pin-cherry-picks.sh` doesn't persist resolved SHAs
**Phase**: 2
**Symptom**: Script resolves `main` to a SHA at run-time but doesn't write the SHA back to itself. Next run re-resolves `main` and may pull different commits.
**Fix**: Resolved SHA now written to `~/.agents/state/cherry-pick-pins.yaml` and consulted on subsequent runs.
**Repo change**: scripts/pin-cherry-picks.sh (v0.9.1 fix)

---

## Real-install entries (populated during installs)

*(Empty. First real install will populate this section.)*

---

## How to add an entry

When you (or your setup AI) hit something unexpected:

1. Open this file
2. Add an entry under "Real-install entries" with today's date
3. Include all six fields (Machine, Phase, Symptom, Cause, Fix, Repo change)
4. If the fix is repo-side, file a PR / push the fix yourself
5. If you're not sure of the fix, leave it with `Fix: TBD — investigating` and revisit

Don't censor. Don't summarize. Don't generalize. Each entry helps the NEXT installer skip your pain.

## How the setup AI uses this file

`SETUP_PROMPT.md` instructs the frontier LLM doing setup to:

> Write to `~/.research/lessons.md` AND `lessons.md` (in the repo) as you go. Every workaround. Every package that wasn't where you expected. Every brew formula that conflicted. Future setups across the user's team will reference this.

Two copies on purpose:
- `~/.research/lessons.md` is local, per-machine, includes hardware-specific quirks
- `lessons.md` (in the repo) is shared, gets PR'd back to GitHub for everyone

Per-machine entries that are NOT generally applicable stay in `~/.research/lessons.md`. Entries that would help anyone get committed to the repo file.

---

*Modeled on the lessons.md pattern from Karpathy's pre-flight install order (`references/preflight-install-order.md`). The point is institutional memory across many installs, not just yours.*
