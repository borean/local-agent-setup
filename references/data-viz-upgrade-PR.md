# PR: Data-Viz Skill Upgrade

**Target**: Bora's existing data-viz skill (in his Claude Code skills directory)
**Goal**: integrate the design intel surfaced from his WhatsApp curation without replacing the skill — additive only.

This is a PR-style spec. Hand it to your frontier LLM (or apply yourself) against your existing skill file.

---

## What's new

5 patterns to add. Each is its own subsection in the skill. Each cites where it comes from. Each has a 1-line "when to apply."

---

## 1. OKLCH as the default color model

**Add to the "Color" section of the skill** (or create one):

```markdown
## Color: use OKLCH for all chart palettes

Default to the OKLCH color model, not HSL or RGB. OKLCH is perceptually uniform — equal numerical distances correspond to equal perceived distances. Random hue slider movements stay harmonious.

**For categorical palettes (≤8 categories)**:
- Fix lightness L=65, chroma C=0.15
- Rotate hue H in steps of 360/n degrees from a base hue (default base: 230 = blue)
- Output as `oklch(65% 0.15 230)`, `oklch(65% 0.15 275)`, ... etc

**For sequential palettes (numeric scale)**:
- Fix hue H, vary L from 95 → 25 (light to dark), keep C constant
- Use viridis or rocket as fallback if OKLCH unsupported

**For diverging palettes (negative ↔ positive around zero)**:
- Two-tail OKLCH: blue (H=230) descending L → grey at zero → red (H=30) descending L

**Tools that speak OKLCH natively in 2026**:
- `ggplot2::scale_color_oklch()` (R, via `farver` package)
- `matplotlib` via the `colorspacious` package
- CSS Color Module 4 native browser support
- shadcn/ui v4 ships OKLCH by default

**Why**: any random hue you pick stays in harmony with its neighbors. No more "ugh, those greens clash with the blue."

**Credit**: surfaced via @pie6k tweet on OKLCH; principle from Björn Ottosson's 2020 Oklab paper.
```

---

## 2. Wong palette for color-blind safety

**Add to the same "Color" section**:

```markdown
### Color-blind safe palette: Bang Wong (Nature Methods 2011)

For any chart that will be published, default to the Wong 8-color palette:

| # | Name | Hex | OKLCH |
|---|---|---|---|
| 1 | Black | #000000 | oklch(0% 0 0) |
| 2 | Orange | #E69F00 | oklch(72% 0.15 64) |
| 3 | Sky Blue | #56B4E9 | oklch(75% 0.10 220) |
| 4 | Bluish Green | #009E73 | oklch(60% 0.13 165) |
| 5 | Yellow | #F0E442 | oklch(91% 0.16 100) |
| 6 | Blue | #0072B2 | oklch(50% 0.13 250) |
| 7 | Vermillion | #D55E00 | oklch(60% 0.18 35) |
| 8 | Reddish Purple | #CC79A7 | oklch(63% 0.12 350) |

Safe across deuteranopia, protanopia, and tritanopia.

**When to use**: every figure for a clinical/journal publication. Override only if you have a specific reason.

**Credit**: Bang Wong, "Points of view: Color blindness," Nature Methods 8, 441 (2011).
```

---

## 3. Emil Kowalski timing rules — only for interactive viz

**Add to a new "Motion" section** (only relevant for HTML/JS dashboards, not static PDF figures):

```markdown
## Motion (interactive viz only — D3.js, Plotly hover, decks-bora)

For animated transitions in interactive charts:

- **Micro-interactions** (hover highlights, tooltip appears): **100-150ms**
- **UI element transitions** (filter panel slides, dropdown opens): **150-250ms**
- **Modal / large panel transitions**: **200-300ms**
- **Easing**: `ease-out` for entrance, `ease-in-out` for in-screen movement, never `linear`

For element-state changes:
- Hover state: `transform: scale(0.97)` on `:active` for tactile feedback
- Entrance animation: from `scale(0.95)` to `scale(1)`, not from `scale(0)` — balloon, not nothingness

**When to use**: any chart that has hover, click, or filter interaction. Skip for static PDF/SVG outputs.

**Credit**: Emil Kowalski's "Agents with Taste" — taste rules are extractable, not vibes.
```

---

## 4. nature-figure pattern: SVG + 300dpi PNG multi-panel

