schaffer_v7_1 <- read.csv("data/schaffer-v1-28-Jun-12-09-12.csv")
schaffer_v7_4 <- read.csv("data/schaffer-v4-29-Jun-14-41-58.csv")
schaffer_v7_3 <- read.csv("data/schaffer-v3-29-Jun-07-42-56.csv")
schaffer_v7_2 <- read.csv("data/schaffer-v2-28-Jun-19-16-54.csv")

schaffer_hot_first <- rbind( schaffer_v7_1, schaffer_v7_2, schaffer_v7_3, schaffer_v7_4)

schaffer_hot_first$work <- "hot-first"

schaffer_regular_v7_2 <- read.csv("data/schaffer-regular-v2-30-Jun-15-19-30.csv")
schaffer_regular_v7_1 <- read.csv("data/schaffer-regular-v1-30-Jun-07-58-45.csv")
schaffer_regular_v7_3 <- read.csv("data/schaffer-regular-v3-1-Jul-07-32-30.csv")
schaffer_regular_v7_4 <- read.csv("data/schaffer-regular-v4-1-Jul-14-06-23.csv")

schaffer_regular <- rbind( schaffer_regular_v7_1, schaffer_regular_v7_2)
schaffer_regular$work <- "baseline"

schaffer_v7_all <- rbind(schaffer_hot_first,schaffer_regular)

library(dplyr)
source("R/process_deltas.R")

schaffer_v7_workload <- process_deltas( schaffer_v7_all )
saveRDS(schaffer_v7_workload, file="data/schaffer_v7_workload.rds")

schaffer_v7_workload$dimension <- as.factor( schaffer_v7_workload$dimension)
schaffer_v7_workload$alpha <- as.factor( schaffer_v7_workload$alpha )

schaffer_time_model <- glm( delta_seconds ~ work*dimension*population_size*alpha + evaluations, data=schaffer_v7_workload )

schaffer_temp1_model <- glm( initial_temp_1 ~ work*dimension*population_size*alpha, data=schaffer_v7_workload )
schaffer_temp2_model <- glm( initial_temp_2 ~ work*dimension*population_size*alpha, data=schaffer_v7_workload )

schaffer_v7_workload$residual_time <- residuals(schaffer_time_model)
schaffer_v7_workload$residual_initial_temp_1 <- residuals( schaffer_temp1_model)
schaffer_v7_workload$residual_initial_temp_2 <- residuals( schaffer_temp2_model)

schaffer_delta_pkg_model <- glm( delta_PKG ~ residual_initial_temp_1*residual_initial_temp_2 +
                                   I(residual_initial_temp_1^2)*I(residual_initial_temp_2^2)+
                                   work*dimension*population_size*alpha+
                                   residual_time+I(residual_time^2)+
                                   evaluations,
                                 data=schaffer_v7_workload
                                   )

anova_schaffer_delta_pkg_model <- anova( schaffer_delta_pkg_model)

library(ggplot2)

# ---------------------------------------------------------
# Plot A: The Variance Funnel (Proving the SNR Boost)
# Visualizes the reduction in baseline noise/variance.
# ---------------------------------------------------------
ggplot(schaffer_v7_workload, aes(x = work, y = delta_PKG, fill = work)) +
  geom_violin(alpha = 0.4, color = NA) +
  geom_boxplot(width = 0.2, outlier.shape = NA, alpha = 0.8) +
  geom_jitter(width = 0.15, alpha = 0.2, size = 1) +
  theme_minimal() +
  labs(
    title = "Energy Variance: Hot-First vs. Baseline",
    subtitle = "Enforcing a hot-first state removes chaotic hardware 'spin-up' noise",
    x = "Execution Strategy",
    y = expression(paste(Delta, " PKG Energy (Joules)"))
  ) +
  theme(
    legend.position = "none",
    text = element_text(size = 14)
  )


library(ggnewscale) # Required to mix discrete line colors and continuous point colors
library(scales) # Required for the 'squish' function

