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

plot_temperature <- function(df) {
  print(ggplot(df, aes(x = cum_seconds)) +
    geom_point(color= "red", aes(y=initial_temp_1) ) +
     geom_point(color= "pink", aes(y=initial_temp_2) ) +
    labs(
      title = "Temperature over time",
      x = "Time (s)",
      y = "temperature "
    ) + theme_minimal())
}

europar_test_1 <- process_europar("data/europar-europar-test-2-Feb-11-39-38.csv", "europar-test")
plot_temperature(europar_test_1)
europar_test_2 <- process_europar("data/europar-europar-test-2-2-Feb-13-31-25.csv", "europar-test-2")
plot_temperature(europar_test_2)
europar_test_3 <- process_europar("data/europar-europar-test-3-2-Feb-18-19-59.csv", "europar-test-3")
plot_temperature(europar_test_3)
europar_test_4 <- process_europar("data/europar-europar-test-4-3-Feb-08-31-46.csv", "europar-test-4")
plot_temperature(europar_test_4)
europar_test <- rbind(europar_test_1, europar_test_2, europar_test_3, europar_test_4)

ggplot(europar_test, aes(x=initial_temp, y=PKG)) + geom_point(color=europar_test$dimension )  + labs( title = "Energy Consumption Over Temperature", x = "Temperature", y = "Energy Consumption " ) + theme_minimal()

ggplot(europar_test, aes(x=cum_seconds, y = initial_temp_1 - initial_temp_2, color=initial_temp)) +
  scale_color_viridis_c() +
  geom_point() +
  guides( color = guide_colorbar(title = "Initial Temperature"))  + theme_minimal()

save(europar_test, file = "data/europar_test.rds")
test_temp_range <- c(min(min(europar_test$initial_temp_1), min(europar_test$initial_temp_2)), max(max(europar_test$initial_temp_1), max(europar_test$initial_temp_2)) )

temperatures_df <- data.frame( europar_test$initial_temp_1, europar_test$initial_temp_2 )
library(tidyverse)
temperatures_df %>% pivot_longer(cols = everything(), names_to = "temperature_type", values_to = "temperature") -> temperatures_test_longer

correlation_initial <- cor(europar_test$initial_temp_1, europar_test$initial_temp_2)

ggplot(temperatures_test_longer,aes(x = temperature_type,y=temperature)) +
  geom_violin()+
  labs(
    title = "Distribution of Temperatures",
    x = "Temperature",
    y = "Frequency"
  ) + theme_minimal()

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
temperature_model_interact <- glm(PKG ~ I(initial_temp^3)+ I(initial_temp^2) + initial_temp*dimension*population_size, data = europar_test_base)
temperature_model_interact_quadratic <- glm(PKG ~ I(initial_temp^2) + initial_temp*dimension*population_size, data = europar_test_base)

library(marginaleffects)
predictions_base <- avg_predictions(temperature_model_interact_quadratic,
                                    newdata = transform( europar_test_base, initial_temp = min(europar_test_base$initial_temp)),
                                    by = c("dimension","population_size"))

AIC1 <- AIC(temperature_model,temperature_model_exponential)
anova_1 <- anova(temperature_model,temperature_model_quadratic)
anova_cubic <- anova(temperature_model_quadratic, temperature_model_cubic)

library(car)
anova_model <- Anova( temperature_model_interact, type="III")

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
workload_temperature_model_interact <- glm(delta_PKG ~ I(initial_temp^3)+ I(initial_temp^2) + initial_temp*dimension*population_size+evaluations, data = europar_test_processed)
anova_workload_cubic <- anova(workload_temperature_model_quadratic, workload_temperature_model_cubic)

anova_workload <- Anova(workload_temperature_model_interact, type="III")

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

europar_test %>% group_by(dimension, population_size) %>%
  summarise(
    mean_initial_temp_1 = mean(initial_temp_1),
    median_initial_temp_1 = median(initial_temp_1),
    sd_initial_temp_1 = sd(initial_temp_1),
    trimmed_initial_temp_1 = mean(initial_temp_1, trim = 0.2),
    iqr_initial_temp_1 = IQR(initial_temp_1),
    mean_initial_temp_2 = mean(initial_temp_2),
    median_initial_temp_2 = median(initial_temp_2),
    sd_initial_temp_2 = sd(initial_temp_2),
    trimmed_initial_temp_2 = mean(initial_temp_2, trim = 0.2),
    iqr_initial_temp_2 = IQR(initial_temp_2)
  ) -> summary_test_temperatures

