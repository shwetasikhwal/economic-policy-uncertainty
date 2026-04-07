# =============================================================================
# Spillover Effects of U.S. EPU on Emerging Market Economies
# GMM-PVAR Analysis
#
# Sikhwal S. "Quantifying the spillover effects of U.S. economic policy
# uncertainty on emerging market economies using GMM-PVAR model"
# Russian Journal of Economics, 10 (2024), 229-245.
# DOI: 10.32609/j.ruje.10.128666
#
# Data: 39 EMEs, 2005-2019. Source: IMF IFS + economicpolicyuncertainty.com
# =============================================================================


# =============================================================================
# 1. Install packages (run once, then comment out)
# =============================================================================

# install.packages("readxl")
# install.packages("tidyverse")
# install.packages("vtable")
# install.packages("plm")
# install.packages("panelvar")
# install.packages("ggplot2")
# install.packages("devEMF")
# install.packages("moments")


# =============================================================================
# 2. Load libraries
# =============================================================================

library(readxl)
library(tidyverse)
library(vtable)
library(plm)
library(panelvar)
library(ggplot2)
library(devEMF)
library(moments)


# =============================================================================
# 3. Load and prepare data
# =============================================================================

data1 <- read_excel("EMEData.xlsx")

# Convert to panel data frame
# Panel identifier: id (country) x Year
pdata1 <- pdata.frame(data1, index = c("id", "Year"))


# =============================================================================
# 4. Descriptive statistics (Table B1)
#
# Variables reported in the paper (all in natural log form except interest rate
# which is in percentage form per Section 3.1):
#   lngdp, lncpi, R, lnneer, lnusepu2, lnopu
# Statistics: Mean, Max, Min, Std dev, Skewness, Kurtosis
# =============================================================================

desc_vars <- c("lngdp", "lncpi", "R", "lnneer", "lnusepu2", "lnopu")

desc_labels <- c("GDP", "CPI", "Interest rate", "Exchange rate", "US EPU", "OPU")

desc_stats <- data.frame(
  Variable   = desc_labels,
  Mean       = sapply(desc_vars, function(v) mean(data1[[v]], na.rm = TRUE)),
  Max        = sapply(desc_vars, function(v) max(data1[[v]], na.rm = TRUE)),
  Min        = sapply(desc_vars, function(v) min(data1[[v]], na.rm = TRUE)),
  Std_dev    = sapply(desc_vars, function(v) sd(data1[[v]], na.rm = TRUE)),
  Skewness   = sapply(desc_vars, function(v) skewness(data1[[v]], na.rm = TRUE)),
  Kurtosis   = sapply(desc_vars, function(v) kurtosis(data1[[v]], na.rm = TRUE)),
  row.names  = NULL
)


numeric_cols <- sapply(desc_stats, is.numeric)
desc_stats[numeric_cols] <- round(desc_stats[numeric_cols], 3)
print(desc_stats)


# =============================================================================
# 5. Panel unit root tests (Table B2)
#
# Tests conducted: Im-Pesaran-Shin (IPS) and ADF Fisher, using purtest()
# from the plm package, at levels and first differences for:
#   lngdp, lncpi, R, lnneer, lnusepu2, lnopu
# Both tests include a trend to account for deterministic components.
# Null hypothesis: series has a unit root (non-stationary).
#
# Results reported in Table B2 of the paper:
#   - All series are I(1) — non-stationary at levels, stationary at
#     first differences — except the interest rate (R) which is I(0).
# =============================================================================


# =============================================================================
# 6. Main model — GMM-PVAR with first difference transformation (Table C1)
#
# Endogenous variables: lnusepu2, lncpi, lngdp, R, lnneer
# Exogenous variable:   lnopu (oil price uncertainty, strictly exogenous)
# Transformation:       First difference (fd)
# Estimator:            One-step GMM
# Lag order:            1 (selected by MBIC, Andrews & Lu 2001)
# =============================================================================

ex1 <- pvargmm(
  dependent_vars = c("lnusepu2", "lncpi", "lngdp", "R", "lnneer"),
  lags = 1,
  exog_vars = c("lnopu"),
  transformation = "fd",
  data = pdata1,
  panel_identifier = c("id", "Year"),
  steps = c("onestep"),
  system_instruments = FALSE,
  max_instr_dependent_vars = 30,
  min_instr_dependent_vars = 2L,
  collapse = FALSE
)

summary(ex1)


# =============================================================================
# 7. Main model diagnostics
# =============================================================================

# Lag selection criteria (Andrews & Lu 2001): MBIC, MAIC, MQIC (Table B3)
Andrews_Lu_MMSC(ex1)

# Eigenvalue stability condition (Table B4, Figure B1)
# All eigenvalue moduli must be < 1 for the PVAR system to be stationary
stab_ex1 <- stability(ex1)
print(stab_ex1)
plot(stab_ex1)

# Save stability plot as EMF
emf("stab_ex1_plot.emf", width = 7, height = 5)
plot(stab_ex1)
dev.off()


# =============================================================================
# 8. Impulse response functions — main model (Figure 1)
#
# Generalised IRFs (Pesaran & Shin 1998) — ordering-invariant
# Bootstrapped 95% confidence bands: 1000 draws (Lutkepohl 2005)
# =============================================================================

