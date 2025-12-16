data_3 <- read.csv("data/ola-base-ola-baseline-14-Dec-12-06-42.csv")
data_4 <- read.csv("data/ola-1.11.7-v2-baseline-v2-14-Dec-20-40-47.csv")

data_3$group <- 2
data_4$group <- 3

data <- rbind(data_4,data_3)

library(ggplot2)

data$color <- ifelse(data$group == 2, "red", "blue")
data$shape <- ifelse(data$dimension == 3, 21,23)
ggplot(data, aes(x = seconds, y = PKG)) +
  geom_point(color=data$color, shape=data$shape,size=data$population_size/100) +
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

for (dim in c(3,5)) {
  for (pop in c(200,400)) {
    data_subset <- data %>%
      filter(dimension == dim, population_size == pop)
    group_2 <- data_subset$PKG[data_subset$group == 2]
    group_3 <- data_subset$PKG[data_subset$group == 3]
    test_result <- wilcox.test(group_2, group_3)
    cat("Dimension:", dim, "Population Size:", pop, "p-value:", test_result$p.value, "\n")
  }
}


