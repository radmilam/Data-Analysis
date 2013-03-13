Prediction study design
=======================

Key ideas
* Motivation
* Steps in predictive studies
* Choosing the right data
* Error measures
* Study design

Why predict?
* [Glory](http://zimbio.com/photos/Chris+Volinsky)
* Riches
* Sport
* To save lives

Steps in building a prediction
-------------------------------
1. Find the right data
2. Define your error rate
3. Split data into:
 * Training
 * Testing
 * Validation (optional)
4. On the training set pick features
5. On the training set pick prediction function
6. On the training set cross-validate
7. If no validation - apply 1x to test set
8. If validation - apply to test set and refine
9. If validation - apply 1x to validation

Find the right data
-------------------
1. In some cases it is easy (movie ratings -> new movie ratings)
2. It may be harder (gene expression data -> disease)
3. Depends strongly on the definition of "good prediction".
4. Often more data > better models
5. Know the bench mark
6. You need to start with raw data for predictions - processing is often cross-sample.

Know the benchmarks
-------------------
Probability of perfect classification is approximately $\frac{1}{2}^\text{test set sample size}$

Defining true/false positives
-----------------------------
In general, **Positive** = identified and **Negative** = rejected. Therefore:
* **True positive** = correctly identified
* **False positive** = incorrectly identified
* **True negative** = correctly rejected
* **False negative** = incorrectly rejected

Medical testing example:
* **True positive** = Sick people correctly diagnosed as sick
* **False positive** = Healthy people incorrectly identified as sick
* **True negative** = Healthy people correctly identified as healthy
* **False negative** = Sick people incorrectly identified as healthy.

Sensitivity and specificity

Define your error rate
----------------------
Slide 11/15

[http://en.wikipedia.org/wiki/Sensitivity_and_specificity](http://en.wikipedia.org/wiki/Sensitivity_and_specificity)

Why your choice matters
-----------------------

Common error measures
---------------------
Common error measures
1. Mean squared error (or root mean squared error)
 * Continuous data, sensitive to outliers
2. Median absolute deviation
 * Continuous data, often more robust
3. Sensitivity (recall)
 * If you want few missed positives
4. Specificity
 * If you want few negatives called positives
5. Accuracy - binary data
 * Weights false positives/negatives equally
6. Concordance - multiple predictors, want to know how well they all coordinate predictions
 * One example is kappa
 
Study design
------------
When building own data sets. Gives an idea what to hold out and how to build classifiers.

[http://www2.research.att.com/~volinsky/papers/ASAStatComp.pdf](http://www2.research.att.com/~volinsky/papers/ASAStatComp.pdf)

**Training data** is used to build a predictive function. we may end up overfitting.

Key issues and further resources
--------------------------------
Issues:
1. Accuracy
2. Overfitting
3. Interpretability
4. Computational speed - best functions are slow.

Resources:
1. Practical machine learning
2. Elements of statistical learning
3. Coursera machine learning
4. Machine learning for hackers

Cross validation
================
Way to estimate out of sample error rate for the predictive function.

Key ideas
* Sub-sampling the training data - to build estimates of the error rate that we would get if we applied our prediction function to the test or validation data sets.
* Avoiding overfitting
* Making predictions generalizable

Steps in building a prediction
------------------------------
1. Find the right data
2. Define your error rate
3. Split data into:
 * Training
 * Testing
 * Validation (optional)
4. **On the training set pick features**
5. **On the training set pick prediction function**
6. **On the training set cross-validate**
7. If no validation - apply 1x to test set
8. If validation - apply to test set and refine
9. If validation - apply 1x to validation

Study design
------------
* Build model on training data set
* Test a couple times on test data set to do fine tuning
* Apply exactly one time to the validation set, the goal of it is to estimate how well the function worked between validation and test data sets.

Overfitting
------------
Two variables $x, y$ used to predict and $z$, which is the outcome equal to 0 or 1. $z$ is unrelated ot $x$ or $y$, so there's no predictor for it.

```r
set.seed(12345)
x <- rnorm(10)
y <- rnorm(10)
z <- rbinom(10, size = 1, prob = 0.5)
plot(x, y, pch = 19, col = (z + 3))
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-1.png) 


Classifier
----------
If $-0.2<y<0.6$ call blue, otherwise green

```r
par(mfrow = c(1, 2))
zhat <- (-0.2 < y) & (y < 0.6)
plot(x, y, pch = 19, col = (z + 3))
plot(x, y, pch = 19, col = (zhat + 3))
```

![plot of chunk unnamed-chunk-2](figure/unnamed-chunk-2.png) 


New data
--------
If -0.2 < y < 0.6 call blue, otherwise green


```r
set.seed(1233)
xnew <- rnorm(10)
ynew <- rnorm(10)
znew <- rbinom(10, size = 1, prob = 0.5)
par(mfrow = c(1, 2))
zhatnew <- (-0.2 < ynew) & (ynew < 0.6)
plot(xnew, ynew, pch = 19, col = (z + 3))
plot(xnew, ynew, pch = 19, col = (zhatnew + 3))
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3.png) 

Data has different properties that we exhibited the first time around, so we only capture one point. Classifier was good on training set but is really bad on test set.

Key idea
1. Accuracy on the training set (resubstitution accuracy) is optimistic
2. A better estimate comes from an independent set (test set accuracy)
3. But we can't use the test set when building the model or it becomes part of the training set
4. So we estimate the test set accuracy with the training set.

Cross-validation
-----------------
Approach:
1. Use the training set
2. Split it into training/test sets
3. Build a model on the training set
4. Evaluate on the test set
5. Repeat and average the estimated errors

Used for:
1. Picking variables to include in a model
2. Picking the type of prediction function to use
3. Picking the parameters in the prediction function
4. Comparing different predictors

Random subsampling
------------------
Take random points from the training set. Disadvantage is that you can get repeated elements.

K-fold
------
Brake up data into k parts.
Take first 1/k of the sample and call that the test set and build model on the rest of the data set. Then take the next 1/k, etc k times.

Leave one out
-------------
Take one sample one by one, extreme version of k-fold. Is much less biased, disadvantage is that since you're measure the error rate on one sample, you get sort of a variable estimate of the error rate. 

Example
-------

```r
# training set
y1 <- y[1:5]
x1 <- x[1:5]
z1 <- z[1:5]
# test set
y2 <- y[6:10]
x2 <- x[6:10]
z2 <- z[6:10]
# calc predictive function on basis of first values
zhat2 <- (y2 < 1) & (y2 > -0.5)
par(mfrow = c(1, 3))

plot(x1, y1, col = (z1 + 3), pch = 19)
plot(x2, y2, col = (z2 + 3), pch = 19)
plot(x2, y2, col = (zhat2 + 3), pch = 19)
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4.png) 

We get a pretty bad error rate (2nd fig), we get one value, whereas we have 2 other poinst that should have been blue (3rd fig).

Notes and further resources
---------------------------
* The training and test sets must come from the same popluation.
* Sampling should be designed to mimic real patterns (e.g., sampling time chunks for time series)
* Cross validation estimates have variance - it is difficult to estimate how much
* Cross validation in R
* cvTools
* boot

Predicting with regression models
=================================
Key ideas
* Use a standard regression model
 * lm
 * glm
* Predict new values with the coefficients
* Useful when the linear model is (nearly) correct

Pros:
* Easy to implement
* Easy to interpret
Cons:
* Often poor performance in nonlinear settings
 
Example: Old faithful eruptions
--------------------------------
Waiting time and duration


```r
data(faithful)
dim(faithful)
```

```
## [1] 272   2
```


It's common to use 2/3 for training and 1/3 for test set, but with a large number of samples 1/2 for both would be ok.

```r
set.seed(333)
trainSamples <- sample(1:272, size = (272/2), replace = F)
trainFaith <- faithful[trainSamples, ]
testFaith <- faithful[-trainSamples, ]
head(trainFaith)
```

```
##     eruptions waiting
## 128     4.500      82
## 23      3.450      78
## 263     1.850      58
## 154     4.600      81
## 6       2.883      55
## 194     4.100      84
```


### Eruption duration versus waiting time

```r
plot(trainFaith$waiting, trainFaith$eruptions, pch = 19, col = "blue", xlab = "Waiting", 
    ylab = "Duration")
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7.png) 

Appears there may be a linear trend and some clusters.

Fit a linear model
------------------
Relate eruption duration $ED_i$ to baseline $b_0$ plus change in eruption duration $b_1$ given a one unit change in wait time $WT_i$ plus error term $e_i$.
$$latex
ED_i=b_0+b_1WT_i+e_i
$$
Fit with linear function, we get estimates and standard errors and can perform inference, eg that there's a significant association between eruption duration and waiting time.

```r
lm1 <- lm(eruptions ~ waiting, data = trainFaith)
summary(lm1)
```

```
## 
## Call:
## lm(formula = eruptions ~ waiting, data = trainFaith)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -1.2969 -0.3543  0.0487  0.3310  1.0760 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept) -1.92491    0.22925    -8.4  5.8e-14 ***
## waiting      0.07639    0.00316    24.2  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Residual standard error: 0.494 on 134 degrees of freedom
## Multiple R-squared: 0.814,	Adjusted R-squared: 0.812 
## F-statistic:  585 on 1 and 134 DF,  p-value: <2e-16
```


Model fit
---------

```r
plot(trainFaith$waiting, trainFaith$eruptions, pch = 19, col = "blue", xlab = "Waiting", 
    ylab = "Duration")
lines(trainFaith$waiting, lm1$fitted, lwd = 3)
```

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 


Predict a new value
-------------------
$$latex
\hat{ED}=\hat{b}_0+\hat{b}_1WT
$$
* $\hat{b}_0$ - intercept
* $\hat{b}_1$ - slope
* $WT$ - waiting time

You can calculate that directly, 80 is whatever waiting time you want. You get the duration (intercept).

You can do the `predict` function to do the same thing. To do that, pass the predict function, the original lm object and a data frame with values for the variables you would like to predict. Waiting can also be a vector, in which case it'll return predictions for all those values. Variable names must match the ones in `lm`.

```r
coef(lm1)[1] + coef(lm1)[2] * 80
```

```
## (Intercept) 
##       4.186
```

```r
newdata <- data.frame(waiting = 80)
predict(lm1, newdata)
```

```
##     1 
## 4.186
```


Plot predictions - training and test
------------------------------------

```r
par(mfrow = c(1, 2))
plot(trainFaith$waiting, trainFaith$eruptions, pch = 19, col = "blue", xlab = "Waiting", 
    ylab = "Duration", main = "Training set")
lines(trainFaith$waiting, predict(lm1), lwd = 3)
plot(testFaith$waiting, testFaith$eruptions, pch = 19, col = "blue", xlab = "Waiting", 
    ylab = "Duration", main = "Test set")
lines(testFaith$waiting, predict(lm1, newdata = testFaith), lwd = 3)
```

![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-11.png) 

We can see the lines aren't exact and confirm that with errors below.

Get training set/test set errors
--------------------------------
Take fitted values and subtract the specific eruption durations. Take sum of squared errors. sqrt because we want the estimate of the error rate to be on the same scale as the actual measurements.

```r
# Calculate RMSE on training
sqrt(sum((lm1$fitted - trainFaith$eruptions)^2))
```

```
## [1] 5.713
```

```r

# Calculate RMSE on test
sqrt(sum((predict(lm1, newdata = testFaith) - testFaith$eruptions)^2))
```

```
## [1] 5.827
```

Test error is slightly larger than training error.

Prediction intervals
---------------------
An advantage of using regression models for prediction is that you can calculate prediction intervals.

```r
pred1 <- predict(lm1, newdata = testFaith, interval = "prediction")
ord <- order(testFaith$waiting)
plot(testFaith$waiting, testFaith$eruptions, pch = 19, col = "blue")
matlines(testFaith$waiting[ord], pred1[ord, ], type = "l", , col = c(1, 2, 2), 
    lty = c(1, 1, 1), lwd = 3)
```

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13.png) 

