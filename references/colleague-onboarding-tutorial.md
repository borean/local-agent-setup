# Colleague Onboarding — Air-Gapped Local LLM for Academic Research

**Adapted from**: an excellent 5-part Claude Code tutorial for academic researchers (author unknown; surfaced from a curated link digest).
**Adapted for**: our air-gapped local Qwen 3.6 stack via Hermes Agent Desktop. No Claude Code, no internet, no terminal.
**Audience**: clinician colleagues with no programming background. The author writes: *"If you can write sentences in English, you can use Hermes Agent Desktop."*

---

## Part 1 — What is this?

You install **Hermes Agent Desktop** on your computer just like you would Zoom or Zotero. Once installed, you point it at a folder on your computer (dissertation, paper, project) and let it work inside that folder. It can read every file, edit existing files, and create new ones. It remembers what you were working on between sessions.

Unlike browser-based AI (ChatGPT, Gemini, etc.) which can only "talk," Hermes Desktop can actually **"do"** things with your files.

**The crucial difference from Claude Code**: Hermes runs against your *own* local Qwen 3.6 model. **Nothing leaves your computer.** Patient data stays on disk. KVKK / GDPR / HIPAA all satisfied at the technical level.

### Why you should care

You have a folder full of PDFs, paper drafts, datasets, interview transcripts. You need to make connections across published literature, your gathered data, and your own notes. **This is what local-agent-setup was built for.**

### What it's not

Hermes Desktop is powerful but it is **not** a replacement for your expert judgment. It can draft, summarize, code — what counts as argument or evidence is your responsibility. Treat it as a research assistant, not as a brain transplant.

---

## Part 2 — Installation and first session

Set aside 15-20 minutes the first time. After that, you never need the terminal again.

### One-time setup