ex1_girf <- girf(ex1, n.ahead = 8, ma_approx_steps = 8)
ex1_bs   <- bootstrap_irf(ex1,
                           typeof_irf      = c("GIRF"),
                           n.ahead         = 8,
                           nof_Nstar_draws = 1000,
                           confidence.band = 0.95,
                           mc.cores        = 1)

# Quick diagnostic plot
plot(ex1_girf, ex1_bs)


# =============================================================================
# 9. GIRF plot — responses to U.S. EPU shock (Figure 1 in paper)
# =============================================================================

steps <- 1:8

irf_data <- data.frame(
  Steps    = rep(steps, 4),
  Response = c(ex1_girf$lnusepu2[, "lngdp"],
               ex1_girf$lnusepu2[, "lncpi"],
               ex1_girf$lnusepu2[, "lnneer"],
               ex1_girf$lnusepu2[, "R"]),
  Lower    = c(ex1_bs$Lower$lnusepu2[, "lngdp"],
               ex1_bs$Lower$lnusepu2[, "lncpi"],
               ex1_bs$Lower$lnusepu2[, "lnneer"],
               ex1_bs$Lower$lnusepu2[, "R"]),
  Upper    = c(ex1_bs$Upper$lnusepu2[, "lngdp"],
               ex1_bs$Upper$lnusepu2[, "lncpi"],
               ex1_bs$Upper$lnusepu2[, "lnneer"],
               ex1_bs$Upper$lnusepu2[, "R"]),
  Variable = rep(c("RGDP", "CPI", "NEER", "R"), each = length(steps))
)

girf_plot <- ggplot(irf_data, aes(x = Steps)) +
  geom_ribbon(aes(ymin = Lower, ymax = Upper), fill = "#FFA07A", alpha = 0.3) +
  geom_line(aes(y = Response), color = "#FF4500", size = 1.2) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  facet_wrap(~Variable, scales = "free_y") +
  labs(title = "Generalised Impulse Response to US EPU Shock",
       x = "Steps", y = "Response") +
  theme_minimal() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.background  = element_rect(fill = "white", color = NA),
        text             = element_text(size = 12))

print(girf_plot)

# Save as EMF
emf("Generalised_Impulse_Response_Plot.emf", width = 7, height = 5)
print(girf_plot)
dev.off()


# =============================================================================
# 10. Robustness checks
# =============================================================================

# -----------------------------------------------------------------------------
# Robustness 1: Forward orthogonal deviation transformation (Table D1)
# Same model as ex1 but using fod instead of fd
# -----------------------------------------------------------------------------

ex2 <- pvargmm(
  dependent_vars = c("lnusepu2", "lncpi", "lngdp", "R", "lnneer"),
  lags = 1,
  exog_vars = c("lnopu"),
  transformation = "fod",
  data = pdata1,
  panel_identifier = c("id", "Year"),
  steps = c("onestep"),
  system_instruments = FALSE,
  max_instr_dependent_vars = 99,
  min_instr_dependent_vars = 2L,
  collapse = FALSE
)

summary(ex2)

# Diagnostics for robustness 1
Andrews_Lu_MMSC(ex2)
stab_ex2 <- stability(ex2)
print(stab_ex2)
plot(stab_ex2)

# -----------------------------------------------------------------------------
# Robustness 2: Alternative U.S. EPU index — three-component index (Table D2)
# lnusepu1 replaces lnusepu2 as the EPU measure
# -----------------------------------------------------------------------------

ex3 <- pvargmm(
  dependent_vars = c("lnusepu1", "lncpi", "lngdp", "R", "lnneer"),
  lags = 1,
  exog_vars = c("lnopu"),
  transformation = "fd",
  data = pdata1,
  panel_identifier = c("id", "Year"),
  steps = c("onestep"),
  system_instruments = FALSE,
  max_instr_dependent_vars = 99,
  min_instr_dependent_vars = 2L,
  collapse = FALSE
)

summary(ex3)

# Diagnostics for robustness 2
Andrews_Lu_MMSC(ex3)
stab_ex3 <- stability(ex3)
print(stab_ex3)
plot(stab_ex3)

# -----------------------------------------------------------------------------
# Robustness 3: EPU and OPU as predetermined variables (Table D3)
# Treats lnusepu1 and lnopu as weakly exogenous (predetermined)
# to address potential endogeneity of the OPU index
# -----------------------------------------------------------------------------

ex4 <- pvargmm(
  dependent_vars = c("lncpi", "lngdp", "R", "lnneer"),
  predet_vars    = c("lnopu", "lnusepu1"),
  lags = 1,
  transformation = "fd",
  data = pdata1,
  panel_identifier = c("id", "Year"),
  steps = c("onestep"),
  system_instruments = FALSE,
  max_instr_dependent_vars = 99,
  min_instr_dependent_vars = 2L,
  collapse = FALSE
)

summary(ex4)

# Diagnostics for robustness 3
Andrews_Lu_MMSC(ex4)
stab_ex4 <- stability(ex4)
print(stab_ex4)
plot(stab_ex4)