In this case it's a 95% prediction interval. That means that at each particular point, the probability that future observations fall within the interval is 95%. This wouldn't necessarily work for a highly non-linear data set.

Example with binary data: Baltimore Ravens
-------------------------------------------

```r
if (!file.exists("./data/ravensData.rda")) {
    download.file("http://dl.dropbox.com/u/7710864/data/ravensData.rda", destfile = "./data/ravensData.rda")
}
load("./data/ravensData.rda")
head(ravensData)
```

```
##   ravenWinNum ravenWin ravenScore opponentScore
## 1           1        W         24             9
## 2           1        W         38            35
## 3           1        W         28            13
## 4           1        W         34            31
## 5           1        W         44            13
## 6           0        L         23            24
```


Fit a logistic regression
-------------------------
* $RW$ - Ravens' win variable
* $RS$ - Ravens' score variable

Logit of the probability that The Ravens win equal to a linear function of the Ravens' score.
$$latex
logit(E[RW_i\mid RS_i])=b_0+b_1RS_i
$$

```r
glm1 <- glm(ravenWinNum ~ ravenScore, family = "binomial", data = ravensData)
par(mfrow = c(1, 2))
# this is without splitting to training and test sets yet
boxplot(predict(glm1) ~ ravensData$ravenWinNum, col = "blue")
boxplot(predict(glm1, type = "response") ~ ravensData$ravenWinNum, col = "blue")
```

