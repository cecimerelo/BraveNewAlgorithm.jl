
scaphandre_data <- read.csv("data/scaphandre-test-run-pop-10k-dim-40.csv", header=FALSE)
names(scaphandre_data)[names(scaphandre_data) == "V1"] <- "energy_consumed"

library(ggplot2)

ggplot(scaphandre_data, aes(x=1,y=energy_consumed))+geom_violin()

scaphandre_data_with_time <- read.csv("data/scaphandre-with-time-pop-10k-dim-40.csv",sep=";")

ggplot(scaphandre_data_with_time, aes(x=seconds,y=Energy))+geom_point()+theme_minimal()
