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

schaffer_v7_workload$alpha <- as.factor( schaffer_v7_workload$alpha )

library(ggplot2)
library(dplyr)

plot_slopes_grid <- schaffer_v7_workload %>%
  mutate(dimension_num = as.numeric(as.character(dimension))) %>%
  ggplot(aes(x = dimension_num, y = delta_PKG, color = work, fill = work)) +

  # Back to a single color scale mapped only to 'work'
  geom_point(
    position = position_jitterdodge(jitter.width = 0.25, dodge.width = 0.6),
    alpha = 0.2,  # Dropped opacity to let the lines breathe
    size = 1.2,
    shape = 16    # Solid circles
  ) +

  # Linear model fit using linewidth instead of the deprecated size
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE, linewidth = 1.5, alpha = 0.2) +

  # THE FIX: A 2D grid. Rows = alpha, Columns = population_size
  facet_grid(alpha ~ population_size, labeller = label_both) +

  # theme_bw() provides a crisp border for grids, usually printing better in papers
  theme_bw() +
  labs(
    title = "Isolating the Algorithmic Payload: Energy Scaling",
    subtitle = "Comparing execution strategies across Alpha (Rows) and Population Size (Columns)",
    x = "Schaffer Function Dimension",
    y = expression(paste(Delta, " PKG Energy (Joules)")),
    color = "Strategy",
    fill = "Strategy"
  ) +
  scale_color_brewer(palette = "Set1") +
  scale_fill_brewer(palette = "Set1") +
  theme(
    legend.position = "bottom",
    text = element_text(size = 14),
    strip.background = element_rect(fill = "grey95"), # Subtle background for panel labels
    strip.text = element_text(size = 11, face = "bold"),
    panel.spacing = unit(1, "lines")
  )

print(plot_slopes_grid)

