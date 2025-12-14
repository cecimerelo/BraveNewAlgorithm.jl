data_1 <- read.csv("data/evoapps-1.11.7-baseline-bna-baseline-16-Oct-11-08-20.csv")
data_2 <- read.csv("data/evoapps-1.11.7-baseline-bna-baseline-2-19-Oct-19-25-31.csv")
data_3 <- read.csv("data/ola-base-ola-baseline-14-Dec-12-06-42.csv")

data_1$group <- 1
data_2$group <- 1
data_3$group <- 2

data <- rbind(data_1, data_2,data_3)

library(ggplot2)

data$color <- ifelse(data$population_size == 200, "red", "blue")
data$shape <- ifelse(data$dimension == 3, 21,23)
ggplot(data, aes(x = seconds, y = PKG)) +
  geom_point(color=data$color, shape=data$shape,size=1+data$group) +
  labs(
    title = "Energy Consumption Over Time",
    x = "Time",
    y = "Energy Consumption "
  ) +
  theme_minimal()

ggplot(data, aes(x = factor(population_size), y = PKG, color=factor(dimension))) +
  geom_violin() +
  labs(
    title = "Energy Consumption Over Time",
    x = "Time",
    y = "Energy Consumption ",
    color = "Population Size",
    shape = "Dimension"
  ) +
  theme_minimal()

library(dplyr)
summary_data <- data %>%
  group_by(population_size, dimension, group) %>%
  summarise(
    mean_PKG = mean(PKG),
    median_PKG = median(PKG),
    sd_PKG = sd(PKG),
    trimmed_PKG = mean(PKG, trim = 0.2)
  )

saveRDS(summary_data, "plots/energy-summary-data.rds")
saveRDS(data, "plots/energy-full-data.rds")
