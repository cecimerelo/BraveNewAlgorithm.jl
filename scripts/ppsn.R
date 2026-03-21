load("data/icsm_hot_first.rds")

icsme_workload <- icsm_hot_first[ !startsWith(icsm_hot_first$work, "base-"), ]

library(dplyr)
# Compute mean, median and standard deviation of evaluations and generations for every combination of dimension, population_size and max_gens
icsme_workload %>% group_by(dimension,population_size, max_gens) %>%
  summarise(
    evaluations_mean = mean(evaluations),
    evaluations_sd = sd(evaluations),
    evaluations_median = median(evaluations),
    generations_mean = mean(generations),
    generations_sd = sd(generations),
    generations_median = median(generations),
    diff_fitness_mean = mean(diff_fitness),
    diff_fitness_sd = sd(diff_fitness),
    diff_fitness_median = median(diff_fitness)
  ) -> summary_icsme_workload


ppsn_hc_1 <- read.csv("data/PPSN-speedup-hc-64-1-8-Mar-20-24-22.csv")
ppsn_hc_1_workload <- ppsn_hc_1[ !startsWith(ppsn_hc_1$work, "base-"), ]

ppsn_hc_1_workload %>% group_by(dimension, population_size, max_gens) %>%
  summarise(
    evaluations_mean = mean(evaluations),
    evaluations_sd = sd(evaluations),
    evaluations_median = median(evaluations),
    generations_mean = mean(generations),
    generations_sd = sd(generations),
    generations_median = median(generations),
    diff_fitness_mean = mean(diff_fitness),
    diff_fitness_sd = sd(diff_fitness),
    diff_fitness_median = median(diff_fitness)
  ) -> summary_ppsn_hc_1


# boxplot diff_fitness for every combination of dimension, population_size and max_gens for icsme_workload comparing with ppsn_hc_1_workload

library(ggplot2)
# create a dataframe with the diff_fitness of both workloads

diff_fitness_icsme_vs_hc <- rbind(
  data.frame(workload = "icsme", dimension = icsme_workload$dimension, population_size = icsme_workload$population_size, max_gens = icsme_workload$max_gens, diff_fitness = icsme_workload$diff_fitness),
  data.frame(workload = "ppsn_hc_1", dimension = ppsn_hc_1_workload$dimension, population_size = ppsn_hc_1_workload$population_size, max_gens = ppsn_hc_1_workload$max_gens, diff_fitness = ppsn_hc_1_workload$diff_fitness)
)

# adapt y axis to the effective dimension for every combination, I can't see anything for dimension 3 and 5
ggplot(diff_fitness_icsme_vs_hc, aes(x = workload, y = diff_fitness)) +
  geom_boxplot() +
  facet_grid(dimension ~ population_size + max_gens, scales = "free_y") +
  labs(title = "Diff Fitness Comparison between ICSME and PPSN HC 1", x = "Workload", y = "Diff Fitness") +

  theme_minimal()


# Work with energy
#

ppsn_hc_2 <- read.csv("data/PPSN-speedup-hc-64-2-9-Mar-08-50-11.csv")
ppsn_hc_3 <- read.csv("data/PPSN-speedup-hc-64-3-9-Mar-10-11-54.csv")
ppsn_hc_4 <- read.csv("data/PPSN-speedup-hc-64-4-9-Mar-11-46-38.csv")

ppsn_hc <- rbind(ppsn_hc_1, ppsn_hc_2, ppsn_hc_3, ppsn_hc_4)

ppsn_hc_baseline <- ppsn_hc[ startsWith(ppsn_hc$work, "base-"), ]

ppsn_hc_baseline %>% group_by(dimension, population_size) %>%
  summarise(
    PKG_mean = mean(PKG),
    PKG_sd = sd(PKG),
    PKG_median = median(PKG),
    PKG_trim_mean = mean(PKG, trim = 0.2),
    PKG_iqr = IQR(PKG)
  ) -> summary_ppsn_hc_baseline

icsme_baseline <- icsm_hot_first[ startsWith(icsm_hot_first$work, "base-"), ]
icsme_baseline %>% group_by(dimension, population_size) %>%
  summarise(
    PKG_mean = mean(PKG),
    PKG_sd = sd(PKG),
    PKG_median = median(PKG),
    PKG_trim_mean = mean(PKG, trim = 0.2),
    PKG_iqr = IQR(PKG)
  ) -> summary_icsme_baseline

