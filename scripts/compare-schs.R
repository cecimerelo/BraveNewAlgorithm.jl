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

schaffer_initial_temp_1_model <- glm( initial_temp_1 ~ work*seconds_baseline_prev, data=schs[schs$func=="Schaffer",])
schaffer_initial_temp_2_model <- glm( initial_temp_2 ~ work*seconds_baseline_prev, data=schs[schs$func=="Schaffer",])
schaffer_final_temp_1_model <- glm( final_temp_1 ~ work*(initial_temp_1*initial_temp_2+seconds), data=schs[schs$func=="Schaffer",])
schaffer_final_temp_2_model <- glm( final_temp_2 ~ work*(initial_temp_1*initial_temp_2+seconds), data=schs[schs$func=="Schaffer",])

schwefel_initial_temp_1_model <- glm( initial_temp_1 ~ work*seconds_baseline_prev, data=schs[schs$func=="Schwefel",])

schwefel_final_temp_1_model <- glm( final_temp_1 ~ work*(initial_temp_1*initial_temp_2+seconds), data=schs[schs$func=="Schwefel",])
schwefel_final_temp_2_model <- glm( final_temp_2 ~ work*(initial_temp_1*initial_temp_2+seconds), data=schs[schs$func=="Schwefel",])

final_temp_1_model <- glm( final_temp_1 ~ work*(initial_temp_1*initial_temp_2+seconds), data=schs)
final_temp_2_model <- glm( final_temp_2 ~ work*(initial_temp_1*initial_temp_2+seconds), data=schs)

schs %>% filter(func=="Schaffer") %>% group_by(work) %>% summarize(mean(seconds_baseline_prev), sd(seconds_baseline_prev))
schs %>% filter(func=="Schwefel") %>% group_by(work) %>% summarize(mean(seconds_baseline_prev), sd(seconds_baseline_prev))

library(ggplot2)

ggplot( schs, aes( x= initial_temp_1, y = final_temp_1, color=interaction(work,func)))+geom_point(alpha=0.5)+theme_minimal()

schs %>% filter(initial_temp_1 > 60) %>% count(func, work)

schs %>% filter(initial_temp_1 > 60) %>%
  group_by(func, work) %>%
  summarize(mean_final = mean(final_temp_1), max_final = max(final_temp_1),
            min_final = min(final_temp_1), mean_secs = mean(seconds), n = n())

ggplot( schs, aes( x= initial_temp_2, y = final_temp_2, color=interaction(work,func)))+geom_point(alpha=0.5)+theme_minimal()

schs$initial_diff_temp <- schs$initial_temp_1 - schs$initial_temp_2

final_temp_1_diff_model <- glm( final_temp_1 ~ work*(initial_temp_1*initial_diff_temp+seconds), data=schs)
final_temp_2_diff_model <- glm( final_temp_2 ~ work*(initial_temp_2*initial_diff_temp+seconds), data=schs)

schwefel_final_temp_1_diff_model <- glm( final_temp_1 ~ work*(initial_temp_1*initial_diff_temp+seconds), data=schs[schs$func=="Schwefel",])
schwefel_final_temp_2_diff_model <- glm( final_temp_2 ~ work*(initial_temp_2*initial_diff_temp+seconds), data=schs[schs$func=="Schwefel",])

schaffer_final_temp_1_diff_model <- glm( final_temp_1 ~ work*(initial_temp_1*initial_diff_temp+seconds), data=schs[schs$func=="Schaffer",])
schaffer_final_temp_2_diff_model <- glm( final_temp_2 ~ work*(initial_temp_2*initial_diff_temp+seconds), data=schs[schs$func=="Schaffer",])
