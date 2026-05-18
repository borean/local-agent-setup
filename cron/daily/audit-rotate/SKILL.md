---
name: audit-rotate
description: Archive yesterday's audit folder; gzip files older than 7 days; SHA-256 hash each archive for KVKK Art. 12 tamper-evidence.
schedule: "30 3 * * *"   # 03:30 daily
domain: shared
network: airgap-ok
---

# Audit Rotate

KVKK Art. 12 wants you to demonstrate technical and administrative measures. This cron is one of them: append-only audit logs with tamper-evidence hashing.

## Procedure

1. **Move yesterday's audit folder** to archive:
   ```bash
   YESTERDAY=$(date -v-1d +%F)
   mv ~/Research/audit/$YESTERDAY ~/Research/audit/archive/
   ```

2. **Hash each file** in the just-archived folder:
   ```bash
   cd ~/Research/audit/archive/$YESTERDAY
   sha256sum * > .checksums.txt
   ```
   `.checksums.txt` contains hash + filename for every file.

3. **Hash the checksums file itself**, append to chain:
   ```bash
   PREV_CHAIN_HASH=$(tail -1 ~/Research/audit/archive/chain.txt 2>/dev/null | cut -d' ' -f1)
   CURRENT=$(sha256sum .checksums.txt | cut -d' ' -f1)
   COMBINED=$(echo "$PREV_CHAIN_HASH $CURRENT" | sha256sum | cut -d' ' -f1)
   echo "$COMBINED $YESTERDAY" >> ~/Research/audit/archive/chain.txt
   ```
   Hash chain — modifying any historical audit file invalidates the chain forward.

4. **Gzip files older than 7 days**:
   ```bash
   find ~/Research/audit/archive -mtime +7 -name "*.jsonl" -exec gzip {} \;
   find ~/Research/audit/archive -mtime +7 -name "*.log" -exec gzip {} \;
   ```

5. **Verify** chain integrity:
   - Rebuild chain from scratch by re-hashing every .checksums.txt
   - Compare with stored chain.txt
   - If mismatch: HUGE alert — someone tampered with archive. Write `~/Research/audit-tamper-alert.md` AND keep the original chain.txt intact.

6. **Retention policy** (configurable):
   - Default: keep all audit files indefinitely (compliance-friendly)
   - If `~/Research/audit/.retention-days` exists with a number, delete files older than that
   - Never auto-delete the chain.txt

## Why this is non-trivial

The hash chain is what makes the audit log defensible. Any KVKK audit can be answered with:
1. "Here are my audit logs"
2. "Here's the hash chain"
3. "Verify the chain — if any historical file was modified, the chain breaks"

Without the chain, "audit logs" are just claims.

## Credit

Hash-chain pattern is a Merkle-chain primitive (Lamport 1979, applied to certificate transparency by Google 2013). Adapted for local-only KVKK Art. 12 audit-trail use.