![plot of chunk unnamed-chunk-15](figure/unnamed-chunk-15.png) 

`predict(glm1)` just predicts values for the actual observations in the training set.

Scores for cases when Ravens lost (0) are lower and higher for when they won (1) but they overlap. The values are also not between 0 and 1 as we'd expect. That's because they're on a linear scale of $\hat{b}_0+\hat{b}_1RS_i$. If we want to see them on scales of probabilities themselves - predicted probability that The Ravens are going to win, tell the prediction function to return `type="response"`. However, the difference is not that dramatic and we can't separate the scores clearly, meaning we'd need to use more variables than just `ravensScore`.

Choosing a cutoff (re-substitution)
-----------------------------------
Output of that model is a probability that The Ravens are going to win. The goal is to predict whether the Ravens will win or not, which is a binary variable. We need to convert the probabilities to 0s (lose) and 1s (win). A way to do this is to choose a cutoff. 0.5 is not always the best one, depending on regression model.

```r
# calculate series of cutoffs
xx <- seq(0, 1, length = 10)
err <- rep(NA, 10)
# loop over all possible values of that cutoff
for (i in 1:length(xx)) {
    # calc prob that ravens win, check if bigger than cutoff and calc the
    # number of times (sum) that is not equal to the value of ravenWinNum,
    # that's the number of errors that we're making. Sum of the total number
    # of errors that we make for each value of the cutoff.
    err[i] <- sum((predict(glm1, type = "response") > xx[i]) != ravensData$ravenWinNum)
}
# plot cutoff vs the number of errors.
plot(xx, err, pch = 19, xlab = "Cutoff", ylab = "Error")
```

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-16.png) 