plot_slopes_temp_focused <- schaffer_v7_workload %>%
  mutate(dimension_num = as.numeric(as.character(dimension))) %>%
  ggplot(aes(x = dimension_num, y = delta_PKG)) +

  # --- LAYER 1: The Fit Lines ---
  geom_smooth(
    aes(color = work, fill = work),
    method = "lm", formula = y ~ x, se = TRUE, linewidth = 1.5, alpha = 0.2
  ) +
  scale_color_brewer(palette = "Set1", name = "Strategy") +
  scale_fill_brewer(palette = "Set1", name = "Strategy") +

  # --- THE MAGIC RESET ---
  new_scale_color() +

  # --- LAYER 2: The Points ---
  geom_point(
    aes(shape = work, color = initial_temp_1, group = work),
    position = position_jitterdodge(jitter.width = 0.25, dodge.width = 1),
    size = 1.8,
    alpha = 0.8
  ) +
  # THE FIX: Focus the gradient on the IQR and squish the outliers
  scale_color_viridis_c(
    option = "inferno",
    name = "Initial Temp 1 (°C)",
    limits = c(41, 43.5),      # Stretches the palette across the dense data range
    oob = scales::squish       # Forces anything > 42 to take the maximum bright color
  ) +
  scale_shape_manual(values = c(16, 17), name = "Strategy") +

  # --- FACETING ---
  facet_grid(alpha ~ population_size, labeller = label_both) +

  theme_bw() +
  labs(
    title = "Isolating the Algorithmic Payload: Thermal Stability vs. Baseline Noise",
    subtitle = "Color scale constrained to 36.8-42°C to highlight IQR variance",
    x = "Schaffer Function Dimension",
    y = expression(paste(Delta, " PKG Energy (Joules)"))
  ) +
  theme(
    legend.position = "right",
    text = element_text(size = 14),
    strip.background = element_rect(fill = "grey95"),
    strip.text = element_text(size = 11, face = "bold"),
    panel.spacing = unit(1, "lines")
  )

print(plot_slopes_temp_focused)

# ============================================================
# Where does hot-first actually reduce delta_PKG?
# Treatment-effect curve across population_size, faceted by
# dimension x alpha, with a zero reference line.
# ============================================================

library(emmeans)
library(dplyr)
library(ggplot2)

mod <- schaffer_delta_pkg_model  # adjust if your fitted object has a different name

# --- 1. Sweep population_size across its observed range ---------
pop_range <- range(schaffer_v7_workload$population_size, na.rm = TRUE)
pop_seq   <- seq(pop_range[1], pop_range[2], length.out = 30)

# --- 2. Reference grid: work x dimension x alpha x population_size,
#        other numeric covariates (temp1/2, residual_time, evaluations)
#        held at their median -----------------------------------------
emm <- emmeans(mod, ~ work | dimension * alpha * population_size,
               at = list(population_size = pop_seq),
               cov.reduce = median)

# --- 3. hot-first minus baseline, with proper SEs from the model's
#        covariance matrix (not hand-added coefficients) --------------
work_effect <- contrast(emm, method = "revpairwise") %>%
  confint() %>%
  as.data.frame()
# confirmed from your output: contrast = "(hot-first) - baseline",
# so negative = hot-first saves energy, as used in the plot below.

# --- 4. Quantify the headline claim ------------------------------------
pct_favorable <- mean(work_effect$estimate < 0) * 100
cat(sprintf("hot-first reduces predicted energy in %.1f%% of the tested\n",
            pct_favorable),
    "dimension x population_size x alpha combinations.\n")

