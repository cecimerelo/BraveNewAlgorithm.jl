schaffer_v7_1 <- read.csv("data/schaffer-v1-28-Jun-12-09-12.csv")
schaffer_v7_4 <- read.csv("data/schaffer-v4-29-Jun-14-41-58.csv")
schaffer_v7_3 <- read.csv("data/schaffer-v3-29-Jun-07-42-56.csv")
schaffer_v7_2 <- read.csv("data/schaffer-v2-28-Jun-19-16-54.csv")

schaffer_hot_first <- rbind( schaffer_v7_1, schaffer_v7_2, schaffer_v7_3, schaffer_v7_4)

schaffer_hot_first$work <- "hot-first"

schaffer_regular_v7_2 <- read.csv("data/schaffer-regular-v2-30-Jun-15-19-30.csv")
schaffer_regular_v7_1 <- read.csv("data/schaffer-regular-v1-30-Jun-07-58-45.csv")

schaffer_regular <- rbind( schaffer_regular_v7_1, schaffer_regular_v7_2)
schaffer_regular$work <- "baseline"

schaffer_v7_all <- rbind(schaffer_hot_first,schaffer_regular)

library(dplyr)
source("R/process_deltas.R")

schaffer_v7_workload <- process_deltas( schaffer_v7_all )

schaffer_v7_workload$dimension <- as.factor( schaffer_v7_workload$dimension )
schaffer_v7_workload$population_size <- as.factor( schaffer_v7_workload$population_size )
schaffer_v7_workload$evaluations <- as.factor( schaffer_v7_workload$evaluations )
schaffer_v7_workload$alpha <- as.factor( schaffer_v7_workload$alpha )

schaffer_time_model <- glm( delta_seconds ~ work*dimension*population_size*alpha + evaluations, data=schaffer_v7_workload )