In practice we'd use cross validation.

Comparing models with cross validation
--------------------------------------

```r
library(boot)
# error measure
cost <- function(win, pred = 0) mean(abs(win - pred) > 0.5)
glm1 <- glm(ravenWinNum ~ ravenScore, family = "binomial", data = ravensData)
glm2 <- glm(ravenWinNum ~ ravenScore, family = "gaussian", data = ravensData)
# 3-fold cross validation
cv1 <- cv.glm(ravensData, glm1, cost, K = 3)
cv2 <- cv.glm(ravensData, glm2, cost, K = 3)
# cost we get for each model
cv1$delta
```

```
## [1] 0.350 0.365
```

```r
cv2$delta
```

```
## [1] 0.40 0.42
```

binary outcome works a bit better

Notes and further reading
-------------------------
* Regression models with multiple covariates can be included
* Often useful in combination with other models
* Elements of statistical learning
* Modern applied statistics with S

Predicting with trees
=====================
Key ideas
* Iteratively split variables into groups
* Split where maximally predictive
* Evaluate "homogeneity" within each branch - how similar objects in one group are, want to maximize homogeneity.
* Fitting multiple trees often works better (forests)

Pros:
* Easy to implement
* Easy to interpret
* Better performance in nonlinear settings

Cons:
* Without pruning/cross-validation can lead to overfitting
* Harder to estimate uncertainty
* Results may be variable (different trees on outcome)

Basic algorithm
----------------
1. Start with all variables in one group
2. Find the variable/split that best separates the outcomes
3. Divide the data into two groups ("leaves") on that split ("node")
4. Within each split, find the best variable/split that separates the outcomes within the previous split.
5. Continue until the groups are too small or sufficiently "pure"

