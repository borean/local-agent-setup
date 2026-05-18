# system-prompts/field-presets/

**Empty by default.** Populated by `SETUP_PROMPT.md` Phase 5.5 based on the user's actual field + target journals, using `online-lookup` (clean-session pattern) to fetch current author guidelines.

Reference templates live in `references/field-preset-examples/` — those are seeds that the setup customizes per user, not the active presets.

## What gets generated here

After setup, this folder contains a single file: `{user-field-slug}.md` (e.g., `pediatric-endocrinology.md`, `oncology-immunotherapy-us.md`, `internal-medicine-eu.md`, etc.).

The file is loaded by `style-calibration --mode generic --field "<user-field>"` and merged into the local model's system prompt at every session start.

## Why not just hardcode the examples here?

- Style conventions drift (journals update author guidelines roughly annually)
- "Pediatric endocrinology in Turkey" and "Pediatric endocrinology in US" have subtle differences not worth pre-shipping every variant
- New users may be in a sub-field we haven't pre-written
- Generating fresh during setup + caching to `~/Research/cache/journal-guidelines/` keeps everything current with one mechanism

The examples in `references/field-preset-examples/` give the setup agent a structural template to follow when generating. They are reference materials, not active prompts.
