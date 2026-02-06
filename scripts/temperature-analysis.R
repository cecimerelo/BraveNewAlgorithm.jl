source("R/process_deltas.R")

library(ggplot2)
library(dplyr)

process_europar <- function(file_name, work_name) {
  df <- read.csv(file_name)
  df$initial_temp <- (df$initial_temp_1 + df$initial_temp_2)/2
  df$color <- ifelse(df$work == work_name, "red", "blue")
  df$base <- ifelse(df$work == work_name, FALSE, TRUE)

  ggplot(df, aes(x = initial_temp, y = PKG)) +
    geom_smooth(method = "lm", aes(color=work), se=FALSE) +
    geom_point(color=df$color ) +
    labs(
      title = "Energy Consumption Over Temperature",
      x = "Temperature",
      y = "Energy Consumption "
    ) +
    theme_minimal()

  df$cum_seconds <- cumsum(df$seconds)
  df$initial_temp <- as.numeric(df$initial_temp)
  print(ggplot(df, aes(x = cum_seconds, y = PKG)) +
    # change color scale based on initial_temp
    scale_color_viridis_c() +
    geom_point( aes(color=initial_temp) ) +
    labs(
      title = "Energy Consumption Over time",
      x = "Time",
      y = "Energy Consumption "
    ) +
    theme_minimal())
  return(df)
}

europar_test_1 <- process_europar("data/europar-europar-test-2-Feb-11-39-38.csv", "europar-test")
europar_test_2 <- process_europar("data/europar-europar-test-2-2-Feb-13-31-25.csv", "europar-test-2")
europar_test_3 <- process_europar("data/europar-europar-test-3-2-Feb-18-19-59.csv", "europar-test-3")
europar_test_4 <- process_europar("data/europar-europar-test-4-3-Feb-08-31-46.csv", "europar-test-4")

europar_test <- rbind(europar_test_1, europar_test_2, europar_test_3, europar_test_4)

europar_test_base <- europar_test %>% filter(base == TRUE)


europar_test_base$dimension <- as.factor(europar_test_base$dimension)
ggplot(europar_test_base, aes(x = initial_temp, y = PKG)) +
  geom_smooth(method = "lm", aes(color=dimension), se=FALSE) +
  geom_point(color=europar_test_base$dimension ) +
  labs(
    title = "Energy Consumption Over Temperature",
    x = "Temperature",
    y = "Energy Consumption "
  ) + theme_minimal()

temperature_model <- glm(PKG ~ initial_temp+ dimension + population_size, data = europar_test_base)
temperature_model_exponential <- glm(PKG ~ I(exp(initial_temp))+ dimension + population_size, data = europar_test_base)
temperature_model_quadratic <- glm(PKG ~ I(initial_temp^2) + initial_temp + dimension + population_size, data = europar_test_base)

AIC1 <- AIC(temperature_model,temperature_model_exponential)
AIC2 <- AIC(temperature_model,temperature_model_quadratic)

europar_test_processed <- process_deltas( europar_test )

ggplot(europar_test_processed, aes(x = initial_temp, y = delta_PKG)) +
  geom_point(color=europar_test_processed$dimension ) +
  labs(
    title = "Energy Consumption Over Time",
    x = "Time",
    y = "Temperature "
  ) + theme_minimal()

workload_temperature_model <- glm(delta_PKG ~ initial_temp + dimension + population_size, data = europar_test_processed)
workload_temperature_model_exponential <- glm(delta_PKG ~ I(exp(initial_temp)) + dimension + population_size, data = europar_test_processed )
AIC2 <- AIC(workload_temperature_model, workload_temperature_model_exponential)
