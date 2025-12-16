mixed_data_inverted <- read.csv("data/ola-1.11.8-mixed-inverted-ola-mixed-inverted-16-Dec-09-02-52.csv")
mixed_data_inverted$group <- "1.11.8"
mixed_data_regular <- read.csv("data/ola-1.11.7-mixed-ola-mixed-15-Dec-19-49-11.csv")
mixed_data_regular$group <- "1.11.7"

mixed_data <- rbind(mixed_data_regular, mixed_data_inverted)
for (i in 2:nrow(mixed_data)) {
  if (mixed_data$work[i] == "ola-mixed" | mixed_data$work[i] == "ola-mixed-inverted") {
    mixed_data$delta_seconds[i] <- mixed_data$seconds[i] - mixed_data$seconds[i-1]
    mixed_data$delta_PKG[i] <- mixed_data$PKG[i] - mixed_data$PKG[i-1]
  }
}

library(ggplot2)

mixed_data$color <- ifelse(mixed_data$group == "1.11.8", "red", "blue")
mixed_data$shape <- ifelse(mixed_data$dimension == 3, 21,23)
mixed_data$size <- ifelse(mixed_data$population_size == 200, 3,6)
ggplot(mixed_data, aes(x = delta_seconds, y = delta_PKG)) +
  geom_point(color=mixed_data$color, shape=mixed_data$shape, size=mixed_data$size) +
  labs(
    title = "Energy Consumption Over Time",
    x = "Time",
    y = "Energy Consumption "
  ) +
  theme_minimal() + xlim(0,5)+ ylim(0,250)

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
    data_subset <- mixed_data %>%
      filter(dimension == dim, population_size == pop, (work == "ola-mixed" | work == "ola-mixed-inverted"))
    group_regular <- data_subset$PKG[data_subset$group == "1.11.7"]
    cat( "=================================================================================\n")
    cat( "Mean PKG for 1.11.7, Dim:", dim, "Pop:", pop, "=", mean(group_regular), "\n")
    group_inverted <- data_subset$PKG[data_subset$group == "1.11.8"]
    cat( "Mean PKG for 1.11.8, Dim:", dim, "Pop:", pop, "=", mean(group_inverted), "\n")
    test_result <- wilcox.test(group_regular, group_inverted)
    cat("PKG Dimension:", dim, "Population Size:", pop, "p-value:", test_result$p.value, "\n")

    group_regular <- data_subset$delta_PKG[data_subset$group == "1.11.7"]
    cat( "\nMean delta PKG for 1.11.7, Dim:", dim, "Pop:", pop, "=", mean(group_regular), "\n")
    group_inverted <- data_subset$delta_PKG[data_subset$group == "1.11.8"]
    cat( "Mean delta PKG for 1.11.8, Dim:", dim, "Pop:", pop, "=", mean(group_inverted), "\n")
    test_result <- wilcox.test(group_regular, group_inverted)
    cat("Delta PKG Dimension:", dim, "Population Size:", pop, "p-value:", test_result$p.value, "\n")
  }
}




