---
name: online-lookup
description: Fetch external information (journal author guidelines, package versions, public datasets) in a CLEAN SESSION with no patient-data context loaded. Triggers request-momentary-internet inside the clean session; writes to local cache; resumes original session via passport.
domain: shared
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok  # this skill itself; it INVOKES request-momentary-internet for the actual lift
inputs:
  type: object
  required: [target]
  properties:
    target: {type: string, enum: [journal-guidelines, package-version, public-dataset, reporting-checklist, custom]}
    target_args: {type: object, description: "Skill-specific args, e.g. {journal: 'JCEM'} for journal-guidelines"}
    return_to_passport: {type: string, description: "Hash of the session we resume to afterward"}
outputs:
  type: object
  required: [cache_path, fetched_at, sha256]
  properties:
    cache_path: {type: string}
    fetched_at: {type: string}
    sha256: {type: string}
---

# Online Lookup (Clean-Session)

For when you need to fetch fresh information from the internet — journal author guidelines, latest package versions, public datasets, reporting checklists — without exposing the patient-data context of your current session.

## Why a clean session

If you lift the air-gap (Little Snitch → Setup Mode) WHILE patient data is loaded in your current Hermes context, there's a small but real risk:
- The model might inadvertently include a PHI snippet in a URL parameter
- A network tool might include context in its request payload
- A backgrounded browser tab might capture state

Spawning a clean session — fresh Hermes window, no project loaded — eliminates that risk. The clean session has no PHI to leak.

## Procedure

### Phase A — In the current session (with PHI loaded)

1. Detect that the user wants something online.
2. Emit Material Passport via Skill #02 (`material-passport-emit`).
3. Tell user:
   ```
   I need to look up {target}. To do this safely:
   
   1. Confirm your passport is saved: hash={hash}
   2. Quit this Hermes window
   3. Open a NEW Hermes window (do not load any project)
   4. Paste exactly this:
   
        online-lookup --target={target} --target-args={json} --return-to-passport={hash}
   
   The new session will:
   - Verify no PHI in its context (defensive check)
   - Lift Research Mode briefly via request-momentary-internet
   - Fetch {target}
   - Cache to ~/Research/cache/{slug}.yaml
   - Re-engage Research Mode
   - Tell you to resume this session
   ```
4. Halt.

### Phase B — In the new clean session

1. Defensive verification:
   - Check session ledger is empty (no prior tool calls in this session)
   - Check no skill loaded a project file
   - Check `~/.agents/state/last-session-meta.yaml` is older than 5 minutes (i.e., genuinely new session)
   - If ANY check fails: refuse to proceed; explain why; tell user to open a truly fresh window
2. Invoke `request-momentary-internet` skill with the appropriate command:
   - For `journal-guidelines`: `curl + parse` for the target journal's instructions-to-authors
   - For `package-version`: `uv pip search` or `npm view`
   - For `public-dataset`: appropriate API call
   - For `reporting-checklist`: fetch from EQUATOR Network
3. Parse the fetched content; structure as YAML per the target type's schema (see schemas section below)
4. Write to `~/Research/cache/{slug}.yaml`
5. Hash + audit:
   ```yaml
   - timestamp: 2026-05-18T15:42:00Z
     target: journal-guidelines
     target_args: {journal: "JCEM"}
     fetched_at: 2026-05-18T15:42:00Z
     cache_path: ~/Research/cache/journal-guidelines/jcem.yaml
     sha256: abc123...
     return_to_passport: def456...
   ```
   Append to `~/Research/audit/$(date +%F)/online-lookups.jsonl`
6. Tell user:
   ```
   ✅ Lookup complete. Cached:
       ~/Research/cache/{slug}.yaml
       SHA-256: abc123...
   
   To resume your work:
     1. Close this clean session
     2. Open Hermes with your project
     3. Paste: resume_from_passport={hash}
   
   Your original session will pick up where it left off; the new cache will be
   consulted automatically by outline-build, abstract-format, etc.
   ```

## Cache file schemas

### journal-guidelines/{slug}.yaml

