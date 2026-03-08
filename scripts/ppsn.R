load("data/icsm_hot_first.rds")

icsme_workload <- icsm_hot_first[ !startsWith(icsm_hot_first$work, "base-"), ]

library(dplyr)
# Compute mean, median and standard deviation of evaluations and generations for every combination of dimension, population_size and max_gens
icsme_workload %>% group_by(dimension,population_size, max_gens) %>%
  summarise(
    evaluations_mean = mean(evaluations),
    evaluations_sd = sd(evaluations),
    evaluations_median = median(evaluations),
    generations_mean = mean(generations),
    generations_sd = sd(generations),
    generations_median = median(generations),
    diff_fitness_mean = mean(diff_fitness),
    diff_fitness_sd = sd(diff_fitness),
    diff_fitness_median = median(diff_fitness)
  ) -> summary_icsme_workload


ppsn_hc_1 <- read.csv("data/PPSN-hc-1-8-Mar-14-48-29.csv")
ppsn_hc_1_workload <- ppsn_hc_1[ !startsWith(ppsn_hc_1$work, "base-"), ]

ppsn_hc_1_workload %>% group_by(dimension, population_size, max_gens) %>%
  summarise(
    evaluations_mean = mean(evaluations),
    evaluations_sd = sd(evaluations),
    evaluations_median = median(evaluations),
    generations_mean = mean(generations),
    generations_sd = sd(generations),
    generations_median = median(generations),
    diff_fitness_mean = mean(diff_fitness),
    diff_fitness_sd = sd(diff_fitness),
    diff_fitness_median = median(diff_fitness)
  ) -> summary_ppsn_hc_1


