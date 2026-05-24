---
name: km-curve
description: Survminer/ggsurvfit-style Kaplan-Meier curve with at-risk table, log-rank p, median survival annotation.
domain: research
pillar: visualization
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
  fallback: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
---

# Km Curve

Survminer/ggsurvfit-style Kaplan-Meier curve with at-risk table, log-rank p, median survival annotation.

## Procedure

1. Validate inputs against the JSON schema in frontmatter
2. (Skill-specific procedure — see references/skill-libraries-survey.md and docs/skillset_v1.md / skillset_v2_additions.md for the full method)
3. Emit structured output per frontmatter `outputs:` schema
4. Append to session ledger via post-tool-audit-jsonl hook

## Design principles

Apply per `references/dataviz-principles.md`:

- **T-B4 (direct labels)** — label each group's survival curve at its right-hand endpoint in the group's color. Delete the legend box. Especially impactful for KM, where legends are notoriously bad.
- **T-B2 (range frame)** — trim the time axis to the actual observed follow-up (don't pad to a round number); trim the survival axis tight if the lowest curve doesn't approach 0.
- **T-B5 (light CI bands)** — confidence bands at low alpha (e.g., 0.15); don't let them compete visually with the curves.
- **T-B3 (small multiples)** — for subgroup KMs (sex × treatment, age tertiles), prefer faceted small multiples with shared axes over one overcrowded chart.
- **S-L7 (active title)** — title carries the takeaway: "Median survival 24 vs 38 mo (HR 1.8, log-rank p = 0.01)" not "Overall Survival by Treatment."

Keep the clinical conventions: at-risk table beneath, log-rank p, median survival annotation, censoring tick marks. See [references/dataviz-principles.md](../../../references/dataviz-principles.md) for the full framework.

## Failure modes

- Inputs malformed → reject with explicit schema error; do not silent-pass
- Required local cache/index missing → suggest the relevant setup or cron skill
- Model returns ill-formed structured output → retry once with stricter system prompt; if still fails, raise structured error (Karpathy rule #12)

## Example

(To be filled in with a concrete example during first invocation. The frontier-LLM-driven first-run will populate this.)

## Credit

Wraps R `ggsurvfit` and `survminer`. Design principles per [references/dataviz-principles.md](../../../references/dataviz-principles.md).
