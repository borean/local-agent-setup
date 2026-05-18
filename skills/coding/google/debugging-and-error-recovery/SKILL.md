---
name: debugging-and-error-recovery
description: Lifted verbatim from upstream. See BORA-NOTES.md for our adaptation notes.
domain: coding
sub-category: google
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
upstream:
  source: addyosmani/agent-skills
  path: skills/debugging-and-error-recovery
  pinned-commit: TBD  # set at setup time
---

# Debugging And Error Recovery

⚠️ This skill is **cherry-picked from upstream**. The authoritative version lives at:
  https://github.com/addyosmani/agent-skills/tree/main/skills/debugging-and-error-recovery

We pull the SKILL.md verbatim at the pinned commit (see frontmatter). Our adaptation notes are in `BORA-NOTES.md` alongside this file.

## Setup

```
# Pull the upstream content (run once during setup):
git clone --depth=1 --branch=<pinned-commit> https://github.com/addyosmani/agent-skills /tmp/google-skills
cp /tmp/google-skills/skills/debugging-and-error-recovery/SKILL.md ./SKILL.md  # this file, replaced
```

## Credit

Original work by upstream maintainer. See repo for license.

Quarterly refresh: bump pinned-commit + re-run eval suite before merging.
