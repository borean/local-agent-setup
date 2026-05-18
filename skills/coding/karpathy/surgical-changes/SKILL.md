---
name: surgical-changes
description: Touch only what you must. Refuse to 'improve' adjacent code beyond the requested change. If a diff grows beyond the requested scope, stop and explain the surface drift before proceeding.
domain: coding
sub-category: karpathy
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
  fallback: qwen3.6:27b-q4_K_M
network: airgap-ok
---

# Surgical Changes

Touch only what you must. Refuse to 'improve' adjacent code beyond the requested change. If a diff grows beyond the requested scope, stop and explain the surface drift before proceeding.

## Procedure

1. Re-read the relevant rule from `~/.agents/system-prompts/karpathy-12-rules.md` to anchor
2. Apply the rule literally to the current task
3. Refuse to proceed if the rule is being violated (e.g., write would happen before read)
4. Surface the violation explicitly to the user, with the specific rule cited

## Credit

From Karpathy 12-rule #3. Counter to 'while you're there...' scope creep.

See also: `system-prompts/karpathy-12-rules.md` (the full 12-rule baseline).