# Model PKG
ppsn_hc_baseline$dimension <- as.factor(ppsn_hc_baseline$dimension)
ppsn_hc_baseline$population_size <- as.factor(ppsn_hc_baseline$population_size)
ppsn_hc_baseline$initial_temperature <- (ppsn_hc_baseline$initial_temp_1 + ppsn_hc_baseline$initial_temp_2) / 2

ppsn_hc_baseline %>% group_by(dimension, population_size) %>%
  summarise(
    PKG_mean = mean(PKG),
    PKG_sd = sd(PKG),
    PKG_median = median(PKG),
    PKG_trim_mean = mean(PKG, trim = 0.2),
    PKG_iqr = IQR(PKG)
  ) -> summary_ppsn_hc_baseline

ppsn_hc_pkg_model <- lm(PKG ~ initial_temperature+ I(initial_temperature^2) + seconds + dimension + population_size, data = ppsn_hc_baseline)
anova_ppsn_hc_pkg_model <- anova(ppsn_hc_pkg_model)

ggplot(ppsn_hc_baseline, aes(x = seconds, y = PKG, color=initial_temperature)) +
  geom_point() +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE) +
  labs(title = "PKG vs Initial Temperature", x = "Seconds", y = "PKG") +
  theme_minimal()


# Try fitting
# 1. Choose the 4 temperatures
target_temps <- c(32.5, 37.5, 45)

# 2. Create the grid
# We pick the FIRST available level for your factors to keep it simple
predict_grid <- expand.grid(
  seconds = seq(min(ppsn_hc_baseline$seconds, na.rm = TRUE),
                max(ppsn_hc_baseline$seconds, na.rm = TRUE), length.out = 100),
  initial_temperature = target_temps,
  dimension = levels(ppsn_hc_baseline$dimension)[1],
  population_size = levels(ppsn_hc_baseline$population_size)[1]
)

# 3. Generate the fit values using your model
predict_grid$PKG_fit <- predict(ppsn_hc_pkg_model, newdata = predict_grid)

ggplot(ppsn_hc_baseline, aes(x = seconds, y = PKG, color = initial_temperature)) +
  # The raw data points
  geom_point(alpha = 0.2) +

  # The 4 specific model lines
  geom_line(data = predict_grid,
            aes(y = PKG_fit, group = initial_temperature),
            linewidth = 1.2) +

  # Optional: use a clear color scale for numeric values
  scale_color_viridis_c(option = "plasma") +

  labs(
    title = "Model Fit for Temperatures 30, 35, 40, 45",
    subtitle = paste("Fixed at Dimension:", levels(ppsn_hc_baseline$dimension)[1]),
    x = "Seconds",
    y = "PKG"
  ) +
  theme_minimal()

# Plot temperature histogram
#
ggplot(ppsn_hc_baseline, aes(x = initial_temperature)) +
  geom_histogram(binwidth = 2, fill = "steelblue", color = "black") +
  labs(title = "Histogram of Initial Temperatures", x = "Initial Temperature", y = "Count") +
  theme_minimal()

# Density estimation
density_est <- density(ppsn_hc_baseline$initial_temperature)

# Find the peaks (local maxima)
# This finds points where the density stops increasing and starts decreasing
peaks <- density_est$x[which(diff(sign(diff(density_est$y))) < 0) + 1]

# View the values
print(peaks)

library(mclust)

# Fit a model specifically looking for 2 components
model <- Mclust(ppsn_hc_baseline$initial_temperature, G = 2)

# Get the two central values (means)
model$parameters$mean

km <- kmeans(ppsn_hc_baseline$initial_temperature, centers = 2)
print(km$centers)

# Do the same for icsme
ggplot(icsme_baseline, aes(x = initial_temp)) +
  geom_histogram(binwidth = 2, fill = "steelblue", color = "black") +
  labs(title = "Histogram of Initial Temperatures (ICSME)", x = "Initial Temperature", y = "Count") +
  theme_minimal()
model_icsme <- Mclust(icsme_workload$initial_temp, G = 2)

# Test new model after removing elements from the dependency list
ppsn_speedup_1 <- read.csv("data/PPSN-speedup-fixed-gradient-descent-1-10-Mar-20-23-46.csv")
ppsn_speedup_3 <- read.csv("data/PPSN-speedup-fixed-gradient-descent-3-11-Mar-09-48-33.csv")
ppsn_speedup_4 <- read.csv("data/PPSN-speedup-fixed-gradient-descent-4-11-Mar-13-13-45.csv")
ppsn_speedup_2 <- read.csv("data/PPSN-speedup-fixed-gradient-descent-2-11-Mar-07-30-56.csv")

