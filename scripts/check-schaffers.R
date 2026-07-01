schaffer_v7_1 <- read.csv("data/schaffer-v1-28-Jun-12-09-12.csv")
schaffer_v7_4 <- read.csv("data/schaffer-v4-29-Jun-14-41-58.csv")
schaffer_v7_3 <- read.csv("data/schaffer-v3-29-Jun-07-42-56.csv")
schaffer_v7_2 <- read.csv("data/schaffer-v2-28-Jun-19-16-54.csv")

schaffer_hot_first <- rbind( schaffer_v7_1, schaffer_v7_2, schaffer_v7_3, schaffer_v7_4)

schaffer_hot_first$work <- "hot-first"

schaffer_regular_v7_2 <- read.csv("data/schaffer-regular-v2-30-Jun-15-19-30.csv")
schaffer_regular_v7_1 <- read.csv("data/schaffer-regular-v1-30-Jun-07-58-45.csv")

schaffer_regular <- rbind( schaffer_regular_v7_1, schaffer_regular_v7_2)
schaffer_regular$work <- "baseline"

schaffer_v7_all <- rbind(schaffer_hot_first,schaffer_regular)

library(dplyr)
source("R/process_deltas.R")

schaffer_v7_workload <- process_deltas( schaffer_v7_all )

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
library(dplyr)

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

library(ggplot2)
library(dplyr)
library(ggnewscale) # Required to mix discrete line colors and continuous point colors

library(ggplot2)
library(dplyr)
library(ggnewscale)
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
    aes(shape = work, color = initial_temp_2, group = work),
    position = position_jitterdodge(jitter.width = 0.25, dodge.width = 1),
    size = 1.8,
    alpha = 0.8
  ) +
  # THE FIX: Focus the gradient on the IQR and squish the outliers
  scale_color_viridis_c(
    option = "inferno",
    name = "Initial Temp 2 (°C)",
    limits = c(36.8, 42),      # Stretches the palette across the dense data range
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