1. **You won't do the setup yourself.** Your AI agent does it.
2. Sign in to whichever frontier LLM agent you currently have access to: Claude Code, OpenAI Codex, or Gemini CLI.
3. Tell it: *"Read SETUP_PROMPT.md at https://github.com/borean/local-agent-setup and set up my air-gapped medical research environment."*
4. It will ask you a few questions (which folder is your Zotero, what's your IRB project ID, etc.). Answer them.
5. Wait. It takes ~30 minutes (mostly model downloads).
6. When it prints the hand-off message:
   - **Uninstall the frontier LLM** (System Settings → General → Apps → Uninstall)
   - **Flip Little Snitch menu** → switch to **"Research Mode"**
   - **Launch Hermes Agent Desktop** from your Applications folder

That's the only time you'll need any of that.

### What a session looks like

Open Hermes Desktop. You see a chat panel on the right, a list of past conversations on the left, and a button to **Open Folder** at the top.

Click Open Folder. Navigate to a folder with your research files. Hermes is now "inside" that folder. It can read every file and every subfolder.

In the chat, type:

> *"Read all the papers in this folder and give me their main arguments as a separate file."*

That's the entire interaction model. You write instructions in plain English. Hermes does the work.

As it works, it asks for permission for each file it wants to read or write. In the first few sessions, **leave permissions ON**. Once you trust the workflow, you can speed things up. Don't speed things up on day one.

Every session is auto-saved on the left panel. You can come back to it later.

---

## Part 3 — Hermes as your research assistant

When Hermes starts, it immediately reads a file called `CLAUDE.md` (or `AGENTS.md` — same thing, different harness convention) for its instructions. **You write this once, then forget about it.**

### Create your CLAUDE.md (the easy way)

Open Hermes. Type:

> *"I'm a pediatric endocrinologist working on a study about GLP-1 use in adolescents with type 2 diabetes. I want you to follow JCEM citation style and respond in academic style. When you critique my work, focus on argument, evidence, methodology, in that order. Create a CLAUDE.md file with these instructions."*

Hermes will create the file. Done.

### Sections you want in CLAUDE.md

```markdown
# Role
You are my research assistant for [your project]. I am a [role] working in [field].

# Standards
- Citation style: [JCEM / Vancouver / APA / ...]
- Reporting checklist: [STROBE / CONSORT / PRISMA / ...]

# Writing Style
- Tone: [formal academic / accessible / clinical]
- Use Turkish/English/both for: [different sections]

# Critique Style
- When reviewing my drafts, focus on: [argument, evidence, methodology, literature integration]
```

### Auto-memory

As you work, Hermes writes short notes about your project and saves them silently. You don't see them; you don't manage them. Each new session, it reads your CLAUDE.md AND its own notes. Over time it becomes a reliable assistant.

If something it remembers is outdated, just tell it: *"Forget the citation style and update memory to use Vancouver."*

### What NOT to put in CLAUDE.md

- Anything confidential (your patient names, your hospital's internal politics)
- Outdated instructions (review every few weeks; trim what's stale)

---

## Part 4 — Working with research documents

A research folder doesn't need to be neatly organized. Hermes can organize it for you. Just don't give files cryptic names like `Dissertation_final_FINAL_use_this_one.docx`.

### Literature work

Drop 20 PDFs into a folder. Open it in Hermes. Type:

> *"Read every PDF in this folder and tell me which articles disagree with the following argument: [paste your argument]."*

Hermes reads all the PDFs and returns a table.

### Systematic-review screening

> *"I'm running a systematic review. Here are my inclusion criteria: [paste]. Screen all 50 PDFs in this folder and produce a PRISMA-style table of included/excluded papers with reasons."*

### Qualitative work

> *"Read all interview transcripts in this folder and extract how each respondent answered the question: 'What is your relationship with your endocrinologist?' Produce a table with respondent ID, exact quote, and a one-sentence summary."*

### Repetitive tasks

> *"Open the Literature folder. Rename every PDF using its title and first-author name. Original filenames go into a `_original-filenames.txt` for backup."*

Done in 2 minutes.

### Asking Hermes to save its output

Anytime you ask Hermes to do a real task, **ask it to save the answer as a file**:

> *"Save your answer as `literature-review-summary.md` in the Literature folder."*

Markdown files are tiny, easy to retrieve from later, and you can convert them to Word or PDF when you're ready to share.

---

## Part 5 — Long projects: subfolders + sub-agents + scheduled tasks

For a dissertation or multi-year project, a single folder + single CLAUDE.md isn't enough. You need structure.

### Subfolders

```
My-Dissertation/
├── Literature/        ← PDFs + lit notes
├── Chapters/          ← chapter drafts
├── Data/              ← raw + cleaned datasets
├── Notes/             ← meeting notes, ideas
└── Correspondence/    ← advisor emails, reviewer comments
```

Put a CLAUDE.md at the top (general project info). Put a smaller CLAUDE.md inside each subfolder with task-specific instructions:

- `Chapters/CLAUDE.md`: *"Use MLA citation style. When critiquing drafts, follow argument → evidence → literature → counterargument order."*
- `Data/CLAUDE.md`: *"Never overwrite raw CSVs. Save cleaned versions with `_clean` suffix."*
- `Correspondence/CLAUDE.md`: *"Prioritize points that appear in BOTH reviewer reports and co-author emails."*

Hermes reads the global CLAUDE.md and the relevant subfolder CLAUDE.md every time it works in that subfolder.

### Plan Mode

For complex tasks, ask Hermes to plan before it acts:

> *"In Plan Mode: synthesize my notes on the 35 papers in Literature into a single literature review for Chapter 3."*

Hermes writes out the plan, you approve or adjust, then it executes. Use this for anything that touches 3+ subfolders or produces a long output.

### Sub-agents

For tasks that would clutter your main session's context, spawn a sub-agent. Examples:

- **Citation Checker** — reads a draft chapter, verifies every cited source against the Literature folder, flags missing references. Never edits the draft.
- **Reviewer 2** — critiques drafts as a hostile journal reviewer would.
- **Methodology Auditor** — checks if your methods section is consistent with your data and analysis code.

To create a sub-agent:

> *"Create a sub-agent called Citation Checker. It reads a draft, lists every in-text citation, verifies each against Literature folder PDFs. It produces a markdown report. It must never edit drafts."*

To use it:

> *"Use Citation Checker on `Chapter_4.md` in Chapters."*

Sub-agents have their own context windows. Your main session stays clean.

### Hooks

A hook is an automation that fires automatically when something happens (Hermes starts, ends, edits a file).

> *"Set up a pre-edit safety hook that copies any chapter file into a `Backups/` folder before editing it."*

After that, any chapter you ask Hermes to edit gets backed up first. You don't think about it.

### Scheduled tasks (only for air-gap-compatible work)

In our air-gapped setup, scheduled tasks run **only** on local files. No PubMed scrapes, no Twitter, no internet. But you CAN schedule:

- **Nightly handoff** — fresh summary of today's work in each active project's `handoff.md`
- **Weekly manuscript snapshot** — versioned snapshots of active drafts for regression tracking
- **Monthly passport cleanup** — delete old session-resume hashes

These come pre-configured in `local-agent-setup/cron/`.

---

## What NOT to delegate

Hermes is great at labor-intensive, repetitive, time-consuming tasks. **Outsource those.**

It is NOT good at:
- Generating new and original arguments (the whole point of your scholarship)
- Judging what counts as evidence in your field
- Making clinical decisions about patients

It can synthesize, draft, summarize, extract. What's true and what's important stays with you.

---

## Quick reference card

| You want to... | Type this |
|---|---|
| Read X papers and find a theme | "Read every PDF in this folder and identify a common theme." |
| Compare drafts | "Compare `chapter4_v1.md` and `chapter4_v2.md` and tell me what changed substantively." |
| Clean a dataset | "Clean `patient_data.csv`. Flag any rows with HbA1c >15 or age <0." |
| Get a review | "Use the Reviewer 2 sub-agent to critique `chapter4.md`. Save the critique to `Reviews/`." |
| Update memory | "Forget the old IRB number. Use IRB-2026-042 from now on." |
| See what Hermes remembers | "Tell me what you have stored in your memory about this project." |
| Resume after closing | "Resume the session — read `handoff.md` and tell me where I left off." |

---

## Compliance, briefly

This setup is **technically air-gapped**: nothing leaves your computer.

But you are still the **data controller** under GDPR/KVKK. You still need:
- IRB approval for the research
- Patient consent
- A DPIA (Data Protection Impact Assessment) for the project
- An audit log of every session involving patient data (auto-generated by our hooks → `~/Research/audit/`)

**Local-only is a strong technical control, not a legal exemption.** Read `docs/local_llm_plan.md` Part 0 for the full compliance picture.
