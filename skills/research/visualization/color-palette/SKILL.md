---
name: color-palette
description: Generate project-wide palette in OKLCH + RGB + HEX. Harmonized via OKLCH hue rotation. Color-blind validated (Wong test). Semantic roles. Exports: ggplot scales + matplotlib cycler + CSS.
domain: research
pillar: visualization
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
  fallback: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
---

# Color Palette

Generate project-wide palette in OKLCH + RGB + HEX. Harmonized via OKLCH hue rotation. Color-blind validated (Wong test). Semantic roles. Exports: ggplot scales + matplotlib cycler + CSS.

## Procedure

1. Validate inputs against the JSON schema in frontmatter
2. (Skill-specific procedure — see references/skill-libraries-survey.md and docs/skillset_v1.md / skillset_v2_additions.md for the full method)
3. Emit structured output per frontmatter `outputs:` schema
4. Append to session ledger via post-tool-audit-jsonl hook

## Design principles

Wong's colorblind-safe palette stays the categorical default. On top of that, apply per `references/dataviz-principles.md`:

- **T-B5 + S-L4.1**: color is information, not decoration. If the chart has N categories and color encodes nothing additional, the palette of choice is **one muted color** (or one accent + gray rest), not Wong's full 8-color set. Reserve the full palette for genuine categorical encoding.
- **S-L4 (strategic color)**: when emphasizing one group as the story, recommend gray for everything else and one accent color for the focus group — even if the full Wong palette is technically available.
- **Sequential / ordinal data** (e.g., ordered Likert, age tertiles, severity grades): use a sequential gradient (light → dark) rather than the categorical Wong palette. A natural order deserves a perceptually ordered ramp.

The Wong/OKLCH machinery underneath doesn't change — it's the *recommendation defaults* that shift. See [references/dataviz-principles.md](../../../references/dataviz-principles.md) for the framework.

## Failure modes

- Inputs malformed → reject with explicit schema error; do not silent-pass
- Required local cache/index missing → suggest the relevant setup or cron skill
- Model returns ill-formed structured output → retry once with stricter system prompt; if still fails, raise structured error (Karpathy rule #12)

## Example

(To be filled in with a concrete example during first invocation. The frontier-LLM-driven first-run will populate this.)

## Credit

Emil Kowalski (Agents with Taste) + @pie6k OKLCH + Bang Wong (Nature Methods 2011). One-shot setup skill per project. Design principles per [references/dataviz-principles.md](../../../references/dataviz-principles.md).
