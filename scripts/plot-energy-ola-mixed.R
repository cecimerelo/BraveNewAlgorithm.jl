mixed_data <- read.csv("data/ola-1.11.7-mixed-ola-mixed-15-Dec-19-49-11.csv")
mixed_data$delta_seconds <- 0
mixed_data$delta_PKG <- 0

for (i in 2:nrow(mixed_data)) {
  if (mixed_data$work[i] == "ola-mixed") {
    mixed_data$delta_seconds[i] <- mixed_data$seconds[i] - mixed_data$seconds[i-1]
    mixed_data$delta_PKG[i] <- mixed_data$PKG[i] - mixed_data$PKG[i-1]
  }
}

library(ggplot2)

mixed_data$color <- ifelse(mixed_data$population_size == 200, "red", "blue")
mixed_data$shape <- ifelse(mixed_data$dimension == 3, 21,23)
ggplot(mixed_data, aes(x = delta_seconds, y = delta_PKG)) +
  geom_point(color=mixed_data$color, shape=mixed_data$shape) +
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
summary_data <- mixed_data %>%
  group_by(work,population_size, dimension, max_gens) %>%
  summarise(
    mean_PKG = mean(PKG),
    median_PKG = median(PKG),
    sd_PKG = sd(PKG),
    trimmed_PKG = mean(PKG, trim = 0.2),
    mean_delta_PKG = mean(delta_PKG, trim=0.2),
    sd_delta_PKG = sd(delta_PKG)
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


