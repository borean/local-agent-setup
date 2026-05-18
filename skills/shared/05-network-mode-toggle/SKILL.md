---
name: network-mode-toggle
description: Verify current network egress state. Run a tcpdump sample, check Little Snitch profile, check iCloud sync, return red/yellow/green. The "am I safe right now?" one-button check.
domain: shared
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
inputs:
  type: object
  properties:
    sample_seconds: {type: integer, default: 5}
    verbose: {type: boolean, default: false}
outputs:
  type: object
  required: [status, details]
  properties:
    status: {type: string, enum: [green, yellow, red]}
    details: {type: object}
    suggested_action: {type: string}
---

# Network Mode Toggle (verify)

This skill **verifies** the air-gap state. It does NOT toggle (toggling is a manual Little Snitch click — we intentionally don't automate that, to keep the human in the loop).

## Procedure

1. **tcpdump sample**: `sudo tcpdump -i any -c 50 -n not host 127.0.0.1 and not host ::1` for `sample_seconds`
   - If any packets captured → status = red
   - If zero packets → continue checks

2. **Little Snitch profile check**:
   - `osascript -e 'tell application "Little Snitch" to ...'` or via Little Snitch CLI if installed
   - If profile name = "Research Mode" → ok
   - If profile name = "Setup Mode" or "Default" → status = yellow (network allowed)

3. **iCloud sync check**:
   - `defaults read com.apple.bird CloudDocsEnabled` (1 = on, 0 = off)
   - If on → status = yellow (Documents/Desktop syncing potentially uploads research files)

4. **Time Machine exclusion check**:
   - `tmutil isexcluded ~/Research` (returns 0 if excluded, 1 if included)
   - If included → status = yellow (TM uploads research files to backup destination)

5. **Spotlight web suggestions**:
   - `defaults read com.apple.lookup.shared LookupSuggestionsDisabled`
   - If not disabled → status = yellow

6. **Aggregate**:
   - status = `red` if tcpdump caught any external traffic
   - status = `yellow` if any setting allows leak vector
   - status = `green` only if all clean

7. Generate `suggested_action`:
   - red → "External traffic detected. Toggle Little Snitch to Research Mode IMMEDIATELY. Do not continue clinical work."
   - yellow → "Air-gap not fully engaged. Specific issues: [list]. Address before processing patient-derived data."
   - green → "Safe to process patient-derived data."

8. Log to `~/Research/audit/$(date +%F)/network-check.log`

## Failure modes

- **tcpdump needs sudo**: prompt user once per session for sudo password via `osascript -e 'do shell script "tcpdump ..." with administrator privileges'`. Cache the auth for the session.
- **Little Snitch not installed**: warn user; offer to install via brew.
- **VPN active**: VPN tunneled traffic shows up as external; not red but worth a yellow warning ("you're on VPN, are you sure this is the air-gapped machine?").

## Example

```
User: "am I safe right now?"

Skill output:
  status: green
  details:
    tcpdump_packets: 0 over 5s
    little_snitch_profile: "Research Mode"
    icloud_sync: off
    time_machine_excluded: yes
    spotlight_web: disabled
  suggested_action: "Safe to process patient-derived data."
```

```
User: "am I safe right now?"

Skill output:
  status: yellow
  details:
    tcpdump_packets: 0
    little_snitch_profile: "Default"   ← issue
    icloud_sync: on                     ← issue
  suggested_action: "Air-gap not fully engaged. 1) Click Little Snitch menu → 'Research Mode'. 2) System Settings → iCloud → Drive → toggle 'Desktop & Documents Folders' OFF."
```

## When to fire

- User asks "am I safe" or similar
- Automatically by `session-start-airgap.sh` hook at every session start
- Automatically by `user-prompt-phi-warn.sh` if user includes PHI patterns in a prompt
- Before any export action via `output-scrub`

## Credit

Inspired by KVKK Art. 12 "demonstrate technical measures" requirement. The pattern of human-in-the-loop toggle (skill verifies, human acts) comes from Bora's v3 design decision — automating the toggle is more dangerous than helpful.
