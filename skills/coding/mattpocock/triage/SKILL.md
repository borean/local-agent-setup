---
name: triage
description: Lifted verbatim from upstream. See PERSONAL-NOTES.md for our adaptation notes.
domain: coding
sub-category: mattpocock
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
upstream:
  source: mattpocock/skills/engineering
  path: skills/triage
  pinned-commit: TBD  # set at setup time
---

# Triage

⚠️ This skill is **cherry-picked from upstream**. The authoritative version lives at:
  https://github.com/mattpocock/skills/engineering/tree/main/skills/triage

We pull the SKILL.md verbatim at the pinned commit (see frontmatter). Our adaptation notes are in `PERSONAL-NOTES.md` alongside this file.

## Setup

```
# Pull the upstream content (run once during setup):
git clone --depth=1 --branch=<pinned-commit> https://github.com/mattpocock/skills/engineering /tmp/mattpocock-skills
cp /tmp/mattpocock-skills/skills/triage/SKILL.md ./SKILL.md  # this file, replaced
```

## Credit

Original work by upstream maintainer. See repo for license.

Quarterly refresh: bump pinned-commit + re-run eval suite before merging.
