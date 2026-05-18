# Skills

Three bundles, designed to be installed independently or together.

```
skills/
├── shared/      ← cross-cutting skills (~6)
├── research/    ← clinical/academic research bundle (~37 skills, 6 sub-pillars)
└── coding/      ← coding/engineering bundle (~21 skills cherry-picked from upstream + bora)
```

## Why three bundles, not one giant catalog

Open-weight models route better to 30 cohesive skills than to 130 fragmented ones. Splitting by domain lets us:

1. **Install only what you need** — a clinician researcher who doesn't vibe-code can install just `research/` + `shared/`
2. **Update bundles independently** — `coding/` gets refreshed when Google/Karpathy publishes new patterns; `research/` only when ARS or PaperQA2 ships changes
3. **Filter by session intent** — `session-launch write-mode` shows only research/manuscript skills; `session-launch code-mode` shows only coding skills + shared
4. **Easier audit** — a KVKK auditor inspecting the research workflow doesn't need to see how you refactor TypeScript

## How filtering works at runtime

Every SKILL.md frontmatter declares its `domain:`:

```yaml
---
name: evidence-synthesize
domain: research          # one of: shared | research | coding
pillar: literature        # within the domain
network: airgap-ok
target_models:
  primary: qwen3.6:27b-q4_K_M
---
```

The `session-launch` skill reads the user's session-mode (write / code / quick / vision) and the hook `skill-suggest-airgap.sh` filters the candidate list accordingly. Shared skills always show.

## Install pattern

```
~/.agents/skills/
├── shared/             ← always installed
├── research/           ← installed if domain=research selected
└── coding/             ← installed if domain=coding selected
```

If you install both bundles, the harness still routes per-session via the `domain:` field. No conflict.

## Cross-bundle skill use

Sometimes a coding session needs a research skill (e.g. you're debugging the LEANN index — that's a coding task that uses literature/leann-search). The session-launch's "task description" classifier resolves this: if the user prompt mentions a research skill name explicitly, that skill is unlocked for the session regardless of session mode.

## Bundle-specific READMEs

- [shared/README.md](shared/README.md) — meta and infrastructure
- [research/README.md](research/README.md) — the 37 research skills
- [coding/README.md](coding/README.md) — the 21 cherry-picks + Bora's customs
