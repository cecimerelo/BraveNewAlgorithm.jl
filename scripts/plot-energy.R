data <- read.csv("data/evoapps-1.11.7-baseline-bna-baseline-16-Oct-11-08-20.csv")

# accumulate the column "seconds" in a column "accumulated_time"

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
