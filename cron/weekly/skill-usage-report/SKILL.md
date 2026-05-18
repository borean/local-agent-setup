---
name: skill-usage-report
description: Weekly summary of which skills were invoked, which were never used, and which are prune candidates. Replaces the air-gap subset of daily-session-analysis.
schedule: "0 5 * * 0"   # 05:00 Sunday
domain: shared
network: airgap-ok
---

# Skill Usage Report

Compounds the "are we using what we built?" question.

## Procedure

1. Scan last 7 days of audit ledgers:
   ```bash
   find ~/Research/audit -name "*.ledger.jsonl" -mtime -7
   ```

2. Count Skill tool invocations per skill name:
   ```bash
   grep -h '"tool":"Skill"' [files] | \
     jq -r '.input.skill // .input.name' | \
     sort | uniq -c | sort -rn
   ```

3. List installed skills:
   ```bash
   find ~/.agents/skills -name "SKILL.md" -exec grep -h '^name:' {} \; | sed 's/^name: *//'
   ```

4. Diff to find:
   - **Top 10 invoked** — likely keep + maybe expand
   - **Bottom 25 unused** — prune candidates (warn before deletion; user decides)
   - **Newly installed but never used** — track separately; might need re-introduction in `skill-suggest-airgap.sh`

5. Write report to `~/Research/audit/$(date +%F)/skill-usage-week.md`:
   ```markdown
   # Skill Usage — Week of 2026-05-12 through 2026-05-18

   ## Top 10 invoked
   1. paperqa-synthesize       (43 calls)
   2. draft-write              (28)
   3. analysis-plan            (19)
   ...

   ## Unused this week (prune candidates)
   - shadcn (coding/shadcn)         — 0 calls, installed 30d ago
   - response-to-reviewer            — 0 calls (expected, no revisions this week)
   ...

   ## New but unused
   - storm-systematic-review (installed 2d ago, 0 calls)
     → suggest adding "systematic review" keyword to skill-suggest hook

   ## Total
   Skills installed: 64
   Skills invoked: 23 (36%)
   Skills idle:    41 (64%)
   ```

6. If usage rate <25%, write `~/Research/skill-pruning-suggestion.md` with prune candidates.

## What this replaces

Bora's `daily-session-analysis` did this daily across all 130 skills. Air-gap variant is weekly + scoped to our 64-skill bundle. Less noise, more signal.

## Credit

Pattern from Bora's `~/.claude/scheduled-tasks/daily-session-analysis/SKILL.md`. Compressed to weekly + air-gap-scoped.
