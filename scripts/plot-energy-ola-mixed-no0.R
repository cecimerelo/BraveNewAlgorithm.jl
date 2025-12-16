mixed_data_inverted <- read.csv("data/ola-1.11.8-mixed-inverted-ola-mixed-inverted-16-Dec-09-02-52.csv")
mixed_data_inverted$group <- "regular"
mixed_data_inverted$work <- ifelse( mixed_data_inverted$work == "ola-mixed-inverted", "workload", "base")
mixed_data_regular <- read.csv("data/ola-1.11.8-ola-no0-16-Dec-17-43-49.csv")
mixed_data_regular$group <- "no0"
mixed_data_regular$work <- ifelse( mixed_data_regular$work == "ola-no0", "workload", "base")

mixed_data <- rbind(mixed_data_regular, mixed_data_inverted)
for (i in 2:nrow(mixed_data)) {
  if (mixed_data$work[i] == "workload") {
    if (mixed_data$PKG[i]*mixed_data$PKG[i-1] == 0)  {
      next
    }
    mixed_data$delta_seconds[i] <- mixed_data$seconds[i] - mixed_data$seconds[i-1]
    mixed_data$delta_PKG[i] <- mixed_data$PKG[i] - mixed_data$PKG[i-1]
  }
}

library(ggplot2)
library(dplyr)
mixed_data_workload <- mixed_data %>% filter(delta_PKG != 0)

mixed_data_workload$color <- ifelse(mixed_data_workload$group == "regular", "red", "blue")
mixed_data_workload$shape <- ifelse(mixed_data_workload$dimension == 3, 21,23)
mixed_data_workload$size <- ifelse(mixed_data_workload$population_size == 200, 3,6)
ggplot(mixed_data_workload, aes(x = delta_seconds, y = delta_PKG)) +
  geom_point(color=mixed_data_workload$color, shape=mixed_data_workload$shape, size=mixed_data_workload$size) +
  labs(
    title = "Energy Consumption Over Time",
    x = "Time",
    y = "Energy Consumption "
  ) +
  theme_minimal() + xlim(0,5)+ ylim(0,250)

summary_data <- mixed_data %>%
  filter( PKG != 0) %>%
  group_by(work,population_size, dimension, max_gens, group) %>%
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
      filter(dimension == dim, population_size == pop, work == "workload")
    group_regular <- data_subset$PKG[data_subset$group == "regular"]
    cat( "=================================================================================\n")
    cat( "Mean PKG for regular, Dim:", dim, "Pop:", pop, "=", mean(group_regular), "\n")
    group_inverted <- data_subset$PKG[data_subset$group == "no0"]
    cat( "Mean PKG for no0, Dim:", dim, "Pop:", pop, "=", mean(group_inverted), "\n")
    test_result <- wilcox.test(group_regular, group_inverted)
    cat("PKG Dimension:", dim, "Population Size:", pop, "p-value:", test_result$p.value, "\n")

    group_regular <- data_subset$delta_PKG[data_subset$group == "regular"]
    cat( "\nMean delta PKG for regular, Dim:", dim, "Pop:", pop, "=", mean(group_regular), "\n")
    group_inverted <- data_subset$delta_PKG[data_subset$group == "no0"]
    cat( "Mean delta PKG for no0, Dim:", dim, "Pop:", pop, "=", mean(group_inverted), "\n")
    test_result <- wilcox.test(group_regular, group_inverted)
    cat("Delta PKG Dimension:", dim, "Population Size:", pop, "p-value:", test_result$p.value, "\n")
  }
}




