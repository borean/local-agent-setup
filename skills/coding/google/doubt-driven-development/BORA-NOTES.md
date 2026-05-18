# Bora's Notes — doubt-driven-development

## Why we lifted this

Alternative to TDD: state what you DON'T know first. Maps to research methodology.

## How it maps to our medical-research context

(Skill-specific adaptation — to be filled during first use. The frontier-LLM setup will populate this with examples from Bora's actual workflow.)

## Plays well with

(List of our own skills that should be invoked alongside this one.)

## Local model constraint

This skill was designed for frontier models (Claude/GPT-class). Running on Qwen 3.6 35B-A3B may degrade on:
- Multi-hop reasoning chains beyond 3 steps
- Subtle code-style judgment calls

Mitigation: when the skill produces a recommendation we're unsure about, run `peer-review-checklist` as a second pass.

## Credit

Upstream: addyosmani/agent-skills. We respect their license terms; the SKILL.md content is theirs, this BORA-NOTES.md is ours.
