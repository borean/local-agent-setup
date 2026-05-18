#!/bin/bash
# invoke-skill.sh — generic dispatcher for skill SKILL.md files
# Used by verification tests + ad-hoc skill execution
#
# Usage: invoke-skill.sh <skill-path> [--args '{"key":"value"}'] [extra args...]
# e.g.:  invoke-skill.sh shared/02-material-passport-emit --args '{"stage":"test","ledger_path":"/tmp/test.jsonl"}'
#
# Reads the skill's SKILL.md, extracts bash from Procedure (or simply
# notes the skill description for LLM-driven invocation), and runs it.

set -uo pipefail

SKILL_PATH="${1:-}"
shift
[ -z "$SKILL_PATH" ] && { echo "Usage: $0 <skill-path> [--args JSON]"; exit 1; }

# Source setup-env
[ -f ~/.research/setup-env ] && source ~/.research/setup-env
if [ -z "${LOCAL_AGENT_SETUP:-}" ]; then
    for candidate in ~/local-agent-setup ~/Projects/local-agent-setup ~/code/local-agent-setup; do
        if [ -f "$candidate/SETUP_PROMPT.md" ]; then
            export LOCAL_AGENT_SETUP=$(cd "$candidate" && pwd); break
        fi
    done
fi

# Resolve skill location:
#   first try ~/.agents/skills/<path>/SKILL.md  (installed)
#   then $LOCAL_AGENT_SETUP/skills/<path>/SKILL.md  (repo)
SKILL_FILE=""
for base in ~/.agents/skills "$LOCAL_AGENT_SETUP/skills"; do
    if [ -f "$base/$SKILL_PATH/SKILL.md" ]; then
        SKILL_FILE="$base/$SKILL_PATH/SKILL.md"
        break
    fi
done
[ -z "$SKILL_FILE" ] && { echo "FAIL: skill '$SKILL_PATH' not found"; exit 1; }

# Extract bash blocks from Procedure section
BASH_BLOCKS=$(python3 - "$SKILL_FILE" <<'PYEOF'
import sys, re
with open(sys.argv[1]) as f: md = f.read()
m = re.search(r'## Procedure\s*\n(.*?)(?=\n## |\Z)', md, re.DOTALL)
section = m.group(1) if m else md
for block in re.findall(r'```(?:bash|sh)?\s*\n(.*?)```', section, re.DOTALL):
    print(block)
PYEOF
)

# If there's a bash block, execute it; else emit the skill's frontmatter + procedure
# as a JSON payload for an LLM-driven dispatcher (Hermes will pick this up).
if [ -n "$BASH_BLOCKS" ]; then
    # Pass through any --args JSON via env vars for the skill to consume
    if [ "${1:-}" = "--args" ] && [ -n "${2:-}" ]; then
        export SKILL_ARGS_JSON="$2"
    fi
    echo "$BASH_BLOCKS" | bash
else
    # No bash to execute; this skill is meant for LLM invocation. Dump the spec.
    cat "$SKILL_FILE"
fi