**Add as a new "Publication-grade output" section**:

```markdown
## Publication-grade Matplotlib output (nature-figure style)

For figures destined for submission, default to this pattern:

```python
import matplotlib.pyplot as plt
import matplotlib as mpl

# Set publication defaults
mpl.rcParams.update({
    'font.family': 'Arial',          # or 'Helvetica' if available
    'font.size': 8,                  # 8pt min for axis labels
    'axes.titlesize': 9,             # 9pt panel titles
    'axes.labelsize': 8,
    'xtick.labelsize': 7,
    'ytick.labelsize': 7,
    'legend.fontsize': 7,
    'axes.linewidth': 0.5,
    'lines.linewidth': 1.0,
    'lines.markersize': 4,
    'figure.dpi': 300,
    'savefig.dpi': 300,
    'savefig.bbox': 'tight',
    'svg.fonttype': 'none',          # text stays as text in SVG, not paths
})

# Multi-panel figure (e.g., 2x2)
fig, axes = plt.subplots(2, 2, figsize=(7.0, 5.5))  # max 7" wide for single-column

# Panel labels (a, b, c, d) in upper-left corner of each panel
for ax, label in zip(axes.flat, 'abcd'):
    ax.text(-0.18, 1.08, label, transform=ax.transAxes,
            fontsize=10, fontweight='bold', va='top')

# ... actual plots in each axes ...

# Always save BOTH formats:
fig.savefig('figure.svg', format='svg')     # editable in Illustrator/Inkscape
fig.savefig('figure.png', format='png', dpi=300)  # for Word/Quarto
```

**Tabular numbers** for axis ticks and any number that appears in text:

```python
plt.rcParams['mathtext.fontset'] = 'custom'
plt.rcParams['mathtext.rm'] = 'Arial'
# In ggplot2 R equivalent: + theme(text = element_text(family = "Inter", face = "tabular-nums"))
```

**Why**: Journal submission requirements consistently demand ≥300 DPI rasters AND vector SVG. Saving both at once means one less revision round.

**Credit**: Yuan1z0825's [nature-skills](https://github.com/Yuan1z0825/nature-skills) repo (4.5k⭐). Pattern lifted; defaults adjusted for our clinical context.
```

---

## 5. Figure validation gate

**Add a new section at the end of the skill**:

```markdown
## Figure validation (run before declaring "done")

Every figure passes these checks before saving:

1. **Resolution**: rasters ≥300 DPI
2. **Fonts**: all text ≥8pt; no embedded raster fonts
3. **Palette**: Wong palette unless explicitly overridden
4. **Color-blind simulation**: render the figure under deuteranopia simulation (use `colorspacious.cspace_convert` in Python or `colorBlindness` package in R); inspect for legibility loss
5. **Label overlap**: no overlapping axis labels, legend entries, or panel labels
6. **Turkish character rendering**: if the figure has any Turkish ş, ğ, ı, İ, ç, ö, ü — render in PDF preview to confirm they appear correctly (some Matplotlib fonts mangle ı)
7. **Tabular-nums for numbers**: all numeric axis ticks and in-text numbers use tabular-nums

If any check fails, fix and re-render. Don't ship a figure that fails check 4.
```

---

## Summary of imports for your existing skill

Add a `## Imports & Influences` block at the top of your skill:

```markdown
## Imports & Influences

This skill incorporates patterns from:
- @pie6k — OKLCH color model
- Bang Wong (Nature Methods 2011) — color-blind safe palette
- Emil Kowalski — animation timing rules ("Agents with Taste")
- Yuan1z0825 — nature-skills Matplotlib publication pattern
- Cole Nussbaumer Knaflic — Storytelling with Data (general philosophy)

Originally adapted via: local-agent-setup v0.3.0 PR
```

---

## Don't change

- Your existing chart-type selection logic (keep)
- Your existing R/Python emit patterns (keep)
- Your existing figure-pipeline integration (keep)
- Anything that already works

---

## Verification after applying

Run the skill on a known input from your existing portfolio. Compare output to your last published figure. Differences should be:
- Better color choice (OKLCH/Wong)
- Better print quality (300 DPI SVG+PNG)
- No regressions in chart-type or data accuracy

If you see a regression, the PR is wrong somewhere. File an issue at local-agent-setup with the input + before/after outputs.
