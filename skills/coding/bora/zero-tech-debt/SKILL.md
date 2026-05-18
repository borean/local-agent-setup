---
name: zero-tech-debt
description: Rework a change as if the intended UX and architecture existed from day one, deleting compatibility cruft and accidental complexity.
user-invocable: true
domain: coding
sub-category: bora
target_models:
  primary: qwen3.6:27b-q4_K_M
  fallback: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
---

# Zero Tech Debt

Rework the change from the intended end state, not from the historical path that produced the current patch.

## Steps

1. State the intended end state in one or two sentences.

2. Search for real callers before preserving compatibility.
   If a mode, prop, wrapper, route alias, or fallback has no current caller, delete it.

3. Reshape around the final product surface.
   Prefer one clear component or flow over mode flags. Split only when it creates an obvious boundary such as state, layout, controls, or domain commands.

4. Move shared rules to one place.
   Feature flags, permissions, route gating, URL state, and command naming should not be duplicated across pages or hidden in view components.

5. Verify the intended flow.
   Test the new behavior and any deleted assumptions that affect navigation, permissions, or persisted state.

## Rules

- Optimize for the code that should exist, not the smallest diff from the old shape.
- Delete dead compatibility paths instead of making them better.
- Do not invent a generic framework for one feature.
- Keep the refactor scoped to what makes the final shape coherent.
- Prefer names that describe product intent over implementation history.

## Bora's adaptation for medical-research code

For analysis scripts and manuscript code, this skill maps as:

- **Intended end state in 1-2 sentences** = the methods-section paragraph this code corresponds to
- **Real callers** = which figure/table consumes this output; if no caller, the code is dead
- **Final product surface** = the published Methods section; reshape code to match how Methods will read
- **Shared rules in one place** = data loading, variable transformations, seed values
- **Verify intended flow** = compare table/figure output to the prior version; bit-identical or flag with explanation

Common medical-research tech debt this skill targets:
- Multiple `read_excel(...)` calls that should be one cached fixture
- Commented-out R blocks left over from a peer-review revision round
- `# TODO: switch to lme4` notes from 3 manuscripts ago
- Duplicate "cleaning" code in different notebooks for the same CSV
- Compatibility shims for an old patient-ID format that no longer exists
