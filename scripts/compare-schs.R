library(dplyr)

schwefel_v7 <- readRDS("data/schwefel_v7.RDS")
schaffer_v7 <- readRDS("data/schaffer_v7.RDS")

schaffer_v7$func <- "Schaffer"
schwefel_v7$func <- "Schwefel"

schs <- rbind(schaffer_v7, schwefel_v7) %>% filter( workload == "workload" )

schs$dimension <- as.factor(schs$dimension)
schs$population_size <- as.factor(schs$population_size)

schs_time_model <- glm( seconds ~  work+func*(dimension*population_size + initial_temp_1* initial_temp_2 + final_temp_1*final_temp_2), data=schs)

schaffer <- schs %>% filter( func=="Schaffer")

schaffer_time_model <- glm( seconds ~  work*(dimension*population_size + initial_temp_1* initial_temp_2 + final_temp_1*final_temp_2), data=schaffer)

schs_baseline <- rbind(schaffer_v7_all, schwefel_v7) %>% filter( workload == "base" )
