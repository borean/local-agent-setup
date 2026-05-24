# Cross-platform notes

The stack is **mostly cross-platform**. Apple Silicon Mac is the smoothest path (unified memory + MLX = ~60% faster inference), but Linux and Windows work via GGUF + llama.cpp.

This doc maps the Mac-specific pieces to their Linux / Windows equivalents.

---

## What's universal (no changes needed)

- **llama.cpp + GGUF models** — same binary on Mac (Metal), Linux (CUDA/ROCm/CPU), Windows (CUDA/CPU)
- **Qwen 3.6 27B + 35B-A3B** — both work in GGUF on every platform
- **LFM2.5-350M router** — GGUF, all platforms
- **Hermes Agent** — has Linux build; Windows works via WSL2 or native (less-tested)
- **Raindrop Workshop** — Bun-based, cross-platform
- **Python + uv + pipx** — all cross-platform
- **R + Quarto + Pandoc + TeX** — all cross-platform
- **direnv** — Mac + Linux; on Windows use [direnv-windows](https://github.com/direnv/direnv) port or use WSL2

---

## What's Mac-specific — and the equivalents

### 1. `launchctl` plists (Phase 1, Phase 9)

| Platform | Equivalent | Notes |
|---|---|---|
| **Mac** | `launchctl` + `~/Library/LaunchAgents/*.plist` | Current implementation |
| **Linux** | `systemd --user` + `~/.config/systemd/user/*.service` + timers for cron | Add a `systemd` flavor under `scripts/install-cron-linux.sh` (TODO) |
| **Windows** | Task Scheduler + PowerShell scripts | Add a `scripts/install-cron-windows.ps1` (TODO) |

For the **llama-server background service**, the equivalent on Linux:

```ini
# ~/.config/systemd/user/llama-server.service
[Unit]
Description=llama-server (Qwen 3.6)
After=network.target

[Service]
ExecStart=/usr/local/bin/llama-server --model %h/.research/models/Qwen3.6-35B-A3B-Q4_K_M.gguf --port 11434 --ctx-size 32768 --n-gpu-layers 999 --host 127.0.0.1 --api-key local
Restart=on-failure

[Install]
WantedBy=default.target
```

Then: `systemctl --user enable --now llama-server.service`.

On Windows: a PowerShell script that calls `llama-server.exe` and registers a Scheduled Task on user-login trigger.

### 2. Little Snitch "Research Mode" profile (Phase 8)

| Platform | Equivalent | Notes |
|---|---|---|
| **Mac** | Little Snitch | Current `setup-prompts/little-snitch-research-mode.lsrules` |
| **Linux** | `ufw` (Uncomplicated Firewall) + iptables outbound-deny default | Add `setup-prompts/ufw-research-mode.sh` (TODO) |
| **Windows** | Windows Defender Firewall + outbound rules via `netsh` | Add `setup-prompts/windows-firewall-research-mode.ps1` (TODO) |

The **Linux ufw equivalent** is a few lines:

```bash
# Linux "Research Mode" — block all outbound except loopback
sudo ufw default deny outgoing
sudo ufw default deny incoming
sudo ufw allow out on lo
sudo ufw enable

# To un-engage for a momentary lift:
sudo ufw default allow outgoing  # then immediately revert after install
```

On Windows, equivalent via `netsh advfirewall firewall add rule name=...`.

### 3. MLX (Phase 1 inference)

| Platform | Equivalent | Notes |
|---|---|---|
| **Apple Silicon Mac** | `mlx_lm.server` (~60% faster than GGUF) | Default if M-series detected |
| **Linux/Windows** | Not available; use GGUF + llama.cpp instead | Auto-detected by Phase 1 |

The Phase 1 logic already auto-falls-back: `if INFERENCE_FORMAT="gguf"` runs everywhere. No code change needed on Linux/Windows — they just get GGUF automatically.

### 4. Hardcoded `/opt/homebrew/bin/` paths

| Platform | Equivalent | Notes |
|---|---|---|
| **Mac (Apple Silicon)** | `/opt/homebrew/bin/` | Homebrew default |
| **Mac (Intel)** | `/usr/local/bin/` | Older Homebrew default |
| **Linux** | `/home/linuxbrew/.linuxbrew/bin/` or `/usr/local/bin/` | Homebrew or distro pkg manager |
| **Windows** | n/a — use full paths to `llama-server.exe`, `mlx_lm.server.exe` | Or use WSL2 (recommended) |

**Fix in setup**: use `which <bin>` to resolve paths at install time rather than hardcoding. Phase 1 already does this for the `SERVER_BIN` variable (added in v0.6.1). Audit other phases for stale hardcodes.

### 5. Mac-only commands (`networksetup`, `tmutil`, `system_profiler`)

| Phase | Mac command | Linux equivalent | Windows equivalent |
|---|---|---|---|
| Phase 0 | `system_profiler SPHardwareDataType` | `lscpu` + `free -h` + `df -h` | `Get-ComputerInfo \| Select CsProcessors,CsTotalPhysicalMemory` |
| Phase 8 | `defaults write com.apple.bird CloudDocsEnabled` | n/a (no iCloud) | n/a (no iCloud) |
| Phase 8 | `tmutil addexclusion -p ~/Research` | Exclude from your backup tool config | Exclude from File History |
| Phase 10 Test 3 | `networksetup -setairportpower en0` | `nmcli radio wifi off` | `Disable-NetAdapter -Name Wi-Fi` |

---

## Linux setup walk-through (deferred)

A full `setup-prompts/linux-x86.md` is on the roadmap. Today the practical Linux path:

1. Follow `SETUP_PROMPT.md` Phases 0-4 but substitute:
   - `apt install` or `dnf install` for `brew install`
   - `~/.config/systemd/user/` plists for `launchctl plists`
   - `ufw` for Little Snitch
2. Skip Phase 1 MLX path (auto-detection will skip it anyway)
3. Linux GPU users may need extra steps: install ROCm or CUDA-built `llama.cpp` instead of the CPU-only default

## Windows setup walk-through (deferred)

The realistic Windows path is **WSL2 + Linux flow**. Native Windows works but with friction:

1. Install WSL2 (`wsl --install`)
2. Follow Linux instructions inside WSL
3. Hermes Agent runs inside WSL2 (TUI in `wsl bash`); reach the local model via WSL2's `localhost:11434` (port forwarding works by default). Per Hermes v0.14.0 (May 2026), a native-Windows beta exists for the CLI/TUI — usable but rough at the edges. Nous's native Desktop GUI is still on the roadmap (not released).

For a no-WSL native path: install Ollama (it's native Windows + has GGUF support), point Hermes Agent at it, accept the simpler-but-non-Hermes-native-tool-call architecture.

---

## When you actually need to run on Linux/Windows

For now: **use Mac if you can**. The stack is most tested there. Linux works fine if you're comfortable adapting; Windows works via WSL2 with the same comfort level.

The repo's primary use case (the author's workflow + Turkish-speaking peds endo colleagues) is overwhelmingly Mac. If a non-Mac user needs the stack, the bridge work above is the path; PRs welcome.

---

## Credit

- Cross-platform analysis prompted by user feedback May 2026 ("should be implementable on Windows and Linux too")
- Linux systemd reference: standard `systemctl --user` patterns
- ufw reference: Ubuntu / Debian default firewall doc