ppsn_speedup_with_die <- rbind(ppsn_speedup_2, ppsn_speedup_3, ppsn_speedup_4)
ppsn_speedup_with_die_baseline <- ppsn_speedup_with_die[ startsWith(ppsn_speedup_with_die$work, "base-"), ]

ppsn_speedup_with_die_baseline %>% group_by(population_size,die) %>%
  summarise(
    PKG_mean = mean(PKG),
    PKG_sd = sd(PKG),
    PKG_median = median(PKG),
    PKG_trim_mean = mean(PKG, trim = 0.2),
    PKG_iqr = IQR(PKG)
  ) -> summary_ppsn_speedup_with_die_baseline

# Compute residualized time by fitting a linear model with die as a predictor and then taking the residuals
ppsn_speedup_with_die_baseline$population_size <- as.factor(ppsn_speedup_with_die_baseline$population_size)
ppsn_speedup_with_die_baseline$die <- as.factor(ppsn_speedup_with_die_baseline$die)
time_with_die_model <- glm(seconds ~ die*population_size, data = ppsn_speedup_with_die_baseline)
ppsn_speedup_with_die_baseline$residualized_time <- resid(time_with_die_model)

ppsn_speedup_with_die_baseline$initial_temp <- (ppsn_speedup_with_die_baseline$initial_temp_1 + ppsn_speedup_with_die_baseline$initial_temp_2) / 2
ppsn_speedup_with_die_baseline$final_temp <- (ppsn_speedup_with_die_baseline$final_temp_1 + ppsn_speedup_with_die_baseline$final_temp_2) / 2

final_temp_with_die_model <- glm(final_temp ~ initial_temp + die*population_size*seconds, data = ppsn_speedup_with_die_baseline)
ppsn_speedup_with_die_baseline$residualized_final_temp <- resid(final_temp_with_die_model)

pkg_speedup_with_die_model <- glm(PKG ~ initial_temp*residualized_final_temp+die*population_size+residualized_time, data = ppsn_speedup_with_die_baseline)
anova_pkg_speedup_with_die_model <- anova(pkg_speedup_with_die_model)

# Compute wilcoxon differences for every combination of population_size and die
data_subset_400_1 <- ppsn_speedup_with_die_baseline %>%
      filter(population_size == 400, die == 1)
data_subset_400_2 <- ppsn_speedup_with_die_baseline %>%
      filter(population_size == 400, die == 2)
data_subset_800_1 <- ppsn_speedup_with_die_baseline %>%
      filter(population_size == 800, die == 1)
data_subset_800_2 <- ppsn_speedup_with_die_baseline %>%
  filter(population_size == 800, die == 2)

wilcox_test_400 <- wilcox.test(data_subset_400_1$PKG, data_subset_400_2$PKG)
wilcox_test_800 <- wilcox.test(data_subset_800_1$PKG, data_subset_800_2$PKG)
wilcox_test_die_1 <- wilcox.test(data_subset_400_1$PKG, data_subset_800_1$PKG)
wilcox_test_die_2 <- wilcox.test(data_subset_400_2$PKG, data_subset_800_2$PKG)

ppsn_speedup_4$die <- NULL
ppsn_speedup_2$die <- NULL
ppsn_speedup_3$die <- NULL
ppsn_speedup_fixed_gradient_descent <- rbind(ppsn_speedup_1, ppsn_speedup_2, ppsn_speedup_3, ppsn_speedup_4)

ppsn_speedup_fixed_gradient_descent_baseline <- ppsn_speedup_fixed_gradient_descent[ startsWith(ppsn_speedup_fixed_gradient_descent$work, "base-"), ]

ppsn_speedup_fixed_gradient_descent_baseline %>% group_by(population_size) %>%
  summarise(
    PKG_mean = mean(PKG),
    PKG_sd = sd(PKG),
    PKG_median = median(PKG),
    PKG_trim_mean = mean(PKG, trim = 0.2),
    PKG_iqr = IQR(PKG)
  ) -> summary_ppsn_speedup_baseline

source("R/process_deltas.R")
ppsn_speedup_fixed_gradient_descent_processed <- process_deltas(ppsn_speedup_fixed_gradient_descent)

