---
name: ceddcozum-tools
description: Dispatch 33 pediatric clinical calculators from Bora's ceddcozum NPM CLI as agent-callable tools. Auxology/SDS, BMD/vBMD, blood pressure percentiles, steroid conversion, HbA1c↔glucose, insulin resistance, growth-hormone dosing, IGF SDS, thyroid volume SDS, and more. All calculations local; no network.
domain: coding
sub-category: personal
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
  fallback: qwen3.6:27b-q4_K_M
network: airgap-ok
inputs:
  type: object
  required: [tool]
  properties:
    tool: {type: string, description: "ceddcozum tool name (e.g. auxology, hba1c, bmd-sds). See ~/.agents/tools/ceddcozum-schemas.json for full list."}
    args: {type: object, description: "Arguments for the tool, per its schema"}
outputs:
  type: object
  properties:
    result: {type: object, description: "JSON output from ceddcozum"}
    tool: {type: string}
    duration_ms: {type: integer}
---

# ceddcozum Tools Wrapper

Exposes [ceddcozum](https://github.com/borean/ceddcozum) NPM package (v0.2.2, 33 calculators) as callable tools for the local Qwen.

## What it does

When the local model says "I need to compute the height SDS for a 5-year-old", this skill:
1. Looks up the right ceddcozum tool from the schemas dump (`~/.agents/tools/ceddcozum-schemas.json`)
2. Validates the model's arguments against the tool's JSON schema
3. Invokes `ceddcozum <tool> --args '<json>' --format json`
4. Returns the parsed result

All ceddcozum calculations run **locally** — no network, no API keys. The `--schemas` flag exists specifically to let LLM agents discover the toolkit at session start.

## The 33 tools (per `ceddcozum --list`)

**Growth**: auxology, height-velocity, predicted-height, igf-sds, body-ratios, cnp-analogue, growth-hormone, igf-lagh-adjustment
**Neonatal**: neonatal-parameters, corrected-age
**Bone & Mineral**: bmd-sds, corrected-bmd, tubular-function, phosphate-sds, klotho-sds, elemental-calcium
**Diabetes**: hba1c, insulin-resistance, insulin-cpeptide
**Puberty & Adrenal**: steroid-conversion, hcg-test
**Organ Size**: testicular-volume, penile-anthropometry, uterus-ovary-volume, thyroid-volume, pituitary-height
**Blood Pressure**: point-blood-pressure, abpm
**Miscellaneous**: decimal-age

## Procedure

1. Verify ceddcozum is installed: `which ceddcozum` (set up in Phase 5)
2. Read `~/.agents/tools/ceddcozum-schemas.json` to find the requested `tool` name
3. Validate `args` against the tool's input schema (JSON Schema validation)
4. Invoke: `ceddcozum <tool> --args '<json-of-args>' --format json`
5. Parse stdout as JSON; return as `result`
6. On error: capture stderr; surface to the agent with a structured error per Karpathy rule #12 (fail loud)

## Failure modes

- **ceddcozum not installed**: tell user to run `npm install -g ceddcozum`
- **Tool name not in schemas**: list the 33 valid names; do not silent-fallback
- **Args fail validation**: show which fields are missing/wrong-type; do not invoke with bad args
- **CLI exits non-zero**: surface stderr; common cause is age out of reference range
- **Output not parseable as JSON**: this shouldn't happen with `--format json`; if it does, treat as ceddcozum bug, log to `~/.research/lessons.md`

## Example invocations

```yaml
# Compute SDS for a 5.5-year-old boy
tool: auxology
args:
  sex: male
  age: 5.5
  height: 110
  weight: 19

# Result includes:
#   height_sds: 0.4
#   weight_sds: 0.1
#   bmi: 15.7
#   bmi_sds: -0.2
#   reference: "Neyzi 2015"
```

```yaml
# Convert HbA1c to estimated average glucose
tool: hba1c
args:
  hba1cPercent: 7.5

# Result includes:
#   eag_mg_dl: 169
#   eag_mmol_l: 9.4
#   ifcc_mmol_mol: 58.5
```

```yaml
# Compute blood pressure percentiles
tool: point-blood-pressure
args:
  sex: female
  age: 8
  height: 130
  systolic: 110
  diastolic: 70

# Result includes:
#   systolic_percentile: 75
#   diastolic_percentile: 60
#   classification: "Normal"
#   reference: "AAP 2017"
```

## Why this is a skill, not a hard-coded tool

Two reasons:
1. **Schema-driven dispatch** — the skill reads from `ceddcozum-schemas.json`, so when ceddcozum adds new calculators in a future release (`npm install -g ceddcozum@latest`), this skill picks them up automatically.
2. **Validation gate** — the skill validates args BEFORE invoking the CLI, so the agent gets fast structured errors instead of opaque CLI exit-1 messages. Important when the model is Qwen-class (not Opus-class) — bad tool calls fail loud instead of silently corrupting downstream skills.

## Plays well with

- `research/medical-domain/pediatric-references` — both consult Neyzi/WHO/CDC; ceddcozum-tools does the actual math, pediatric-references answers conceptual questions
- `research/statistics/data-dictionary` — when batch-processing a cohort CSV, call ceddcozum-tools per row for SDS computation
- `research/manuscript/draft-write` — when writing Methods, the model can compute exact SDS thresholds in real time and cite the underlying reference

## Local model constraint

Qwen 3.6 35B-A3B handles 33 tools easily within its tool-call schema. Listing all 33 in the system prompt adds ~3K tokens; we instead use **lazy-load**: only inject the schemas the user's session-mode probably needs. Default: include all Growth + Diabetes tools (most common); include others on-demand. The session-launch skill handles routing.

## Credit

- **ceddcozum NPM package** by [Bora Ulukapı](https://github.com/borean) — 33 pediatric clinical calculators, MIT/open-source, sponsored by Turkish Society for Pediatric Endocrinology and Diabetes (ÇEDD)
- Package treats LLM agents as a first-class consumer (the `--schemas` flag exists because Bora designed it that way)
