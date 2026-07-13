library(readr)
library(purrr)
library(dplyr)
source("R/process_deltas.R")

hot_first_schwefel_workload <- process_deltas(map_dfr( c("data/schwefel-hot-first-v4-11-Jul-08-11-58.csv","data/schwefel-hot-first-v1-7-Jul-16-45-48.csv",
                                 "data/schwefel-hot-first-v2-9-Jul-07-47-56.csv","data/schwefel-hot-first-v3-10-Jul-07-38-18.csv"),
                               read_csv ))

hot_first_schwefel_workload$work <- "hot-first"

regular_schwefel_workload <-  process_deltas(map_dfr( c("data/schwefel-regular-v3-9-Jul-15-07-19.csv", "data/schwefel-regular-v4-10-Jul-15-19-05.csv",
                                "data/schwefel-regular-v1-7-Jul-08-03-24.csv",  "data/schwefel-regular-v2-8-Jul-07-40-20.csv"),
                              read_csv ))
regular_schwefel_workload$work <- "baseline"

schwefel_workload <- rbind(hot_first_schwefel_workload,regular_schwefel_workload)

temp_1_model <- glm( initial_temp_1 ~ work, data=schwefel_workload)
temp_2_model <- glm( initial_temp_2 ~ work, data=schwefel_workload)

schwefel_workload$dimension <- as.factor( schwefel_workload$dimension )
schwefel_workload$population_size <- as.factor( schwefel_workload$population_size )

schwefel_delta_time_model <- glm( delta_seconds ~ work+dimension*population_size + evaluations, data=schwefel_workload )
schwefel_time_model <- glm( seconds ~ work+dimension*population_size + evaluations, data=schwefel_workload )
schwefel_workload$residual_time <- residuals(schwefel_time_model)

schwefel_delta_PKG_model <- glm( delta_PKG ~ initial_temp_1*initial_temp_2 +
                             I(initial_temp_1^2)*I(initial_temp_2^2)+
                             work+dimension*population_size+
                             residual_time+I(residual_time^2)+
                             evaluations,
                            data=schwefel_workload)

schwefel_delta_temp1_model <- glm( initial_temp_1 ~ work+dimension*population_size, data=schwefel_workload)
schwefel_workload$residual_temp1 <- residuals(schwefel_delta_temp1_model)

schwefel_delta_temp2_model <- glm( initial_temp_2 ~ work+dimension*population_size, data=schwefel_workload)
schwefel_workload$residual_temp2 <- residuals(schwefel_delta_temp2_model)

schwefel_split_model <- glm( delta_PKG ~ work*(residual_temp1*residual_temp2 + residual_time)+
                               I(initial_temp_1^2)*I(initial_temp_2^2)+
                               work+dimension*population_size+
                               I(residual_time^2)+
                               evaluations,
                             data=schwefel_workload)
