source("R/process_deltas.R")

library(ggplot2)
library(dplyr)

process_europar <- function(file_name, work_name) {
  df <- read.csv(file_name)
  df$initial_temp <- (df$initial_temp_1 + df$initial_temp_2)/2
  df$color <- ifelse(df$work == work_name, "red", "blue")
  df$base <- ifelse(df$work == work_name, FALSE, TRUE)
  df$shape <- ifelse(df$dimension == 10,21,ifelse(df$dimension == 5, 22,23))
  df$size <- ifelse(df$work == work_name, 4,3)
  df$cum_seconds <- cumsum(df$seconds)
  df$initial_temp <- as.numeric(df$initial_temp)

  print(ggplot(df, aes(x = cum_seconds, y = PKG, size= work ) )+
      scale_color_viridis_c() +
        scale_size_manual( values = c(3,5)) +
      geom_point( aes(color=initial_temp, shape=factor(shape)), alpha=0.5 ) +
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
  geom_smooth(method = "glm", aes(color=dimension), formula=y ~ I(x^3)+ I(x^2) + x) +
  geom_point(color=europar_test_base$dimension ) +
  labs(
    title = "Energy Consumption Over Temperature",
    x = "Temperature",
    y = "Energy Consumption "
  ) + theme_minimal()

temperature_model <- glm(PKG ~ initial_temp+ dimension + population_size, data = europar_test_base)
temperature_model_exponential <- glm(PKG ~ I(exp(initial_temp))+ dimension + population_size, data = europar_test_base)
temperature_model_quadratic <- glm(PKG ~ I(initial_temp^2) + initial_temp + dimension + population_size, data = europar_test_base)
temperature_model_cubic <- glm(PKG ~ I(initial_temp^3)+ I(initial_temp^2) + initial_temp + dimension + population_size, data = europar_test_base)

AIC1 <- AIC(temperature_model,temperature_model_exponential)
anova_1 <- anova(temperature_model,temperature_model_quadratic)
anova_cubic <- anova(temperature_model_quadratic, temperature_model_cubic)

europar_test_processed <- process_deltas( europar_test )

europar_test_processed$dimension <- as.factor(europar_test_processed$dimension)
ggplot(europar_test_processed, aes(x = initial_temp, y = delta_PKG)) +
  geom_point(color=europar_test_processed$dimension ) +
  geom_smooth(method = "glm", aes(color=dimension), formula=y ~ I(x^3)+ I(x^2) + x) +
  labs(
    title = "Energy Consumption Over Time",
    x = "Temperature",
    y = "Delta PKG"
  ) + theme_minimal()

workload_temperature_model <- glm(delta_PKG ~ initial_temp + dimension + population_size+evaluations, data = europar_test_processed)
workload_temperature_model_exponential <- glm(delta_PKG ~ I(exp(initial_temp)) + dimension + population_size+evaluations, data = europar_test_processed )
workload_temperature_model_quadratic <- glm(delta_PKG ~ I(initial_temp^2) + initial_temp + dimension + population_size+evaluations, data = europar_test_processed)
anova_workload <- anova(workload_temperature_model, workload_temperature_model_quadratic)

workload_temperature_model_cubic <- glm(delta_PKG ~ I(initial_temp^3)+ I(initial_temp^2) + initial_temp + dimension + population_size+evaluations, data = europar_test_processed)
anova_workload_cubic <- anova(workload_temperature_model_quadratic, workload_temperature_model_cubic)

library(dplyr)

europar_test_base %>%
  group_by(dimension, population_size) %>%
  summarise(
    mean_PKG = mean(PKG),
    median_PKG = median(PKG),
    sd_PKG = sd(PKG),
    trimmed_PKG = mean(PKG, trim = 0.2),
    iqr_PKG = IQR(PKG)
  ) -> summary_test_base

europar_taskset_1 <- process_europar("data/europar-taskset-1-6-Feb-12-29-38.csv", "taskset-1")
europar_taskset_2 <- process_europar("data/europar-taskset-2-6-Feb-17-15-39.csv", "taskset-2")
europar_taskset_3 <- process_europar("data/europar-taskset-3-7-Feb-09-18-05.csv", "taskset-3")
europar_taskset_4 <- process_europar("data/europar-taskset-4-7-Feb-11-09-48.csv", "taskset-4")

europar_taskset <- rbind(europar_taskset_1, europar_taskset_2, europar_taskset_3, europar_taskset_4)

europar_taskset_base <- europar_taskset %>% filter(base == TRUE)

europar_taskset_base %>% group_by(dimension, population_size) %>%
  summarise(
    mean_PKG = mean(PKG),
    median_PKG = median(PKG),
    sd_PKG = sd(PKG),
    trimmed_PKG = mean(PKG, trim = 0.2),
    iqr_PKG = IQR(PKG)
  ) -> summary_taskset_base