europar_test_processed %>% group_by(dimension, population_size) %>%
  summarise(
    mean_delta_PKG = mean(delta_PKG),
    median_delta_PKG = median(delta_PKG),
    sd_delta_PKG = sd(delta_PKG),
    trimmed_delta_PKG = mean(delta_PKG, trim = 0.2),
    iqr_delta_PKG = IQR(delta_PKG)
  ) -> summary_test_deltas

# taskset in die 1 ---------------------------------------------------------------------------
europar_taskset_1 <- process_europar("data/europar-taskset-1-6-Feb-12-29-38.csv", "taskset-1")
plot_temperature(europar_taskset_1)
europar_taskset_2 <- process_europar("data/europar-taskset-2-6-Feb-17-15-39.csv", "taskset-2")
plot_temperature(europar_taskset_2)
europar_taskset_3 <- process_europar("data/europar-taskset-3-7-Feb-09-18-05.csv", "taskset-3")
plot_temperature(europar_taskset_3)
europar_taskset_4 <- process_europar("data/europar-taskset-4-7-Feb-11-09-48.csv", "taskset-4")
plot_temperature(europar_taskset_4)

europar_taskset <- rbind(europar_taskset_1, europar_taskset_2, europar_taskset_3, europar_taskset_4)

ggplot(europar_taskset, aes(x=initial_temp, y=PKG)) + geom_point(color=europar_taskset$dimension ) + labs( title = "Energy Consumption Over Temperature", x = "Temperature", y = "Energy Consumption " ) + theme_minimal()

ggplot(europar_taskset, aes(x=cum_seconds, y = initial_temp_1 - initial_temp_2, color=initial_temp)) +
  scale_color_viridis_c() +
  geom_point() +
  guides( color = guide_colorbar(title = "Initial Temperature"))  + theme_minimal()

save(europar_taskset, file = "data/europar_taskset.rds")

europar_taskset %>% group_by(dimension, population_size) %>%
  summarise(
    mean_initial_temp_1 = mean(initial_temp_1),
    median_initial_temp_1 = median(initial_temp_1),
    sd_initial_temp_1 = sd(initial_temp_1),
    trimmed_initial_temp_1 = mean(initial_temp_1, trim = 0.2),
    iqr_initial_temp_1 = IQR(initial_temp_1),
    mean_initial_temp_2 = mean(initial_temp_2),
    median_initial_temp_2 = median(initial_temp_2),
    sd_initial_temp_2 = sd(initial_temp_2),
    trimmed_initial_temp_2 = mean(initial_temp_2, trim = 0.2),
    iqr_initial_temp_2 = IQR(initial_temp_2)
  )  -> summary_taskset_temperatures

# Compute temperature range for taskset including both initial_temp_1 and initial_temp_2
taskset_temp_range <- c(min(min(europar_taskset$initial_temp_1), min(europar_taskset$initial_temp_2)), max(max(europar_taskset$initial_temp_1), max(europar_taskset$initial_temp_2)) )

temperatures_taskset_df <- data.frame( europar_taskset$initial_temp_1, europar_taskset$initial_temp_2 )

temperatures_taskset_df %>% pivot_longer(cols = everything(), names_to = "temperature_type", values_to = "temperature") -> temperatures_taskset_longer

library(cocor)
correlation_taskset <- cor(europar_taskset$initial_temp_1, europar_taskset$initial_temp_2)


relationship_correlations <- cocor.indep.groups(r1=cor(europar_test$initial_temp_1, europar_test$initial_temp_2), r2=cor(europar_taskset$initial_temp_1, europar_taskset$initial_temp_2),n1=length(europar_test$initial_temp_1),n2=length(europar_taskset$initial_temp_1))

