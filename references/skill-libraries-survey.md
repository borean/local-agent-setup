# Skill Library Survey — What We Cherry-Pick

Survey of the major open-source SKILL.md libraries (May 2026) and which ones we lift for the air-gapped medical research bundle.

---

## Sources surveyed

| Library | Owner | Stars | Format | Notes |
|---|---|---|---|---|
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | Addy Osmani (Google Chrome team) | **43,273** | SKILL.md | 23 production engineering skills, Google best-practice flavored |
| [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) | forrestchang | **48,965** | CLAUDE.md single file | The 12-rule baseline, already pulled |
| [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills) | Imbad | 6,951 | SKILL.md + orchestrator | The ARS framework, Material Passport, Devil's Advocate, etc. |
| [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | Vercel Labs | n/a | SKILL.md | Official Vercel react/web skills |
| [mattpocock/skills](https://github.com/mattpocock/skills) | Matt Pocock | n/a | SKILL.md | 10 engineering skills + others |
| [shadcn-ui/ui/skills/shadcn](https://github.com/shadcn-ui/ui/tree/main/skills/shadcn) | shadcn | (part of ui repo) | SKILL.md | The shadcn CLI v4 skill |
| [anthropics/skills](https://github.com/anthropics/skills) | Anthropic | (official) | SKILL.md | The format spec authors |
| [Yuan1z0825/nature-skills](https://github.com/Yuan1z0825/nature-skills) | Yuan1z0825 | 4,500 | SKILL.md | 7 Nature-journal skills (figure, polishing, citation) |
| [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) (skills hub) | Nous Research | 156,000 | SKILL.md | Self-evolving skill creation + agentskills.io public hub |

---

## Cherry-picks — what we LIFT into `skills/coding/` and `skills/research/`

### From addyosmani/agent-skills (Google) — pull 9 of 23

The list:
```
api-and-interface-design        ❌ skip — not relevant for medical research
browser-testing-with-devtools   ❌ skip — air-gap
ci-cd-and-automation            ❌ skip — air-gap
code-review-and-quality         ✅ PULL → skills/coding/
code-simplification             ✅ PULL → skills/coding/ (pairs with zero-tech-debt)
context-engineering             ✅ PULL → skills/meta/ (core)
debugging-and-error-recovery    ✅ PULL → skills/coding/
deprecation-and-migration       ❌ skip
documentation-and-adrs          ✅ PULL → skills/meta/
doubt-driven-development        ✅ PULL → skills/coding/ (interesting alt to TDD)
frontend-ui-engineering         ❌ skip — Bora has his own data-viz skill
git-workflow-and-versioning     ❌ skip — colleagues don't use git
idea-refine                     ✅ PULL → skills/meta/ (hypothesis refinement)
incremental-implementation      ✅ PULL → skills/coding/
interview-me                    ❌ skip
performance-optimization        ❌ skip — local model inference is fixed
planning-and-task-breakdown     ✅ PULL → skills/meta/ (pairs with analysis-plan)
security-and-hardening          ❌ skip — air-gap is our hardening
shipping-and-launch             ❌ skip — manuscript = shipping for us
source-driven-development       ❌ skip
spec-driven-development         ✅ PULL → skills/meta/ (pairs with manuscript outline)
test-driven-development         ✅ PULL → skills/coding/ (replace v1 placeholder)
using-agent-skills              ❌ skip — meta about skills, redundant for us
```

**9 pulls**: code-review-and-quality, code-simplification, context-engineering, debugging-and-error-recovery, documentation-and-adrs, doubt-driven-development, idea-refine, incremental-implementation, planning-and-task-breakdown, spec-driven-development, test-driven-development.

(That's actually 11 — I changed mind on doubt-driven-development and documentation-and-adrs being important for research code-and-paper workflows.)

### From mattpocock/skills/engineering — pull 4 of 10

```
diagnose                          ✅ PULL → skills/coding/ — debugging analysis failures
grill-with-docs                   ✅ PULL → skills/literature/ — interrogate docs/papers to find gaps
improve-codebase-architecture     ✅ PULL → skills/coding/ — for the local-agent-setup repo itself
prototype                         ❌ skip — overlaps with idea-refine
setup-matt-pocock-skills          ❌ skip — meta
tdd                               ❌ skip — addyosmani's is more thorough
to-issues                         ❌ skip — no GitHub issues air-gapped
to-prd                            ❌ skip
triage                            ✅ PULL → skills/meta/ — useful for prioritizing tasks
zoom-out                          ✅ PULL → skills/meta/ — when you're stuck in the weeds
```

**5 pulls**: diagnose, grill-with-docs, improve-codebase-architecture, triage, zoom-out.

### From vercel-labs/agent-skills — pull 4 of 7

```
composition-patterns              ✅ PULL → skills/coding/ — generic React composition
deploy-to-vercel                  ❌ skip — air-gap
react-best-practices              ✅ PULL → skills/coding/ — Bora vibes React
react-native-skills               ❌ skip — no mobile
react-view-transitions            ✅ PULL → skills/visualization/ — for decks-bora animations
vercel-cli-with-tokens            ❌ skip — air-gap
web-design-guidelines             ✅ PULL → skills/visualization/ — Vercel design rules, pairs with Bora's data-viz upgrade
```

**4 pulls**: composition-patterns, react-best-practices, react-view-transitions, web-design-guidelines.

### From shadcn-ui/ui/skills/shadcn — pull 1

```
shadcn (the CLI v4 skill)         ✅ PULL → skills/coding/ — useful for decks-bora UI components
```

### From Imbad0202/academic-research-skills — already absorbed into skillset_v2_additions

Material Passport, Anti-Leakage, Style Calibration, Score Trajectory, Devil's Advocate, 7-Mode Failure Check, PRISMA-trAIce, Two-Phase Generator-Evaluator, Pipeline State Machine — already part of v2 spec.

### From Yuan1z0825/nature-skills — already absorbed into Pillar 5

nature-figure → Skill #30 (already in v2 viz)

### From Anthropic skills (official) — selectively

We already use the format spec. Their actual reference skills (`pdf`, `docx`, `xlsx`, `pptx`, `skill-creator`, `setup-cowork`, `consolidate-memory`) — Bora already has these via the anthropic-skills marketplace plugin. We do NOT duplicate; we let his existing installation cover them, just confirm they're symlinked or copied into the air-gap `~/.agents/skills/` path.

---

## Total bonus skills lifted into the bundle: 19

```
skills/coding/
  code-review-and-quality/
  code-simplification/
  context-engineering/
  debugging-and-error-recovery/
  doubt-driven-development/
  documentation-and-adrs/
  incremental-implementation/
  spec-driven-development/
  test-driven-development/
  diagnose/                   (from mattpocock)
  improve-codebase-architecture/  (from mattpocock)
  composition-patterns/       (from vercel)
  react-best-practices/       (from vercel)
  shadcn/                     (from shadcn-ui)

skills/meta/
  idea-refine/
  planning-and-task-breakdown/
  triage/                     (from mattpocock)
  zoom-out/                   (from mattpocock)

skills/literature/
  grill-with-docs/            (from mattpocock)

skills/visualization/
  react-view-transitions/     (from vercel)
  web-design-guidelines/      (from vercel)
```

These are pulled VERBATIM from upstream, then a `BORA-NOTES.md` per-skill file is added with our adaptation notes (medical-research framing, air-gap constraints, model-routing 27B-vs-35B-A3B preferences).

Grand total skill bundle: **43 core (v1+v2) + 19 cherry-picks = 62 skills.**

That's still fewer than Bora's existing 130 — the bundle is curated for one purpose, not general-coding.

---

## Update cadence

- These upstream repos update fast (some weekly)
- We **pin a commit hash** for each pull
- Quarterly: scan for new skills, bump commit hashes, re-eval
- `cron/weekly/skill-usage-report` flags skills that are never invoked → prune candidates
