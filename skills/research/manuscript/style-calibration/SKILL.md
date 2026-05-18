---
name: style-calibration
description: USER-ONBOARDING SKILL. Extract a 6-dim voice profile from the user's 3-5 own past papers. Output a system-prompt fragment loaded by all downstream writing skills. DEFERRABLE — first-paper users can skip with a generic baseline.
domain: research
pillar: manuscript
user-invocable: true
optional: true
deferrable: true
target_models:
  primary: qwen3.6:27b-q4_K_M
  fallback: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
inputs:
  type: object
  properties:
    papers: {type: array, items: {type: string}, description: "Paths to 3-5 of YOUR own published papers (PDF/Word/Markdown)"}
    mode: {type: string, enum: [calibrate, generic, defer], default: calibrate}
    field: {type: string, description: "If mode=generic, your field e.g. 'pediatric endocrinology'"}
outputs:
  type: object
  properties:
    voice_profile_path: {type: string}
    mode_used: {type: string}
    dimensions: {type: object}
---

# Style Calibration

Personalizes the local model's writing voice to match yours. Loaded as part of the system prompt by every manuscript-writing skill.

## Three modes

### Mode 1: `calibrate` (default — for users with ≥3 published papers)

Read 3-5 of YOUR own published papers. Extract a 6-dimensional voice profile:

1. **Formality** — passive vs active voice ratio; nominalization rate; "we" vs "the authors"
2. **Sentence-length variance** — short-short-long rhythm pattern, mean, SD
3. **Jargon density** — domain-specific term frequency normalized to general medical baseline
4. **Hedging frequency** — "may suggest" / "could indicate" rate per 1000 words
5. **Citation density** — citations per paragraph; in-text vs sentence-end placement
6. **Language code-switch ratio** — for bilingual users, TR↔EN switching patterns

Write `~/.agents/system-prompts/{username}-voice.md` as a prompt fragment:

```markdown
## Voice profile — {username}

When drafting manuscript sections for this user, match these patterns:

- Active voice preferred (your active:passive ratio is 2.1:1; mean across endocrinology is 1.3:1)
- Sentence length: mean 24 words, SD 11. Mix short declarative + longer qualified.
- Hedging: 4-6 per 1000 words. Default to "suggests" not "demonstrates".
- Citations: end-of-sentence, Vancouver style.
- Code-switch: avoid Turkish in English drafts unless quoting; use Turkish patient-facing summaries.
- Avoid these patterns the user historically rejects in peer review:
  {extracted from rejection signals — placeholder}
```

### Mode 2: `generic` (for first-paper users, or those who explicitly opt out of calibration)

Skip the corpus pass. Use a generic clinical-research voice baseline for `{field}`:

- For pediatric endocrinology: ESPE Yearbook + JCEM style
- For oncology: Lancet Oncology style
- For internal medicine: NEJM style
- For surgery: Annals of Surgery style

Write `~/.agents/system-prompts/{username}-voice.md` with the generic profile and a notice:

```markdown
## Voice profile — {username} (GENERIC BASELINE for {field})

You haven't run calibrate mode yet. This is a domain-typical baseline.
After your first paper is accepted, re-run style-calibration in calibrate mode
with that paper to start personalizing.
```

### Mode 3: `defer` (skip entirely for now)

No voice profile loaded. Writing skills proceed with system prompt = Karpathy 12-rules + air-gap preamble only.

A reminder fires on every 10th session-launch:
```
ℹ️  Style calibration deferred. Run `style-calibration --mode generic --field <your-field>`
   for an immediate baseline, or `--mode calibrate --papers <paths>` once you have papers.
```

## When to (re-)calibrate

- After your first paper is accepted → switch from `defer`/`generic` to `calibrate`
- After 5 new acceptances → add them to corpus and re-run
- After any significant shift in your writing style (new co-author, new journal)
- After upgrading the local model (Qwen 3.6 → 3.7 someday)

## What we deliberately don't do

- Don't try to mimic style from drafts (only accepted/published versions count)
- Don't average across different journals — each journal has its own register
- Don't include reviewer-rewrites as ground truth (they're the reviewer's voice, not yours)

## Failure modes

- **<3 papers provided in calibrate mode**: skill suggests `generic` mode instead; doesn't force fewer-than-3 calibration (unreliable)
- **Papers in unsupported format**: extract via `pdf` or `docling` skill first, then retry
- **Field not in `generic` mode preset list**: skill asks user for their preferred journal style template
- **Calibration produces flat profile** (all dimensions near population mean): warn user; profile loaded but voice gain is minimal

## Example

```
# First-time user, has 4 papers
$ style-calibration --mode calibrate --papers ~/Research/my-papers/{paper1,paper2,paper3,paper4}.pdf

Calibrating from 4 papers (12,847 words)...
  Formality:         active:passive 2.3:1  (above field median)
  Sentence length:   mean 26 words, SD 12  (longer than median; complex syntax)
  Hedging:           4.8/1000 words        (typical for clinical research)
  Citation density:  8.2 per paragraph     (high; you cite densely)
  Code-switch:       0.3% (English-dominant, occasional Turkish patient quotes)

Written: ~/.agents/system-prompts/voice.md
Future drafts will match this profile.
```

```
# First-paper user
$ style-calibration --mode generic --field "pediatric endocrinology"

Loading generic pediatric-endocrinology baseline (ESPE Yearbook + JCEM)...
Written: ~/.agents/system-prompts/{username}-voice.md (generic mode)

⚠️ After your first paper is accepted, re-run with --mode calibrate to personalize.
```

```
# Wants to defer entirely
$ style-calibration --mode defer

Voice profile deferred. Will remind every 10 session-launches.
```

## Credit

From [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills) (the ARS repo). Cherry-picked May 14-15, 2026 as one of the 6 must-grabs. Generic-mode fallback and defer mode are our additions for first-paper users.
