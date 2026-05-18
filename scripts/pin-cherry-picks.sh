#!/bin/bash
# pin-cherry-picks.sh — fetch upstream cherry-pick SKILL.md content at pinned commits
# Usage: pin-cherry-picks.sh             (uses pinned-commits.yaml if exists, else resolves main)
#        pin-cherry-picks.sh --refresh   (force re-resolve current main → SHA, update pinned-commits.yaml)

set -euo pipefail

PINS_FILE=~/.agents/state/cherry-pick-pins.yaml
REFRESH=false
[ "${1:-}" = "--refresh" ] && REFRESH=true

mkdir -p "$(dirname "$PINS_FILE")"

# ─── Default pins: source → ref (sha or "main") ───────────────────────
declare -A DEFAULT_PINS=(
    [addyosmani/agent-skills]="main"
    [mattpocock/skills]="main"
    [vercel-labs/agent-skills]="main"
    [shadcn-ui/ui]="main"
)

# Load existing pins if present (overrides defaults)
declare -A PINS
if [ -f "$PINS_FILE" ] && [ "$REFRESH" = "false" ]; then
    while IFS=': ' read -r key val; do
        [ -n "$key" ] && PINS["$key"]="$val"
    done < "$PINS_FILE"
    echo "Loaded $(echo "${!PINS[@]}" | wc -w) pins from $PINS_FILE"
else
    for k in "${!DEFAULT_PINS[@]}"; do
        PINS["$k"]="${DEFAULT_PINS[$k]}"
    done
fi

# Resolve any "main" refs to current SHA + persist
echo "Resolving refs to commit SHAs..."
for repo in "${!PINS[@]}"; do
    ref="${PINS[$repo]}"
    if [ "$ref" = "main" ] || [ "$ref" = "master" ]; then
        echo "  → ${repo}: resolving ${ref}..."
        sha=$(curl -sL "https://api.github.com/repos/${repo}/commits/${ref}" | \
              python3 -c "import json,sys; print(json.load(sys.stdin)['sha'])" 2>/dev/null)
        if [ -z "$sha" ]; then
            echo "  ✗ Failed to resolve ${repo}#${ref}"
            continue
        fi
        echo "  ✓ ${repo}: ${sha}"
        PINS["$repo"]="$sha"
    else
        echo "  → ${repo}: already pinned to ${ref:0:12}"
    fi
done

# Persist resolved pins back to the file (THE FIX from v0.9.1 — SHAs now stick)
{
    echo "# Cherry-pick commit pins"
    echo "# Updated: $(date -Iseconds)"
    echo "# Refresh with: pin-cherry-picks.sh --refresh"
    echo ""
    for repo in "${!PINS[@]}"; do
        echo "${repo}: ${PINS[$repo]}"
    done
} > "$PINS_FILE"
echo "✓ Pins persisted to $PINS_FILE"

# ─── Skills to lift per source ──────────────────────────────────────────
declare -a GOOGLE=(
    context-engineering code-review-and-quality code-simplification
    debugging-and-error-recovery documentation-and-adrs doubt-driven-development
    idea-refine incremental-implementation planning-and-task-breakdown
    spec-driven-development test-driven-development
)
declare -a MATTPOCOCK=(diagnose improve-codebase-architecture triage zoom-out)
declare -a VERCEL_CODING=(composition-patterns)
declare -a VERCEL_VIZ=(react-best-practices react-view-transitions web-design-guidelines)

fetch_skill() {
    local repo="$1" sha="$2" skill_name="$3" dest="$4"
    local raw_url="https://raw.githubusercontent.com/${repo}/${sha}/skills/${skill_name}/SKILL.md"
    echo "  → ${repo}@${sha:0:8} :: skills/${skill_name}/SKILL.md → ${dest}"

    if ! curl -sL --fail "$raw_url" -o "${dest}/SKILL.md.tmp"; then
        echo "    ✗ Fetch failed (404? Repo restructured?)"
        rm -f "${dest}/SKILL.md.tmp"
        return 1
    fi

    # Update frontmatter with pinned commit
    python3 - "$repo" "$sha" "$skill_name" "$dest" <<'PYEOF'
import sys, re, os
repo, sha, skill_name, dest = sys.argv[1:5]
path = os.path.join(dest, "SKILL.md.tmp")
with open(path) as f:
    content = f.read()
m = re.match(r'^---\n(.*?)\n---\n(.*)', content, re.DOTALL)
if m:
    fm_text, body = m.group(1), m.group(2)
    pin_block = f"upstream:\n  source: {repo}\n  commit: {sha}\n  skill: {skill_name}\n  fetched_at: '" + os.environ.get('NOW','') + "'"
    # Remove old upstream block if present
    fm_text = re.sub(r'upstream:\n(?:  .+\n)*', '', fm_text)
    fm_text += "\n" + pin_block
    with open(os.path.join(dest, "SKILL.md"), "w") as f:
        f.write(f"---\n{fm_text}\n---\n{body}")
    os.remove(path)
PYEOF
    NOW=$(date -Iseconds) python3 - "$repo" "$sha" "$skill_name" "$dest" <<'PYEOF' 2>/dev/null || true
import sys, os
PYEOF
}

NOW=$(date -Iseconds)
export NOW

for skill in "${GOOGLE[@]}"; do
    dest=~/.agents/skills/coding/google/$skill
    mkdir -p "$dest"
    fetch_skill "addyosmani/agent-skills" "${PINS[addyosmani/agent-skills]}" "$skill" "$dest"
done

for skill in "${MATTPOCOCK[@]}"; do
    dest=~/.agents/skills/coding/mattpocock/$skill
    mkdir -p "$dest"
    fetch_skill "mattpocock/skills" "${PINS[mattpocock/skills]}" "$skill" "$dest"
done

for skill in "${VERCEL_CODING[@]}"; do
    dest=~/.agents/skills/coding/vercel/$skill
    mkdir -p "$dest"
    fetch_skill "vercel-labs/agent-skills" "${PINS[vercel-labs/agent-skills]}" "$skill" "$dest"
done

for skill in "${VERCEL_VIZ[@]}"; do
    dest=~/.agents/skills/research/visualization/$skill
    mkdir -p "$dest"
    fetch_skill "vercel-labs/agent-skills" "${PINS[vercel-labs/agent-skills]}" "$skill" "$dest"
done

# shadcn special path — not under skills/
dest=~/.agents/skills/coding/shadcn/shadcn
mkdir -p "$dest"
curl -sL "https://raw.githubusercontent.com/shadcn-ui/ui/${PINS[shadcn-ui/ui]}/skills/shadcn/SKILL.md" \
    -o "$dest/SKILL.md" 2>/dev/null || echo "  ✗ shadcn fetch failed"

echo ""
echo "✓ Cherry-picks pinned. Re-run with --refresh quarterly + run eval suite before bumping."
echo "  Pinned commits: $PINS_FILE"
echo "  Per-skill upstream in SKILL.md frontmatter: upstream.source + upstream.commit"
