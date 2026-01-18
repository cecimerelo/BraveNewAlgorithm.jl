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
# compute mean, median, trimmed mean, sd and interquartile range of delta_PKG grouped by dimension and population_size

library(dplyr)
summary_data_regular <- mixed_data_regular_workload %>%
  group_by(dimension, population_size, max_gens ) %>%
  summarise(
    mean_delta_PKG = mean(delta_PKG),
    median_delta_PKG = median(delta_PKG),
    trimmed_mean_delta_PKG = mean(delta_PKG, trim=0.2),
    sd_delta_PKG = sd(delta_PKG),
    iqr_delta_PKG = IQR(delta_PKG)
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
    iqr_delta_PKG = IQR(delta_PKG)
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
    iqr_delta_PKG = IQR(delta_PKG)
  )
