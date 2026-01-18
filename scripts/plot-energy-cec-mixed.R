mixed_data_regular <- read.csv("data/cec-1.11.8-cec-initial-17-Jan-12-08-26.csv")
mixed_data_regular$group <- "regular"
mixed_data_regular$cum_seconds <- cumsum(mixed_data_regular$seconds)
library(ggplot2)
ggplot(mixed_data_regular, aes(x = cum_seconds, y = PKG,group=work,color=work)) +
  geom_line() +
  labs(
    title = "Energy Consumption Over Time",
    x = "Time",
    y = "Energy Consumption "
  ) +
  theme_minimal()

# measure autocorrelation in this time series
mixed_data_regular_self_correlation <- acf(mixed_data_regular$PKG, lag.max=60)


for (i in seq(from=2,to=nrow(mixed_data_regular),by=2)) {
  mixed_data_regular$delta_seconds[i] <- mixed_data_regular$seconds[i] - mixed_data_regular$seconds[i-1]
  mixed_data_regular$delta_PKG[i] <- mixed_data_regular$PKG[i] - mixed_data_regular$PKG[i-1]
}


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

mixed_data <- rbind(mixed_data_regular, mixed_data_sandwich)


mixed_data$color <- ifelse(mixed_data$group == "regular", "red", "blue")
mixed_data$shape <- ifelse(mixed_data$dimension == 10, 21,
                           ifelse(mixed_data$dimension == 5,22,23))

library(ggplot2)
ggplot(mixed_data, aes(x = delta_seconds, y = delta_PKG)) +
  geom_point(color=mixed_data$color, shape=mixed_data$shape, size=3) +
  labs(
    title = "Energy Consumption Over Time",
    x = "Time",
    y = "Energy Consumption "
  ) +
  theme_minimal()
