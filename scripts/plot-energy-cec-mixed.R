mixed_data_regular <- read.csv("data/cec-1.11.8-cec-initial-17-Jan-12-08-26.csv")
mixed_data_regular$group <- "regular"

for (i in seq(from=2,to=nrow(mixed_data_regular),by=2)) {
  mixed_data_regular$delta_seconds[i] <- mixed_data_regular$seconds[i] - mixed_data_regular$seconds[i-1]
  mixed_data_regular$delta_PKG[i] <- mixed_data_regular$PKG[i] - mixed_data_regular$PKG[i-1]
}

mixed_data_sandwich <- read.csv("data/cec-1.11.8-cec-sandwich-17-Jan-14-16-14.csv")
mixed_data_sandwich$group <- "sandwich"

for (k in seq(from=0,to=nrow(mixed_data_sandwich)-1,by=61)) {
  for (i in seq(from=2,to=60,by=2)) {
    mixed_data_sandwich$delta_seconds[k+i] <- mixed_data_sandwich$seconds[k+i] - (mixed_data_sandwich$seconds[k+i-1]+ mixed_data_sandwich$seconds[k+i+1])/2
    mixed_data_sandwich$delta_PKG[k+i] <- mixed_data_sandwich$PKG[k+i]  - (mixed_data_sandwich$PKG[k+i-1] + mixed_data_sandwich$PKG[k+i+1])/2
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
