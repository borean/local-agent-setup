---
name: pediatric-references
description: Lookup against cached growth charts + normative tables (Neyzi, WHO, CDC, IAP). Returns p3/p10/p50/p90/p97 + SDS for a value + source citation.
domain: research
pillar: medical-domain
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
  fallback: qwen3.6:35b-a3b-q4_K_M
network: local-with-cache
---

# Pediatric References

Lookup against cached growth charts + normative tables (Neyzi, WHO, CDC, IAP). Returns p3/p10/p50/p90/p97 + SDS for a value + source citation.

## Procedure

1. Validate inputs against the JSON schema in frontmatter
2. (Skill-specific procedure — see references/skill-libraries-survey.md and docs/skillset_v1.md / skillset_v2_additions.md for the full method)
3. Emit structured output per frontmatter `outputs:` schema
4. Append to session ledger via post-tool-audit-jsonl hook

## Failure modes

- Inputs malformed → reject with explicit schema error; do not silent-pass
- Required local cache/index missing → suggest the relevant setup or cron skill
- Model returns ill-formed structured output → retry once with stricter system prompt; if still fails, raise structured error (Karpathy rule #12)

## Example

(To be filled in with a concrete example during first invocation. The frontier-LLM-driven first-run will populate this.)

## Credit

Neyzi growth charts (Turkish), WHO 2007, CDC 2000, IAP charts. Cached from each organization's open data.
