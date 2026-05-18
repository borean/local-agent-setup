---
name: read-before-write
description: Before writing any new function, read: (a) exports, (b) callers, (c) shared utilities. Verify the function doesn't already exist (or that you're not duplicating its behavior). Refuse to write until verification done.
domain: coding
sub-category: karpathy
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
  fallback: qwen3.6:27b-q4_K_M
network: airgap-ok
---

# Read Before Write

Before writing any new function, read: (a) exports, (b) callers, (c) shared utilities. Verify the function doesn't already exist (or that you're not duplicating its behavior). Refuse to write until verification done.

## Procedure

1. Re-read the relevant rule from `~/.agents/system-prompts/karpathy-12-rules.md` to anchor
2. Apply the rule literally to the current task
3. Refuse to proceed if the rule is being violated (e.g., write would happen before read)
4. Surface the violation explicitly to the user, with the specific rule cited

## Credit

From Karpathy 12-rule #8. Counter to silent duplicate-function generation.

See also: `system-prompts/karpathy-12-rules.md` (the full 12-rule baseline).
