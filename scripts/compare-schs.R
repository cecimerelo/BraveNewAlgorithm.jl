library(dplyr)
source("R/process_covariates.R")

schwefel_v7 <- readRDS("data/schwefel_v7.Rds")
schaffer_v7 <- readRDS("data/schaffer_v7.Rds")

schaffer_v7$func <- "Schaffer"
schwefel_v7$func <- "Schwefel"

schs <- process_covariates(rbind(schaffer_v7, schwefel_v7) )

schs$dimension <- as.factor(schs$dimension)
schs$population_size <- as.factor(schs$population_size)

schaffer_time_model <- glm( seconds ~  work*(dimension*population_size + initial_temp_1* initial_temp_2 + final_temp_1*final_temp_2)+seconds_baseline_prev+seconds_baseline_post, data=schs[schs$func=="Schaffer",])

schaffer_final_temp_1_model <- glm( final_temp_1 ~ work*initial_temp_1*initial_temp_2, data=schs[schs$func=="Schaffer",])
schaffer_final_temp_2_model <- glm( final_temp_2 ~ work*initial_temp_1*initial_temp_2, data=schs[schs$func=="Schaffer",])

schwefel_final_temp_1_model <- glm( final_temp_1 ~ work*initial_temp_1*initial_temp_2, data=schs[schs$func=="Schwefel",])
schwefel_final_temp_2_model <- glm( final_temp_2 ~ work*initial_temp_1*initial_temp_2, data=schs[schs$func=="Schwefel",])

final_temp_1_model <- glm( final_temp_1 ~ work*(initial_temp_1*initial_temp_2+seconds), data=schs)
final_temp_2_model <- glm( final_temp_2 ~ work*(initial_temp_1*initial_temp_2+seconds), data=schs)
