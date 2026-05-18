---
name: llama-server-health
description: Verify llama-server services on ports 11434 (Qwen) and 11436 (LFM2.5) respond. Restart dead services. Notify on persistent failure.
schedule: "0 3 * * *"   # 03:00 daily; can also run every 6h
domain: shared
network: airgap-ok
---

# llama-server Health Check

Air-gap variant of Bora's existing `process-guardian`. Checks the OAI-compat endpoints we depend on.

## Procedure

1. For each port (11434, 11436):
   ```bash
   curl -s --max-time 3 http://localhost:$PORT/v1/models -o /dev/null
   ```
   Return code 0 = healthy.

2. If unhealthy:
   - Check launchctl status: `launchctl list | grep com.local-agent.llama-server`
   - If service crashed, attempt restart: `launchctl unload && launchctl load`
   - Verify again. If still unhealthy after restart, escalate to notification.

3. Tail llama-server stderr (`~/.research/logs/llama-server-err.log`) for the last 50 lines and look for common failure modes:
   - "out of memory" → swap to smaller quant; alert user to free RAM
   - "model file not found" → check disk; alert user
   - "metal init failed" → check macOS Metal support; rare on M-series but flag

4. Write status to `/tmp/llama-server-status.json`:
   ```json
   {"timestamp": "...", "ports": {"11434": "healthy", "11436": "healthy"},
    "last_restart": "...", "failures_24h": 0}
   ```

5. If failures_24h > 3, write alert to `~/Research/llama-server-alert.md`.

## Why this matters

Without llama-server, Hermes (or any harness) has no model to talk to. This is the always-on backbone. Checking nightly + auto-restarting on crash means you wake up to a working setup, not a 6-hour silent failure.

## Credit

Adapted from `~/.claude/scheduled-tasks/process-guardian/SKILL.md`.
