# distributions
# rfoo functions generate data
# function(n, mean=0, sd=1)
heights = rnorm(10, mean=188, sd=3)
# function(n, size, prob)
# n - number of scenarios
# size - number of coins "flipped"
# prob - each coins is fair, number of heads is added up
rbinom(10, size=10, prob=0.5)

# densities - probability of X values being in a some ranges
#function(x, mean=0, sd=1, log=FALSE) log units
x = seq(from=5, to=5, length=10)
# calc normal density of those points
normalDensity = dnorm(x, mean=0, sd=1)
round(normalDensity, 2)
# normal density
# function(x, size, prob, log=FALSE)
x = seq(0, 10, by=1)
binomialDensity = dbinom(x, size=10, prob=0.5)
round(binomialDensity, 2)


# sampling
# function(x, size, replace=FALSE, prob=NULL)
heights = rnorm(10, mean=188, sd=3)
# sample with replacement may sample the same value, draw one random value
# from vector of heights, then replaces that value in vector of heights and then
# draws a new random sample from among the 10 values
sample(heights, size=10, replace=T)
# value removed from heights vector, and so forth,
# in this case the we end up with the same vector
# because sizes are the same
sample(heights, size=10, replace=F)
# sampling in accordance with probabilities
# 0.4 prob that first value sampled, etc
probs = c(0.4, 0.3, 0.2, 0.1, 0, 0, 0, 0, 0, 0)
sample(heights, size=10, replace=T, prob=probs)

#setting seed - allows generating same random values
set.seed(12345)
rnorm(5, mean=0, sd=1)
