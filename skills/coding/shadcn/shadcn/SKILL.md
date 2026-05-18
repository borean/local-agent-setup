---
name: shadcn
description: Lifted verbatim from upstream. See BORA-NOTES.md for our adaptation notes.
domain: coding
sub-category: shadcn
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
upstream:
  source: shadcn-ui/ui/skills/shadcn
  path: skills/shadcn
  pinned-commit: TBD  # set at setup time
---

# Shadcn

⚠️ This skill is **cherry-picked from upstream**. The authoritative version lives at:
  https://github.com/shadcn-ui/ui/skills/shadcn/tree/main/skills/shadcn

We pull the SKILL.md verbatim at the pinned commit (see frontmatter). Our adaptation notes are in `BORA-NOTES.md` alongside this file.

## Setup

```
# Pull the upstream content (run once during setup):
git clone --depth=1 --branch=<pinned-commit> https://github.com/shadcn-ui/ui/skills/shadcn /tmp/shadcn-skills
cp /tmp/shadcn-skills/skills/shadcn/SKILL.md ./SKILL.md  # this file, replaced
```

## Credit

Original work by upstream maintainer. See repo for license.

Quarterly refresh: bump pinned-commit + re-run eval suite before merging.
