# Devil's Advocate — plain language explainer

The `devils-advocate` skill is a pre-submission stress test for manuscripts (or grant applications, or any high-stakes document).

It does two things:

## 1. Attack mode

Read your manuscript + abstract. Generate the strongest possible attack on each claim. Like a hostile journal reviewer at their worst — not "this is fine" but "here is exactly what I will object to."

Output is a list:
```
Claim: "GLP-1 treatment improved HbA1c by 0.8% at 12 weeks (p<0.001)"
Attack: "The 0.8% reduction is within published placebo response range for adolescents (Smith 2024). Without a placebo arm or active comparator, this is consistent with regression to the mean."
Severity: high
Suggested defense: add power calculation showing detectable effect size; cite the natural-history HbA1c trajectory; if observational, run propensity score sensitivity analysis.
```

## 2. Calibration mode (the part that makes it trustworthy)

Before you trust the attacks on your NEW manuscript, the skill runs the same attack pattern against 5 of your **already-accepted** papers — papers you know are publishable.

For each of those 5, it measures:

- **Recall (sensitivity)**: of the issues the reviewers actually raised, what fraction did this skill predict?
- **Precision**: of the attacks this skill generated, what fraction matched a real reviewer concern (or a substantive weakness)?

Then it reports back:

```
Calibration over 5 accepted papers:
  Recall:    0.62  (caught 62% of real reviewer concerns)
  Precision: 0.78  (78% of generated attacks matched a real weakness)
  Verdict:   USABLE — recall above 0.5 threshold, precision above 0.7
  Caveat:    skill misses ~38% of real concerns; treat as supplement, not replacement, for human pre-read
```

Or it reports:

```
Calibration over 5 accepted papers:
  Recall:    0.31
  Precision: 0.45
  Verdict:   NOT YET TRUSTWORTHY — recall and precision both below threshold
  Action:    iterate on the attack-generation prompt OR add domain-specific examples to the calibration corpus before relying on this skill
```

## Why both modes

Without calibration, you don't know if the model is too lenient (misses real problems) or too paranoid (generates noise). Either way, you waste your time.

With calibration, you know **exactly how trustworthy** the attacks are. You read them with the right level of skepticism.

## What you need to provide once at setup

5 of your already-accepted papers, with the reviewer reports if you have them. The skill stores:

```
~/.agents/state/devils-advocate-calibration/
  {paper-id}/
    paper.md              ← the accepted version
    reviewer-comments.md  ← if you have the actual reviewer reports (optional but better)
    annotations.md        ← labels for what the reviewers actually flagged (optional)
```

If you only have the papers and not the reviewer reports, the skill works with a degraded calibration — it uses heuristics to identify what the reviewers *probably* flagged (changes between submitted and accepted versions, citations added, methods sections revised).

## When to recalibrate

- After 12 months
- After 5 new acceptances (add them to the corpus)
- After a substantive change to the manuscript-write or claim-check skills
- After upgrading the model (Qwen 3.6 → 3.7 someday)

## When NOT to use it

- First draft — too early, you don't have a coherent argument yet
- Reviewer-response stage — there you want the response-to-reviewer skill, not Devil's Advocate
- Conference abstracts — overkill

## When to use it

- 2-3 days before submission, after the manuscript is feature-complete
- Before pre-print posting
- When a co-author says "this is great" — that's exactly when you want a hostile read

---

## Credit

The Devil's Advocate + Calibration Mode pattern is from [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills) (the "ARS" repo). We surfaced it as one of 6 must-grabs during the May 14-15, 2026 evaluation session.
