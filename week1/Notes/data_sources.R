# Census
# measure each of the individuals, we don't need to
# use a small subset to say something about the population

# Observational Study
# take random sample of individuals, each individual
# can be sampled once
# then we make an inference about all 8 individuals in
# this study
set.seed(5)
sample(1:8, size=4, replace=F)

# Convenience sample
# suppose some individuals are more likely to get sampled
# than others
# it may be more difficult to perform an inference
# on an entire population, be careful
probs = c(5, 5, 5, 5, 1, 1, 1, 1)/16
sample(1:8, size=4, replace=F, prob=probs)

# Randomized trial - causal analysis
# If a change in variable leads to a change in 
# another variable, to find do randomized trial
# see if there's a difference in their outcome
# and perform an analysis if the treatment caused
# that difference
treat1 = sample(1:8, size=2, replace=F);
treat2 = sample(2:7, size=2, replace=f);
c(treat1, treat2)

# Prediction study: train
# training set - build predictive model
# test set - evaluate predictive model
# measure variables, build predictive function
# based on those variables
set.seed(5)
sample(1:8, size=4, replace=F)
# Prediction study: test
# take a second sample from the remaining individuals
# and measure all their vars
# apply the function on vars and see if we can predict
# if the individuals have cancer or something
sample(c(1, 3, 4, 7), size=2, replace=F)

# Study over time: cross-sectional
# imagine we have the same indivuduals that we measure
# over couple days
# In this study, we take a particular time point
# and a random sample of individuals from that time point

# Study over time: longitudinal
# follow the same random sample of individuals 
# over time, goal may be inference or prediction

# Study over time: retrospective
# like longitudinal, but instead sampling them at
# beginning, we sample at the end
# we measure how many of the sample (sick or not) 
# were exposed at the beginning. then we can ident 
# relationship between outcome and exposure.
# goal is inference