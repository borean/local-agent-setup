---
name: figure-validate
description: Check exported figure: font ≥8pt, DPI ≥300 raster, no overlapping labels, color-blind safe (Wong simulation), Turkish character rendering (ı, ş, ğ, ç, ö, ü).
domain: research
pillar: visualization
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
  fallback: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
---

# Figure Validate

Check exported figure: font ≥8pt, DPI ≥300 raster, no overlapping labels, color-blind safe (Wong simulation), Turkish character rendering (ı, ş, ğ, ç, ö, ü).

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

Adapted from Bora's existing figure-pipeline skill. Air-gap subset.