Measures of impurity
---------------------
* $\hat{P}_{mk}$ - Fraction of the observations assigned to group $m$ that have outcomes $k$
$$latex
\hat{P}_{mk}=\frac{1}{N_m}\sum\limits_{x_i\text{ in Leaf m}} ind(y_i=k)
$$
Misclassification error
$$latex
1-\hat{P}_{mk(m)}
$$
Gini index - measure of imbalance, maximized when you each of the outcomes has exactly half of the observations within the group.
$$latex
\sum\limits_{k\neq k'} \hat{P}_{mk}\times\hat{P}_{mk'}=\sum\limits_{k=1}^K \hat{P}_{mk}(1-\hat{P}_{mk})
$$
Cross-entropy or deviance - if all members of the group have the same outcome, entropy is small.
$$latex
\sum\limits_{k=1}^K \hat{P}_{mk}\ln\hat{p}_{mk}
$$
Goal is go find outcomes that have smallest measures of impurity.

Example: Iris data
-------------------

```r
data(iris)
names(iris)
```

```
## [1] "Sepal.Length" "Sepal.Width"  "Petal.Length" "Petal.Width" 
## [5] "Species"
```

```r
table(iris$Species)
```

```
## 
##     setosa versicolor  virginica 
##         50         50         50
```


Iris petal widths/sepal width
------------------------------

```r
plot(iris$Petal.Width, iris$Sepal.Width, pch = 19, col = as.numeric(iris$Species))
legend(1, 4.5, legend = unique(iris$Species), col = unique(as.numeric(iris$Species)), 
    pch = 19)
```

![plot of chunk unnamed-chunk-19](figure/unnamed-chunk-19.png) 


Iris petal widths/sepal width
-----------------------------

```r
# An alternative is library(rpart)
library(tree)
```

```
## Warning: package 'tree' was built under R version 2.15.3
```



```r
tree1 <- tree(Species ~ Sepal.Width + Petal.Width, data = iris)
summary(tree1)
```

```
## 
## Classification tree:
## tree(formula = Species ~ Sepal.Width + Petal.Width, data = iris)
## Number of terminal nodes:  5 
## Residual mean deviance:  0.204 = 29.6 / 145 
## Misclassification error rate: 0.0333 = 5 / 150
```

Residual mean and deviance is the measure of impurity.
The low misclassification error rate is not on cross validation set.

Plot tree
---------
`plot` gives lines, `text` gives... text. Second branch is between 0.8 ad 1.75

```r
plot(tree1)
text(tree1)
```

![plot of chunk unnamed-chunk-22](figure/unnamed-chunk-22.png) 


Another way of looking at a CART model
---------------------------------------

```r
plot(iris$Petal.Width, iris$Sepal.Width, pch = 19, col = as.numeric(iris$Species))
# overlays the lines
partition.tree(tree1, label = "Species", add = TRUE)
legend(1.75, 4.5, legend = unique(iris$Species), col = unique(as.numeric(iris$Species)), 
    pch = 19)
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-23.png) 

We can observe misclassifications, when different color points are in majority color's partition.

Predicting new values
----------------------
Generate uniform distribution from similar values from data. Reports probabilities of being each of the species given a data point.

```r
set.seed(32313)
newdata <- data.frame(Petal.Width = runif(20, 0, 2.5), Sepal.Width = runif(20, 
    2, 4.5))
