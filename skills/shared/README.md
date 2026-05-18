# shared/ — Cross-cutting skills

Used by both `research/` and `coding/` sessions. Always loaded.

## Skills in this bundle (~6)

| # | Name | Job |
|---|---|---|
| 01 | `session-launch` | LFM2.5-350M classifies task → picks Qwen 27B or 35B-A3B → loads system prompt + skills → starts warm. Decide once, commit. |
| 02 | `material-passport-emit` | At full checkpoint or pre-compaction: hash the append-only ledger (JCS + SHA-256), emit `[PASSPORT-RESET: hash=<h>]`, halt. |
| 03 | `material-passport-resume` | In fresh session, accept `resume_from_passport=<hash>` → restore minimal state → skip done stages. |
| 04 | `output-scrub` | Before any output leaves the laptop: regex for TCKN/MRN/Turkish names/exact dates. Auto-generalize ("week 12" not "April 14"). |
| 05 | `network-mode-toggle` | One-button check: Little Snitch Research Mode active? tcpdump shows no egress? iCloud sync off? Returns red/yellow/green. |
| 06 | `request-momentary-internet` | Stepwise prompt to user: lift Research Mode → install package → verify → re-engage. Audit logged. |

## Why these are shared, not in research/

- They have no domain logic. They're infrastructure.
- Both research and coding sessions need them at session-start, session-end, and on every output export.
- `material-passport-*` solves context exhaustion — both domains hit it.

## Loading order at session-start

```
1. session-launch          ← decides everything else
2. material-passport-resume  ← if user pasted a hash
3. (session work proceeds with research/ or coding/ skills loaded)
4. material-passport-emit  ← on context-pressure or natural break
5. output-scrub            ← when user asks to export
6. network-mode-toggle     ← anytime user says "am I safe?"
7. request-momentary-internet ← when a skill says "I need package X"
```