ggplot(temperatures_taskset_longer, aes(x = temperature_type,y=temperature)) +
  geom_violin()+
  labs(
    title = "Distribution of Temperatures",
    x = "Temperature",
    y = "Frequency"
  ) + theme_minimal()

temperature_comparison <- data.frame(
  work = c(rep("Test", length(temperatures_test_longer$temperature_type)), rep("Taskset", length(temperatures_taskset_longer$temperature_type))),
  temperature_type = c(temperatures_test_longer$temperature_type, temperatures_taskset_longer$temperature_type),
  temperature = c(temperatures_test_longer$temperature, temperatures_taskset_longer$temperature)
)

temperature_comparison %>% group_by(work, temperature_type) %>%
  summarise(
    mean_temperature = mean(temperature),
    median_temperature = median(temperature),
    sd_temperature = sd(temperature),
    trimmed_temperature = mean(temperature, trim = 0.2),
    iqr_temperature = IQR(temperature)
  ) -> summary_temperature_comparison

wilcox_across_experiments_1 <- wilcox.test(temperatures_test_longer[ temperatures_test_longer$temperature_type == "europar_test.initial_temp_1", ]$temperature, temperatures_taskset_longer[temperatures_taskset_longer$temperature_type=="europar_taskset.initial_temp_1",]$temperature)
wilcox_across_experiments_2 <- wilcox.test(temperatures_test_longer[ temperatures_test_longer$temperature_type == "europar_test.initial_temp_2", ]$temperature, temperatures_taskset_longer[temperatures_taskset_longer$temperature_type=="europar_taskset.initial_temp_2",]$temperature)

ggplot(temperature_comparison, aes(x=temperature_type, y=temperature, fill=work)) +
  geom_violin(position = position_dodge(width = 0.8)) +
  labs(
    title = "Distribution of Temperatures",
    x = "Temperature Type",
    y = "Temperature Value",
  ) + theme_minimal()

europar_taskset_base <- europar_taskset %>% filter(base == TRUE)

europar_taskset_base %>% group_by(dimension, population_size) %>%
  summarise(
    mean_PKG = mean(PKG),
    median_PKG = median(PKG),
    sd_PKG = sd(PKG),
    trimmed_PKG = mean(PKG, trim = 0.2),
    iqr_PKG = IQR(PKG)
  ) -> summary_taskset_base

taskset_temperature_model_cubic <- glm(PKG ~ I(initial_temp^3)+ I(initial_temp^2) + initial_temp + dimension + population_size, data = europar_taskset_base)

taskset_temperature_model_cubic_interact <- glm(PKG ~ I(initial_temp^3)+ I(initial_temp^2) + initial_temp*dimension*population_size, data = europar_taskset_base)

taskset_temperature_model_quadratic_interact <- glm(PKG ~ I(initial_temp^2) + initial_temp*dimension*population_size, data = europar_taskset_base)

europar_taskset_processed <- process_deltas( europar_taskset )
europar_taskset_processed$dimension <- as.factor(europar_taskset_processed$dimension)
ggplot(europar_taskset_processed, aes(x = initial_temp_1, y = delta_PKG)) +
  geom_point(color=europar_taskset_processed$dimension ) +
  geom_smooth(method = "glm", aes(color=dimension), formula=y ~ I(x^2) + x + dimension*population_size) +
  labs(
    title = "Energy Consumption Over Time",
    x = "Temperature",
    y = "Delta PKG"
  ) + theme_minimal()

europar_taskset_processed %>% group_by(dimension, population_size) %>%
  summarise(
    mean_delta_PKG = mean(delta_PKG),
    median_delta_PKG = median(delta_PKG),
    sd_delta_PKG = sd(delta_PKG),
    trimmed_delta_PKG = mean(delta_PKG, trim = 0.2),
    iqr_delta_PKG = IQR(delta_PKG)
  ) -> summary_taskset_deltas

taskset_workload_temperature_model <- glm(delta_PKG ~ I(initial_temp_1^2) + initial_temp_1*dimension *population_size*evaluations, data = europar_taskset_processed)

anova_taskset_workload <- Anova(taskset_workload_temperature_model, type="III")

studentized_residuals <- rstudent(taskset_workload_temperature_model)

