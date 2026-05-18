#!/bin/bash
# pin-cherry-picks.sh — fetch upstream cherry-pick SKILL.md content at pinned commits
# Usage: pin-cherry-picks.sh (no args; reads pinning policy from this file)

set -euo pipefail

# ─── Pinned commits (bump quarterly, re-run eval suite before bumping) ──
# Format: "owner/repo COMMIT-SHA"
PINS=(
    "addyosmani/agent-skills:main"      # replace `main` with specific SHA after first install
    "mattpocock/skills:main"
    "vercel-labs/agent-skills:main"
    "shadcn-ui/ui:main"                  # we read only skills/shadcn/
)

# ─── Skills to lift per source ──────────────────────────────────────────
declare -a GOOGLE=(
    context-engineering
    code-review-and-quality
    code-simplification
    debugging-and-error-recovery
    documentation-and-adrs
    doubt-driven-development
    idea-refine
    incremental-implementation
    planning-and-task-breakdown
    spec-driven-development
    test-driven-development
)
declare -a MATTPOCOCK=(
    diagnose
    improve-codebase-architecture
    triage
    zoom-out
)
declare -a VERCEL_CODING=(composition-patterns)
declare -a VERCEL_VIZ=(react-best-practices react-view-transitions web-design-guidelines)

WORK_DIR=$(mktemp -d -t pin-cherry-picks)
trap "rm -rf $WORK_DIR" EXIT

fetch_skill() {
    local repo="$1" ref="$2" skill_name="$3" dest="$4"
    local owner=${repo%%/*}
    local raw_url="https://raw.githubusercontent.com/${repo}/${ref}/skills/${skill_name}/SKILL.md"
    echo "  → ${repo}#${ref} :: skills/${skill_name}/SKILL.md → ${dest}"

    # Try ${ref} as a branch; if it's main, prefer to resolve to current SHA for pin
    if [ "$ref" = "main" ]; then
        ref=$(curl -sL "https://api.github.com/repos/${repo}/commits/main" | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])")
        echo "    resolved main → ${ref}"
        raw_url="https://raw.githubusercontent.com/${repo}/${ref}/skills/${skill_name}/SKILL.md"
    fi

    curl -sL "$raw_url" -o "${dest}/SKILL.md"

    # Update frontmatter pinned-commit
    python3 - <<PYEOF
import yaml, re
with open("${dest}/SKILL.md") as f:
    content = f.read()
# Find existing frontmatter
m = re.match(r'^---\n(.*?)\n---\n(.*)', content, re.DOTALL)
if m:
    fm_text, body = m.group(1), m.group(2)
    try:
        fm = yaml.safe_load(fm_text) or {}
    except:
        fm = {}
    # Add or update upstream pin
    fm.setdefault('upstream', {})
    fm['upstream']['source'] = "${repo}"
    fm['upstream']['ref'] = "${ref}"
    fm['upstream']['skill'] = "${skill_name}"
    new_fm = yaml.dump(fm, default_flow_style=False, sort_keys=False)
    with open("${dest}/SKILL.md","w") as f:
        f.write(f"---\n{new_fm}---\n{body}")
PYEOF
}

# Google (addyosmani)
for skill in "${GOOGLE[@]}"; do
    dest=~/.agents/skills/coding/google/$skill
    mkdir -p "$dest"
    fetch_skill "addyosmani/agent-skills" "main" "$skill" "$dest"
done

# Matt Pocock
for skill in "${MATTPOCOCK[@]}"; do
    dest=~/.agents/skills/coding/mattpocock/$skill
    mkdir -p "$dest"
    fetch_skill "mattpocock/skills" "main" "$skill" "$dest"
done

# Vercel (coding)
for skill in "${VERCEL_CODING[@]}"; do
    dest=~/.agents/skills/coding/vercel/$skill
    mkdir -p "$dest"
    fetch_skill "vercel-labs/agent-skills" "main" "$skill" "$dest"
done

# Vercel (visualization-applicable)
for skill in "${VERCEL_VIZ[@]}"; do
    dest=~/.agents/skills/research/visualization/$skill
    mkdir -p "$dest"
    fetch_skill "vercel-labs/agent-skills" "main" "$skill" "$dest"
done

# shadcn (special path — not under skills/)
dest=~/.agents/skills/coding/shadcn/shadcn
mkdir -p "$dest"
curl -sL "https://raw.githubusercontent.com/shadcn-ui/ui/main/skills/shadcn/SKILL.md" -o "$dest/SKILL.md"

echo ""
echo "✓ Cherry-picks pinned. Re-run quarterly + run eval suite before bumping commits."
echo "  Pinned commits saved in each SKILL.md frontmatter (upstream.ref)."
