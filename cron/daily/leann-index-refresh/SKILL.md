---
name: leann-index-refresh
description: If ~/Zotero/storage has new or modified files since last index build, run incremental LEANN re-index. Air-gap-only — uses local BGE-M3 embeddings.
schedule: "45 3 * * *"   # 03:45 daily
domain: shared
network: airgap-ok
---

# LEANN Index Refresh

Keeps your local literature search current without ever touching the network.

## Procedure

1. Compare:
   - `ls -la ~/Zotero/storage/` latest mtime
   - `~/.leann/peds-endo-corpus/.last-indexed` timestamp

2. If Zotero is newer:
   ```bash
   leann update ~/.leann/peds-endo-corpus \
     --source ~/Zotero/storage \
     --embed-model bge-m3 \
     --incremental
   ```

3. If full rebuild needed (Zotero structure changed significantly, e.g. >20% new files):
   ```bash
   leann build ~/.leann/peds-endo-corpus \
     --source ~/Zotero/storage \
     --embed-model bge-m3
   ```

4. Touch `.last-indexed` with current timestamp.

5. Quick sanity test: query for a known paper title; verify it shows up in top-5.

6. Log to `~/Research/audit/$(date +%F)/leann-refresh.log`.

## Failure modes

- BGE-M3 embedding model not loaded in llama-server: skip refresh; alert
- Zotero library empty: skip with notice
- LEANN binary not installed: alert + exit
- Disk full: alert + exit (incremental update can briefly need 2× space)

## Why daily

Bora adds 5-15 new papers per week. Daily incremental keeps the index <24h fresh, which means PaperQA2 queries always see latest. Cheap operation (~30s incremental, ~5min full).

## Credit

LEANN by @LiorOnAI (surfaced in WhatsApp data). 60M chunks in 6GB by storing graph instead of vectors.