ppsn_speedup_fixed_gradient_descent_processed %>% group_by( population_size, max_gens, alpha, steps ) %>%
  summarise(
    mean_delta_PKG = mean(delta_PKG, trim=0.2),
    sd_delta_PKG = sd(delta_PKG),
    trim_mean_delta_PKG = mean(delta_PKG, trim=0.2),
    median_delta_PKG = median(delta_PKG),
    iqr_delta_PKG = IQR(delta_PKG),
    mean_fitness = mean(diff_fitness),
    sd_fitness = sd(diff_fitness),
    median_fitness = median(diff_fitness)
  ) -> summary_ppsn_speedup_fixed_gradient_descent

# Test the last improvement
gamma_upgrade_1 <- read.csv("data/PPSN-gamma-upgrade-1-11-Mar-20-34-57.csv")
gamma_upgrade_2 <- read.csv("data/PPSN-gamma-upgrade-3-12-Mar-19-34-01.csv")
gamma_upgrade_3 <- read.csv("data/PPSN-gamma-upgrade-2-12-Mar-17-24-11.csv")
gamma_upgrade_4 <- read.csv("data/PPSN-gamma-upgrade-4-13-Mar-07-19-54.csv")

gamma_upgrade_processed <- process_deltas(rbind(gamma_upgrade_1, gamma_upgrade_2, gamma_upgrade_3, gamma_upgrade_4))

ppsn_speedup_fixed_gradient_descent_processed$group <- "base"
gamma_upgrade_processed$group <- "gamma_upgrade"
gamma_upgrade_processed$die <- NULL
comparison_gamma_upgrade <- rbind(ppsn_speedup_fixed_gradient_descent_processed, gamma_upgrade_processed)

comparison_gamma_upgrade %>% group_by(population_size, max_gens, alpha, steps, group) %>%
  summarise(
    mean_delta_PKG = mean(delta_PKG, trim=0.2),
    sd_delta_PKG = sd(delta_PKG),
    trim_mean_delta_PKG = mean(delta_PKG, trim=0.2),
    median_delta_PKG = median(delta_PKG),
    iqr_delta_PKG = IQR(delta_PKG),
    mean_fitness = mean(diff_fitness),
    sd_fitness = sd(diff_fitness),
    median_fitness = median(diff_fitness)
  ) -> summary_comparison_gamma_upgrade

comparison_gamma_upgrade$group <- as.factor(comparison_gamma_upgrade$group)
comparison_gamma_upgrade$population_size <- as.factor(comparison_gamma_upgrade$population_size)
comparison_gamma_upgrade$max_gens <- as.factor(comparison_gamma_upgrade$max_gens)
comparison_gamma_upgrade$alpha <- as.factor(comparison_gamma_upgrade$alpha)
comparison_gamma_upgrade$initial_temp <- (comparison_gamma_upgrade$initial_temp_1 + comparison_gamma_upgrade$initial_temp_2) / 2
comparison_gamma_upgrade$final_temp <- (comparison_gamma_upgrade$final_temp_1 + comparison_gamma_upgrade$final_temp_2) / 2

comparison_gamma_upgrade_model <- glm( delta_seconds ~ initial_temp + final_temp + group + population_size + max_gens*alpha*steps + generations*evaluations, data = comparison_gamma_upgrade)
anova_comparison_gamma_upgrade_model <- anova(comparison_gamma_upgrade_model)

comparison_gamma_upgrade_interact_model <- glm( delta_seconds ~ initial_temp + final_temp +  population_size*group*max_gens*alpha*steps + generations*evaluations, data = comparison_gamma_upgrade)

# compare the two models with anova to see if the interaction model is significantly better than the non-interaction model
anova_comparison_gamma_upgrade_interact_model <- anova(comparison_gamma_upgrade_interact_model)

compare_models <- anova(comparison_gamma_upgrade_model, comparison_gamma_upgrade_interact_model, test="Chisq")

comparison_gamma_upgrade$residualized_delta_seconds <- resid(comparison_gamma_upgrade_interact_model)

comparison_gamma_upgrade_pkg_model <- glm( delta_PKG ~ initial_temp + final_temp + group*population_size*max_gens*alpha*steps + generations*evaluations + residualized_delta_seconds, data = comparison_gamma_upgrade)

anova_comparison_gamma_upgrade_pkg_model <- anova(comparison_gamma_upgrade_pkg_model)


