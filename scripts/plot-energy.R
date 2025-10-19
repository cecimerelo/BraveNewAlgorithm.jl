data_1 <- read.csv("data/evoapps-1.11.7-baseline-bna-baseline-16-Oct-11-08-20.csv")
data_2 <- read.csv("data/evoapps-1.11.7-baseline-bna-baseline-2-19-Oct-19-25-31.csv")

data_1$group <- "1"
data_2$group <- "2"

data <- rbind(data_1, data_2)

data$accumulated_time <- cumsum(data$seconds)
library(ggplot2)

data$color <- ifelse(data$population_size == 200, "red", "blue")
data$shape <- ifelse(data$dimension == 3, 21,23)
ggplot(data, aes(x = accumulated_time, y = PKG)) +
  geom_line() + geom_point(color=data$color, shape=data$shape,size=3) +
  labs(
    title = "Energy Consumption Over Time",
    x = "Accumulated Time",
    y = "Energy Consumption "
  ) +
  theme_minimal()
ggsave("plots/energy-consumption-over-time-2.png", width=8, height=6)

ggplot(data, aes(x = factor(population_size), y = PKG, color=factor(dimension))) +
  geom_violin() +
  labs(
    title = "Energy Consumption Over Time",
    x = "Accumulated Time",
    y = "Energy Consumption ",
    color = "Population Size",
    shape = "Dimension"
  ) +
  theme_minimal()

library(dplyr)
summary_data <- data %>%
  group_by(population_size, dimension) %>%
  summarise(
    mean_PKG = mean(PKG),
    median_PKG = median(PKG),
    sd_PKG = sd(PKG),
    trimmed_PKG = mean(PKG, trim = 0.2)
  )
