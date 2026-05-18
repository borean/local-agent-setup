---
name: devils-advocate
description: Pre-submission stress test. Phase 1 generates hostile-reviewer attacks on every claim. Phase 2 CALIBRATES the attack pattern against the user's 5 accepted papers (measures recall/precision) before trusting it on the new manuscript. DEFERRABLE — first-paper users get an uncalibrated mode + reminder.
domain: research
pillar: peer-review
user-invocable: true
optional: true
deferrable: true
target_models:
  primary: qwen3.6:27b-q4_K_M
  fallback: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
inputs:
  type: object
  required: [manuscript_path]
  properties:
    manuscript_path: {type: string}
    calibration_corpus: {type: array, items: {type: string}, description: "Paths to 5 of YOUR accepted papers (optional — if absent, runs uncalibrated)"}
    mode: {type: string, enum: [calibrated, uncalibrated, defer], default: calibrated}
outputs:
  type: object
  properties:
    attacks: {type: array, items: {type: object}}
    calibration: {type: object, properties: {recall: {type: number}, precision: {type: number}, verdict: {type: string}}}
    mode_used: {type: string}
---

# Devil's Advocate

Hostile-reviewer simulation. The two-phase design (attack + calibration) is what makes it trustworthy.

See [references/devils-advocate-explained.md](../../../../references/devils-advocate-explained.md) for the plain-language explainer.

## Three modes

### Mode 1: `calibrated` (default — for users with ≥5 accepted papers)

**Phase 1 — Attack**

Read the new manuscript + abstract. For each major claim, generate the strongest possible attack: methodology objections, alternative explanations, missing controls, statistical objections, generalizability limits.

Output per claim:
```yaml
claim: "GLP-1 treatment improved HbA1c by 0.8% at 12 weeks (p<0.001)"
attack: "Without a placebo arm, the 0.8% reduction is consistent with regression to the mean..."
severity: high
suggested_defense: "Add power calculation showing detectable effect size; cite natural-history HbA1c..."
```

**Phase 2 — Calibrate**

Run the same attack pattern against 5 of the user's already-accepted papers. For each:
- Find the actual reviewer reports (if the user provided them)
- OR infer what reviewers probably flagged (changes between submitted and accepted versions)
- Compare model-predicted attacks to actual reviewer concerns

Measure:
- **Recall** = (model-predicted attacks matching real reviewer concerns) / (all real reviewer concerns)
- **Precision** = (model-predicted attacks matching real concerns) / (all model-predicted attacks)

Thresholds:
- Recall ≥0.5 AND Precision ≥0.7 → verdict: USABLE
- Below either → verdict: NOT YET TRUSTWORTHY → iterate attack-generation prompt OR enrich calibration corpus

### Mode 2: `uncalibrated` (for first-paper users — or when no time for calibration)

Phase 1 only. Skip calibration.

Output is the attack list with an explicit caveat header:

```markdown
⚠️ UNCALIBRATED RUN
This Devil's Advocate output has NOT been calibrated against your accepted papers
(you have none yet, or you chose to skip).

What this means:
- The attacks below are based on generic clinical-research methodology critiques
- We don't know how this skill performs on your specific writing style
- Treat as a checklist, not a verdict

Recommended: when your first paper IS accepted, return here and run --mode calibrated
with that paper as the corpus seed (n=1 is better than n=0).
```

In `uncalibrated` mode, the attack prompt is built from a generic-reviewer corpus:
- Cochrane methodological critiques (open)
- Common Reviewer 2 patterns from STROBE/CONSORT supplementary materials
- EQUATOR Network reporting guidelines

### Mode 3: `defer` (skip entirely for now)

No-op. A reminder fires on every 20th session-launch:
```
ℹ️ Devil's Advocate skill deferred. Run `devils-advocate --mode uncalibrated` for
   a quick critique baseline (works without a paper corpus), or wait until your
   first paper is accepted for full calibration.
```

## Adding to the calibration corpus over time

Each new accepted paper of yours:
1. Place in `~/.agents/state/devils-advocate-corpus/{paper-id}/paper.md`
2. If you have the reviewer reports: `~/.agents/state/devils-advocate-corpus/{paper-id}/reviewer-comments.md`
3. Re-run calibration: `devils-advocate --mode calibrated --recalibrate-only`

After 3 papers in corpus: minimum viable (high variance estimates)
After 5 papers: solid (default threshold)
After 10 papers: very reliable
After 20 papers: stop adding; marginal gain is negligible

## What we deliberately don't do

- Don't generate attacks on co-author work without their knowledge (it's your manuscript, not theirs)
- Don't auto-apply suggested defenses (just suggest)
- Don't store reviewer reports outside the air-gapped corpus (they may identify reviewers)
- Don't use rejection letters as calibration corpus (rejection has venue-fit reasons beyond manuscript quality)

## Failure modes

- **<3 calibration papers**: refuse `calibrated` mode; offer `uncalibrated` with explicit caveat
- **Calibration corpus all from same journal**: warn; biases toward that journal's reviewer style
- **Reviewer reports absent**: degrade gracefully — use heuristics (diff between submitted and accepted) instead
- **Manuscript still in early-draft state**: skill warns it's too early (claims aren't stable); suggest waiting until feature-complete draft

## When to fire

- 2-3 days before submission, on a feature-complete draft
- Before pre-print posting
- When a co-author says "looks good to me" — exactly when you want a hostile read
- NEVER on first-draft state (claims aren't formed yet)

## Example invocations

```
# Established researcher with corpus
$ devils-advocate --manuscript ~/Research/glp1-paper/draft-v4.md \
                  --calibration-corpus ~/Research/my-accepted/*.pdf

Calibrating against 5 accepted papers... done.
  Recall:    0.62   (caught 62% of real reviewer concerns)
  Precision: 0.78   (78% of generated attacks matched a real weakness)
  Verdict:   USABLE
  Caveat:    misses ~38% of real concerns; supplement, don't replace, human pre-read

Running attacks on draft-v4.md... 14 attacks generated.
Written to: ~/Research/glp1-paper/devils-advocate-attacks.md
```

```
# First-paper user
$ devils-advocate --manuscript ~/Research/my-first-paper/draft.md --mode uncalibrated

⚠️ UNCALIBRATED RUN — generating generic-reviewer attacks...
12 attacks generated. Treat as checklist, not verdict.
After acceptance, return and run --mode calibrated for personalized critique.
```

```
$ devils-advocate --mode defer
Devil's Advocate deferred. Reminder every 20 session-launches.
```

## Credit

Two-phase calibrated-attack pattern from [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills). Cherry-picked May 14-15, 2026 as one of the 6 must-grabs. Uncalibrated mode + defer mode + generic-reviewer corpus are our additions for first-paper users.
