# coding/ — Engineering Skill Bundle

21 skills cherry-picked from upstream open-source libraries plus Bora's customs. Each upstream pull comes with a per-skill `PERSONAL-NOTES.md` adapting it to the air-gapped medical-research context (where it applies).

## Sub-categories

```
coding/
├── karpathy/      ← skills derived from the 12-rule baseline
├── google/        ← 11 from addyosmani/agent-skills (Google best practices)
├── mattpocock/    ← 4 from mattpocock/skills/engineering
├── vercel/        ← 1 from vercel-labs/agent-skills
├── shadcn/        ← shadcn/ui CLI v4 skill
└── bora/          ← custom additions
```

(react-best-practices, react-view-transitions, web-design-guidelines, composition-patterns from vercel-labs/agent-skills are split: 1 stays here in `vercel/`, 3 are research/visualization-applicable and live in `research/visualization/`.)

## The 21 skills

### karpathy/ (3 — distilled from the 12 rules)
- `fail-loud` — every status report surfaces partial-skip percentage (Rule 12)
- `surgical-changes` — touch only what you must; refuse to "improve" adjacent code (Rule 3)
- `read-before-write` — must read exports + callers + shared utilities before writing (Rule 8)

### google/ (11 from addyosmani/agent-skills @ pinned commit)
- `context-engineering` — codified Anthropic context engineering framework
- `code-review-and-quality` — multi-pass code review with explicit rubric
- `code-simplification` — remove speculative abstractions, dead code, dup logic
- `debugging-and-error-recovery` — structured debugging with explicit hypothesis tracking
- `documentation-and-adrs` — Architecture Decision Records for non-obvious choices
- `doubt-driven-development` — alternative to TDD: state what you DON'T know first
- `idea-refine` — hypothesis refinement loop (great for both research questions + product ideas)
- `incremental-implementation` — explicit smallest-change-that-could-work pattern
- `planning-and-task-breakdown` — task decomposition with dependency graph
- `spec-driven-development` — write the spec, then write the test, then write the code
- `test-driven-development` — strict TDD with red-green-refactor

### mattpocock/ (4 from mattpocock/skills/engineering @ pinned commit)
- `diagnose` — debugging analysis failures with explicit root-cause discipline
- `improve-codebase-architecture` — for the local-agent-setup repo itself + your apps
- `triage` — task prioritization with explicit cost/benefit framing
- `zoom-out` — when you're stuck in the weeds, force the global view

### vercel/ (1 from vercel-labs/agent-skills @ pinned commit)
- `composition-patterns` — generic React composition (Bora vibes React)

(The other 3 vercel skills live in `research/visualization/` because they're for figure/UI design.)

### shadcn/ (1)
- `shadcn` — shadcn CLI v4 skill (used by decks-bora UI components)

### bora/ (1 today, grows over time)
- `zero-tech-debt` — rework from intended end-state, delete cruft (the skill you shared)

## What we explicitly LEFT BEHIND from upstream

Listed for transparency — these aren't bugs, they're skips:

From addyosmani (skipped 12 of 23):
- `api-and-interface-design` — not relevant for medical research code
- `browser-testing-with-devtools` — air-gap
- `ci-cd-and-automation` — air-gap
- `deprecation-and-migration` — too general
- `frontend-ui-engineering` — Bora has his own data-viz skill, would conflict
- `git-workflow-and-versioning` — colleagues don't use git
- `interview-me` — meta, not applicable
- `performance-optimization` — local model inference is fixed
- `security-and-hardening` — air-gap is our hardening
- `shipping-and-launch` — manuscript = shipping for us
- `source-driven-development` — overlaps with spec-driven
- `using-agent-skills` — meta about skills, redundant

From mattpocock (skipped 6 of 10):
- `prototype` — overlaps with idea-refine
- `setup-matt-pocock-skills` — meta
- `tdd` — addyosmani's is more thorough
- `to-issues` — no GitHub issues air-gapped
- `to-prd` — no PRD workflow
- `grill-with-docs` — moved to `research/literature/` (interrogating papers, not docs)

From vercel-labs (skipped 3 of 7, 3 moved to research/visualization):
- `deploy-to-vercel` — air-gap
- `react-native-skills` — no mobile
- `vercel-cli-with-tokens` — air-gap
- `react-best-practices`, `react-view-transitions`, `web-design-guidelines` — moved to `research/visualization/` (they apply to figures + decks-bora)

## Upstream pinning

Each external pull is at a **pinned commit hash** stored in `pinned-commits.yaml`. Quarterly refresh cadence; commit hash bumps require running the eval suite before merging.

## Bundle scope

This bundle is **NOT** intended to replace Bora's existing 130-skill catalog or his daily Claude Code work. It is the **minimum** coding-skill set required to maintain the local-agent-setup repo itself, fix bugs in the research skills, and write the occasional analysis script in an air-gap-friendly way.

If you don't vibe-code, you can skip this bundle entirely and install just `shared/` + `research/`.
