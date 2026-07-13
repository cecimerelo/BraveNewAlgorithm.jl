readRDS("data/schwefel_v7.RDS")
readRDS("data/schaffer_v7.RDS")

schaffer_v7_all$func <- "Schaffer"
schwefel_v7$func <- "Schwefel"

schs <- rbind(schaffer_v7_all, schwefel_v7)

schs_time_model <- glm( seconds ~  work*func*(dimension*population_size + initial_temp_1* initial_temp_2 + final_temp_1*final_temp_2), data=schs)
