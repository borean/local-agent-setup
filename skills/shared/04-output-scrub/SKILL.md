---
name: output-scrub
description: Before any text leaves the laptop (email, slide, shared doc, export), scrub for first names, TCKN, MRN, exact dates, and other PHI patterns. Auto-generalize ("week 12" not "April 14"). Defense-in-depth for the air-gap.
domain: shared
user-invocable: true
target_models:
  primary: qwen3.6:35b-a3b-q4_K_M
network: airgap-ok
inputs:
  type: object
  required: [text]
  properties:
    text: {type: string}
    aggressiveness: {type: string, enum: [low, medium, high], default: medium}
    target_destination: {type: string, enum: [email, slide, doc, log, audit, unknown]}
outputs:
  type: object
  required: [scrubbed_text, redactions]
  properties:
    scrubbed_text: {type: string}
    redactions: {type: array, items: {type: object, properties: {pattern: {type: string}, count: {type: integer}}}}
    warnings: {type: array, items: {type: string}}
---

# Output Scrub

Last line of defense before text leaves the laptop. NOT for input sanitization (the air-gap handles inputs).

## Procedure

1. Run regex pass over `text`:
   - **TCKN**: `^[1-9][0-9]{10}$` standalone, or `[1-9][0-9]{10}` in context — replace with `[TCKN]`
   - **MRN**: `^[0-9]{6,8}$` standalone — replace with `[MRN]`
   - **Phone TR**: `(\+90|0)?\s?5[0-9]{2}\s?[0-9]{3}\s?[0-9]{2}\s?[0-9]{2}` — replace with `[PHONE]`
   - **Exact dates with day precision**: `\d{1,2}[./-]\d{1,2}[./-]\d{4}` — flag for generalization
   - **Email**: `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}` — replace with `[EMAIL]`
   - **IBAN-TR**: `TR\d{2}\s?\d{4}\s?\d{4}\s?\d{4}\s?\d{4}\s?\d{4}\s?\d{2}` — replace with `[IBAN]`
   - **MERNIS/SGK numeric IDs** of known length

2. LLM pass (only if aggressiveness ≥ medium):
   - Identify Turkish first names that appear with title prefixes ("Sn.", "Dr.", "Ahmet Bey")
   - Identify hospital names ("Etlik Şehir Hastanesi", "Hacettepe", etc.)
   - Identify rare combinations that could re-identify (rare disease + small city + age range)

3. Date generalization (only if `target_destination` is in [email, slide, doc]):
   - "April 14, 2026" → "week 12 of treatment" (use the visit/treatment timeline as denominator)
   - "Q2 2025" → keep (already general)
   - Birth dates → "{age} years old"

4. Build the `redactions` list — what was changed, count of each.
5. Build `warnings` list — anything that LOOKS like PHI but wasn't a clean regex match (ask user to verify).
6. Return scrubbed text + audit.

## Failure modes

- **Aggressive mode false positives**: e.g., scrubbing "Aspirin" because it pattern-matches a 7-letter word — never happens with our regexes, but the LLM pass might. Always show diff before final replacement; let user undo per-line.
- **Turkish character edge cases**: `İSTANBUL` (uppercase dotted I) doesn't always lowercase correctly. Use `str.lower()` with locale=`tr_TR` if available.
- **Aggressiveness = high + research log**: high-aggressiveness scrubbing on the audit log itself defeats the audit. The hook `stop-output-scrub.sh` enforces `aggressiveness: medium` on audit destinations.

## Aggressiveness levels

- **low**: regex only, no LLM pass, no date generalization
- **medium** (default): regex + LLM names/hospitals + date generalization for external destinations
- **high**: medium + flag any 3-token sequence that's unusual in your corpus

## Audit trail

Every scrub is logged to `~/Research/audit/$(date +%F)/scrub.jsonl`:
```json
{"timestamp": "2026-05-18T14:32:00Z", "destination": "email",
 "redactions": {"TCKN": 1, "MRN": 2, "date_generalized": 4},
 "session_id": "2026-05-18-7af83b21"}
```

## Example

```
Input:
  "Hastamız Ahmet Yılmaz (TCKN 12345678901, MRN 0048231) 14 Nisan 2026'da
   Etlik ŞH'ye başvurdu. HbA1c 8.4."

Output (medium aggressiveness, destination=slide):
  "Hastamız [REDACTED-NAME] (TCKN [REDACTED], MRN [REDACTED])
   tedavinin 12. haftasında bir tertiary endokrinoloji merkezine başvurdu.
   HbA1c 8.4."

Redactions: [{pattern: TCKN, count: 1}, {pattern: MRN, count: 1},
             {pattern: turkish_name_with_title, count: 1},
             {pattern: hospital_name, count: 1},
             {pattern: date_generalized, count: 1}]

Warnings: []
```

## Credit

Hardening pattern derived from:
- HIPAA Safe Harbor 18-identifier list (adapted for Turkish context)
- KVKK Art. 12 audit obligations
- Defense-in-depth doctrine — even in air-gap, outputs leave via human copy-paste