# Microoptimization
ppsn_microopt_1 <- read.csv("data/PPSN-microopt-1-18-Mar-17-11-50.csv")
ppsn_microopt_3 <- read.csv("data/PPSN-microopt-3-19-Mar-17-49-53.csv")
ppsn_microopt_2 <- read.csv("data/PPSN-microopt-2-18-Mar-19-47-01.csv")
ppsn_microopt_4 <- read.csv("data/PPSN-microopt-4-19-Mar-20-04-16.csv")

ppsn_microopt <- rbind(ppsn_microopt_1, ppsn_microopt_2, ppsn_microopt_3, ppsn_microopt_4)

ppsn_microopt_baseline <- ppsn_microopt[ startsWith(ppsn_microopt$work, "base-"), ]
ppsn_microopt_baseline %>% group_by(population_size) %>%
  summarise(
    PKG_mean = mean(PKG),
    PKG_sd = sd(PKG),
    PKG_median = median(PKG),
    PKG_trim_mean = mean(PKG, trim = 0.2),
    PKG_iqr = IQR(PKG)
  ) -> summary_ppsn_microopt_baseline

ppsn_microopt_baseline$population_size <- as.factor(ppsn_microopt_baseline$population_size)
ggplot( ppsn_microopt_baseline, aes(x = population_size, y = PKG)) +
  geom_boxplot(notch=T) +
  labs(title = "PKG by Population Size (Microoptimization)", x = "Population Size", y = "PKG") +
  theme_minimal()

ppsn_microopt_processed <- process_deltas(ppsn_microopt)
ppsn_microopt_processed %>% group_by(population_size, max_gens, steps, alpha ) %>%
  summarise(
    mean_delta_PKG = mean(delta_PKG, trim=0.2),
    sd_delta_PKG = sd(delta_PKG),
    trim_mean_delta_PKG = mean(delta_PKG, trim=0.2),
    median_delta_PKG = median(delta_PKG),
    iqr_delta_PKG = IQR(delta_PKG),
    mean_fitness = mean(diff_fitness),
    sd_fitness = sd(diff_fitness),
    median_fitness = median(diff_fitness)
  ) -> summary_ppsn_microopt

ppsn_microopt_processed$population_size <- as.factor(ppsn_microopt_processed$population_size)
ppsn_microopt_processed$max_gens <- as.factor(ppsn_microopt_processed$max_gens)
ppsn_microopt_processed$alpha <- as.factor(ppsn_microopt_processed$alpha)
ppsn_microopt_processed$initial_temp <- (ppsn_microopt_processed$initial_temp_1 + ppsn_microopt_processed$initial_temp_2) / 2
ppsn_microopt_processed$final_temp <- (ppsn_microopt_processed$final_temp_1 + ppsn_microopt_processed$final_temp_2) / 2


ppsn_microopt_time_model <- glm(delta_seconds ~ initial_temp + final_temp + population_size*max_gens*alpha*steps + generations*evaluations, data = ppsn_microopt_processed)
ppsn_microopt_processed$residualized_delta_seconds <- resid(ppsn_microopt_time_model)

ppsn_microopt_final_temp_model <- glm(final_temp ~ initial_temp + population_size*max_gens*alpha*steps + generations*evaluations + delta_seconds, data = ppsn_microopt_processed)
ppsn_microopt_processed$residualized_final_temp <- resid(ppsn_microopt_final_temp_model)

ppsn_microopt_pkg_model <- glm(delta_PKG ~ initial_temp*residualized_final_temp + population_size*max_gens*alpha*steps + generations*evaluations + residualized_delta_seconds, data = ppsn_microopt_processed)
anova_ppsn_microopt_pkg_model <- anova(ppsn_microopt_pkg_model)

ppsn_microopt_fitness_model <- glm(diff_fitness ~ initial_temp*residualized_final_temp + population_size*max_gens*alpha*steps + generations*evaluations + residualized_delta_seconds, data = ppsn_microopt_processed)
anova_ppsn_microopt_fitness_model <- anova(ppsn_microopt_fitness_model)

ppsn_microopt_processed$steps <- as.factor(ppsn_microopt_processed$steps)
ppsn_microopt_fitness_noopenv_model <- glm(diff_fitness ~ population_size*max_gens*alpha*steps, data = ppsn_microopt_processed)
anova_ppsn_microopt_fitness_noopenv_model <- anova(ppsn_microopt_fitness_noopenv_model)

