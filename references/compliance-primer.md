# Compliance primer — KVKK, GDPR, HIPAA

What each law actually says, in plain language. Article numbers so you can cite them in your IRB/DPIA/audit paperwork.

---

## KVKK (Turkey — Law 6698, Kişisel Verilerin Korunması Kanunu)

The Turkish equivalent of GDPR.

### Article 6 — Special category personal data ("özel nitelikli kişisel veri")
Defines health, biometric, religious, political, sexual life, criminal records, association memberships as "special category."

**Health data is special category.** Patient records, lab values, genetic data, imaging — all under Art. 6.

**Requirements**:
- Explicit consent ("açık rıza") for processing, OR
- Specific legal exception (e.g., public health, established by law)
- For health data specifically: processing allowed by persons under confidentiality obligation (doctors) without explicit consent when necessary for treatment — but **research is not treatment**. Research on identifiable health data needs explicit consent + IRB approval.
- Cross-border transfers and third-party processors require **Kurul** (the Data Protection Authority) approval.

### Article 12 — Data controller security obligations
*"The data controller is obliged to take all necessary technical and administrative measures to provide a sufficient level of security to prevent unlawful processing of and access to personal data and ensure protection of personal data."*

In practice for our setup:
- **Audit logs** of every processing operation (our `~/Research/audit/` directory)
- **Access controls** (FileVault, screen lock, dedicated macOS user account)
- **Network segregation** when processing (Little Snitch "Research Mode" = our technical control)
- **Breach notification** to Kurul + affected individuals within 72 hours if anything leaks
- **Periodic review** of the technical measures (quarterly hash check of audit logs for tamper-evidence)

### Article 35 (analogous concept) — DPIA-like requirement
KVKK doesn't have an explicit DPIA article, but the Kurul's secondary regulations + April 15 2026 Agentic AI guidance require risk-based impact assessment for high-risk processing of special-category data.

In practice for us:
- Write a DPIA-style document for the research project: data flows, technical controls (this stack), residual risks, mitigations
- Update it when the stack changes (model upgrade, new skill that processes data differently, etc.)
- Template TODO: `references/dpia-template.md` (future)

### VERBIS — Veri Sorumluları Sicil Bilgi Sistemi
Controller registration system. Most institutions are already registered. For solo practitioners doing research, check thresholds — typically required if you process special-category data systematically.

### April 15, 2026 Agentic AI guidance — the key recent update
The Turkish DPA explicitly addressed Agentic AI:
- AI-derived/inferred outputs **are personal data** subject to full KVKK compliance
- **No "on-device exemption"** exists — local processing still requires lawful basis, purpose limitation, data minimization, privacy-by-design
- Risk-based governance required

**Translation for our setup**: local-only is a strong **technical control**. It dramatically reduces the threat surface. But it does NOT remove the controller's legal obligations. You still need IRB, consent, DPIA, audit, retention policy.

---

## GDPR (EU + Turkey-bound researchers collaborating with EU institutions)

### Article 9 — Special category data
Same idea as KVKK Art. 6. Health data is special category. Requires:
- Explicit consent, OR
- Substantial public interest, OR
- Necessary for medical diagnosis/treatment by a health professional, OR
- Necessary for archiving/scientific research with appropriate safeguards (Art. 89)

### Article 32 — Security of processing
Equivalent of KVKK Art. 12. Same practical requirements.

### Article 35 — DPIA
Explicit DPIA requirement for high-risk processing including health data on a large scale. **DPIA is required for our use case.**

### Article 89 — Research safeguards
Pseudonymization, technical/organizational safeguards, purpose limitation. Our local-only + audit-log + Material Passport architecture satisfies the technical side.

### What local-only eliminates under GDPR
- Standard Contractual Clauses (SCCs) for cross-border transfers — there are no transfers
- Data Processing Agreements (DPAs) with cloud providers — there are no processors
- Vendor breach risk — there is no vendor

