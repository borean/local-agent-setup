---
name: forest-plot
description: Meta-analysis forest plot — pooled effect, CI, weights, heterogeneity (I², τ²), Egger test if n>10.
domain: research
pillar: visualization
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
  fallback: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
---

# Forest Plot

Meta-analysis forest plot — pooled effect, CI, weights, heterogeneity (I², τ²), Egger test if n>10.

## Procedure

1. Validate inputs against the JSON schema in frontmatter
2. (Skill-specific procedure — see references/skill-libraries-survey.md and docs/skillset_v1.md / skillset_v2_additions.md for the full method)
3. Emit structured output per frontmatter `outputs:` schema
4. Append to session ledger via post-tool-audit-jsonl hook

## Design principles

Forest plots are already pretty Tufte-aligned; these refinements apply per `references/dataviz-principles.md`:

- **T-B2 (range frame on effect axis)** — trim the effect axis to the actual study CI range (don't pad to a round symmetric range like ±5 if data only spans -1 to +2). Mark the null effect line.
- **T-B5 (minimal non-data ink)** — no internal gridlines; only the null effect reference line and the axis itself.
- **T-B4 (direct study labels)** — confirm each row already has its study label adjacent (not in a remote key). Standard `metafor` output already does this.
- **T-B3 (small multiples for subgroups)** — when running subgroup analyses, prefer side-by-side forest plots with a shared effect axis over a single forest with subgroup-grouped rows (better visual separation).
- **S-L7 (active title)** — title carries the pooled effect and inference: "Treatment reduced HbA1c by -0.6% (95% CI -0.8 to -0.4); I² = 32%" not "Forest Plot of HbA1c Outcomes."

Keep the meta-analysis conventions: pooled diamond, weights, heterogeneity stats (I², τ²), Egger asymmetry plot if n ≥ 10. See [references/dataviz-principles.md](../../../references/dataviz-principles.md).

## Failure modes

- Inputs malformed → reject with explicit schema error; do not silent-pass
- Required local cache/index missing → suggest the relevant setup or cron skill
- Model returns ill-formed structured output → retry once with stricter system prompt; if still fails, raise structured error (Karpathy rule #12)

## Example

(To be filled in with a concrete example during first invocation. The frontier-LLM-driven first-run will populate this.)

## Credit

Wraps R `metafor` package. Output: ggplot2 + numeric summary. Design principles per [references/dataviz-principles.md](../../../references/dataviz-principles.md).