# --- 5. Plot -------------------------------------------------------------
ggplot(work_effect, aes(x = population_size, y = estimate)) +
  geom_ribbon(aes(ymin = pmin(estimate, 0), ymax = 0),
              fill = "#1b9e77", alpha = 0.35) +
  geom_ribbon(aes(ymin = 0, ymax = pmax(estimate, 0)),
              fill = "#d95f02", alpha = 0.35) +
  geom_ribbon(aes(ymin = lower.CL, ymax = upper.CL),
              fill = "grey30", alpha = 0.15) +
  geom_line(linewidth = 0.9) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey30") +
  facet_grid(dimension ~ alpha, labeller = label_both) +
  labs(
    x = "population_size",
    y = "hot-first \u2212 baseline (predicted \u0394PKG)",
    title = "Where hot-first reduces energy vs. where it doesn't",
    subtitle = paste0(
      "Green = hot-first saves energy. Orange = hot-first costs more. ",
      "Grey band = 95% CI.\n",
      sprintf("Favorable in %.1f%% of the swept parameter space.", pct_favorable)
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(strip.text = element_text(face = "bold"))

# Show cutoff

# ============================================================
# Raw (non-residualized) operating-context variables vs delta_PKG
# ------------------------------------------------------------
# Unlike the earlier model-based chart, this is NOT adjusted for
# dimension / population_size / alpha / evaluations -- it's the
# raw relationship, fit fresh per protocol. Cutoffs can legitimately
# differ between hot-first and baseline here.
# ============================================================

library(dplyr)
library(tidyr)
library(ggplot2)

raw_long <- schaffer_v7_workload %>%
  select(work, delta_PKG, initial_temp_1, initial_temp_2, delta_seconds) %>%
  pivot_longer(cols = c(initial_temp_1, initial_temp_2, delta_seconds),
               names_to = "variable", values_to = "x")

work_levels <- levels(factor(schaffer_v7_workload$work))
pal <- setNames(c("#d95f02", "#1b9e77"), work_levels)

# --- 1. Per-protocol quadratic fit -> real, unadjusted cutoffs ----
peak_df <- raw_long %>%
  group_by(variable, work) %>%
  group_modify(~{
    fit <- lm(delta_PKG ~ x + I(x^2), data = .x)
    b <- coef(fit)
    if (unname(b["I(x^2)"]) < 0) {
      tibble(peak_x = unname(-b["x"] / (2 * b["I(x^2)"])))
    } else {
      tibble(peak_x = NA_real_)  # positive/zero quadratic term -> no peak
    }
  }) %>%
  ungroup()

# --- 2. Observed distributions by protocol -------------------------
dens_df <- raw_long %>%
  group_by(variable, work) %>%
  group_modify(~{
    d <- density(.x$x, na.rm = TRUE, n = 512)
    tibble(x = d$x, d = d$y)
  }) %>%
  ungroup()

y_range <- range(schaffer_v7_workload$delta_PKG, na.rm = TRUE)
dens_df <- dens_df %>%
  group_by(variable, work) %>%
  mutate(d_scaled = y_range[1] + (d / max(d)) * diff(y_range) * 0.2) %>%
  ungroup()

# --- 3. Labels -------------------------------------------------------
nice_labels <- c(
  initial_temp_1 = "Initial temp \u2014 component 1 (raw)",
  initial_temp_2 = "Initial temp \u2014 component 2 (raw)",
  delta_seconds  = "Runtime, seconds (raw)"
)

# --- 4. The plot -------------------------------------------------------
ggplot() +
  geom_area(data = dens_df, aes(x = x, y = d_scaled, fill = work),
            alpha = 0.25, position = "identity") +
  geom_smooth(data = raw_long, aes(x = x, y = delta_PKG, colour = work, fill = work),
              method = "lm", formula = y ~ x + I(x^2), se = TRUE,
              alpha = 0.15, linewidth = 1) +
  geom_vline(data = filter(peak_df, !is.na(peak_x)),
             aes(xintercept = peak_x, colour = work),
             linetype = "dotted", show.legend = FALSE) +
  facet_wrap(~variable, scales = "free_x", labeller = as_labeller(nice_labels)) +
  scale_colour_manual(values = pal, name = "Protocol") +
  scale_fill_manual(values = pal, name = "Protocol") +
  labs(
    x = NULL,
    y = expression(Delta*"PKG (energy)"),
    title = "Raw operating conditions vs. energy, by protocol",
    subtitle = paste(
      "Curve: quadratic fit to the RAW (unadjusted) relationship, per protocol.",
      "Shaded area: where each protocol's actual raw values sit.",
      "Dotted line: cutoff, only where that protocol's curve has a real peak.",
      sep = "\n"
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "top", plot.subtitle = element_text(size = 9))

# --- 5. Print the actual cutoff values / confirm which curves peak ---
peak_df


# analyze mediation

library(dplyr)

# --- Path a: does `work` genuinely shift the raw mediators,
#     controlling for algorithm parameters (not just the raw
#     marginal comparison from the t-test a few turns back)? -------
mediator_temp1 <- lm(initial_temp_1 ~ work + dimension * population_size * alpha,
                     data = schaffer_v7_workload)
cat("work -> initial_temp_1, controlling for algorithm params:\n")
print(summary(mediator_temp1)$coefficients["workhot-first", ])

mediator_temp2 <- lm(initial_temp_2 ~ work + dimension * population_size * alpha,
                     data = schaffer_v7_workload)
cat("\nwork -> initial_temp_2, controlling for algorithm params:\n")
print(summary(mediator_temp2)$coefficients["workhot-first", ])

mediator_time <- lm(delta_seconds ~ work + dimension * population_size * alpha,
                    data = schaffer_v7_workload)
cat("\nwork -> delta_seconds, controlling for algorithm params:\n")
print(summary(mediator_time)$coefficients["workhot-first", ])
# negative & significant here = hot-first genuinely lowers temp/duration
# net of algorithm settings, not just as a raw marginal artifact.

# --- Path c' (direct effect): refit with RAW temp/time instead of
#     residualized, but still controlling for algorithm parameters.
#     This is the clean version of what the raw chart was gesturing at.
direct_model <- glm(delta_PKG ~ initial_temp_1 * initial_temp_2 +
                      I(initial_temp_1^2) * I(initial_temp_2^2) +
                      work * dimension * population_size * alpha +
                      delta_seconds + I(delta_seconds^2) + evaluations,
                    data = schaffer_v7_workload)

cat("\nDirect work effect, controlling for RAW temp/time AND algorithm params:\n")
print(summary(direct_model)$coefficients["workhot-first", ])
# If this is small, non-significant, or positive (unfavorable),
# it confirms the paper's real story isn't "hot-first is inherently
# more efficient" -- it's "hot-first alters the thermal/temporal
# profile, and THAT is what saves the energy."


#-------
#

library(dplyr)

# Uses mediator_temp1, mediator_temp2, mediator_time, and direct_model
# already fit in your session.

base_covariates <- schaffer_v7_workload %>%
  select(dimension, population_size, alpha, evaluations)

grid_baseline <- base_covariates %>% mutate(work = "baseline")
grid_hotfirst <- base_covariates %>% mutate(work = "hot-first")

# --- "Typical" (fitted) mediator values under EACH protocol label,
#     holding each row's own dimension/population/alpha fixed --------
grid_baseline$initial_temp_1 <- predict(mediator_temp1, newdata = grid_baseline)
grid_baseline$initial_temp_2 <- predict(mediator_temp2, newdata = grid_baseline)
grid_baseline$delta_seconds  <- predict(mediator_time,  newdata = grid_baseline)

grid_hotfirst$initial_temp_1 <- predict(mediator_temp1, newdata = grid_hotfirst)
grid_hotfirst$initial_temp_2 <- predict(mediator_temp2, newdata = grid_hotfirst)
grid_hotfirst$delta_seconds  <- predict(mediator_time,  newdata = grid_hotfirst)

# --- Total effect: work switches AND mediators shift to their own
#     protocol's typical level ------------------------------------------
pred_total_hotfirst <- predict(direct_model, newdata = grid_hotfirst)
pred_total_baseline <- predict(direct_model, newdata = grid_baseline)
total_effect <- mean(pred_total_hotfirst) - mean(pred_total_baseline)

# --- Direct effect: work switches, but mediators are FROZEN at
#     baseline's typical level (isolates the protocol-only effect,
#     matching what direct_model's workhot-first coefficient tested) ---
grid_hotfirst_frozen_mediators <- grid_hotfirst %>%
  mutate(initial_temp_1 = grid_baseline$initial_temp_1,
         initial_temp_2 = grid_baseline$initial_temp_2,
         delta_seconds  = grid_baseline$delta_seconds)

pred_direct_hotfirst <- predict(direct_model, newdata = grid_hotfirst_frozen_mediators)
direct_effect <- mean(pred_direct_hotfirst) - mean(pred_total_baseline)

# --- Indirect effect: what's left ---------------------------------------
indirect_effect <- total_effect - direct_effect

cat(sprintf(
  "Total effect (hot-first - baseline):    %7.2f\nDirect effect (protocol only):          %7.2f\nIndirect effect (via thermal profile):  %7.2f\n%% of total that is indirect:            %7.1f%%\n",
  total_effect, direct_effect, indirect_effect,
  100 * indirect_effect / total_effect
))

# checks

library(boot)
library(dplyr)

# Wraps path-a (mediator models), path-c' (direct model), and the
# g-computation decomposition into one function of the data, so
# resampling propagates uncertainty from ALL of it, not just one piece.

mediation_pipeline <- function(data, indices) {
  d <- data[indices, ]

  m_temp1 <- lm(initial_temp_1 ~ work + dimension * population_size * alpha, data = d)
  m_temp2 <- lm(initial_temp_2 ~ work + dimension * population_size * alpha, data = d)
  m_time  <- lm(delta_seconds  ~ work + dimension * population_size * alpha, data = d)

  m_direct <- glm(delta_PKG ~ initial_temp_1 * initial_temp_2 +
                    I(initial_temp_1^2) * I(initial_temp_2^2) +
                    work * dimension * population_size * alpha +
                    delta_seconds + I(delta_seconds^2) + evaluations,
                  data = d)

  base_cov <- d %>% select(dimension, population_size, alpha, evaluations)
  g_base <- base_cov %>% mutate(work = "baseline")
  g_hot  <- base_cov %>% mutate(work = "hot-first")

  g_base$initial_temp_1 <- predict(m_temp1, newdata = g_base)
  g_base$initial_temp_2 <- predict(m_temp2, newdata = g_base)
  g_base$delta_seconds  <- predict(m_time,  newdata = g_base)
  g_hot$initial_temp_1  <- predict(m_temp1, newdata = g_hot)
  g_hot$initial_temp_2  <- predict(m_temp2, newdata = g_hot)
  g_hot$delta_seconds   <- predict(m_time,  newdata = g_hot)

  pred_hot  <- predict(m_direct, newdata = g_hot)
  pred_base <- predict(m_direct, newdata = g_base)
  total <- mean(pred_hot) - mean(pred_base)

  g_hot_frozen <- g_hot %>%
    mutate(initial_temp_1 = g_base$initial_temp_1,
           initial_temp_2 = g_base$initial_temp_2,
           delta_seconds  = g_base$delta_seconds)
  direct <- mean(predict(m_direct, newdata = g_hot_frozen)) - mean(pred_base)

  indirect <- total - direct

  c(total = total, direct = direct, indirect = indirect,
    pct_indirect = 100 * indirect / total)
}

# NOTE: this refits 4 models per replicate on ~13k rows -- start with
# a small R to confirm it runs cleanly, then scale up.
set.seed(1)
boot_out <- boot(schaffer_v7_workload, mediation_pipeline, R = 200)
boot_out

boot.ci(boot_out, type = "perc", index = 1)  # total effect CI
boot.ci(boot_out, type = "perc", index = 2)  # direct effect CI
boot.ci(boot_out, type = "perc", index = 3)  # indirect effect CI
boot.ci(boot_out, type = "perc", index = 4)  # % mediated CI

# Sanity check: look at the shape of the bootstrap distributions
# before trusting the percentile CIs, especially for % mediated
# (a ratio can be skewed/unstable if any replicate's total effect
# lands near zero).
hist(boot_out$t[, 1], main = "Bootstrap: total effect", xlab = "")
hist(boot_out$t[, 4], main = "Bootstrap: % mediated", xlab = "")

