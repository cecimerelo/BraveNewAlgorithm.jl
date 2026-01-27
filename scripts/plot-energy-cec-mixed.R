process_and_plot <- function(file_path, group_name) {
  data <- read.csv(file_path)
  data$group <- group_name
  data$cum_seconds <- cumsum(data$seconds)
  print( ggplot(data, aes(x = cum_seconds, y = PKG, group=work, color=work)) +
    geom_line() +
    labs(
      title = paste("Energy Consumption Over Time -", group_name),
      x = "Time",
      y = "Energy Consumption "
    ) +
    theme_minimal())
  return(data)
}

process_deltas <- function(data) {
  n <- nrow(data)
  data$delta_PKG <- rep(NA_real_, n)
  data$delta_seconds <- rep(NA_real_, n)
  for (k in seq(from=0,to=n-1,by=61)) {
    for (i in seq(from=2,to=60,by=2)) {
      index <- k+i
      data$delta_seconds[index] <- data$seconds[index] - (data$seconds[index-1]+ data$seconds[index+1])/2
      data$delta_PKG[index] <- data$PKG[index] - (data$PKG[index-1] + data$PKG[index+1])/2

    }
  }
  return(data %>% filter( delta_PKG != 0))
}

create_summary <- function(data) {
  return(
    data %>%
      group_by(dimension, population_size, max_gens ) %>%
      summarise(
        mean_delta_PKG = mean(delta_PKG),
        median_delta_PKG = median(delta_PKG),
        trimmed_mean_delta_PKG = mean(delta_PKG, trim=0.2),
        sd_delta_PKG = sd(delta_PKG),
        iqr_delta_PKG = IQR(delta_PKG),
        iqr_PKG = IQR(PKG),
        conf_interval_delta_PKG = sprintf("[%s, %s]", round(t.test(delta_PKG)$conf.int[1], 2), round(t.test(delta_PKG)$conf.int[2], 2))
      )
  )
}

mixed_data_regular <- read.csv("data/cec-1.11.8-cec-initial-17-Jan-12-08-26.csv")
mixed_data_regular$group <- "regular"
mixed_data_regular$cum_seconds <- cumsum(mixed_data_regular$seconds)
mixed_data_regular$linewidth <- ifelse( mixed_data_regular$dimension == 10, 4,
                                       ifelse( mixed_data_regular$dimension ==5, 2, 1))
library(ggplot2)
ggplot(mixed_data_regular, aes(x = cum_seconds, y = PKG,group=work,color=work)) +
  geom_line(linewidth=mixed_data_regular$linewidth) +
  labs(
    title = "Energy Consumption Over Time",
    x = "Time",
    y = "Energy Consumption "
  ) +
  theme_minimal()

mixed_data_regular_self_correlation <- acf(mixed_data_regular$PKG, lag.max=60)


for (i in seq(from=2,to=nrow(mixed_data_regular),by=2)) {
  mixed_data_regular$delta_seconds[i] <- mixed_data_regular$seconds[i] - mixed_data_regular$seconds[i-1]
  mixed_data_regular$delta_PKG[i] <- mixed_data_regular$PKG[i] - mixed_data_regular$PKG[i-1]
}

library(dplyr)
mixed_data_regular_workload <- mixed_data_regular %>% filter( delta_PKG != 0)

summary_data_regular <- mixed_data_regular_workload %>%
  group_by(dimension, population_size, max_gens ) %>%
  summarise(
    mean_delta_PKG = mean(delta_PKG),
    median_delta_PKG = median(delta_PKG),
    trimmed_mean_delta_PKG = mean(delta_PKG, trim=0.2),
    sd_delta_PKG = sd(delta_PKG),
    iqr_delta_PKG = IQR(delta_PKG),
    conf_interval_delta_PKG = sprintf("[%s, %s]", round(t.test(delta_PKG)$conf.int[1], 2), round(t.test(delta_PKG)$conf.int[2], 2)),
    iqr_PKG = IQR(PKG)
  )


mixed_data_sandwich <- read.csv("data/cec-1.11.8-cec-sandwich-17-Jan-20-05-31.csv")
mixed_data_sandwich$group <- "sandwich"
mixed_data_sandwich$cum_seconds <- cumsum(mixed_data_sandwich$seconds)

mixed_data_sandwich_base <- mixed_data_sandwich %>% filter( work == "base-cec-sandwich")
mixed_data_sandwich_base_self_correlation <- acf(mixed_data_sandwich_base$PKG, lag.max=60)
mixed_data_sandwich_workload <- mixed_data_sandwich %>% filter( work == "cec-sandwich")
mixed_data_sandwich_workload_self_correlation <- acf(mixed_data_sandwich_workload$PKG, lag.max=60)

