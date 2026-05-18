---
name: fail-loud
description: Surface uncertainty, never hide it. Every status report includes partial-skip percentage. 'Completed successfully with 14% of records silently skipped' is the worst class of bug — make sure that never happens silently.
domain: coding
sub-category: karpathy
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
  fallback: qwen3.6:27b-q4_K_M
network: airgap-ok
---

# Fail Loud

Surface uncertainty, never hide it. Every status report includes partial-skip percentage. 'Completed successfully with 14% of records silently skipped' is the worst class of bug — make sure that never happens silently.

## Procedure

1. Re-read the relevant rule from `~/.agents/system-prompts/karpathy-12-rules.md` to anchor
2. Apply the rule literally to the current task
3. Refuse to proceed if the rule is being violated (e.g., write would happen before read)
4. Surface the violation explicitly to the user, with the specific rule cited

## Credit

From Karpathy 12-rule #12. Pattern: explicit count of skipped/failed/partial cases in every summary.

See also: `system-prompts/karpathy-12-rules.md` (the full 12-rule baseline).
