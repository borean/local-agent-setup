---
name: manuscript-snapshot
description: Weekly versioned snapshots of active manuscripts for score-trajectory baseline. Cap 12 snapshots per manuscript; prune oldest.
schedule: "0 4 * * 0"   # 04:00 Sunday
domain: shared
network: airgap-ok
---

# Manuscript Snapshot

Foundation for the `score-trajectory` skill. Without a snapshot trail, regression detection is impossible.

## Procedure

1. Find active manuscripts (modified in last 7 days):
   ```bash
   find ~/Research -name "manuscript*.{md,qmd,tex}" -mtime -7 \
     -not -path "*/snapshots/*" 2>/dev/null
   ```

2. For each manuscript:
   ```bash
   # Snapshot location
   SNAP_DIR=~/.agents/state/manuscript-snapshots/{project}/{filename}/
   mkdir -p "$SNAP_DIR"

   # Snapshot with date stamp
   cp "$manuscript" "$SNAP_DIR/$(date +%Y-%m-%d).md"

   # Compute and store metadata
   wc -w "$manuscript" > "$SNAP_DIR/$(date +%Y-%m-%d).meta.txt"
   sha256sum "$manuscript" >> "$SNAP_DIR/$(date +%Y-%m-%d).meta.txt"
   ```

3. Prune: keep only the 12 most recent snapshots per manuscript:
   ```bash
   ls -t "$SNAP_DIR"/*.md | tail -n +13 | xargs rm -f
   ```

4. If `score-trajectory` skill is installed AND ≥3 snapshots exist for any manuscript, run it on that manuscript:
   ```bash
   curl -X POST http://localhost:11434/v1/chat/completions \
     -d '{"messages":[...score-trajectory invocation...]}'
   ```
   Output to `~/Research/{project}/score-trajectory-report.md`.

5. Update a roll-up index: `~/.agents/state/manuscript-snapshots/index.json`.

## Failure modes

- No active manuscripts: exit silently
- Manuscript moved/renamed mid-week: orphan the old snapshot dir; create new one
- Snapshot disk fills: prune more aggressively (8 snapshots cap instead of 12)

## Why Sunday

End-of-week is when most researchers naturally have a "done for now" state of their drafts. Snapshot captures Saturday's state. Monday work continues from there, with score-trajectory able to flag if Monday's edits regressed Sunday's gains.

## Credit

Score-trajectory pattern from [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills). Cherry-picked May 14-15, 2026 as one of the 6 must-grabs.