pred1 <- predict(tree1, newdata)
pred1
```

```
##    setosa versicolor virginica
## 1       0    0.02174   0.97826
## 2       0    0.02174   0.97826
## 3       1    0.00000   0.00000
## 4       0    1.00000   0.00000
## 5       0    0.02174   0.97826
## 6       0    0.02174   0.97826
## 7       0    0.02174   0.97826
## 8       0    0.90476   0.09524
## 9       0    1.00000   0.00000
## 10      0    0.02174   0.97826
## 11      0    1.00000   0.00000
## 12      1    0.00000   0.00000
## 13      1    0.00000   0.00000
## 14      1    0.00000   0.00000
## 15      0    0.02174   0.97826
## 16      0    0.02174   0.97826
## 17      0    1.00000   0.00000
## 18      1    0.00000   0.00000
## 19      0    1.00000   0.00000
## 20      0    1.00000   0.00000
```


Overlaying new values
---------------------
We can then calculate prediciton value for each data point and plot.

```r
pred1 <- predict(tree1, newdata, type = "class")
plot(newdata$Petal.Width, newdata$Sepal.Width, col = as.numeric(pred1), pch = 19)
partition.tree(tree1, "Species", add = TRUE)
```

![plot of chunk unnamed-chunk-25](figure/unnamed-chunk-25.png) 


Pruning trees example: Cars
----------------------------
The prediction functions use a specific built in stopping point in the `tree` function. That stopping point isn't designed by cross-validation or any other step so it's not always clear that you won't overfit if you directly use the tree without doing any pruning.

```r
data(Cars93, package = "MASS")
head(Cars93)
```

```
##   Manufacturer   Model    Type Min.Price Price Max.Price MPG.city
## 1        Acura Integra   Small      12.9  15.9      18.8       25
## 2        Acura  Legend Midsize      29.2  33.9      38.7       18
## 3         Audi      90 Compact      25.9  29.1      32.3       20
## 4         Audi     100 Midsize      30.8  37.7      44.6       19
## 5          BMW    535i Midsize      23.7  30.0      36.2       22
## 6        Buick Century Midsize      14.2  15.7      17.3       22
##   MPG.highway            AirBags DriveTrain Cylinders EngineSize
## 1          31               None      Front         4        1.8
## 2          25 Driver & Passenger      Front         6        3.2
## 3          26        Driver only      Front         6        2.8
## 4          26 Driver & Passenger      Front         6        2.8
## 5          30        Driver only       Rear         4        3.5
## 6          31        Driver only      Front         4        2.2
##   Horsepower  RPM Rev.per.mile Man.trans.avail Fuel.tank.capacity
## 1        140 6300         2890             Yes               13.2
## 2        200 5500         2335             Yes               18.0
## 3        172 5500         2280             Yes               16.9
## 4        172 5500         2535             Yes               21.1
## 5        208 5700         2545             Yes               21.1
## 6        110 5200         2565              No               16.4
##   Passengers Length Wheelbase Width Turn.circle Rear.seat.room
## 1          5    177       102    68          37           26.5
## 2          5    195       115    71          38           30.0
## 3          5    180       102    67          37           28.0
## 4          6    193       106    70          37           31.0
## 5          4    186       109    69          39           27.0
## 6          6    189       105    69          41           28.0
##   Luggage.room Weight  Origin          Make
## 1           11   2705 non-USA Acura Integra
## 2           15   3560 non-USA  Acura Legend
## 3           14   3375 non-USA       Audi 90
## 4           17   3405 non-USA      Audi 100
## 5           13   3640 non-USA      BMW 535i
## 6           16   2880     USA Buick Century
```


Build a tree
------------
We're going to try to predict the drive-train. There's a lot of splits because there are a lot of variables. By including more and more splits, we can get better measures of impurity.

```r
treeCars <- tree(DriveTrain ~ MPG.city + MPG.highway + AirBags + EngineSize + 
    Width + Length + Weight + Price + Cylinders + Horsepower + Wheelbase, data = Cars93)
plot(treeCars)
text(treeCars)
```

![plot of chunk unnamed-chunk-27](figure/unnamed-chunk-27.png) 


Plot errors
-----------
we can cross-validate that model with the `cv.tree` function. `method="misclass"` will tell the number of misclassification errors, default is the deviance impurity measure.

We plot what happens for different sizes of the model. The misclassification error rate is not re-substitution error rate. Re-substitution would get smaller as we include more splits.

```r
par(mfrow = c(1, 2))
plot(cv.tree(treeCars, FUN = prune.tree, method = "misclass"))
plot(cv.tree(treeCars))
```

![plot of chunk unnamed-chunk-28](figure/unnamed-chunk-28.png) 


Prune the tree
---------------
Take original tree and give one that has the best 4 split tree.

```r
pruneTree <- prune.tree(treeCars, best = 4)
plot(pruneTree)
text(pruneTree)
```

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29.png) 

Gives a tree that has the smallest out-of-sample error rate than the tree that we'd grow without any pruning.

Show resubstitution error
-------------------------

```r
table(Cars93$DriveTrain, predict(pruneTree, type = "class"))
```

```
##        
##         4WD Front Rear
##   4WD     5     5    0
##   Front   1    66    0
##   Rear    1    10    5
```

```r
table(Cars93$DriveTrain, predict(treeCars, type = "class"))
```

```
##        
##         4WD Front Rear
##   4WD     5     5    0
##   Front   2    61    4
##   Rear    0     3   13
```

Pruned would work better. Simpler models sometimes perform better with new data sets.

* Note that cross validation error is a better measure of test set accuracy

Notes and further resources
----------------------------
* Hector Corrada Bravo's Notes, code
* Cosma Shalizi's notes
* Elements of Statistical Learning
* Classification and regression trees
Random forests