# Low mutation
#
ppsn_low_mutation_1 <- read.csv("data/PPSN-low-mutation-1-20-Mar-07-30-38.csv")
ppsn_low_mutation_2 <- read.csv("data/PPSN-low-mutation-2-20-Mar-08-52-54.csv")
ppsn_low_mutation_3 <- read.csv("data/PPSN-low-mutation-3-20-Mar-12-31-43.csv")
ppsn_low_mutation_4 <- read.csv("data/PPSN-low-mutation-4-20-Mar-14-10-00.csv")

ppsn_low_mutation <- rbind(ppsn_low_mutation_1, ppsn_low_mutation_2, ppsn_low_mutation_3, ppsn_low_mutation_4)

ppsn_low_mutation_processed <- process_deltas(ppsn_low_mutation)

ppsn_low_mutation_processed %>% group_by(population_size, max_gens, steps, alpha ) %>%
  summarise(
    mean_delta_PKG = mean(delta_PKG, trim=0.2),
    sd_delta_PKG = sd(delta_PKG),
    trim_mean_delta_PKG = mean(delta_PKG, trim=0.2),
    median_delta_PKG = median(delta_PKG),
    iqr_delta_PKG = IQR(delta_PKG),
    mean_fitness = mean(diff_fitness),
    sd_fitness = sd(diff_fitness),
    median_fitness = median(diff_fitness)
  ) -> summary_ppsn_low_mutation


ppsn_low_mutation_processed$population_size <- as.factor(ppsn_low_mutation_processed$population_size)
ppsn_low_mutation_processed$max_gens <- as.factor(ppsn_low_mutation_processed$max_gens)
ppsn_low_mutation_processed$alpha <- as.factor(ppsn_low_mutation_processed$alpha)
ppsn_low_mutation_processed$steps <- as.factor(ppsn_low_mutation_processed$steps)
ppsn_low_mutation_processed$initial_temp <- (ppsn_low_mutation_processed$initial_temp_1 + ppsn_low_mutation_processed$initial_temp_2) / 2
ppsn_low_mutation_processed$final_temp <- (ppsn_low_mutation_processed$final_temp_1 + ppsn_low_mutation_processed$final_temp_2) / 2

ppsn_low_mutation_pkg_model <- glm(delta_PKG ~ initial_temp*final_temp + population_size*max_gens*alpha*steps + generations*evaluations + delta_seconds, data = ppsn_low_mutation_processed)
anova_ppsn_low_mutation_pkg_model <- anova(ppsn_low_mutation_pkg_model)

ppsn_microopt_processed$residualized_delta_seconds <- NULL
ppsn_microopt_processed$residualized_final_temp <- NULL
ppsn_low_mutation_processed$group <- "low_mutation"
ppsn_microopt_processed$group <- "microopt"
ppsn_comparison_low_mutation <- rbind(ppsn_low_mutation_processed, ppsn_microopt_processed)

ggplot( ppsn_comparison_low_mutation, aes(x = delta_PKG, y = diff_fitness, shape=group,color=alpha) ) +
  geom_point() +
  facet_grid(population_size ~ max_gens) +
  scale_y_log10() +
  labs(title = "Delta PKG Comparison between Low Mutation and Microoptimization", x = "Delta PKG", y = "Diff Fitness") +
  theme_minimal()

# Work with covariates
source("R/process_covariates.R")

ppsn_microopt_covariates <- process_covariates(ppsn_microopt)
ppsn_microopt_covariates$group <- "microopt"

ppsn_low_mutation_covariates <- process_covariates(ppsn_low_mutation)
ppsn_low_mutation_covariates$group <- "low_mutation"

ppsn_covariates_comparison <- rbind(ppsn_microopt_covariates, ppsn_low_mutation_covariates)

ppsn_covariates_comparison$population_size <- as.factor(ppsn_covariates_comparison$population_size)
ppsn_covariates_comparison$max_gens <- as.factor(ppsn_covariates_comparison$max_gens)
ppsn_covariates_comparison$alpha <- as.factor(ppsn_covariates_comparison$alpha)
ppsn_covariates_comparison$steps <- as.factor(ppsn_covariates_comparison$steps)
ppsn_covariates_comparison$initial_temp <- (ppsn_covariates_comparison$initial_temp_1 + ppsn_covariates_comparison$initial_temp_2) / 2
ppsn_covariates_comparison$final_temp <- (ppsn_covariates_comparison$final_temp_1 + ppsn_covariates_comparison$final_temp_2) / 2

