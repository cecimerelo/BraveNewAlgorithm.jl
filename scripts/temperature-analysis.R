europar.test <- read.csv("data/europar-europar-test-2-Feb-11-39-38.csv")

library(ggplot2)

europar.test$initial_temp <- (europar.test$initial_temp_1 + europar.test$initial_temp_2)/2
europar.test$color <- ifelse(europar.test$work == "europar-test", "red", "blue")

ggplot(europar.test, aes(x = initial_temp, y = PKG)) +
  geom_smooth(method = "lm", aes(color=work), se=FALSE) +
  geom_point(color=europar.test$color ) +
  labs(
    title = "Energy Consumption Over Temperature",
    x = "Temperature",
    y = "Energy Consumption "
  ) +
  theme_minimal()

europar.test$cum_seconds <- cumsum(europar.test$seconds)
europar.test$initial_temp <- as.numeric(europar.test$initial_temp)
ggplot(europar.test, aes(x = cum_seconds, y = PKG)) +
  # change color scale based on initial_temp
  scale_color_viridis_c() +
  geom_point( aes(color=initial_temp) ) +
  labs(
    title = "Energy Consumption Over time",
    x = "Time",
    y = "Energy Consumption "
  ) +
  theme_minimal()
