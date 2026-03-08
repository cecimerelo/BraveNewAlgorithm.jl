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


# boxplot diff_fitness for every combination of dimension, population_size and max_gens for icsme_workload comparing with ppsn_hc_1_workload

library(ggplot2)
# create a dataframe with the diff_fitness of both workloads

diff_fitness_icsme_vs_hc <- rbind(
  data.frame(workload = "icsme", dimension = icsme_workload$dimension, population_size = icsme_workload$population_size, max_gens = icsme_workload$max_gens, diff_fitness = icsme_workload$diff_fitness),
  data.frame(workload = "ppsn_hc_1", dimension = ppsn_hc_1_workload$dimension, population_size = ppsn_hc_1_workload$population_size, max_gens = ppsn_hc_1_workload$max_gens, diff_fitness = ppsn_hc_1_workload$diff_fitness)
)

# adapt y axis to the effective dimension for every combination, I can't see anything for dimension 3 and 5
ggplot(diff_fitness_icsme_vs_hc, aes(x = workload, y = diff_fitness)) +
  geom_boxplot() +
  facet_grid(dimension ~ population_size + max_gens, scales = "free_y") +
  labs(title = "Diff Fitness Comparison between ICSME and PPSN HC 1", x = "Workload", y = "Diff Fitness") +

  theme_minimal()
