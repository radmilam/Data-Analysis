library(ggplot2)
summary(cars)
qplot(speed, dist, data=cars) + geom_smooth()