#!/usr/bin/env Rscript
# medical-research-renv.R
# Installs the air-gapped medical-research R stack. Locks via `renv::snapshot()`
# into renv.lock for reproducibility.
#
# Usage: Rscript ~/local-agent-setup/setup-prompts/medical-research-renv.R
# After install: a renv.lock file is created in the current project.

if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv", repos = "https://cran.rstudio.com")
}

renv::init(bare = TRUE, restart = FALSE)

# ─── Tidyverse + data wrangling ─────────────────────────────────────────
packages_tidy <- c(
  "tidyverse",       # dplyr, ggplot2, tidyr, purrr, readr, tibble, stringr, forcats
  "janitor",         # clean column names, tabulation
  "naniar",          # missing data viz
  "skimr",           # quick data summary
  "vroom",           # fast CSV
  "arrow",           # parquet
  "DBI",
  "duckdb"
)

# ─── Statistical analysis ───────────────────────────────────────────────
packages_stats <- c(
  "gtsummary",       # publication-ready Table 1 (JAMA/NEJM/Lancet styles)
  "broom",           # tidy model outputs
  "broom.mixed",
  "survival",
  "survminer",
  "ggsurvfit",       # KM curves — pillar 5 km-curve skill backend
  "cmprsk",          # competing risks
  "lme4",            # mixed models
  "nlme",
  "emmeans",         # marginal means / post-hoc
  "marginaleffects",
  "lavaan",          # SEM
  "tidymodels",      # ML pipelines
  "pROC",            # ROC curves
  "rms"              # Frank Harrell's regression modeling strategies
)

# ─── Meta-analysis ──────────────────────────────────────────────────────
packages_meta <- c(
  "meta",            # forest plots, heterogeneity
  "metafor",         # the canonical meta-analysis package
  "robumeta",        # robust variance estimation
  "dmetar"           # Cochrane Doing Meta-Analysis companion
)

# ─── Power analysis ─────────────────────────────────────────────────────
packages_power <- c(
  "pwr",
  "WebPower",
  "simr"             # power for mixed models via simulation
)

# ─── Visualization ──────────────────────────────────────────────────────
packages_viz <- c(
  "ggrepel",         # non-overlapping labels
  "patchwork",       # multi-panel layouts (Pillar 5 nature-figure backend)
  "cowplot",
  "ggsci",           # journal-themed palettes (NEJM, Lancet, JAMA, NPG, AAAS)
  "ggdist",          # distributions
  "tidybayes",
  "ggsankey",        # patient-flow Sankey (CONSORT)
  "ggalluvial",
  "scales",
  "RColorBrewer",
  "viridis",
  "colorspace"       # OKLCH/OKlab via `farver`
)

# ─── Bayesian ───────────────────────────────────────────────────────────
packages_bayes <- c(
  "rstan",           # may need: brew install rstan separately for compilation
  "brms",
  "bayesplot"
)

# ─── Local LLM bridge ───────────────────────────────────────────────────
packages_llm <- c(
  "mall",            # mlverse: R↔Ollama/OpenAI-compat bridge (Pillar 3 analysis-run backend)
  "ellmer",          # Posit: LLM tool calling in R
  "chatlas",         # alternative LLM client
  "chattr"           # older but stable
)

# ─── Reporting (Quarto, Markdown, LaTeX) ────────────────────────────────
packages_report <- c(
  "rmarkdown",
  "knitr",
  "quarto",
  "officer",         # generate Word docs
  "flextable",       # publication tables in Word
  "kableExtra",
  "DT"
)

# ─── Combine + install ──────────────────────────────────────────────────
all_packages <- c(
  packages_tidy,
  packages_stats,
  packages_meta,
  packages_power,
  packages_viz,
  packages_bayes,
  packages_llm,
  packages_report
)

# Install with renv
renv::install(
  all_packages,
  repos = c(CRAN = "https://cran.rstudio.com"),
  prompt = FALSE,
  rebuild = FALSE
)

# Snapshot to renv.lock
renv::snapshot(prompt = FALSE)

# Verify key packages load
key_packages <- c("tidyverse", "gtsummary", "survival", "meta", "mall", "quarto")
for (pkg in key_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(sprintf("FAIL: %s did not install correctly", pkg))
  }
}

cat("─────────────────────────────────────\n")
cat("R medical-research stack installed.\n")
cat("Total packages:", length(all_packages), "\n")
cat("renv.lock:", file.path(getwd(), "renv.lock"), "\n")
cat("─────────────────────────────────────\n")
