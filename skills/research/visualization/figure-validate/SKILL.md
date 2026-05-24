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

## Tufte + SwD audit (advisory pass)

Beyond the existing DPI / font / Turkish-char / Wong-palette checks, run this advisory pass and emit warnings (not failures). Cite each finding by code so the reader can look it up in `references/dataviz-principles.md`.

- **T-B1 (lie factor)** — detect bar charts whose y-axis lower bound is non-zero; flag `non-zero bar baseline`.
- **T-B5 (chartjunk-via-color)** — count distinct fill colors per panel; if `distinct_colors > categorical_dimensions_encoded`, flag `decorative color`.
- **T-B6 (pie/donut)** — detect circular slice geometry; flag `pie/donut chart — substitute bar`.
- **S-L2 (secondary y-axis)** — detect dual-y-axis (`twinx`); flag `dual axis — separate panels or compute a ratio`.
- **S-L7 (descriptive title)** — flag any panel title that is a noun phrase with no verb (e.g. "Treatment Modalities" → suggest active sentence carrying the takeaway).

Warning-only; the clinician decides what to act on. See [references/dataviz-principles.md](../../../references/dataviz-principles.md) for the full grading framework (9 Tufte criteria + 7 remedies + 6 SwD lessons).

## Failure modes

- Inputs malformed → reject with explicit schema error; do not silent-pass
- Required local cache/index missing → suggest the relevant setup or cron skill
- Model returns ill-formed structured output → retry once with stricter system prompt; if still fails, raise structured error (Karpathy rule #12)

## Example

(To be filled in with a concrete example during first invocation. The frontier-LLM-driven first-run will populate this.)

## Credit

Adapted from Bora's existing figure-pipeline skill. Air-gap subset. Tufte + SwD audit per [references/dataviz-principles.md](../../../references/dataviz-principles.md) (sources: Tufte VDQI 1983; Knaflic SwD 2015; encoding adapted from gnurio/tufte-vdqi-plugin MIT).