outliers <- which(abs(studentized_residuals) > 3)
europar_taskset_processed_no_outliers <- europar_taskset_processed[-outliers, ]

median_temperature_1 <- median(europar_taskset_processed$initial_temp_1)
mad_temperature_1 <- mad(europar_taskset_processed$initial_temp_1)

median_temperature_2 <- median(europar_taskset_processed$initial_temp_2)
mad_temperature_2 <- mad(europar_taskset_processed$initial_temp_2)

threshold_temperature_1 <- median_temperature_1 + 3 * mad_temperature_1
threshold_temperature_2 <- median_temperature_2 + 3 * mad_temperature_2

europar_taskset_processed_no_outliers_MAD <- europar_taskset_processed %>%
  filter(initial_temp_1 <= threshold_temperature_1, initial_temp_2 <= threshold_temperature_2)

europar_taskset_processed_no_outliers_MAD %>% group_by(dimension, population_size) %>%
  summarise(
    mean_delta_PKG = mean(delta_PKG),
    median_delta_PKG = median(delta_PKG),
    sd_delta_PKG = sd(delta_PKG),
    trimmed_delta_PKG = mean(delta_PKG, trim = 0.2),
    iqr_delta_PKG = IQR(delta_PKG)
  ) -> summary_taskset_deltas_no_outliers_MAD

europar_taskset_processed_no_outliers %>% group_by(dimension, population_size) %>%
  summarise(
    mean_delta_PKG = mean(delta_PKG),
    median_delta_PKG = median(delta_PKG),
    sd_delta_PKG = sd(delta_PKG),
    trimmed_delta_PKG = mean(delta_PKG, trim = 0.2),
    iqr_delta_PKG = IQR(delta_PKG)
  ) -> summary_taskset_deltas_no_outliers

# Using die 2, which is usually less occupied ------------------------------------------------------------
europar_taskset_die2_1 <- process_europar("data/europar-die-2-taskset-1-9-Feb-09-52-47.csv", "taskset-1")
plot_temperature(europar_taskset_die2_1)
europar_taskset_die2_2 <- process_europar("data/europar-die-2-taskset-2-9-Feb-12-48-31.csv", "taskset-2")
plot_temperature(europar_taskset_die2_2)
europar_taskset_die2_3 <- process_europar("data/europar-die-2-taskset-3-9-Feb-17-49-44.csv", "taskset-3")
plot_temperature(europar_taskset_die2_3)
europar_taskset_die2_4 <- process_europar("data/europar-die-2-taskset-4-10-Feb-07-32-28.csv", "taskset-4")
plot_temperature(europar_taskset_die2_4)
europar_taskset_die2_5 <- process_europar("data/europar-die-2-taskset-5-10-Feb-11-53-53.csv", "taskset-5")
plot_temperature(europar_taskset_die2_5)

europar_taskset_die2 <- rbind(europar_taskset_die2_1, europar_taskset_die2_2, europar_taskset_die2_3, europar_taskset_die2_4, europar_taskset_die2_5)

ggplot(europar_taskset_die2, aes(x=initial_temp, y=PKG)) + geom_point(color=europar_taskset_die2$dimension ) + labs( title = "Energy Consumption Over Temperature", x = "Temperature", y = "Energy Consumption " ) + theme_minimal()

ggplot(europar_taskset_die2, aes(x=cum_seconds, y = initial_temp_1 - initial_temp_2, color=initial_temp)) +
  scale_color_viridis_c() +
  geom_point() +
  guides( color = guide_colorbar(title = "Initial Temperature"))  + theme_minimal()

save(europar_taskset_die2, file = "data/europar_taskset_die2.rds")
taskset_die2_temp_range <- c(min(min(europar_taskset_die2$initial_temp_1), min(europar_taskset_die2$initial_temp_2)), max(max(europar_taskset_die2$initial_temp_1), max(europar_taskset_die2$initial_temp_2)) )

