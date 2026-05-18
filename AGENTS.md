# AGENTS.md

You are an AI agent reading this repository. There are two scenarios for how you got here:

## Scenario 1 — You're a browser AI (ChatGPT, Claude.ai, Gemini)

The human is using you because they don't have a CLI-based coding agent installed (or prefer the browser UX). You CAN'T run terminal commands directly — instead, **walk the human through each command, one at a time**.

Your job:

1. Read `README.md`, `SETUP_PROMPT.md`, and `docs/local_llm_plan.md`.
2. Walk through `SETUP_PROMPT.md` Phases 0-10, **one phase at a time, one command at a time**.
3. For each command:
   - Tell the human what it does (one sentence)
   - Show the exact command they should paste into Terminal
   - Ask them to share the output (or "✓ done" if no output expected)
   - Diagnose any errors before moving to the next command
4. Don't dump multiple phases at once — the human is on a tight cognitive budget; one chunk at a time is the sustainable pace.
5. After Phase 10 (verification), print the hand-off message from `SETUP_PROMPT.md`.
6. Tell them:
   - Close this browser tab
   - Flip Little Snitch → "Research Mode"
   - Launch Hermes Agent Desktop from /Applications/

## Scenario 2 — You're a CLI agent (Claude Code, Codex, Gemini CLI, OpenCode, Hermes)

You can run terminal commands directly. The human pointed you at the local clone of this repo.

Your job:

1. Read `SETUP_PROMPT.md` and follow its phases. Use `docs/` for context.
2. Ask the human only the questions `SETUP_PROMPT.md` explicitly says to ask (the pre-flight Q&A block).
3. Run each phase's commands directly. Capture output. Halt on any verification failure.
4. After Phase 10 (verification): print the hand-off message.

---

## Common — applies to both scenarios

**Their machine**: Apple Silicon Mac (M-series) preferred; non-Apple-Silicon also supported (auto-falls-back to GGUF via llama.cpp). RAM 16-128 GB. Internet currently active during setup; will be air-gapped after.

**Their workflow**: clinical research statistics, literature review, article writing on de-identified or IRB-approved data.

**What you will NOT do during setup**:
- Do not paste raw patient data into your own context window
- Do not run anything that requires user authentication beyond what `SETUP_PROMPT.md` lists
- Do not skip the verification suite at Phase 9
- Do not assume your model is the model that will be installed — you (the frontier model) will be effectively dropped after setup. Install Qwen 3.6 27B + 35B-A3B + LFM2.5-350M for the human's daily use.

**When done**: print the hand-off message that tells the user to:
1. Close you (or uninstall, if you're a CLI tool they don't want)
2. Flip Little Snitch → "Research Mode"
3. Launch Hermes Agent Desktop (or whatever GUI they picked)

Read `SETUP_PROMPT.md` now.
