---
name: material-passport-emit
description: At a FULL checkpoint or PreCompact event, hash the session's append-only ledger via JCS + SHA-256, emit a [PASSPORT-RESET: hash=...] marker the user can paste into a fresh session to resume work without context loss.
domain: shared
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
inputs:
  type: object
  required: [stage, ledger_path]
  properties:
    stage: {type: string, description: "Current pipeline stage, e.g. 'analysis-plan-complete', 'draft-1-written'"}
    ledger_path: {type: string, description: "Path to the append-only ledger file"}
    next_stage: {type: string}
outputs:
  type: object
  required: [passport_hash, reset_marker]
  properties:
    passport_hash: {type: string, description: "SHA-256 of JCS-canonicalized ledger"}
    reset_marker: {type: string, description: "The string the user pastes into next session"}
    halt: {type: boolean, default: true}
---

# Material Passport — Emit

Solves the #1 pain: context exhaustion. The skill emits a deterministic hash of the session's append-only ledger; the user pastes the hash into a fresh session via `material-passport-resume`; the new session restores state and skips done stages.

## Procedure

1. Read the ledger file at `ledger_path` (JSONL or YAML format, append-only)
2. Strip volatile fields (timestamps with sub-second precision, session UUIDs) — keep only content-affecting entries
3. JCS-canonicalize (JSON Canonicalization Scheme, RFC 8785) — produces a deterministic byte stream
4. SHA-256 the canonical bytes → hex string
5. Write the full ledger to `~/.agents/state/passports/{hash}.json` (the resumable snapshot)
6. Emit to user:
   ```
   [PASSPORT-RESET: hash=<hash> stage=<stage> next=<next_stage>]

   To resume in a fresh session, paste:
     resume_from_passport=<hash>

   I'm halting here to prevent context drift.
   ```
7. Return `{passport_hash, reset_marker, halt: true}`. Harness should honor halt.

## What goes in the ledger

The ledger is the **append-only** session record. Every meaningful event:
- User prompts (sanitized — no raw PHI)
- Skill invocations + structured outputs
- Files created/modified (paths + content hashes, not content)
- Decisions made (e.g., "chose Cox regression over Fine-Gray because ...")
- External tool outputs (LEANN query results, R analysis outputs as numbers)

What doesn't go in:
- Token-by-token model output
- Tool-call retries
- Filesystem listings
- Anything sensitive (PHI scrubbed per `output-scrub`)

## Failure modes

- **Ledger missing**: skill fails loudly. Don't silently produce a hash of nothing.
- **Ledger contains PHI**: skill flags and refuses. User must run `output-scrub` on ledger first.
- **Hash collision** (≈ 2⁻¹²⁸ — never): refuse to overwrite passport file; emit different stage suffix.
- **User refuses to halt** ("just keep going"): emit hash but continue session. Mark that decision in ledger for audit.

## When to fire

Automatically via hooks:
- `precompact-passport-emit.sh` hook before any context compaction
- `session-end-passport.sh` hook on session natural end

Manually:
- User says "checkpoint" or "save this so I can resume tomorrow"
- After a long planning phase you don't want to lose
- Before risky next-step that might fail

## Example

```
Stage: analysis-plan-complete
Ledger entries: 47 (data dictionary, hypothesis, 5 proposed analyses with assumptions, peer review of plan)

Output:
[PASSPORT-RESET: hash=8c9d2af7b3e441f6a02d6c95e1f8b3d4 stage=analysis-plan-complete next=analysis-run]

To resume in a fresh session, paste:
  resume_from_passport=8c9d2af7b3e441f6a02d6c95e1f8b3d4

I'm halting here to prevent context drift.
```

## Credit

The Material Passport pattern is from [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills). Adapted from the ARS `passport_as_reset_boundary.md` reference. Cherry-picked during Bora's May 14-15 2026 evaluation session as one of the 6 must-grabs.
