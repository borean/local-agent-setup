---
name: chart-spec
description: Given data + question, recommend chart type (bar/box/violin/forest/KM/Sankey/raincloud) with rationale, axes, palette.
domain: research
pillar: visualization
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
  fallback: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
---

# Chart Spec

Given data + question, recommend chart type (bar/box/violin/forest/KM/Sankey/raincloud) with rationale, axes, palette.

## Procedure

1. Validate inputs against the JSON schema in frontmatter
2. (Skill-specific procedure — see references/skill-libraries-survey.md and docs/skillset_v1.md / skillset_v2_additions.md for the full method)
3. Emit structured output per frontmatter `outputs:` schema
4. Append to session ledger via post-tool-audit-jsonl hook

## Design principles

Bias recommendations per `references/dataviz-principles.md`:

- **T-B6**: prefer Cleveland dot plots over bars when values cluster near the floor; avoid pie / donut for >2 slices; never 3-D.
- **T-B3 + S-L2**: prefer small multiples over grouped/stacked bars when comparing more than 3 series across categories; never secondary y-axis (separate panels or ratio instead).
- **T-B5**: if the recommended chart has one categorical dimension, recommend one color — color is information, not decoration.
- **S-L1**: ask the user *what action* the chart needs to support before recommending a type. A chart with no action behind it is decoration.

See [references/dataviz-principles.md](../../../references/dataviz-principles.md) for the full chart-type table and rationale.

## Failure modes

- Inputs malformed → reject with explicit schema error; do not silent-pass
- Required local cache/index missing → suggest the relevant setup or cron skill
- Model returns ill-formed structured output → retry once with stricter system prompt; if still fails, raise structured error (Karpathy rule #12)

## Example

(To be filled in with a concrete example during first invocation. The frontier-LLM-driven first-run will populate this.)

## Credit

Synthesis of Tufte + Knaflic + Junk Charts principles. Full framework in [references/dataviz-principles.md](../../../references/dataviz-principles.md).
