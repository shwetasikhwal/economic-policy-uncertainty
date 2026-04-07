# Spillover Effects of U.S. EPU on Emerging Market Economies — GMM-PVAR Analysis

Code and data for the paper:

**Sikhwal S.** "Quantifying the spillover effects of U.S. economic policy uncertainty on emerging market economies using GMM-PVAR model."
*Russian Journal of Economics*, 10 (2024), 229–245.
DOI: [10.32609/j.ruje.10.128666](https://doi.org/10.32609/j.ruje.10.128666)

---

## Overview

This repository contains the R code and panel dataset used to quantify how
U.S. economic policy uncertainty (EPU) spills over into the macroeconomic
conditions of emerging market economies (EMEs). Using a GMM estimation of a
panel vector autoregression (PVAR) model on 39 EMEs from 2005 to 2019, the
paper finds that increased U.S. EPU significantly raises CPI, depreciates
emerging market currencies, lowers short-term interest rates, and negatively
impacts real GDP in these economies.

---

## Files

| File | Description |
|------|-------------|
| `GMM_PVAR_Analysis.R` | Full R script: descriptive statistics, GMM-PVAR estimation, impulse response functions, and robustness checks |
| `EMEData_clean.xlsx` | Panel dataset: 39 EMEs, 2005–2019, annual frequency |

---

## Data

**Source:** IMF International Financial Statistics; EPU indices from [economicpolicyuncertainty.com](https://www.economicpolicyuncertainty.com)

**Panel:** 39 emerging market economies (listed in Appendix A of the paper), 2005–2019 (T = 15, N = 39)

### Variables

| Column | Description | Form used in model |
|--------|-------------|-------------------|
| `id` | Country identifier | Panel index |
| `Country` | Country name | Panel index |
| `Year` | Year | Panel index |
| `GDP` | Real GDP (level) | `lngdp` = log(GDP) |
| `CPI` | Consumer Price Index (level) | `lncpi` = log(CPI) |
| `NEER` | Nominal Effective Exchange Rate (level) | `lnneer` = log(NEER) |
| `R` | Short-term interest rate (%) | Used as-is — not logged |
| `USEPU1` | U.S. EPU index — three-component version (level) | `lnusepu1` = log(USEPU1) |
| `USEPU2` | U.S. EPU index — news-based version (level) | `lnusepu2` = log(USEPU2) |
| `lnopu` | Log of Oil Price Uncertainty index | Used directly (no raw column) |

### The two U.S. EPU indices

Both indices are developed by Baker, Bloom & Davis (2016) and retrieved from
[economicpolicyuncertainty.com](https://www.economicpolicyuncertainty.com).

**USEPU2 — News-based EPU index (main model)**
This index is constructed solely from newspaper coverage. It counts daily
articles from the NewsBank Access World News service that simultaneously
mention terms related to the economy, policy, and uncertainty. Raw counts are
normalised against the total number of articles published to account for the
growing number of newspapers over time (from 18 in 1985 to over 1800 by 2008).
This single-component measure is used as the main EPU variable in the paper
because it provides a direct, transparent reflection of public uncertainty
perceptions as reported in the press.

**USEPU1 — Three-component EPU index (robustness check)**
This broader index combines three distinct information sources: (1) newspaper
coverage (same as USEPU2), (2) the number of federal tax code provisions set
to expire in coming years, and (3) disagreement among economic forecasters
about future government spending and inflation. By incorporating tax and
forecaster disagreement components alongside news, USEPU1 captures a wider
dimension of policy uncertainty. It is used in Robustness Check 2 (Table D2)
to verify that the main findings are not sensitive to the choice of EPU measure.
The two indices have a correlation of 0.83 over the sample period.

---

## Methodology

The paper employs a **GMM-PVAR model** (Holtz-Eakin et al. 1988; Sigmund &
Ferstl 2021), estimated using the **one-step first-difference GMM estimator**
(Arellano & Bond 1991). The model treats GDP, CPI, NEER, interest rates, and
U.S. EPU as endogenous variables, with the Oil Price Uncertainty (OPU) index
as a strictly exogenous variable.

**Lag order:** 1 (selected by MBIC criterion, Andrews & Lu 2001)

**Impulse responses:** Generalised IRFs (Pesaran & Shin 1998), ordering-invariant,
with bootstrapped 95% confidence bands (1000 draws)

**Robustness checks:**
1. Forward orthogonal deviation transformation instead of first difference
2. Alternative three-component EPU index (USEPU1) instead of USEPU2
3. U.S. EPU and OPU treated as predetermined (weakly exogenous) variables

---

## Requirements

```r
install.packages(c("readxl", "tidyverse", "vtable", "plm",
                   "panelvar", "ggplot2", "devEMF", "moments"))
```

---

## How to run

1. Place `GMM_PVAR_Analysis.R` and `EMEData_clean.xlsx` in the same folder
2. Open `GMM_PVAR_Analysis.R` in RStudio
3. Set your working directory to that folder: `setwd("path/to/folder")`
4. Run the script section by section

---

## Citation

```
Sikhwal, S. (2024). Quantifying the spillover effects of U.S. economic policy
uncertainty on emerging market economies using GMM-PVAR model.
Russian Journal of Economics, 10, 229–245.
https://doi.org/10.32609/j.ruje.10.128666
```
