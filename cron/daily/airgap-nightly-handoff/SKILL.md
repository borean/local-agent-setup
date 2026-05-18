---
name: airgap-nightly-handoff
description: End-of-day scan of active research projects; write fresh handoff.md per project with today's activity so tomorrow starts clean. Air-gap-only (no network).
schedule: "0 3 * * *"   # 03:00 daily
domain: shared
network: airgap-ok
---

# Airgap Nightly Handoff

Adapted from Bora's existing `nightly-handoff` scheduled task. Scoped to research projects only; no internet calls.

## Procedure

1. Find research projects with session activity in last 24h:
   ```bash
   find ~/Research -maxdepth 3 -name "handoff.md" -mtime -1 2>/dev/null
   find ~/.agents/state/passports -name "*.json" -mtime -1
   ```

2. For each active project:
   - Read recent ledger entries from `~/Research/audit/$(date +%F)/*.jsonl`
   - Extract: tools invoked, files modified, decisions made, passport hash if emitted
   - Read project's `handoff.md` (or create if missing)
   - Append `## End-of-Day Summary — {date}` section with:
     - Skills invoked today
     - Files modified
     - Material Passport hash (for resume)
     - "Next:" inferred from incomplete tasks in ledger

3. Cap `handoff.md` at 200 lines; trim oldest entries beyond that.

4. Write digest summary to `~/Research/recent-research.md` (rolling 50 lines).

## Failure modes

- Project directory deleted mid-task: skip with log entry, no error
- handoff.md write-locked: retry once then skip
- No projects active today: exit silently

## Credit

Adapted from Bora's `~/.claude/scheduled-tasks/nightly-handoff/SKILL.md`. Air-gap-scoped variant.