### What local-only does NOT eliminate
- Controller obligations (Art. 32, 33, 34, 35)
- Data subject rights (access, erasure, portability — Art. 15-22)
- Retention limits (Art. 5(1)(e))
- DPIA (Art. 35)

---

## HIPAA (US — only relevant for collaborations with US institutions)

The US healthcare privacy law. Different scope from KVKK/GDPR — only applies to "covered entities" (providers, health plans, clearinghouses) and "business associates" who handle PHI.

### Who's a covered entity?
- Healthcare providers who transmit health information electronically
- Health plans (insurance)
- Healthcare clearinghouses

A clinician researcher in Turkey doing research with US collaborators is typically NOT directly under HIPAA — but their US collaborators are, and any data they share with you may carry HIPAA obligations contractually.

### BAA — Business Associate Agreement
Required when PHI is shared with any third-party processor.

**Our local-only setup eliminates the need for a BAA with the model provider entirely** — there is no third party processing the data. The model runs on the clinician's own hardware.

If the clinician shares data with their US collaborator's cloud, the BAA is between the collaborator and the cloud — not us.

### De-identification (45 CFR 164.514)
HIPAA has explicit de-identification standards (Safe Harbor + Expert Determination). If you de-identify per Safe Harbor (remove 18 specified identifiers), the data is no longer PHI and HIPAA doesn't apply to it.

For our research workflow:
- If you de-identify at source (in the hospital DB before export), no further HIPAA obligations
- If you process identifiable PHI locally, you're outside HIPAA only because you're not a covered entity yourself — but if you publish or share the identifiable data downstream, you need authorization

---

## How our stack maps to compliance

| Requirement | Where our stack helps |
|---|---|
| KVKK Art. 12 audit log | `~/Research/audit/YYYY-MM-DD/session-*.jsonl` auto-populated by `post-tool-audit-jsonl.sh` hook |
| GDPR Art. 32 technical measures | llama-server localhost-only + Little Snitch Research Mode + Material Passport hash chain |
| Cross-border transfer concerns | Eliminated — no transfers happen |
| BAA/DPA with model provider | Eliminated — no model provider |
| Tamper-evidence | Audit logs hashed nightly via `audit-rotate` cron |
| Right to erasure | Filename conventions (every file tagged with subject pseudo-ID) + erasure-by-grep utility (TODO skill) |
| Breach notification | mitmproxy + Raindrop Workshop trace logs + network-mode-toggle status — if anything leaks, you can prove what was processed and when |
| DPIA evidence | This entire stack + the documented architecture = the "appropriate technical and organizational measures" your DPIA cites |

## What we DON'T solve and you still need to do

- **IRB approval** for your research
- **Patient consent** documentation
- **DPIA writeup** — actual document explaining your data flows and risks
- **Retention policy** — when do audit logs and derivatives get deleted?
- **Backup hygiene** — exclude `~/Research/` from iCloud, Time Machine, Dropbox
- **Physical device security** — FileVault, screen lock, dedicated user account
- **Training your colleagues** — they're the actual leak vector if anything goes wrong

## Disclaimers

This primer is written by a non-lawyer (an AI assistant), reviewed by a clinician (not a lawyer). It is **not legal advice**. For binding compliance posture:
- Talk to your institution's DPO (Data Protection Officer)
- Talk to a KVKK-specialist lawyer
- Check the Kurul's current secondary regulations (they update)
- Verify with your IRB

The technical architecture here is designed to make the legal answer EASIER to defend. It does not produce the legal answer itself.

---

## Credit

Compliance framing synthesized from:
- KVKK Law 6698 text (Resmi Gazete)
- Turkish DPA guidance documents (kvkk.gov.tr) — including April 15, 2026 Agentic AI guidance
- GDPR Article text (eur-lex.europa.eu)
- HIPAA Privacy Rule (HHS.gov)
- Bora's prior conversations with his institution's DPO
- Web research conducted May 2026
