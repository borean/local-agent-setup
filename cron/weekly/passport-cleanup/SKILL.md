---
name: passport-cleanup
description: Delete material-passport snapshots older than 30 days. Keep hash history for re-stitching old work but prune the bulky JSON snapshots.
schedule: "30 4 * * 0"   # 04:30 Sunday
domain: shared
network: airgap-ok
---

# Passport Cleanup

Material Passports accumulate. The hash chain is small (one line per passport). The snapshot JSON is bigger. Keep recent ones full; archive old ones to hash-only.

## Procedure

1. Find passports >30 days old:
   ```bash
   find ~/.agents/state/passports -name "*.json" -mtime +30
   ```

2. For each old passport:
   - Append a one-line entry to `~/.agents/state/passports/.archive-index.txt`:
     ```
     {hash}  {original-date}  {original-size-bytes}  ARCHIVED
     ```
   - Delete the full JSON

3. Keep recent 50 passports regardless of age (safety floor).

4. Log to `~/Research/audit/$(date +%F)/passport-cleanup.log`:
   - How many archived
   - How many kept
   - Total disk freed

## What we lose by archiving

You can no longer fully `resume_from_passport=<hash>` on an archived hash — the snapshot is gone. The hash + date + size remain in the index, so you can prove the passport existed (KVKK audit). For most work, 30-day window is plenty; longer-term resumes are rare.

## When to override

If a long-running project will span >30 days at the same passport stage, mark the passport as `keep: true` in its JSON metadata. The cleanup skill skips passports with this flag.

## Credit

Routine housekeeping. The archive-index pattern is from append-only log archival best practice.
