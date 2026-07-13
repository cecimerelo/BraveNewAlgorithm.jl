library(readr)
library(purrr)
library(dplyr)
source("R/process_deltas.R")

hot_first_schwefel_workload <- process_deltas(map_dfr( c("data/schwefel-hot-first-v4-11-Jul-08-11-58.csv","data/schwefel-hot-first-v1-7-Jul-16-45-48.csv",
                                 "data/schwefel-hot-first-v2-9-Jul-07-47-56.csv","data/schwefel-hot-first-v3-10-Jul-07-38-18.csv"),
                               read_csv ))

hot_first_schwefel_workload$work <- "hot-first"

regular_schwefel_workload <-  process_deltas(map_dfr( c("data/schwefel-regular-v3-9-Jul-15-07-19.csv", "data/schwefel-regular-v4-10-Jul-15-19-05.csv",
                                "data/schwefel-regular-v1-7-Jul-08-03-24.csv",  "data/schwefel-regular-v2-8-Jul-07-40-20.csv"),
                              read_csv ))
regular_schwefel_workload$work <- "baseline"

schwefel_workload <- rbind(hot_first_schwefel_workload,regular_schwefel_workload)

temp_1_model <- glm( initial_temp_1 ~ work, data=schwefel_workload)
temp_2_model <- glm( initial_temp_2 ~ work, data=schwefel_workload)

schwefel_workload$dimension <- as.factor( schwefel_workload$dimension )
schwefel_workload$population_size <- as.factor( schwefel_workload$population_size )

schwefel_delta_time_model <- glm( delta_seconds ~ work+dimension*population_size + evaluations, data=schwefel_workload )
schwefel_time_model <- glm( seconds ~ work+dimension*population_size + evaluations, data=schwefel_workload )

schwefel_delta_time_interaction_model <- glm( delta_seconds ~ work*dimension*population_size + evaluations, data=schwefel_workload )
schwefel_workload$residual_time <- residuals(schwefel_time_model)

schwefel_delta_PKG_model <- glm( delta_PKG ~ initial_temp_1*initial_temp_2 +
                             I(initial_temp_1^2)*I(initial_temp_2^2)+
                             work+dimension*population_size+
                             residual_time+I(residual_time^2)+
                             evaluations,
                            data=schwefel_workload)

schwefel_delta_temp1_model <- glm( initial_temp_1 ~ work+dimension*population_size, data=schwefel_workload)
schwefel_workload$residual_temp1 <- residuals(schwefel_delta_temp1_model)

schwefel_delta_temp2_model <- glm( initial_temp_2 ~ work+dimension*population_size, data=schwefel_workload)
schwefel_workload$residual_temp2 <- residuals(schwefel_delta_temp2_model)

schwefel_split_model <- glm( delta_PKG ~ work*(residual_temp1*residual_temp2 + residual_time)+
                               I(initial_temp_1^2)*I(initial_temp_2^2)+
                               work+dimension*population_size+
                               I(residual_time^2)+
                               evaluations,
                             data=schwefel_workload)

# 1. Define a grid of operational contexts
temp_grid <- seq(min(schwefel_workload$residual_temp1), max(schwefel_workload$residual_temp1), length.out = 20)
time_grid <- seq(min(schwefel_workload$residual_time), max(schwefel_workload$residual_time), length.out = 20)
grid <- expand.grid(residual_temp1 = temp_grid, residual_time = time_grid, residual_temp2 = 0) # Holding temp2 at 0 (mean)

# 2. Predict the Delta Energy (Energy Penalty)
# Extract just the terms involving 'workhot-first'
# Formula: Delta_E = 14.11 + 0.2387*T1 + 2.529*T2 + 4.979*Time - 0.1294*T1*T2
grid$penalty <- 14.11 + (0.2387 * grid$residual_temp1) + (2.529 * grid$residual_temp2) + (4.979 * grid$residual_time) - (0.1294 * grid$residual_temp1 * grid$residual_temp2)

# 3. Plotting
library(ggplot2)
ggplot(grid, aes(x = residual_temp1, y = residual_time, fill = penalty)) +
  geom_tile() +
  scale_fill_gradient2(low = "green", mid = "yellow", high = "red", midpoint = 0) +
  labs(title = "Energy Penalty of 'Hot-First' Intervention",
       x = "Residual Temperature (°C)",
       y = "Residual Execution Time (s)",
       fill = "Energy Delta (J)") +
  theme_minimal()

