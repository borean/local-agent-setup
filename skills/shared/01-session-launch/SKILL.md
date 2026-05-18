---
name: session-launch
description: Classify the incoming task, pick the right Qwen 3.6 variant (27B dense or 35B-A3B MoE), load the appropriate system prompt and skill bundle, and start a warm session. Decides once per session and commits — never swaps models mid-session.
domain: shared
user-invocable: true
target_models:
  router: lfm2.5-350m-q8       # always-warm on :11436 for the routing decision
  primary: qwen3.6:35b-a3b-q4_K_M  # default
  alt: qwen3.6:27b-q4_K_M
network: airgap-ok
inputs:
  type: object
  required: [task_description]
  properties:
    task_description: {type: string, description: "1-3 sentences of what the user wants to do"}
    explicit_mode: {type: string, enum: [write, code, quick, vision, auto], default: auto}
outputs:
  type: object
  properties:
    model: {type: string}
    port: {type: integer}
    loaded_skills: {type: array, items: {type: string}}
    system_prompt_path: {type: string}
    session_id: {type: string}
    resume_passport: {type: string, nullable: true}
---

# Session Launch

The orchestrator. Runs ONCE at the start of every research session. Decides everything else.

## Procedure

1. Receive `task_description` from user (the harness's first prompt).
2. If `explicit_mode` is not `auto`, skip classification — go to step 4 with that mode.
3. Otherwise, POST `task_description` to LFM2.5-350M on `localhost:11436` with the schema:
   ```
   System: You classify research tasks into modes.
   Modes: write | code | quick | vision
   - write:  manuscript writing, literature synthesis, response-to-reviewer
   - code:   data analysis script, R/Python, debugging, refactoring
   - quick:  one-shot lookup, definition, single calculation
   - vision: image/figure/chart inspection (uses Qwen 3.6 35B-A3B vision)
   Return one word.
   ```
4. Map mode → model + port + skill bundle:
   - `write`  → Qwen 3.6 27B dense (`:11434` after swap if not loaded), domain=research/manuscript
   - `code`   → Qwen 3.6 35B-A3B MoE, domain=coding + research/statistics (joint)
   - `quick`  → Qwen 3.6 35B-A3B MoE (fast), domain=shared only
   - `vision` → Qwen 3.6 35B-A3B (has vision), domain=research/visualization
5. Check current llama-server model on :11434:
   - If matches: skip swap, KV cache preserved
   - If mismatch: `launchctl unload` + edit plist + `launchctl load` (5-10s)
6. Generate session_id: `$(date +%F)-$(uuidgen | cut -c1-8)`
7. Concatenate system prompt:
   - `~/.agents/system-prompts/karpathy-12-rules.md`
   - `~/.agents/system-prompts/air-gap-preamble.md`
   - `~/.agents/system-prompts/{username}-voice.md` (if exists)
8. Filter loaded skills by `domain:` frontmatter — only `shared` + selected domain skills become discoverable
9. Check `~/.agents/state/last-passport.txt` — if user mentioned a passport hash in `task_description`, call `material-passport-resume` skill
10. Write session metadata to `~/Research/audit/$(date +%F)/session-$session_id.meta.yaml`
11. Return structured object; harness loads it into context

## Failure modes

- **LFM2.5 router unreachable**: fall back to user prompt — ask user to pick mode explicitly. Log failure.
- **Both Qwen models unloaded**: load default (35B-A3B); warn user.
- **Voice profile missing**: skip with notice; suggest user runs `style-calibration` once.
- **task_description too short** (<10 chars): default to `quick` mode.
- **Multiple conflicting domain mentions**: pick the dominant mode; warn user.

## Example invocations

```
User: "Help me synthesize 8 papers into the introduction of my manuscript"
Skill output: {mode: write, model: qwen3.6:27b-q4_K_M, port: 11434,
               loaded_skills: [paperqa-synthesize, draft-write, claim-check,
                               anti-leakage, writing-quality-check, style-calibration],
               session_id: 2026-05-18-7af83b21}

User: "Debug why the LEANN index isn't returning hits for thyroid papers"
Skill output: {mode: code, model: qwen3.6:35b-a3b-q4_K_M, port: 11434,
               loaded_skills: [leann-search, diagnose, debugging-and-error-recovery],
               session_id: 2026-05-18-9c2d10f3}
```

## Credit

Pattern derived from:
- **qizhengz_alex's ACE framework** (Generator-Reflector-Curator) — surfaced in WhatsApp link-digest curation, May 2026
- **LFM2.5-350M sidecar router idea** — @liquidai's tweet on the 350M tool-use model
- **Session-locked orchestration** — emerged in v3_changes after Bora's "no mid-session model swap" rule
