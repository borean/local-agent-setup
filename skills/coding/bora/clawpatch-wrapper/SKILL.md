---
name: clawpatch-wrapper
description: Wrap Peter Steinberger's clawpatch CLI (semantic feature-slice code review with explicit fix-attempt validation) as a skill our agents can invoke.
domain: coding
sub-category: bora
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok  # clawpatch itself runs locally once installed
inputs:
  type: object
  required: [target_path]
  properties:
    target_path: {type: string, description: "Path to a codebase or specific file to review"}
    mode: {type: string, enum: [review, patch, validate], default: review}
---

# Clawpatch Wrapper

[clawpatch](https://clawpatch.ai) by [@steipete](https://x.com/steipete) (Peter Steinberger) maps codebases into semantic feature slices, reviews them for bugs and quality issues, and records explicit fix attempts with validation.

## Why wrap it as a skill

clawpatch is a CLI (`npm install -g clawpatch`). Wrapping as a skill means:
- Our agents (Hermes, OpenCode) invoke it consistently
- Output gets piped into our audit ledger
- Pairs cleanly with `peer-review-checklist` for code reviews of our analysis scripts

## Procedure

1. Verify clawpatch installed: `which clawpatch`. If missing, suggest invoking `request-momentary-internet` to install: `npm install -g clawpatch`
2. Run clawpatch in the requested mode:
   - `review`: `clawpatch review {target_path}` — produces semantic feature-slice analysis
   - `patch`: `clawpatch patch {target_path}` — proposes patches per slice
   - `validate`: `clawpatch validate {target_path}` — verifies past fix attempts
3. Capture stdout to `~/Research/audit/$(date +%F)/clawpatch-{session_id}.md`
4. Parse the structured output (clawpatch emits markdown with explicit slice/issue/fix sections)
5. Return as structured object to the agent

## Failure modes

- clawpatch not installed: prompt user to install via request-momentary-internet
- Target path too large (>10k LOC): warn; suggest narrower scope
- Pure-data files (CSV, etc.): clawpatch isn't designed for these; refuse

## Credit

clawpatch by [@steipete](https://x.com/steipete). Repository: [openclaw/clawpatch](https://github.com/openclaw/clawpatch). Site: [clawpatch.ai](https://clawpatch.ai). Surfaced in Bora's WhatsApp curation, May 2026.
