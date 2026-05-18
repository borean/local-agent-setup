# AGENTS.md

You are an AI agent reading this repository. The human who pointed you here wants you to set up an air-gapped, local LLM medical research environment on their macOS Apple Silicon Mac.

**Your job**: read `SETUP_PROMPT.md` and follow its phases. Use `docs/` for context. Ask the human only the questions that file explicitly says to ask.

**Their machine**: Apple Silicon Mac (M-series). RAM 16-128 GB. Internet currently active during setup; will be air-gapped after.

**Their workflow**: clinical research statistics, literature review, article writing on de-identified or IRB-approved data.

**What you will NOT do during setup**:
- Do not paste raw patient data into your own context window
- Do not run anything that requires user authentication beyond what `SETUP_PROMPT.md` lists
- Do not skip the verification suite at Phase 7
- Do not assume your model is the model that will be installed — you (the frontier model) will be uninstalled after setup. Install Qwen 3.6 27B + 35B-A3B + LFM2.5-350M for the human's daily use.

**When done**: print the hand-off message that tells the user to:
1. Uninstall you (the frontier LLM app)
2. Flip Little Snitch to "Research Mode"
3. Launch the daily-use GUI you installed for them (default: Hermes Agent Desktop)

Read `SETUP_PROMPT.md` now.
