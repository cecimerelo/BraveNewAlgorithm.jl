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


mixed_data_regular_workload <- mixed_data_regular %>% filter( delta_PKG != 0)

library(dplyr)
summary_data_regular <- mixed_data_regular_workload %>%
  group_by(dimension, population_size, max_gens ) %>%
  summarise(
    mean_delta_PKG = mean(delta_PKG),
    median_delta_PKG = median(delta_PKG),
    trimmed_mean_delta_PKG = mean(delta_PKG, trim=0.2),
    sd_delta_PKG = sd(delta_PKG),
    iqr_delta_PKG = IQR(delta_PKG),
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


n <- nrow(mixed_data_sandwich)
mixed_data_sandwich$delta_PKG <- rep(NA_real_, n)
mixed_data_sandwich$delta_seconds <- rep(NA_real_, n)
for (k in seq(from=0,to=n-1,by=61)) {
  for (i in seq(from=2,to=60,by=2)) {
    index <- k+i
    mixed_data_sandwich$delta_seconds[index] <- mixed_data_sandwich$seconds[index] - (mixed_data_sandwich$seconds[index-1]+ mixed_data_sandwich$seconds[index+1])/2
    mixed_data_sandwich$delta_PKG[index] <- mixed_data_sandwich$PKG[index] - (mixed_data_sandwich$PKG[index-1] + mixed_data_sandwich$PKG[index+1])/2

  }
}

mixed_data_sandwich_workload <- mixed_data_sandwich %>% filter( delta_PKG != 0)
summary_data_sandwich <- mixed_data_sandwich_workload %>%
  group_by(dimension, population_size, max_gens ) %>%
  summarise(
    mean_delta_PKG = mean(delta_PKG),
    median_delta_PKG = median(delta_PKG),
    trimmed_mean_delta_PKG = mean(delta_PKG, trim=0.2),
    sd_delta_PKG = sd(delta_PKG),
    iqr_delta_PKG = IQR(delta_PKG),
    iqr_PKG = IQR(PKG)
  )


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
n <- nrow(mixed_data_sandwich_v2)
mixed_data_sandwich_v2$delta_PKG <- rep(NA_real_, n)
mixed_data_sandwich_v2$delta_seconds <- rep(NA_real_, n)
for (k in seq(from=0,to=n-1,by=61)) {
  for (i in seq(from=2,to=60,by=2)) {
    index <- k+i
    mixed_data_sandwich_v2$delta_seconds[index] <- mixed_data_sandwich$seconds[index] - (mixed_data_sandwich_v2$seconds[index-1]+ mixed_data_sandwich_v2$seconds[index+1])/2
    mixed_data_sandwich_v2$delta_PKG[index] <- mixed_data_sandwich_v2$PKG[index] - (mixed_data_sandwich_v2$PKG[index-1] + mixed_data_sandwich_v2$PKG[index+1])/2
  }
}
mixed_data_sandwich_v2_workload <- mixed_data_sandwich_v2 %>% filter( delta_PKG != 0)
summary_data_sandwich_v2 <- mixed_data_sandwich_v2_workload %>%
  group_by(dimension, population_size, max_gens ) %>%
  summarise(
    mean_delta_PKG = mean(delta_PKG),
    median_delta_PKG = median(delta_PKG),
    trimmed_mean_delta_PKG = mean(delta_PKG, trim=0.2),
    sd_delta_PKG = sd(delta_PKG),
    iqr_delta_PKG = IQR(delta_PKG),
    iqr_PKG = IQR(PKG)
  )

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
