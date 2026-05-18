---
name: request-momentary-internet
description: When a skill or user needs to install a package or update a cache that requires internet, this skill emits stepwise instructions to lift the air-gap briefly. Audit-logged. User clicks Little Snitch toggle; we do not auto-toggle.
domain: shared
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
inputs:
  type: object
  required: [reason, command]
  properties:
    reason: {type: string, description: "What needs internet and why"}
    command: {type: string, description: "Exact command to run, e.g. 'uv pip install lifelines'"}
    estimated_seconds: {type: integer, default: 60}
outputs:
  type: object
  required: [completed, audit_entry]
  properties:
    completed: {type: boolean}
    audit_entry: {type: object}
---

# Request Momentary Internet

For when a skill genuinely needs network access and there's no offline alternative. The flow:

1. Skill requests via this skill
2. Skill explains to user WHY + WHAT will run
3. User toggles Little Snitch → "Setup Mode" (one click)
4. Skill runs the command (with verification)
5. User toggles back to "Research Mode" (one click)
6. Audit log captures the entire window

## Procedure

1. Show user the request, clearly:
   ```
   ┌─ MOMENTARY INTERNET LIFT REQUESTED ─┐
   │
   │  Reason:    {reason}
   │  Command:   {command}
   │  Estimated: ~{estimated_seconds} seconds
   │
   │  This will briefly lift the air-gap.
   │  No patient data will be exposed to the network
   │  during this window. Outbound traffic is logged.
   │
   └─────────────────────────────────────┘

   To proceed:
     1. Click Little Snitch menu icon → switch to "Setup Mode"
     2. Reply: "ready"

   To cancel:
     Reply: "cancel"
   ```

2. Wait for user response.

3. If "ready", verify Little Snitch profile changed:
   - Call `network-mode-toggle` skill internally
   - If status != yellow/red (i.e., still green), warn user — they haven't toggled
   - Wait for them to actually toggle

4. **Pre-flight**:
   - If `command` is a `uv pip install`, run `uv pip install --dry-run {pkg}` first; show what will install
   - Verify `command` doesn't include any obvious leak vector ("curl ... | bash" requires extra confirmation)
   - Capture the start timestamp + Little Snitch profile + initial tcpdump status

5. **Run** the command. Capture stdout, stderr, exit code, all network endpoints touched.

6. **Post-flight**:
   - Confirm installation succeeded
   - Run `pip check` (or equivalent) — fail loudly if deps now broken
   - Capture end timestamp

7. Tell user:
   ```
   ✅ Command completed (exit 0).
   {summary of what was installed/fetched}

   Network endpoints touched: {list}
   Duration: {seconds}s

   IMPORTANT: Toggle Little Snitch back to "Research Mode" now.
   Reply "back" once you've done it.
   ```

8. Wait for "back". Re-verify via `network-mode-toggle` — must be green.

9. Append to audit:
   ```yaml
   - timestamp: {start_ts}
     reason: {reason}
     command: {command}
     user_confirmed: true
     little_snitch_profile_during: Setup Mode
     duration_seconds: {seconds}
     network_endpoints: [pypi.org, files.pythonhosted.org, ...]
     exit_code: 0
     stdout_hash: {sha256}
     reverted_at: {end_ts}
     reverted_profile: Research Mode
   ```
   Append to `~/Research/audit/$(date +%F)/momentary-lifts.jsonl`

## Failure modes

- **User says "ready" but Little Snitch still green**: refuse to run; re-prompt
- **Command fails mid-run**: rollback (`uv pip uninstall {pkg}` if applicable); audit-log the failure; tell user to toggle back regardless
- **User never replies "back"**: emit a notification every 30 seconds; do not exit until confirmed
- **User wants to leave Setup Mode on for "a while"**: refuse — this skill is for brief lifts, not for extended sessions. For longer setup work, the user explicitly switches mode and we don't pretend it's still air-gapped.

## What this skill does NOT do

- It does NOT toggle Little Snitch automatically. The human MUST click. This is by design — automating the toggle defeats the purpose of having Little Snitch.
- It does NOT cache the user's sudo password.
- It does NOT batch multiple installs (one request, one install, one confirmation).

## When called from other skills

Skills that need a package they don't have should call this skill rather than failing or trying to install directly. Example: `analysis-run` discovers it needs `lifelines` and the venv doesn't have it → calls this skill → user confirms → install proceeds.

## Example

```
Skill `analysis-run` reports:
  I need package `lifelines` for the survival analysis. Not in current venv.

Skill `request-momentary-internet` activates:
  ┌─ MOMENTARY INTERNET LIFT REQUESTED ─┐
  │  Reason:    lifelines (survival analysis) required by analysis-run
  │  Command:   uv pip install lifelines==0.27.8
  │  Estimated: ~30s
  └─────────────────────────────────────┘
  To proceed: toggle Little Snitch → "Setup Mode", then reply "ready"

User: ready

Skill: ✅ Toggle confirmed. Running uv pip install lifelines...
       ✅ lifelines 0.27.8 installed.
       Network endpoints: pypi.org, files.pythonhosted.org
       Duration: 12s

       Toggle Little Snitch back to "Research Mode". Reply "back" when done.

User: back

Skill: ✅ Air-gap restored. Audit-logged.
       Resuming analysis-run.
```

## Credit

The "human-in-the-loop network toggle" pattern is from Bora's v3 design decision. The audit-log-everything approach maps to KVKK Art. 12. Inspired by Karpathy's #1 preflight install (direnv + secrets manager) — same philosophy: brief, scoped, audited credential exposure rather than ambient access.
