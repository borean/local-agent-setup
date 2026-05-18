# First-Paper Onboarding

For users writing their first manuscript. Read this once, then forget — the skills handle the rest.

---

## You don't have a corpus yet. That's OK.

Two of our skills calibrate against your already-published work:

- `style-calibration` — extracts a voice profile from your 3-5 own papers
- `devils-advocate` — calibrates a hostile-reviewer attack against your 5 accepted papers

If you have **zero published papers**, neither skill can fully calibrate. We handle this gracefully:

| Skill | First-paper option | What happens |
|---|---|---|
| `style-calibration` | `--mode generic --field "<your field>"` | Loads a generic field-specific voice baseline. Run again with `--mode calibrate` once your first paper is accepted. |
| `style-calibration` | `--mode defer` | No voice profile loaded. Manuscript-writing skills proceed with Karpathy 12-rules + air-gap preamble only. Reminder every 10 sessions. |
| `devils-advocate` | `--mode uncalibrated` | Generates attacks using Cochrane/STROBE/CONSORT generic-reviewer patterns. Stamped with explicit caveat. |
| `devils-advocate` | `--mode defer` | Skip entirely. Reminder every 20 sessions. |

## The pipeline still works without a corpus

The `clinical-data-to-manuscript` orchestrator (15 phases) checks `first_paper: true` and:

- Forces guided mode (slower, more explanation)
- Phase 11 (draft-write) auto-runs `style-calibration --mode generic` if no voice profile exists
- Phase 14 (devils-advocate) auto-runs in `uncalibrated` mode if no corpus
- Adds gentle reminders about the eventual switch to calibrated mode

Everything else runs normally.

## What to expect

A typical first manuscript takes 12-25 hours of actual work, spread across multiple sessions. That's NOT a software speed limit — it's a research-quality requirement. The skills are designed to slow you down at the right moments (analysis plan, claim verification, anti-leakage) and speed you up at the right moments (drafting, formatting, citation).

Expected session breakdown:
- Session 1 (2-3 hours): Pre-flight + data dictionary + statistical test picker + analysis plan
  → Major breakpoint, passport emitted
- Session 2 (3-4 hours): Power analysis + analysis run + result interpretation + Table 1
  → Major breakpoint, passport emitted
- Session 3 (2-3 hours): Figures (chart-spec, palette, individual figures, validation)
  → Major breakpoint, passport emitted
- Session 4-5 (4-6 hours): Outline + drafting all sections
  → Major breakpoint, passport emitted
- Session 6 (1-2 hours): Claim-check + anti-leakage + writing-quality-check
  → Major breakpoint, passport emitted
- Session 7 (1-2 hours): PRISMA-trAIce + ROB-2/GRADE (if applicable) + Devil's Advocate (uncalibrated for you)
  → Final breakpoint
- Session 8 (1 hour): Peer-review-checklist final gate, submission package

You can resume from any breakpoint via the passport hash.

## What to skip until later

Don't try to use these on your first paper:

- `score-trajectory` — needs ≥3 versions of the manuscript; will activate naturally as you revise
- `response-to-reviewer` — only relevant after submission and revision request
- `style-calibration --mode calibrate` — wait until acceptance
- `devils-advocate --mode calibrated` — wait until acceptance

## After your first acceptance

Congrats. Now:

1. Place the accepted paper in `~/.agents/state/devils-advocate-corpus/{paper-id}/paper.md`
2. Place the reviewer reports (if you have them) in `~/.agents/state/devils-advocate-corpus/{paper-id}/reviewer-comments.md`
3. Run `style-calibration --mode calibrate --papers <path-to-accepted-paper>` (yes, n=1 is fine to start)
4. Run `devils-advocate --mode calibrated --recalibrate-only` to seed the calibration corpus

The model now starts learning your voice and your reviewer patterns. After 3 acceptances: solid calibration. After 5: full default behavior. After 10: very reliable.

## Things you should NOT do as a first-paper user

- **Don't delegate the research question** — the skill helps you sharpen it, but it must be yours
- **Don't skip the data-dictionary phase** — even if you "know your data," the skill catches typos and out-of-range values you missed
- **Don't accept the first draft** — every drafted section should be read line-by-line on your end
- **Don't paste raw patient data into prompts** — the air-gap protects you technically, but copy-paste into co-author email/slides is the real leak vector (see `output-scrub`)
- **Don't skip claim-check** — open-weight models hallucinate citations more than frontier; the skill is your safety net

## Resources we ship for first-paper users

- This document (`references/first-paper-onboarding.md`)
- `references/colleague-onboarding-tutorial.md` — broader Hermes-Desktop tutorial
- `references/compliance-primer.md` — what KVKK/GDPR/HIPAA actually require
- `references/devils-advocate-explained.md` — plain-language explainer
- All the SKILL.md files have `## Failure modes` sections — read those, they're the cheap lessons

## When to ask for help

- Stuck on a phase for >2 hours: emit a passport, take a break, ask a colleague (human, not model)
- Skill keeps failing the same way: it's probably an input issue (file path, data format, malformed JSON); check the audit log
- Model output feels off-tone: switch from `--mode generic` to a different `--field` baseline, or supply 1-2 papers from your supervisor as a stand-in calibration corpus
- KVKK/IRB question: this stack helps with the technical control; it does not replace your DPO and IRB

---

## Credit

Workflow expectations calibrated from typical first-manuscript timeline observations across endocrinology, internal medicine, and pediatrics training programs. The 12-25 hour estimate is a rough mean from informal trainee feedback over years — not an empirical study. Yours may vary widely.

The "defer / generic / calibrated" three-mode pattern for first-paper users is our extension of the ARS calibration framework.
