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

## Failure modes

- Inputs malformed → reject with explicit schema error; do not silent-pass
- Required local cache/index missing → suggest the relevant setup or cron skill
- Model returns ill-formed structured output → retry once with stricter system prompt; if still fails, raise structured error (Karpathy rule #12)

## Example

(To be filled in with a concrete example during first invocation. The frontier-LLM-driven first-run will populate this.)

## Credit

From Yuan1z0825/nature-skills (4.5k stars). Adapted for clinical figures.