#---
# 1. Generate sequence of real temperatures
temp_real <- seq(35, 85, by = 0.5)

# 2. Un-center the formula (holding time at average, residual_time = 0)
# T1_mean = 43.22, T2_mean = 40.69
penalty <- 14.11 +
  (0.2387 * (temp_real - 43.22)) +
  (2.529 * (temp_real - 40.69)) -
  (0.1294 * (temp_real - 43.22) * (temp_real - 40.69))

policy_data <- data.frame(Temperature = temp_real, Energy_Delta = penalty)

# 3. Plot the Decision Boundary
ggplot(policy_data, aes(x = Temperature, y = Energy_Delta)) +
  geom_line(size = 1.5, color = "dodgerblue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red", size = 1) +
  geom_vline(xintercept = 68.4, linetype = "dotted", color = "darkred", size = 1) +
  annotate("text", x = 50, y = 15, label = "Penalty Zone (Blacklist)", color = "red", fontface = "bold") +
  annotate("text", x = 76, y = -20, label = "Savings Zone (Allow)", color = "darkgreen", fontface = "bold") +
  annotate("text", x = 68.4, y = 25, label = "Cut-off: 68.4°C", angle = 90, vjust = -0.5) +
  labs(title = "Scheduler Decision Boundary for 'Hot-First' Intervention",
       x = "Actual CPU Temperature (°C)",
       y = "Predicted Energy Impact (Joules)") +
  theme_minimal() +
  theme(text = element_text(size = 14))

#----
library(ggplot2)
library(dplyr)

# ---------------------------------------------------------
# 1. Setup: Safely extract levels from the trained model
# ---------------------------------------------------------
# Assuming your model is saved as `schaffer_delta_time_model`

# Extract the exact factor levels the model was trained on
# If dimension/population_size were numeric in your model, this will return NULL
model_levels <- schaffer_delta_time_model$xlevels

if (is.null(model_levels$dimension) || is.null(model_levels$population_size)) {
  stop("Error: 'dimension' or 'population_size' were trained as numeric variables, not factors. Please re-run your GLM with factor(dimension) and factor(population_size).")
}

# Build the grid using ONLY the levels the model actually knows about
config_grid <- expand.grid(
  dimension = factor(model_levels$dimension),
  population_size = factor(model_levels$population_size),
  evaluations = 10000 # Holding constant (doesn't affect the relative interaction)
)

# ---------------------------------------------------------
# 2. Extract Predictions
# ---------------------------------------------------------

impact_data <- config_grid %>%
  mutate(
    # Predict time without intervention (baseline OS scheduling)
    time_control = predict(schaffer_delta_time_model,
                           newdata = mutate(., work = "baseline")),

    # Predict time with intervention
    time_hot_first = predict(schaffer_delta_time_model,
                             newdata = mutate(., work = "hot-first")),

    # Calculate Net Impact: Negative means Hot-First is faster (Savings)
    time_impact = time_hot_first - time_control
  )

# ---------------------------------------------------------
# 3. Plot the Decision Boundary
# ---------------------------------------------------------
ggplot(impact_data, aes(x = dimension, y = time_impact, fill = time_impact > 0)) +
  geom_col(color = "black", alpha = 0.8) +
  facet_wrap(~population_size, labeller = labeller(population_size = label_both)) +

  # The Zero-Line (Decision Boundary)
  geom_hline(yintercept = 0, linetype = "dashed", color = "black", size = 1) +

  # Dynamic coloring for Penalty vs Savings
  scale_fill_manual(
    values = c("TRUE" = "tomato", "FALSE" = "seagreen"),
    labels = c("TRUE" = "Penalty Zone (Blacklist)", "FALSE" = "Savings Zone (Allow)"),
    name = "Scheduler Action"
  ) +
  labs(
    title = "Scheduler Decision Boundary by Workload Configuration",
    subtitle = "Schaffer V7 Workload Impact Profile",
    x = "Dimension",
    y = "Predicted Execution Time Impact (Seconds)"
  ) +
  theme_minimal() +
  theme(
    text = element_text(size = 14),
    legend.position = "bottom",
    strip.background = element_rect(fill = "grey90", color = NA),
    strip.text = element_text(face = "bold")
  )