```yaml
journal: JCEM
slug: jcem
url: https://academic.oup.com/jcem/pages/General_Instructions
fetched_at: 2026-05-18T15:42:00Z
fetched_by_user: bora
abstract:
  type: structured        # or "unstructured"
  word_limit: 250
  sections: [Context, Objective, Design, Setting, Participants, Intervention, Outcome, Results, Conclusion]
main_text:
  word_limit: 3000
  sections: [Introduction, Methods, Results, Discussion, Conclusion]
references:
  style: vancouver
  in_text_format: "[1]"
  max_count: 50
figures:
  max_count: 5
  formats: [tiff, eps, pdf]
  min_dpi: 300
tables:
  max_count: 5
ethics_statement:
  required: true
  format: "must reference IRB approval, date, and consent procedure"
data_sharing:
  required: true
  policy_url: "..."
ai_disclosure:
  required: true        # as of 2026
  format: "Authors must disclose AI tool use per PRISMA-trAIce (Holst 2025)"
caveat: "Verify by visiting the URL before final submission. Author guidelines change."
```

### reporting-checklist/{slug}.yaml

```yaml
checklist: STROBE
slug: strobe
url: https://www.equator-network.org/reporting-guidelines/strobe/
fetched_at: 2026-05-18T15:42:00Z
applies_to: observational
items: [{number: 1a, section: title-abstract, text: "..."}, ...]
```

## When to use

- Before submitting a manuscript (refresh target journal's guidelines)
- When skill output references a journal's word limit (verify the cached version isn't stale)
- When a paper-qa query needs a specific reporting checklist version
- When considering a Python/R package that may have been updated

## Cache refresh policy

- Journal guidelines: refresh monthly (cron task: TBD)
- Reporting checklists: refresh quarterly
- Package versions: on-demand (no cron)
- Public datasets: per-dataset cadence in their schema

## Failure modes

- **User opens new session but it isn't clean** (some project auto-loaded): skill refuses; tells user to use "New Project (Empty)" option in Hermes
- **request-momentary-internet refused by user**: skill aborts; original session can resume but with stale cache
- **Fetched content parse fails** (e.g., journal changed their HTML structure): skill saves the raw HTML + asks user to manually fill the schema once
- **Network down during lookup**: skill logs failure to audit and returns; user can retry next online window

## Why we don't just do this inline

You CAN do this inline in your current session — just invoke `request-momentary-internet` directly. But for journal guidelines specifically, where:
- The lookup happens days/weeks after the analysis (low time pressure)
- The patient data is unrelated to the lookup
- Multiple manuscripts might share the same cache result
- KVKK audit benefits from explicit context separation

...the clean-session pattern is the right design.

For quick "what's the latest version of `lifelines`?" use-on-the-spot use cases, `request-momentary-internet` inline is fine. For "let me fetch the current JCEM author guidelines," clean session wins.

## Example flow

```
[In session A with patient data loaded]
User: "I want to draft the abstract for my JCEM submission."
Skill draft-write: "Need current JCEM author guidelines first. Are they in cache?"
Cache check: ~/Research/cache/journal-guidelines/jcem.yaml exists but is 89 days old (refresh policy: 30 days).
draft-write: "Cache stale. Invoking online-lookup..."

online-lookup Phase A:
  Emitted passport: hash=abc123
  Halting session A.
  Showing user the clean-session instructions.

[User opens new Hermes window, no project]
User pastes: online-lookup --target=journal-guidelines --target-args='{"journal":"JCEM"}' --return-to-passport=abc123

online-lookup Phase B:
  Defensive check: session is clean ✓
  Invoking request-momentary-internet...
  User confirms Little Snitch → Setup Mode
  Fetched: https://academic.oup.com/jcem/pages/General_Instructions
  Parsed; wrote ~/Research/cache/journal-guidelines/jcem.yaml (sha256: 9f8a...)
  User confirms Little Snitch → Research Mode
  
✅ Done. Resume your original session via: resume_from_passport=abc123

[User opens project session A; pastes resume_from_passport=abc123]
session-launch + material-passport-resume restore the original context.
draft-write proceeds, now reading the fresh JCEM guidelines.
```

## Credit

Pattern designed in response to Bora's observation that lifting the air-gap while PHI is loaded creates an unnecessary leak risk — even though the air-gap toggle is human-in-the-loop. Clean-session separation eliminates the risk surface entirely.