ggplot(mixed_data_sandwich, aes(x = cum_seconds, y = PKG,group=work,color=work)) +
  geom_line() +
  labs(
    title = "Energy Consumption Over Time",
    x = "Time",
    y = "Energy Consumption "
  ) +
  theme_minimal()

processed_sandwich_v1 <- process_deltas(mixed_data_sandwich)
summary_data_sandwich_v1 <- create_summary(processed_sandwich_v1)

mixed_data_sandwich_v2 <- read.csv("data/cec-1.11.8-cec-sandwich-v2-18-Jan-09-39-50.csv")
mixed_data_sandwich_v2$group <- "sandwich_v2"
mixed_data_sandwich_v2$cum_seconds <- cumsum(mixed_data_sandwich_v2$seconds)

ggplot(mixed_data_sandwich_v2, aes(x = cum_seconds, y = PKG,group=work,color=work)) +
  geom_line() +
  labs(
    title = "Energy Consumption Over Time",
    x = "Time",
    y = "Energy Consumption "
  ) +
  theme_minimal()

processed_sandwich_v2 <- process_deltas(mixed_data_sandwich_v2)
summary_data_sandwich_v2 <- create_summary(processed_sandwich_v2)

mixed_data_sandwich_v3 <- process_and_plot("data/cec-1.11.8-cec-sandwich-v3-18-Jan-11-55-49.csv", "sandwich_v3")
processed_sandwich_v3 <- process_deltas(mixed_data_sandwich_v3)
summary_data_sandwich_v3 <- create_summary(processed_sandwich_v3)


mixed_data_sandwich_v4 <- process_and_plot("data/cec-1.11.8-cec-sandwich-v4-18-Jan-13-40-03.csv", "sandwich_v4")
processed_sandwich_v4 <- process_deltas(mixed_data_sandwich_v4)
summary_data_sandwich_v4 <- create_summary(processed_sandwich_v4)

mixed_data_sandwich_v5 <- read.csv("data/cec-1.11.8-cec-sandwich-v5-18-Jan-17-48-30.csv")
mixed_data_sandwich_v5$group <- "sandwich_v5"
mixed_data_sandwich_v5$cum_seconds <- cumsum(mixed_data_sandwich$seconds)
ggplot(mixed_data_sandwich_v5, aes(x = cum_seconds, y = PKG,group=work,color=work)) +
  geom_line() + labs(
    title = "Energy Consumption Over Time",
    x = "Time",
    y = "Energy Consumption "
  ) + theme_minimal()
processed_sandwich_v5 <- process_deltas(mixed_data_sandwich_v5)
summary_data_sandwich_v5 <- create_summary(processed_sandwich_v5)

# Combine all data
processed_sandwich <- rbind(processed_sandwich_v1,
                              processed_sandwich_v2,
                              processed_sandwich_v3,
                              processed_sandwich_v4,
                              processed_sandwich_v5)

summary_sandwich <- create_summary(processed_sandwich)


# New results
results_v12_v1 <- read.csv("data/cec-1.12.4-cec-sandwich-v1-20-Jan-12-35-01.csv")
results_v12_v1$group <- "v12_v1"
results_v12_v1$cum_seconds <- cumsum(results_v12_v1$seconds)
ggplot(results_v12_v1, aes(x = cum_seconds, y = PKG,group=work,color=work)) +
  geom_line() + labs(
    title = "Energy Consumption Over Time",
    x = "Time",
    y = "Energy Consumption "
  ) + theme_minimal()
processed_results_v12_v1 <- process_deltas(results_v12_v1)
summary_results_v12_v1 <- create_summary(processed_results_v12_v1)

results_v12_v2 <- read.csv("data/cec-1.12.4-cec-sandwich-v2-20-Jan-15-14-48.csv")
results_v12_v2$group <- "v12_v2"
results_v12_v2$cum_seconds <- cumsum(results_v12_v2$seconds)
ggplot(results_v12_v2, aes(x = cum_seconds, y = PKG, group=work,color=work)) +
  geom_line() + labs(
    title = "Energy Consumption Over Time",
    x = "Time",
    y = "Energy Consumption "
  ) + theme_minimal()
processed_results_v12_v2 <- process_deltas(results_v12_v2)
summary_results_v12_v2 <- create_summary(processed_results_v12_v2)

results_v12_v3 <- read.csv("data/cec-1.12.4-cec-sandwich-v3-20-Jan-17-31-35.csv")
results_v12_v3$group <- "v12_v3"
results_v12_v3$cum_seconds <- cumsum(results_v12_v3$seconds)
ggplot(results_v12_v3, aes(x = cum_seconds, y = PKG, group=work,color=work)) +
  geom_line() + labs(
    title = "Energy Consumption Over Time",
    x = "Time",
    y = "Energy Consumption "
  ) + theme_minimal()