library(nlme)
covariates_model <- gls( PKG ~ group + initial_temp*final_temp +
                           population_size*max_gens*alpha*steps +
                           generations*evaluations +
                           seconds + PKG_baseline_prev + PKG_baseline_post,
                         data = ppsn_covariates_comparison,
                         weights = varIdent(form = ~1|group) )

library(emmeans)

# This calculates the expected Energy for each group,
# allowing 'seconds' and 'temp' to be what they actually were for those groups.
adj_means <- emmeans(covariates_model, "group", data = ppsn_covariates_comparison)

# This gives you the 'Real World' Delta
comparison <- pairs(adj_means)

workload_only <- emmeans(covariates_model, "group",
                         at = list(PKG_baseline_prev = 0,
                                   PKG_baseline_post = 0))

plot_data <- as.data.frame(workload_only)

ggplot(plot_data, aes(x = group, y = emmean, fill = group)) +
  geom_bar(stat = "identity", width = 0.5) +
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.2) +
  labs(title = "Workload-Exclusive Energy (Baseline Corrected)",
       y = "Estimated PKG Energy (Adjusted)",
       x = "Optimization Type") +
  theme_minimal()

workload_grid <- emmeans(covariates_model,
                         ~ group | population_size * max_gens * alpha * steps,
                         at = list(PKG_baseline_prev = 0,
                                   PKG_baseline_post = 0))

PKG_comparison_microopt_low_mutation <- as.data.frame(workload_grid)

anova_covariates_model <- anova(covariates_model)

# Low mutation

ppsn_no_alpha_1 <- read.csv("data/PPSN-no-alpha-mut-20-Mar-17-35-25.csv")
ppsn_no_alpha_2 <- read.csv("data/PPSN-no-alpha-mut-2-20-Mar-19-13-20.csv")
ppsn_no_alpha_3 <- read.csv("data/PPSN-no-alpha-mut-3-21-Mar-08-20-20.csv")
ppsn_no_alpha_4 <- read.csv("data/PPSN-no-alpha-mut-4-21-Mar-09-47-20.csv")

ppsn_no_alpha <- rbind(ppsn_no_alpha_1, ppsn_no_alpha_2, ppsn_no_alpha_3, ppsn_no_alpha_4)

ppsn_no_alpha_processed <- process_deltas(ppsn_no_alpha)

ppsn_no_alpha_processed %>% group_by(population_size, max_gens, steps, alpha ) %>%
  summarise(
    mean_delta_PKG = mean(delta_PKG, trim=0.2),
    sd_delta_PKG = sd(delta_PKG),
    trim_mean_delta_PKG = mean(delta_PKG, trim=0.2),
    median_delta_PKG = median(delta_PKG),
    iqr_delta_PKG = IQR(delta_PKG),
    mean_fitness = mean(diff_fitness),
    sd_fitness = sd(diff_fitness),
    median_fitness = median(diff_fitness)
  ) -> summary_ppsn_no_alpha

summary_ppsn_no_alpha$shape <- factor(ifelse(summary_ppsn_no_alpha$population_size == 400, 21, 22))
summary_ppsn_no_alpha$max_gens <- as.factor(summary_ppsn_no_alpha$max_gens)
summary_ppsn_no_alpha$alpha <- as.factor(summary_ppsn_no_alpha$alpha)
summary_ppsn_no_alpha$color <- ifelse(summary_ppsn_no_alpha$steps==16, "red", "blue")
summary_ppsn_no_alpha$fill <- ifelse(summary_ppsn_no_alpha$alpha == 10, "lightblue", "lightpink")

ggplot(summary_ppsn_no_alpha, aes( x= median_fitness, y = median_delta_PKG, color=color, size=factor(steps), fill=fill, shape=factor(population_size) ) )+
  scale_color_identity()+
  scale_fill_identity()+
  geom_point(stroke=1.2 )+
  scale_shape_manual(values = c(21, 22)) +
  scale_x_log10() +
  labs(title = "Median Delta PKG vs Median Fitness for No Alpha Mutation", x = "Median Fitness", y = "Median Delta PKG") +
  theme_minimal()

ppsn_no_alpha_processed$group <- "no_alpha"