europar_taskset_die2 %>% group_by(dimension, population_size) %>%
  summarise(
    mean_initial_temp_1 = mean(initial_temp_1),
    median_initial_temp_1 = median(initial_temp_1),
    sd_initial_temp_1 = sd(initial_temp_1),
    trimmed_initial_temp_1 = mean(initial_temp_1, trim = 0.2),
    iqr_initial_temp_1 = IQR(initial_temp_1),
    mean_initial_temp_2 = mean(initial_temp_2),
    median_initial_temp_2 = median(initial_temp_2),
    sd_initial_temp_2 = sd(initial_temp_2),
    trimmed_initial_temp_2 = mean(initial_temp_2, trim = 0.2),
    iqr_initial_temp_2 = IQR(initial_temp_2)
  ) -> summary_taskset_die2_temperatures

temperatures_taskset_die2_df <- data.frame( europar_taskset_die2$initial_temp_1, europar_taskset_die2$initial_temp_2, europar_taskset_die2_1$work )
colnames(temperatures_taskset_die2_df) <- c("initial_temp_1", "initial_temp_2", "work")
temperatures_taskset_die2_df %>% pivot_longer(cols = starts_with("initial_temp"), names_to = "temperature_type", values_to = "temperature") -> temperatures_taskset_die2_longer
ggplot(temperatures_taskset_die2_longer, aes(color = temperature_type,y=temperature,x=work)) +
  geom_violin()+
  labs(
    title = "Distribution of Temperatures",
    x = "Temperature",
    y = "Frequency"
  ) + theme_minimal()

ggplot(temperatures_taskset_die2_longer, aes(x = temperature_type,y=temperature,color=work)) +
  geom_boxplot(notch=T)+
  labs(
    title = "Distribution of Temperatures",
    x = "Temperature type",
    y = "Temperature"
  ) + theme_minimal()


europar_taskset_die2_base <- europar_taskset_die2 %>% filter(base == TRUE)

europar_taskset_die2_base %>% group_by(dimension, population_size) %>%
  summarise(
    mean_PKG = mean(PKG),
    median_PKG = median(PKG),
    sd_PKG = sd(PKG),
    trimmed_PKG = mean(PKG, trim = 0.2),
    iqr_PKG = IQR(PKG)
  ) -> summary_taskset_die2_base

# Testing with balanced dies
icsme_balanced_1 <- process_europar("data/icsme-balanced-balanced-1-12-Feb-08-02-40.csv", "balanced-1")
plot_temperature(icsme_balanced_1)
icsme_balanced_2 <- process_europar("data/icsme-balanced-balanced-2-12-Feb-09-55-51.csv", "balanced-2")
plot_temperature(icsme_balanced_2)
icsme_balanced_3 <- process_europar("data/icsme-balanced-balanced-3-12-Feb-12-35-27.csv", "balanced-3")
plot_temperature(icsme_balanced_3)
icsme_balanced_4 <- process_europar("data/icsme-balanced-balanced-4-12-Feb-17-13-09.csv", "balanced-4")
plot_temperature(icsme_balanced_4)
icsme_balanced <- rbind(icsme_balanced_1, icsme_balanced_2, icsme_balanced_3, icsme_balanced_4)

ggplot(icsme_balanced, aes(x=initial_temp, y=PKG)) +
  geom_point(color=icsme_balanced$dimension ) +
  labs( title = "Energy Consumption Over Temperature", x = "Temperature", y = "Energy Consumption " ) + theme_minimal()

ggplot(icsme_balanced, aes(x=cum_seconds, y = initial_temp_1 - initial_temp_2, color=initial_temp)) + scale_color_viridis_c() + geom_point() + guides( color = guide_colorbar(title = "Initial Temperature")) + theme_minimal()

save(icsme_balanced, file = "data/icsme_balanced.rds")

# testing with hot first
icsm_hot_first_1 <- process_europar("data/icsme-unbalanced-1-13-Feb-07-21-46.csv", "unbalanced-1")
plot_temperature(icsm_hot_first_1)

icsm_hot_first_2 <- process_europar("data/icsme-unbalanced-2-13-Feb-12-27-47.csv", "unbalanced-2")
plot_temperature(icsm_hot_first_2)

icsm_hot_first_3 <- process_europar("data/icsme-unbalanced-3-13-Feb-17-09-01.csv", "unbalanced-3")
plot_temperature(icsm_hot_first_3)
