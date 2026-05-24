---
name: nature-figure
description: Emit Matplotlib code for Nature-journal panel layout. Multi-panel with shared legend. SVG + 300dpi PNG outputs. 8pt min font, Wong palette, OKLCH defaults.
domain: research
pillar: visualization
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
  fallback: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
---

# Nature Figure

Emit Matplotlib code for Nature-journal panel layout. Multi-panel with shared legend. SVG + 300dpi PNG outputs. 8pt min font, Wong palette, OKLCH defaults.

## Procedure

1. Validate inputs against the JSON schema in frontmatter
2. (Skill-specific procedure — see references/skill-libraries-survey.md and docs/skillset_v1.md / skillset_v2_additions.md for the full method)
3. Emit structured output per frontmatter `outputs:` schema
4. Append to session ledger via post-tool-audit-jsonl hook

## Design principles

Apply per `references/dataviz-principles.md`. Nature house style now trends Tufte-ward; these align rather than conflict:

- **T-B5 (strip non-data ink)** — no panel frames, no internal gridlines (or very light), no background fill, no drop shadows.
- **T-B4 (integrated panel letters)** — A / B / C inside the data area (top-left corner of each panel), bold, not as subplot titles floating above.
- **T-B3 (shared axes)** — when panels show the same units, share the y-axis (and x-axis where applicable); don't auto-scale per panel.
- **T-B6 (single encoding)** — don't double-encode a categorical variable with both color *and* marker shape *and* hatching. Pick one.
- **S-L4.1 (default to one color)** — only branch to a multi-color palette when a categorical dimension is explicitly passed. Single-color bars are the default.
- **S-L7 (active title scaffold)** — generate a title that states the panel's takeaway, not the variable being shown.

Keep the Nature requirements: 8 pt minimum font, Wong colorblind palette when categorical color is used, 300 dpi PNG + SVG outputs. See [references/dataviz-principles.md](../../../references/dataviz-principles.md).

## Failure modes

- Inputs malformed → reject with explicit schema error; do not silent-pass
- Required local cache/index missing → suggest the relevant setup or cron skill
- Model returns ill-formed structured output → retry once with stricter system prompt; if still fails, raise structured error (Karpathy rule #12)

## Example

(To be filled in with a concrete example during first invocation. The frontier-LLM-driven first-run will populate this.)

## Credit

From Yuan1z0825/nature-skills (4.5k stars). Adapted for clinical figures. Design principles per [references/dataviz-principles.md](../../../references/dataviz-principles.md).
