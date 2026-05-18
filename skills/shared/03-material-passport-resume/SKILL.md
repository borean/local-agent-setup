---
name: material-passport-resume
description: In a fresh session, accept a passport hash from the user, locate the snapshot, restore minimal state, skip stages already done.
domain: shared
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
inputs:
  type: object
  required: [passport_hash]
  properties:
    passport_hash: {type: string, pattern: "^[a-f0-9]{32,64}$"}
outputs:
  type: object
  required: [restored, next_action]
  properties:
    restored: {type: boolean}
    next_action: {type: string}
    skipped_stages: {type: array, items: {type: string}}
    ledger_summary: {type: string}
---

# Material Passport — Resume

The other half of `material-passport-emit`. Paste the hash, pick up where you left off.

## Procedure

1. Locate `~/.agents/state/passports/{passport_hash}.json`
2. If missing: fail loudly. List 5 most recent passports; suggest one.
3. Verify the hash matches the snapshot's contents (defends against corruption).
4. Read the ledger; extract:
   - Project root path
   - Last completed stage
   - Next intended stage
   - Key decisions (load into context as a compact bullet list)
   - File paths referenced (verify they still exist)
5. Show user a summary:
   ```
   Resuming passport 8c9d2af7...
   Last stage:    analysis-plan-complete
   Next stage:    analysis-run
   Decisions carried over:
     - Cox regression chosen over Fine-Gray (reason: low censoring rate)
     - Imputation: complete-case for primary, multiple imputation for sensitivity
     - Subgroup analyses: pre-specified by age band (10-13, 14-17)
   Files referenced (verified):
     - ~/Research/glp1-adolescents/data/cohort_clean.csv  ✓
     - ~/Research/glp1-adolescents/analysis-plan.md       ✓
   Ready to continue at: analysis-run.
   ```
6. Set the session's current stage to the resumed stage
7. Skill `session-launch` already ran before this — model is loaded; we just inject the resumed context into the system prompt
8. Return structured object; harness adds it to context

## Failure modes

- **Hash not found**: list recent passports + suggest the most likely one (within 7 days)
- **Hash found but referenced files missing**: refuse to resume; explain what's missing
- **Hash from an old project that doesn't match current cwd**: warn user; allow override
- **Ledger contains skills not currently installed**: warn; offer to install or skip those entries

## What does NOT carry over

- Full conversation history (that's the whole point — we're shedding context)
- Raw model outputs (only structured outputs persist)
- Intermediate scratch work (only committed decisions persist)

## Example

```
User (fresh session, day 2):
  resume_from_passport=8c9d2af7b3e441f6a02d6c95e1f8b3d4

Skill output:
  Restored: true
  Next action: analysis-run
  Skipped stages: [data-dictionary, statistical-test-picker, power-analysis, analysis-plan]
  Ledger summary: "Cohort study, n=412, primary outcome HbA1c at 12 weeks,
                   plan: Cox regression with PS-matched subset, pre-specified subgroups by age"

[session continues with analysis-run as next step]
```

## Credit

Companion to `material-passport-emit`. From [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills). Cherry-picked May 14-15, 2026.