processed_results_v12_v3 <- process_deltas(results_v12_v3)
summary_results_v12_v3 <- create_summary(processed_results_v12_v3)

results_v12_v4 <- read.csv("data/cec-1.12.4-cec-sandwich-v4-21-Jan-07-36-17.csv")
results_v12_v4$group <- "v12_v4"
results_v12_v4$cum_seconds <- cumsum(results_v12_v4$seconds)
ggplot(results_v12_v4, aes(x = cum_seconds, y = PKG,
       group=work,color=work)) +
  geom_line() + labs(
    title = "Energy Consumption Over Time",
    x = "Time",
    y = "Energy Consumption "
  ) + theme_minimal()
processed_results_v12_v4 <- process_deltas(results_v12_v4)
summary_results_v12_v4 <- create_summary(processed_results_v12_v4)

results_v12_v5 <- read.csv("data/cec-1.12.4-cec-sandwich-v5-21-Jan-09-37-26.csv")
results_v12_v5$group <- "v12_v5"
results_v12_v5$cum_seconds <- cumsum(results_v12_v5$seconds)
ggplot(results_v12_v5, aes(x = cum_seconds, y = PKG,
       group=work,color=work)) +
  geom_line() + labs(
    title = "Energy Consumption Over Time",
    x = "Time",
    y = "Energy Consumption "
  ) + theme_minimal()

processed_results_v12_v5 <- process_deltas(results_v12_v5)
summary_results_v12_v5 <- create_summary(processed_results_v12_v5)

# Combine all new results
processed_results_v12 <- rbind(processed_results_v12_v1,
                               processed_results_v12_v2,
                               processed_results_v12_v3,
                               processed_results_v12_v4,
                               processed_results_v12_v5)

summary_results_v12 <- create_summary(processed_results_v12)


# Results with new kernel
results_new_kernel_v1 <- read.csv("data/cec-1.12.4-25.10-cec-mixed-v1-26-Jan-08-30-26.csv")
results_new_kernel_v1$group <- "new_kernel_v1"
results_new_kernel_v1$cum_seconds <- cumsum(results_new_kernel_v1$seconds)
ggplot(results_new_kernel_v1, aes(x = cum_seconds, y = PKG,
       group=work,color=work)) +
  geom_line() + labs(
    title = "Energy Consumption Over Time",
    x = "Time",
    y = "Energy Consumption "
  ) + theme_minimal()

# Old results
lion_baseline <- read.csv("data/lion-1.11.7-baseline-bna-baseline-12-Jan-14-46-15.csv")
lion_baseline %>% group_by(dimension,population_size) %>%
  summarise(median_energy=median(PKG), sd_energy=sd(PKG),
            trimmed_mean_energy=mean(PKG,trim=0.2),
            median_time=median(seconds), sd_time=sd(seconds),
            trimmed_mean_time=mean(seconds, trim=0.2)) -> summary_lion_baseline

lion_results <- read.csv("data/lion-1.11.7-bna-fix-rand-bna-fix-rand-12-Jan-15-22-19.csv")
lion_results$delta_PKG <- 0
lion_results$delta_seconds <- 0
for (dim in c(3,5)) {
  for ( pop_size in c(200,400)) {
    number_of_rows <- nrow(lion_results[ lion_results$dimension==dim & lion_results$population_size==pop_size,])
    lion_results[ lion_results$dimension==dim & lion_results$population_size==pop_size,]$delta_PKG <-
      lion_results[ lion_results$dimension==dim & lion_results$population_size==pop_size,]$PKG  -
      rep(summary_lion_baseline[ summary_lion_baseline$population_size == pop_size & summary_lion_baseline$dimension==dim, ]$median_energy,number_of_rows)

    lion_results[ lion_results$dimension==dim & lion_results$population_size==pop_size,]$delta_seconds <-
      lion_results[ lion_results$dimension==dim & lion_results$population_size==pop_size,]$seconds  -
      rep(summary_lion_baseline[ summary_lion_baseline$population_size == pop_size & summary_lion_baseline$dimension==dim, ]$median_time,number_of_rows)
  }
}

lion_results %>% group_by(dimension,population_size) %>%
  summarise(
    mean_delta_PKG = mean(delta_PKG),
    median_delta_PKG = median(delta_PKG),
    trimmed_mean_delta_PKG = mean(delta_PKG, trim=0.2),
    sd_delta_PKG = sd(delta_PKG),
    iqr_delta_PKG = IQR(delta_PKG),
    iqr_PKG = IQR(PKG)
  ) -> summary_lion_results