ppsn_no_alpha_processed$initial_temp <- (ppsn_no_alpha_processed$initial_temp_1 + ppsn_no_alpha_processed$initial_temp_2) / 2
ppsn_no_alpha_processed$final_temp <- (ppsn_no_alpha_processed$final_temp_1 + ppsn_no_alpha_processed$final_temp_2) / 2
comparison_no_alpha <- rbind(ppsn_no_alpha_processed, ppsn_low_mutation_processed)

comparison_no_alpha$steps <- as.numeric(comparison_no_alpha$steps)
comparison_no_alpha$size <- ifelse(comparison_no_alpha$steps == 16, 2, 1)
ggplot( comparison_no_alpha, aes(x = delta_PKG, y = diff_fitness, shape=group,color=alpha,size=size) ) +
  geom_point(alpha=0.5) +
  facet_grid(population_size ~ max_gens) +
  scale_y_log10() +
  labs(title = "Delta PKG Comparison between No Alpha Mutation and Low Mutation", x = "Delta PKG", y = "Diff Fitness") +
  theme_minimal()

comparison_no_alpha$delta_temp <- comparison_no_alpha$final_temp - comparison_no_alpha$initial_temp
ggplot( comparison_no_alpha, aes(x = delta_seconds, y = delta_temp, color=alpha, shape=group) ) +
  geom_point(alpha=0.5) +
  labs(title = "Initial vs Final Temperature by Group", x = "delta seconds", y = "delta T") +
  theme_minimal()

delta_seconds_model <- glm(delta_seconds ~ group + delta_temp + die + steps*alpha*population_size*max_gens + evaluations, data = comparison_no_alpha)

evaluations_model <- glm(evaluations ~ group*steps*alpha*population_size*max_gens, data = comparison_no_alpha)

comparison_no_alpha_time_model <- glm( delta_seconds ~ group + initial_temp + steps*alpha*population_size*max_gens + evaluations, data = comparison_no_alpha)

comparison_no_alpha$residualized_delta_seconds <- resid(comparison_no_alpha_time_model)

comparison_no_alpha_model <- glm( delta_PKG ~ group*steps*alpha*population_size*max_gens + residualized_delta_seconds + initial_temp + evaluations, data = comparison_no_alpha)

anova_comparison_no_alpha_model <- anova(comparison_no_alpha_model)

comparison_no_alpha$steps <- as.factor(comparison_no_alpha$steps)
comparison_no_alpha_fitness_model <- glm( diff_fitness ~ group*steps*alpha*population_size*max_gens + evaluations, data = comparison_no_alpha)
anova_comparison_no_alpha_fitness_model <- anova(comparison_no_alpha_fitness_model)

ppsn_no_alpha_processed$population_size <- as.factor(ppsn_no_alpha_processed$population_size)
ppsn_no_alpha_processed$max_gens <- as.factor(ppsn_no_alpha_processed$max_gens)
ppsn_no_alpha_processed$alpha <- as.factor(ppsn_no_alpha_processed$alpha)
ppsn_no_alpha_processed$steps <- as.factor(ppsn_no_alpha_processed$steps)
ggplot( ppsn_no_alpha_processed, aes(x = max_gens, y = diff_fitness, fill=max_gens) ) +
  geom_boxplot( notch=T) +
  scale_y_log10() +
  facet_grid(population_size ~ alpha + steps) +
  labs(title = "Fitness comparison", x = "Max gens", y = "Diff Fitness") +
  theme_minimal()

ggplot( ppsn_no_alpha_processed, aes(x = steps, y = diff_fitness, fill=steps) ) +
  geom_boxplot( notch=T) +
  scale_y_log10() +
  facet_grid(population_size ~ alpha + max_gens) +
  labs(title = "Fitness comparison", x = "Max gens", y = "Diff Fitness") +
  theme_minimal()

ggplot( ppsn_no_alpha_processed, aes(x = steps, y = delta_PKG, fill=steps) ) +
  geom_boxplot( notch=T) +
  scale_y_log10() +
  facet_grid(population_size ~ alpha + max_gens) +
  labs(title = "Fitness comparison", x = "Max gens", y = "Diff Fitness") +
  theme_minimal()


ggplot( ppsn_low_mutation_processed, aes(x = steps, y = diff_fitness, fill=steps) ) +
  geom_boxplot( notch=T) +
  scale_y_log10() +
  facet_grid(population_size ~ alpha + max_gens) +
  labs(title = "Fitness comparison", x = "Max gens", y = "Diff Fitness") +
  theme_minimal()
