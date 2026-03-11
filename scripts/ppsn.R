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
ppsn_hc_3 <- read.csv("data/PPSN-speedup-hc-64-1-8-Mar-20-24-22.csv")
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
ppsn_speedup_1_baseline <- ppsn_speedup_1[ startsWith(ppsn_speedup_1$work, "base-"), ]

ppsn_speedup_1_baseline$population_size <- as.factor(ppsn_speedup_1_baseline$population_size)

ppsn_speedup_1_baseline %>% group_by(population_size) %>%
  summarise(
    PKG_mean = mean(PKG),
    PKG_sd = sd(PKG),
    PKG_median = median(PKG),
    PKG_trim_mean = mean(PKG, trim = 0.2),
    PKG_iqr = IQR(PKG)
  ) -> summary_ppsn_speedup_1_baseline
