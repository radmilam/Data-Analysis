Clustering Example
==================
Data from Samsung Galaxy accelerometer


```r
load("./Data/samsungData.rda")
names(samsungData)[1:12]
```

```
##  [1] "tBodyAcc-mean()-X" "tBodyAcc-mean()-Y" "tBodyAcc-mean()-Z"
##  [4] "tBodyAcc-std()-X"  "tBodyAcc-std()-Y"  "tBodyAcc-std()-Z" 
##  [7] "tBodyAcc-mad()-X"  "tBodyAcc-mad()-Y"  "tBodyAcc-mad()-Z" 
## [10] "tBodyAcc-max()-X"  "tBodyAcc-max()-Y"  "tBodyAcc-max()-Z"
```

```r
table(samsungData$activity)
```

```
## 
##   laying  sitting standing     walk walkdown   walkup 
##     1407     1286     1374     1226      986     1073
```


We're going to try to predict what sort of activity the subject was doing based on training data.

#### Plotting average acceleration for first subject

```r
par(mfrow = c(1, 2))
numericActivity <- as.numeric(as.factor(samsungData$activity))[samsungData$subject == 
    1]
# first subject, mean acceleration
plot(samsungData[samsungData$subject == 1, 1], pch = 19, col = numericActivity, 
    ylab = names(samsungData)[1])
plot(samsungData[samsungData$subject == 1, 2], pch = 19, col = numericActivity, 
    ylab = names(samsungData)[2])
legend(150, -0.1, legend = unique(samsungData$activity), col = unique(numericActivity), 
    pch = 19)
```

![plot of chunk unnamed-chunk-2](figure/unnamed-chunk-2.png) 


#### Clustering based just on average acceleration
* Calculate distance between acceleration measurements, between all the activities performed by subject 1
* perform hierarchical clustering

```r
source("http://dl.dropbox.com/u/7710864/courseraPublic/myplclust.R")
distanceMatrix <- dist(samsungData[samsungData$subject == 1, 1:3])
hclustering <- hclust(distanceMatrix)
myplclustust(hclustering, lab.col = numericActivity)
```

```
## Error: could not find function "myplclustust"
```

Since it doesn't cluster nicely, we can look at other variables in the data set.

Max acceleration in each of the axis directions

```r
par(mfrow = c(1, 2))
plot(samsungData[samsungData$subject == 1, 10], pch = 19, col = numericActivity, 
    ylab = names(samsungData)[10])
plot(samsungData[samsungData$subject == 1, 11], pch = 19, col = numericActivity, 
    ylab = names(samsungData)[11])
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4.png) 


Now the data is distinguished better. Walking has higher acceleration than lying.
#### Clustering based on maximum acceleration
See how well the clusters are distinguished.

```r
distanceMatrix <- dist(samsungData[samsungData$subject == 1, 10:12])
hclustering <- hclust(distanceMatrix)
myplclust(hclustering, lab.col = numericActivity)
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5.png) 

Walking and walking up is not clearly distinguished, but walking down gets its own cluster - far left baby blue.

The clustering is improved over using just the mean acceleration. To distinguish the other activities, we'll use SVD.

#### Singular value decomposition
* Rows: each subject
* columns: data collected with accelerometer - the data below leaves out subject (562) and activity (563) variables because we're not interested in those, just the Samsung data.

```r
svd1 = svd(scale(samsungData[samsungData$subject == 1, -c(562, 563)]))
par(mfrow = c(1, 2))
# first and second singular vectors
plot(svd1$u[, 1], col = numericActivity, pch = 19)
plot(svd1$u[, 2], col = numericActivity, pch = 19)
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.png) 


First singular vector distinguishes sitting lying standing from walking, walking up or down. Looks a lot like the max acceleration vector. The second singular vector is orthogonal (correlated) to the first one. In it walking up and down is distinguished. The left singular vector represents an average over the patterns in data set. We want to see if we can discover what are the variables that we're observing. To do this:

#### Find maximum contributor

```r
plot(svd1$v[, 2], pch = 19)
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7.png) 


We're looking at all the variables and weights that they contribute to the pattern that is the second singular vector. We may want to pick up the heaviest variables, ones that contribute the most variation and include that variable when we do our clustering.

#### New clustering with maximum contributor

```r
# second singular vector, the one that distinguished walking up from
# walking down
maxContrib <- which.max(svd1$v[, 2])
# max acceleration variables and max contributor variable
distanceMatrix <- dist(samsungData[samsungData$subject == 1, c(10:12, maxContrib)])
hclustering <- hclust(distanceMatrix)
myplclust(hclustering, lab.col = numericActivity)
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8.png) 


Now you can see more variables separated.

#### New clustering with maximum contributor
We can go back and see what variable it was that contributed the above.


```r
names(samsungData)[maxContrib]
```

```
## [1] "fBodyAcc-meanFreq()-Z"
```


Mean frequency for the Z variable will separate walking from walking upstairs.

#### K-means clustering (nstart=1, first try)
Same data is omited as before. We want 6 clusters, then we make a table of what cluster we want the data in vs what activity the subject was performing.


```r
kClust <- kmeans(samsungData[samsungData$subject == 1, -c(562, 563)], centers = 6)
table(kClust$cluster, samsungData$activity[samsungData$subject == 1])
```

```
##    
##     laying sitting standing walk walkdown walkup
##   1     20      13        3    0        0      0
##   2      0       0        0    0       48      0
##   3      0       0        0   45        0      0
##   4     26      34       50    0        0      0
##   5      4       0        0    0        0     53
##   6      0       0        0   50        1      0
```


#### K-means clustering (nstart=1, second try)

```r
kClust <- kmeans(samsungData[samsungData$subject == 1, -c(562, 563)], centers = 6, 
    nstart = 1)
table(kClust$cluster, samsungData$activity[samsungData$subject == 1])
```

```
##    
##     laying sitting standing walk walkdown walkup
##   1      0       9       25    0        0      0
##   2      8       2        0    0        0      0
##   3     27       0        0    0        0      0
##   4      0      28       27    0        0      0
##   5      0       0        0   95       49     53
##   6     15       8        1    0        0      0
```

Clusters differ from the first time, to remedy that we can give the algorithm more starts.

#### K-means clustering (nstart=100, first try)

```r
kClust <- kmeans(samsungData[samsungData$subject == 1, -c(562, 563)], centers = 6, 
    nstart = 100)
table(kClust$cluster, samsungData$activity[samsungData$subject == 1])
```

```
##    
##     laying sitting standing walk walkdown walkup
##   1      3       0        0    0        0     53
##   2     29       0        0    0        0      0
##   3     18      10        2    0        0      0
##   4      0      37       51    0        0      0
##   5      0       0        0   95        0      0
##   6      0       0        0    0       49      0
```



Running it again gives a similar example, ordering may be unstable.

#### Cluster 1 Variable Centers (Laying)
We can look at what each of the clusters means

```r
plot(kClust$center[1, 1:10], pch = 19, ylab = "Cluster Center", xlab = "")
```

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13.png) 


First 3 variables represent mean acceleration X, Y, Z, etc

Walking:

```r
plot(kClust$center[6, 1:10], pch = 19, ylab = "Cluster Center", xlab = "")
```

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14.png) 


Basic Least Squares
===================
Regression

Example: Average parent and child heights
-----------------------------------------
Still better to use mid-heights than genetic indicators.

#### Load Galton Data

```r
library(UsingR)
```

```
## Loading required package: MASS
```

```r
data(galton)
par(mfrow = c(1, 2))
hist(galton$child, col = "blue", breaks = 100)
hist(galton$parent, col = "blue", breaks = 100)
```

![plot of chunk unnamed-chunk-15](figure/unnamed-chunk-15.png) 


#### Only know the child - average height
How do we brake up this distribution? We can use the mean.


```r
hist(galton$child, col = "blue", breaks = 100)
meanChild <- mean(galton$child)
lines(rep(meanChild, 100), seq(0, 150, length = 100), col = "red", lwd = 5)
```

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-16.png) 


#### Why average?
If $C_i$ is the height of child $i$ then the average is the value of $\mu$ that minimizes:
$$latex
\sum\limits_{i=1}^928 (C_i-\mu\)^2
$$

#### What if we plot child versus average parent

```r
plot(galton$parent, galton$child, pch = 19, col = "blue")
```

![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17.png) 

There seems to be a relationship. Data stacked because of lack of many significant digits. You can add jitter.

```r
set.seed(1234)
plot(jitter(galton$parent, factor = 2), jitter(galton$child, factor = 2), pch = 19, 
    col = "blue")
```

![plot of chunk unnamed-chunk-18](figure/unnamed-chunk-18.png) 


#### Average parent=65 inches tall
Other way to look at different ways to predict child height.

Average child height for parents that have some average height: 65 inches

```r
plot(galton$parent, galton$child, pch = 19, col = "blue")
near65 <- galton[abs(galton$parent - 65) < 1, ]
points(near65$parent, near65$child, pch = 19, col = "red")
lines(seq(64, 66, length = 100), rep(mean(near65$child), 100), col = "red", 
    lwd = 4)
```

![plot of chunk unnamed-chunk-19](figure/unnamed-chunk-19.png) 


#### Fitting a line
lm: linear model: quantitative outcome on left ~ variables to include in model

The line gives average child height for parents with height on x axis.

```r
plot(galton$parent, galton$child, pch = 19, col = "blue")
near71 <- galton[abs(galton$parent - 71) < 1, ]
points(near71$parent, near71$child, pch = 19, col = "red")
lines(seq(70, 72, length = 100), rep(mean(near71$child), 100), col = "red", 
    lwd = 4)
```

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20.png) 


#### The equation for a line
If $C_i$ is the height of a child $i$ and $P_i$ is the height of the average parent, then we can imagine riting the equation for a line:
$$latex
C_i=b_0+b_1P_i
$$
Adding an error term
$$latex
C_i=b_0+b_1P_i+e_i
$$
$e_i is everything we didn't measure (how much they eat, where they live, do they stretch in the morning...)

#### How do we pick best?
If $C_i$ is the height of child $i$ and $P_i$ is the height of the average parent, pick the line that makes the child values $C_i$ and our guesses
$$latex
\sum\limits_{i_1}^928 (C_i-\{b_0+b_1P_i\})^2
$$
We have height and want to estimate based it on some variable (the line in \{\} in this case). We pick $b_0$ and $b_1$ that make the equation smallest. That's what `lm` does.

#### Plot what is leftover

```r
par(mfrow = c(1, 2))
plot(galton$parent, galton$child, pch = 19, col = "blue")
lines(galton$parent, lm1$fitted, col = "red", lwd = 3)
```

```
## Error: object 'lm1' not found
```

```r
plot(galton$parent, lm1$residuals, col = "blue", pch = 19)
```

```
## Error: object 'lm1' not found
```

```r
abline(c(0, 0), col = "red", lwd = 3)
```

![plot of chunk unnamed-chunk-21](figure/unnamed-chunk-21.png) 

We plot parent vs child height, and overlay the lm estimate and distance of point to line, which would give how much variation there is around the ideal case (lm). That's the second graph, the points are called **residuals**.

Inference Basics
================
What can we tell about the data?

Fit a line to the Galton Data
-----------------------------
Average parent height vs child height. `lm` always fits an intercept term, unless you tell it not to.

```r
library(UsingR)
data(galton)
plot(galton$parent, galton$child, pch = 19, col = "blue")
lm1 <- lm(galton$child ~ galton$parent)
lines(galton$parent, lm1$fitted, col = "red", lwd = 3)
```

![plot of chunk unnamed-chunk-22](figure/unnamed-chunk-22.png) 


If you increase parent's height by one unit (1 inch in this case), you'll get a corresponding change in child's height by 0.646 unit.

```r
lm1
```

```
## 
## Call:
## lm(formula = galton$child ~ galton$parent)
## 
## Coefficients:
##   (Intercept)  galton$parent  
##        23.942          0.646
```


### Create a "population" of 1 million families
Based on fit from original data set. We'll generate the parent's heights with mean being the mean we got from the Galton data set and sd from Galton. We also make up child heights from the model we fit on the Galton data. Intercept term from the galton model `lm1$coeff[1]` + slope, `lm1$coeff[2]` * parent value + some noise with `rnorm` so not all points lie on the line.

```r
newGalton <- data.frame(parent = rep(NA, 1e+06), child = rep(NA, 1e+06))
newGalton$parent <- rnorm(1e+06, mean = mean(galton$parent), sd = sd(galton$parent))
newGalton$child <- lm1$coeff[1] + lm1$coeff[2] * newGalton$parent + rnorm(1e+06, 
    sd = sd(lm1$residuals))
smoothScatter(newGalton$parent, newGalton$child)
```

```
## KernSmooth 2.23 loaded Copyright M. P. Wand 1997-2009
```

```r
abline(lm1, col = "red", lwd = 3)
```

![plot of chunk unnamed-chunk-24](figure/unnamed-chunk-24.png) 

### Let's take a sample: 1
Hypothetically - We can take a sub-sample of those million families and generate a new line. We sample size 50 with no replacement, then we fit a linear model. Red line is the original data, black is the new liear model on the sub-sample.

```r
set.seed(134325)
sampleGalton1 <- newGalton[sample(1:1e+06, size = 50, replace = F), ]
sampleLm1 <- lm(sampleGalton1$child ~ sampleGalton1$parent)
plot(sampleGalton1$parent, sampleGalton1$child, pch = 19, col = "blue")
lines(sampleGalton1$parent, sampleLm1$fitted, lwd = 3, lty = 2)
abline(lm1, col = "red", lwd = 3)
```

![plot of chunk unnamed-chunk-25](figure/unnamed-chunk-25.png) 


### Sample: 2
Using a different sub-sample.

```r
sampleGalton2 <- newGalton[sample(1:1e+06, size = 50, replace = F), ]
sampleLm2 <- lm(sampleGalton2$child ~ sampleGalton2$parent)
plot(sampleGalton2$parent, sampleGalton2$child, pch = 19, col = "blue")
lines(sampleGalton2$parent, sampleLm2$fitted, lwd = 3, lty = 2)
abline(lm1, col = "red", lwd = 3)
```

![plot of chunk unnamed-chunk-26](figure/unnamed-chunk-26.png) 

### Sample: 3

```r
sampleGalton3 <- newGalton[sample(1:1e+06, size = 50, replace = F), ]
sampleLm3 <- lm(sampleGalton3$child ~ sampleGalton3$parent)
plot(sampleGalton3$parent, sampleGalton3$child, pch = 19, col = "blue")
lines(sampleGalton3$parent, sampleLm3$fitted, lwd = 3, lty = 2)
abline(lm1, col = "red", lwd = 3)
```

![plot of chunk unnamed-chunk-27](figure/unnamed-chunk-27.png) 


### Many samples
We can do the above lots of times.

```r
sampleLm <- vector(100, mode = "list")
for (i in 1:100) {
    sampleGalton <- newGalton[sample(1:1e+06, size = 50, replace = F), ]
    sampleLm[[i]] <- lm(sampleGalton$child ~ sampleGalton$parent)
}
```

and plot.

```r
smoothScatter(newGalton$parent, newGalton$child)
for (i in 1:100) {
    abline(sampleLm[[i]], lwd = 3, lty = 2)
}
abline(lm1, col = "red", lwd = 3)
```

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29.png) 

Repeatedly applied a linear to the sample data sets.

### Histogram of estimates
If we were to tell something about the red line, but all we had was one of the black lines, what would we be able to say. We plot a histogram.

```r
par(mfrow = c(1, 2))
hist(sapply(sampleLm, function(x) {
    coef(x)[1]
}), col = "blue", xlab = "Intercept", main = "")
hist(sapply(sampleLm, function(x) {
    coef(x)[2]
}), col = "blue", xlab = "Slope", main = "")
```

![plot of chunk unnamed-chunk-30](figure/unnamed-chunk-30.png) 

However, we usually only have one sample.

### Distribution of coefficients
From central limit theorem, it turns out that in many cases  $\hat{b}_0$, the estimate of intercept and $\hat{b}_1$, the estimate of slope, follow normal distributions with mean $b_0$ and $b_1$:
$$latex
\hat{b}_0~(N(b_0, Var(\hat{b}_0)))\\
\hat{b}_1~(N(b_0, Var(\hat{b}_1)))\\\\
$$
We may not know what the variances are exactly but we can estimate with:
$$latex
\hat{b}_0\approx(N(b_0, \hat{Var(\hat{b}_0)}))\\
\hat{b}_1\approx(N(b_1, \hat{Var(\hat{b}_1)}))
$$


$\sqrt{\hat{Var}(\hat{b}_0)}$ is the "standard error" of the estimate $\hat{b}_0$ and is abbreviated $S.E.(\hat{b}_0)$

### Estimating the values in R
We take a subsample of size 50 and fit a linear model. We look at coefficients, second row is the slope.

```r
sampleGalton4 <- newGalton[sample(1:1e+06, size = 50, replace = F), ]
sampleLm4 <- lm(sampleGalton4$child ~ sampleGalton4$parent)
summary(sampleLm4)
```

```
## 
## Call:
## lm(formula = sampleGalton4$child ~ sampleGalton4$parent)
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -4.391 -1.805 -0.434  1.912  5.966 
## 
## Coefficients:
##                      Estimate Std. Error t value Pr(>|t|)    
## (Intercept)             9.859     13.831    0.71  0.47941    
## sampleGalton4$parent    0.851      0.202    4.22  0.00011 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Residual standard error: 2.58 on 48 degrees of freedom
## Multiple R-squared: 0.27,	Adjusted R-squared: 0.255 
## F-statistic: 17.8 on 1 and 48 DF,  p-value: 0.000109
```


The distribution of slopes if we ran the study 100 different times (`hist`) and the red line is the distribution that we estimate using the one slope and variance (S.E.) from the above sub-sample. Variance is about the same, Slope is slightly different.

```r
hist(sapply(sampleLm, function(x) {
    coef(x)[2]
}), col = "blue", xlab = "Slope", main = "", freq = F)
lines(seq(0, 5, length = 100), dnorm(seq(0, 5, length = 100), mean = coef(sampleLm4)[2], 
    sd = summary(sampleLm4)$coeff[2, 2]), lwd = 3, col = "red")
```

![plot of chunk unnamed-chunk-32](figure/unnamed-chunk-32.png) 


Why do we standardize?
----------------------
We want to be able to make comparisons and understanding of variables easier. Like converting Kelving to Celcius.

Suppose we want to identify we want to distribution is in the below model, without having all the different parameters.

```r
par(mfrow = c(1, 2))
hist(sapply(sampleLm, function(x) {
    coef(x)[1]
}), col = "blue", xlab = "Intercept", main = "")
hist(sapply(sampleLm, function(x) {
    coef(x)[2]
}), col = "blue", xlab = "Slope", main = "")
```

![plot of chunk unnamed-chunk-33](figure/unnamed-chunk-33.png) 


#### Standardization Coefficients
$$latex
\hat{b}_0\approx(N(b_0, \hat{Var(\hat{b}_0)}))\\
\hat{b}_1\approx(N(b_1, \hat{Var(\hat{b}_1)}))\\\\
$$
Turns out that if you do the below, where $b_0$ is the known mean value, it has what's called the T distribution, $n-2$ is the number of samples we had in our study - 2 degrees of freedom, which tell us how much variation we have left over after estimating the parameters.
$$latex
\frac{\hat{b}_0-b_0}{S.E.(\hat{b}_0)}\textasciitilde  t_n-2\\
\frac{\hat{b}_1-b_1}{S.E.(\hat{b}_1)}\textasciitilde  t_n-2
$$
Degrees of freedom $\approx$ number of samples - number of things you estimated.
```

#### $t_{n-2}$ versus $N(0, 1)$
* black - Normal distribution
* red - t with 3 deg of freedom, more prob density, less sure about center of the distribution, because we're more spread out
* blue - t with 10 degrees of freedom. As degrees of freedom get large, it's more like the normal distribution.

```r
x <- seq(-5, 5, length = 100)
plot(x, dnorm(x), type = "l", lwd = 3)
lines(x, dt(x, df = 3), lwd = 3, col = "red")
lines(x, dt(x, df = 10), lwd = 3, col = "blue")
```

![plot of chunk unnamed-chunk-34](figure/unnamed-chunk-34.png) 


Confidence intervals
--------------------
We have an estimate $\hat{b}_1$ and we want to know something about how good our estimate is, like what the real $b_1$ is. One way is to create a "level $\alpha$ confidence interval". 

The confidence interval will be a set of values for $b_1$ that we think are plausible. They're going to be divided. A confidence interval will include the parameter $\alpha$ percent of the time in repeated studies. If we took the sample over and over (say 100 times) and recalculated the confidence interval in the same way, then we'd get 100 different intervals and of those, $\alpha\%$ will cover the parameter that we actually care about.

The way we calculate them using T distribution and estimates of the S.E. that we calculate:
$$latex
(\hat{b}_1-T_{\alpha/2}\times S.E.(\hat{b}_1), \hat{b}_1+T_{\alpha/2}\times S.E.(\hat{b}_1))
$$
$\hat{b}_1$ and $S.E.(\hat{b}_1)$ we estimate using `lm`. To get the confidence interval, we multiply using S.E. with the quantile of the T distribution, where the quantile is $\alpha/2$. We do + and - that to make a symmetric interval.

`cofint` performs this calculation - we tell it what confidence level we want the result to be in.

```r
summary(sampleLm4)$coeff
```

```
##                      Estimate Std. Error t value  Pr(>|t|)
## (Intercept)            9.8590    13.8309  0.7128 0.4794056
## sampleGalton4$parent   0.8515     0.2019  4.2172 0.0001089
```

```r
confint(sampleLm4, level = 0.95)
```

```
##                         2.5 % 97.5 %
## (Intercept)          -17.9499 37.668
## sampleGalton4$parent   0.4455  1.257
```

What this tells us that while our intercept estimate is 15.8632, the 95% confidence interval is between -17.8072 to 39.534. So if we did the study over and over, we'd get values in this interval. Same values with the slope (second row).

These have a statistical meaning in terms of the frequency the confidence interval covers the actual value.

We do the same sub-sampling of 1m data sets, we take repeated samples of size 50, calculate linear model for each one and confidence interval for each of the 100 different replicants (?) - grey. Coefficient values are for the slope, black line is the real value. Most of the confidence intervals cover it, so about 5% as we told the `confint` function.

```r
par(mar = c(4, 4, 0, 2))
plot(1:10, type = "n", xlim = c(0, 1.5), ylim = c(0, 100), xlab = "Coefficient Values", 
    ylab = "Replication")
for (i in 1:100) {
    ci <- confint(sampleLm[[i]])
    color = "red"
    if ((ci[2, 1] < lm1$coeff[2]) & (lm1$coeff[2] < ci[2, 2])) {
        color = "grey"
    }
    segments(ci[2, 1], i, ci[2, 2], i, col = color, lwd = 3)
}
lines(rep(lm1$coeff[2], 100), seq(0, 100, length = 100), lwd = 3)
```

![plot of chunk unnamed-chunk-36](figure/unnamed-chunk-36.png) 



How you report the inference
----------------------------
We get the estimates for intercept and slope and confidence intervals for those values. 

```r
sampleLm4$coeff
```

```
##          (Intercept) sampleGalton4$parent 
##               9.8590               0.8515
```

```r
confint(sampleLm4, level = 0.95)
```

```
##                         2.5 % 97.5 %
## (Intercept)          -17.9499 37.668
## sampleGalton4$parent   0.4455  1.257
```

We may say:

A one inch increase in parental height is associated with a 0.77 inch increase in child's height (95% CI: 0.42-1.12 inches).

P-values
========
* Most common measure of "statistical significance"
* Commonly reported in papers
* Used for decision making (e.g. FDA)
* [Controversial among statisticians](http://warnercnr.colostate.edu/~anderson/thompson1.html), but [some find it useful](http://simplystatistics.org/2012/01/06/p-values-and-hypothesis-testing-get-a-bad-rap-but-we/)

What is a P-value?
------------------
**Idea:** Suppose nothing is going on - how unusual is it to see the estimate we got?

**Approach:**
1. Define the hypothetical distribution of a data summary (statistic) when "nothing is going on" (null hypothesis)
2. Calculate the summary/statistic with the data we have (test statistic)
3. Compare what we calculated to our hypothetical distribution and see if the value is "extreme" (p-value)

Galton data
------------
Overlayed least squares line

```r
library(UsingR)
data(galton)
plot(galton$parent, galton$child, pch = 19, col = "blue")
lm1 <- lm(galton$child ~ galton$parent)
abline(lm1, col = "red", lwd = 3)
```

![plot of chunk unnamed-chunk-38](figure/unnamed-chunk-38.png) 


### Null hypothesis/distribution
We can hypothesize there's no relationship between the variables.

$\hat{b}_1$ is the slope. If it was 0, the line would be horizontal, there'd be no relationship in the data.

The null hypothesis will be that $\hat{b}_1=0$

$$latex
\frac{\hat{b}_1-b_1}{S.E.(\hat{b}_1)}\textasciitilde  t_{n-2}
$$

$H_0$: That there is no relationship between parent and child height ($b_1=0$). Under the null hypothesis the distribution is:

$$latex
\frac{\hat{b}_1}{S.E.(\hat{b}_1)}\textasciitilde  t_{n-2}
$$

### Null distribution
2 degrees of freedom to estimate parameters.


```r
x <- seq(-20, 20, length = 100)
plot(x, dt(x, df = (928 - 2)), col = "blue", lwd = 3, type = "l")
```

![plot of chunk unnamed-chunk-39](figure/unnamed-chunk-39.png) 


### Null distribution + observed statistic
The t statistic

```r
x <- seq(-20, 20, length = 100)
plot(x, dt(x, df = (928 - 2)), col = "blue", lwd = 3, type = "l")
arrows(summary(lm1)$coeff[2, 3], 0.25, summary(lm1)$coeff[2, 3], 0, col = "red", 
    lwd = 4)
```

![plot of chunk unnamed-chunk-40](figure/unnamed-chunk-40.png) 

If nothing was happening the t statistic would be drawn from closer to the mean of the distribution. So the result is unlikely.

### Cummulating p-values

```r
summary(lm1)
```

```
## 
## Call:
## lm(formula = galton$child ~ galton$parent)
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -7.805 -1.366  0.049  1.634  5.926 
## 
## Coefficients:
##               Estimate Std. Error t value Pr(>|t|)    
## (Intercept)    23.9415     2.8109    8.52   <2e-16 ***
## galton$parent   0.6463     0.0411   15.71   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Residual standard error: 2.24 on 926 degrees of freedom
## Multiple R-squared: 0.21,	Adjusted R-squared: 0.21 
## F-statistic:  247 on 1 and 926 DF,  p-value: <2e-16
```

t value is estimate/standard error. p-value is small (Pr(>|t|))

### A quick simulated example

```r
set.seed(9898324)
yValues <- rnorm(10)
xValues <- rnorm(10)
lm2 <- lm(yValues ~ xValues)
summary(lm2)
```

```
## 
## Call:
## lm(formula = yValues ~ xValues)
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -1.546 -0.570  0.136  0.771  1.052 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)    0.310      0.351    0.88     0.40
## xValues        0.289      0.389    0.74     0.48
## 
## Residual standard error: 0.989 on 8 degrees of freedom
## Multiple R-squared: 0.0644,	Adjusted R-squared: -0.0525 
## F-statistic: 0.551 on 1 and 8 DF,  p-value: 0.479
```

The p value says that we're not at all surprised to see estimate of 0.289 with the given std error if nothing is happening.


```r
x <- seq(-5, 5, length = 100)
plot(x, dt(x, df = (10 - 2)), col = "blue", lwd = 3, type = "l")
arrows(summary(lm2)$coeff[2, 3], 0.25, summary(lm2)$coeff[2, 3], 0, col = "red", 
    lwd = 4)
```

![plot of chunk unnamed-chunk-43](figure/unnamed-chunk-43.png) 

Showing 8 degrees of freedom, because we have sample of 10 with 2 degrees of freedom to estimate the parameters. The t stat falls hear center, so we see it's not unlikely.

The way we calculate the unlikely or extreme is we take the statistic and look at how much density is to the right.


```r
xCoords <- seq(-5, 5, length = 100)
plot(xCoords, dt(xCoords, df = (10 - 2)), col = "blue", lwd = 3, type = "l")
xSequence <- c(seq(summary(lm2)$coeff[2, 3], 5, length = 10), summary(lm2)$coeff[2, 
    3])
ySequence <- c(dt(seq(summary(lm2)$coeff[2, 3], 5, length = 10), df = 8), 0)
polygon(xSequence, ySequence, col = "red")
polygon(-xSequence, ySequence, col = "red")
```

![plot of chunk unnamed-chunk-44](figure/unnamed-chunk-44.png) 

Extreme could be positive or negative, so we take to the right and we reflect the statistic around 0 and take to the left. We say "extreme in magnitude". The area ends up being equal to p-value. If the statistic falls in the center of the area, we're going to get most of the area under the curve. Since this is a distribution, we know the area = 1, so if it lands at 0, we get a p-value of 1 and if on outskirts, we get a tiny value.

### Simulate a ton of data sets with no signal
P values have some properties and they're important to know when performing these sorts of analises.
1. suppose we perform lots of studies and in each one there's no relationship between the x values and y values. 

```r
set.seed(8323)
pValues <- rep(NA, 100)
for (i in 1:100) {
    xValues <- rnorm(20)
    yValues <- rnorm(20)
    pValues[i] <- summary(lm(yValues ~ xValues))$coeff[2, 4]
}
hist(pValues, col = "blue", main = "", freq = F)
abline(h = 1, col = "red", lwd = 3)
```

![plot of chunk unnamed-chunk-45](figure/unnamed-chunk-45.png) 

We see that the p-values are equally likely to take any value from 0 to 1 (uniform distribution). The more studies, the more apparent that is.

### Simulate a ton of data sets with signal
signal - relationship

The y values are generated such that there is a relationship to x values + noise. We notice the p-values start to move a bit to the left. Regardless of how many samples we take, p values will always be normally distributed.

```r
set.seed(8323)
pValues <- rep(NA, 100)
for (i in 1:100) {
    xValues <- rnorm(20)
    yValues <- 0.2 * xValues + rnorm(20)
    pValues[i] <- summary(lm(yValues ~ xValues))$coeff[2, 4]
}
hist(pValues, col = "blue", main = "", freq = F, xlim = c(0, 1))
abline(h = 1, col = "red", lwd = 3)
```

![plot of chunk unnamed-chunk-46](figure/unnamed-chunk-46.png) 


If the **alternative hypothesis** is true, then the p-values depend not only on the signal (slope bw. the two vars) but also on how big the sample size is.

```r
set.seed(8323)
pValues <- rep(NA, 100)
for (i in 1:100) {
    xValues <- rnorm(100)
    yValues <- 0.2 * xValues + rnorm(100)
    pValues[i] <- summary(lm(yValues ~ xValues))$coeff[2, 4]
}
hist(pValues, col = "blue", main = "", freq = F, xlim = c(0, 1))
abline(h = 1, col = "red", lwd = 3)
```

![plot of chunk unnamed-chunk-47](figure/unnamed-chunk-47.png) 


### Some typical values (single test)
* p < 0.05 (significant)
* p < 0.01 (strongly significant)
* p < 0.001 (very significant)

In modern analyses, people generally report both the confidence interval and p-value. This is less true if many many hypotheses are tested.

How you interpret the results
-----------------------------
We get the coeff matrix: intercept and standard error for the slope and t-value and p-value

```r
summary(lm(galton$child ~ galton$parent))$coeff
```

```
##               Estimate Std. Error t value  Pr(>|t|)
## (Intercept)    23.9415    2.81088   8.517 6.537e-17
## galton$parent   0.6463    0.04114  15.711 1.733e-49
```

A one inch increase in parental height is associated with a 0.77 inch increase in child's height (95% CI: 0.42-1.12 inches). This difference was statistically significant (P < 0.001).

Regression with factor variables
================================
Key ideas

* Outcome is still quantitative
* Covariate(s) are factor variables
* Fitting lines = fitting means
* Want to evaluate contribution of all factor levels at once

Movie Data
----------

```r
download.file("http://www.rossmanchance.com/iscam2/data/movies03RT.txt", destfile = "./Data/movies.txt")
movies <- read.table("./data/movies.txt", sep = "\t", header = T, quote = "")
head(movies)
```

```
##                  X score rating            genre box.office running.time
## 1 2 Fast 2 Furious  48.9  PG-13 action/adventure     127.15          107
## 2    28 Days Later  78.2      R           horror      45.06          113
## 3      A Guy Thing  39.5  PG-13       rom comedy      15.54          101
## 4      A Man Apart  42.9      R action/adventure      26.25          110
## 5    A Mighty Wind  79.9  PG-13           comedy      17.78           91
## 6 Agent Cody Banks  57.9     PG action/adventure      47.81          102
```


Rotten tomatoes score vs. rating
--------------------------------

```r
plot(movies$score ~ jitter(as.numeric(movies$rating)), col = "blue", xaxt = "n", 
    pch = 19)
axis(side = 1, at = unique(as.numeric(movies$rating)), labels = unique(movies$rating))
```

![plot of chunk unnamed-chunk-50](figure/unnamed-chunk-50.png) 


### Average score by rating


```r
plot(movies$score ~ jitter(as.numeric(movies$rating)), col = "blue", xaxt = "n", 
    pch = 19)
axis(side = 1, at = unique(as.numeric(movies$rating)), labels = unique(movies$rating))
# brake it down by movie rating and within each level of rating we apply
# mean. For the G movies mean is slightly higher, but also based on much
# smaller sample of movies.
meanRatings <- tapply(movies$score, movies$rating, mean)
points(1:4, meanRatings, col = "red", pch = "-", cex = 5)
```

![plot of chunk unnamed-chunk-51](figure/unnamed-chunk-51.png) 


Another way to write it down
----------------------------
Suppose we have a score $S_i$, that score is related to a linear model. We add an "indicator" or "dummy variable", stands in for logical variable.

eq: slide 7/20

The notation $(Ra_i=" PG ")$ is a logical value that is one if the movie rating is "PG" and zero otherwise.

### Average values
* $b_0=$ average of the G movies
* $b_0+b_1=$ average of the PG movies
* $b_0+b_2=$ average of the PG-13 movies
* $b_0+b_3=$ average of the R movies

### How you do this in R
Coerce to factor, we don't want to treat them to factors, so that R treats them not as continuous variables but factors.

```r
lm1 <- lm(movies$score ~ as.factor(movies$rating))
summary(lm1)
```

```
## 
## Call:
## lm(formula = movies$score ~ as.factor(movies$rating))
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -26.43  -9.98  -0.98   9.34  38.97 
## 
## Coefficients:
##                               Estimate Std. Error t value Pr(>|t|)    
## (Intercept)                      67.65       7.19    9.40   <2e-16 ***
## as.factor(movies$rating)PG      -12.59       7.85   -1.60     0.11    
## as.factor(movies$rating)PG-13   -11.81       7.41   -1.59     0.11    
## as.factor(movies$rating)R       -12.02       7.48   -1.61     0.11    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Residual standard error: 14.4 on 136 degrees of freedom
## Multiple R-squared: 0.0199,	Adjusted R-squared: -0.00177 
## F-statistic: 0.918 on 3 and 136 DF,  p-value: 0.434
```

If you're a PG movie, you have 67.65-12.59 rating. None of the p-values are significant and t values are small, probably because there's so few points among G points, hard to tell if we observe difference.

### Plot fitted values

```r
plot(movies$score ~ jitter(as.numeric(movies$rating)), col = "blue", xaxt = "n", 
    pch = 19)
axis(side = 1, at = unique(as.numeric(movies$rating)), labels = unique(movies$rating))
points(1:4, lm1$coeff[1] + c(0, lm1$coeff[2:4]), col = "red", pch = "-", cex = 5)
```

![plot of chunk unnamed-chunk-53](figure/unnamed-chunk-53.png) 

Means within each group

#### Question 1
Average values:

* $b_0=$ average of the G movies
* $b_0+b_1=$ average of the PG movies
* $b_0+b_2=$ average of the PG-13 movies
* $b_0+b_3=$ average of the R movies

**What is the average difference in rating between G and R movies?*
$latex
b_0+b_3-b_0=b_3
$

#### Question 1 in R
We can calculate the confidence interval for the difference as from -26.80 and 2.763. It covers 0, which is the case when there's no difference between R and PG. Since it covers 0, it's unlikely we've seen a big difference in ratings.


```r
lm1 <- lm(movies$score ~ as.factor(movies$rating))
summary(lm1)
```

```
## 
## Call:
## lm(formula = movies$score ~ as.factor(movies$rating))
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -26.43  -9.98  -0.98   9.34  38.97 
## 
## Coefficients:
##                               Estimate Std. Error t value Pr(>|t|)    
## (Intercept)                      67.65       7.19    9.40   <2e-16 ***
## as.factor(movies$rating)PG      -12.59       7.85   -1.60     0.11    
## as.factor(movies$rating)PG-13   -11.81       7.41   -1.59     0.11    
## as.factor(movies$rating)R       -12.02       7.48   -1.61     0.11    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Residual standard error: 14.4 on 136 degrees of freedom
## Multiple R-squared: 0.0199,	Adjusted R-squared: -0.00177 
## F-statistic: 0.918 on 3 and 136 DF,  p-value: 0.434
```


#### Question 2
Average values:

* $b_0=$ average of the G movies
* $b_0+b_1=$ average of the PG movies
* $b_0+b_2=$ average of the PG-13 movies
* $b_0+b_3=$ average of the R movies

What is the average difference in rating between PG-13 and R movies?
$latex
b_0+b_2-(b_0+b_3)=b_2-b_3
$

We don't get the estimate of $b_2-b_3$ from our standard linear model using the defaults, but

### We could rewrite our model
eq: slide 14/20

We reorder model to create a different set of indicator variables.

Average values:

* $b_0=$ average of the R movies
* $b_0+b_1=$ average of the G movies
* $b_0+b_2=$ average of the PG movies
* $b_0+b_3=$ average of the PG-13 movies

What is the average difference in rating between PG-13 and R movies?
$latex
b_0 + b_3 - b_0=b_3
$

#### Question 2 in R
We need to tell R what is the reference category, the one used in the intercept term.

```r
lm2 <- lm(movies$score ~ relevel(movies$rating, ref = "R"))
summary(lm2)
```

```
## 
## Call:
## lm(formula = movies$score ~ relevel(movies$rating, ref = "R"))
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -26.43  -9.98  -0.98   9.34  38.97 
## 
## Coefficients:
##                                        Estimate Std. Error t value
## (Intercept)                              55.630      2.035   27.34
## relevel(movies$rating, ref = "R")G       12.020      7.476    1.61
## relevel(movies$rating, ref = "R")PG      -0.573      3.741   -0.15
## relevel(movies$rating, ref = "R")PG-13    0.205      2.706    0.08
##                                        Pr(>|t|)    
## (Intercept)                              <2e-16 ***
## relevel(movies$rating, ref = "R")G         0.11    
## relevel(movies$rating, ref = "R")PG        0.88    
## relevel(movies$rating, ref = "R")PG-13     0.94    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Residual standard error: 14.4 on 136 degrees of freedom
## Multiple R-squared: 0.0199,	Adjusted R-squared: -0.00177 
## F-statistic: 0.918 on 3 and 136 DF,  p-value: 0.434
```

Now the difference is 0.205.

You can use `confint` to calculate the difference in average score between PG-13 and R mvoies and again, it covers 0, so it's unlikely that there's a major difference.

```r
lm2 <- lm(movies$score ~ relevel(movies$rating, ref = "R"))
confint(lm2)
```

```
##                                         2.5 % 97.5 %
## (Intercept)                            51.606 59.654
## relevel(movies$rating, ref = "R")G     -2.763 26.803
## relevel(movies$rating, ref = "R")PG    -7.971  6.825
## relevel(movies$rating, ref = "R")PG-13 -5.146  5.557
```



#### Question 3
Average values:

* $b_0=$ average of the G movies
* $b_0+b_1=$ average of the PG movies
* $b_0+b_2=$ average of the PG-13 movies
* $b_0+b_3=$ average of the R movies

Is there any difference in score between any of the movie ratings?

We do this using ANOVA - Analysis of variance. We get an analysis of variance table. 

```r
lm1 <- lm(movies$score ~ as.factor(movies$rating))
anova(lm1)
```

```
## Analysis of Variance Table
## 
## Response: movies$score
##                           Df Sum Sq Mean Sq F value Pr(>F)
## as.factor(movies$rating)   3    570     190    0.92   0.43
## Residuals                136  28149     207
```

The degrees of freedom tells us how many parameters we had to estimate for table and residuals is the number of movies - deg freedom, mean square is sum of squares divided by deg reedom, F value is the ratio of Mean sq for rating factor and residuals.

The F value can be interpreted on the scale of averages of movie scores. The P value has the usual property that if there is no difference across any of the ratings levels, it will have uniform distribution and it will be slightly less than the uniform distribution if there's something going on. The p-value in this case doesn't suggest much difference between categories.


#### Sum of squares (G movies)
The mean square for the factor variable in this case will be almost equal to sum of the distances from the fitted values in the G movies (blue) to the overall average (red). 


```r
gMovies <- movies[movies$rating == "G", ]
xVals <- seq(0.2, 0.8, length = 4)
plot(xVals, gMovies$score, ylab = "Score", xaxt = "n", xlim = c(0, 1), pch = 19)
abline(h = mean(gMovies$score), col = "blue", lwd = 3)
abline(h = mean(movies$score), col = "red", lwd = 3)
segments(xVals + 0.01, rep(mean(gMovies$score), length(xVals)), xVals + 0.01, 
    rep(mean(movies$score), length(xVals)), col = "red", lwd = 2)
segments(xVals - 0.01, gMovies$score, xVals - 0.01, rep(mean(gMovies$score), 
    length(xVals)), col = "blue", lwd = 2)
```

![plot of chunk unnamed-chunk-58](figure/unnamed-chunk-58.png) 



```r
lm1 <- lm(movies$score ~ as.factor(movies$rating))
anova(lm1)
```

```
## Analysis of Variance Table
## 
## Response: movies$score
##                           Df Sum Sq Mean Sq F value Pr(>F)
## as.factor(movies$rating)   3    570     190    0.92   0.43
## Residuals                136  28149     207
```

The denominator term, which is the sum of squares for the residuals is the sum of distances from the actual data points to the fitted values. If the fitted value is really close to the data points, the residual terms will be very small (denominator). The numerator is how far the fitted value is from the overall average - how far we had to move from this group to get a really good fit. So if red numbers are really big and blue are really small, we've done good job of moving the line to fit the data points.

#### Turkey's (honestly significant difference test)

```r
lm1 <- aov(movies$score ~ as.factor(movies$rating))
TukeyHSD(lm1)
```

```
##   Tukey multiple comparisons of means
##     95% family-wise confidence level
## 
## Fit: aov(formula = movies$score ~ as.factor(movies$rating))
## 
## $`as.factor(movies$rating)`
##              diff     lwr    upr  p adj
## PG-G     -12.5929 -33.008  7.822 0.3795
## PG-13-G  -11.8146 -31.092  7.463 0.3854
## R-G      -12.0200 -31.464  7.424 0.3776
## PG-13-PG   0.7782  -8.615 10.171 0.9964
## R-PG       0.5729  -9.158 10.304 0.9987
## R-PG-13   -0.2054  -7.245  6.834 0.9998
```

`aov` is another way to do anova. This is going to calculate differences between 2-tuples of factor variables. lwr, upr are lower and upper confidence bounds for the differences. This is family-wise confidence interval, it means that we've adjusted the p-values for the fact that we made a whole bunch of different comparisons. So if we call p-values significant < 0.05, we won't get a lot more false positive results because we've accounted for the fact we've done all possible comparisons.

Multiple Regression
===================
Key Ideas

* Regression with multiple covariates
* Still using least squares/central limit theorem
* Interpretation depends on all variables

Data from Millenium Development Goal

WHO Childhood hunger data
-------------------------
Using just both males and females


```r
if (!file.exists("./data/hunger.txt")) {
    download.file("http://apps.who.int/gho/athena/data/GHO/WHOSIS_000008.csv?profile=text&filter=COUNTRY:*;SEX:*", 
        "./data/hunger.csv")
}
hunger <- read.csv("./data/hunger.csv")
hunger <- hunger[hunger$Sex != "Both sexes", ]
head(hunger)
```

```
##                                 Indicator Data.Source     Country    Sex
## 2  Children aged <5 years underweight (%) NLIS_312819 Afghanistan Female
## 3  Children aged <5 years underweight (%) NLIS_312819 Afghanistan   Male
## 6  Children aged <5 years underweight (%) NLIS_312361     Albania   Male
## 7  Children aged <5 years underweight (%) NLIS_312361     Albania Female
## 9  Children aged <5 years underweight (%) NLIS_312879     Albania   Male
## 10 Children aged <5 years underweight (%) NLIS_312879     Albania Female
##    Year            WHO.region Display.Value Numeric Low High Comments
## 2  2004 Eastern Mediterranean          33.0    33.0  NA   NA       NA
## 3  2004 Eastern Mediterranean          32.7    32.7  NA   NA       NA
## 6  2000                Europe          19.6    19.6  NA   NA       NA
## 7  2000                Europe          14.2    14.2  NA   NA       NA
## 9  2005                Europe           7.3     7.3  NA   NA       NA
## 10 2005                Europe           5.8     5.8  NA   NA       NA
```


### Plot percent hunbry versus time

```r
lm1 <- lm(hunger$Numeric ~ hunger$Year)
plot(hunger$Year, hunger$Numeric, pch = 19, col = "blue")
```

![plot of chunk unnamed-chunk-62](figure/unnamed-chunk-62.png) 


### Remember the linear model

$$latex
Hu_i=b_0+b_1Y_i+e_i
$$
* $b_0=$ percent hungry at Year 0
* $b_1=$ decrease in percent hungry per year
* $e_i=$ everything we didn't measure

### Add the linear model

```r
lm1 <- lm(hunger$Numeric ~ hunger$Year)
plot(hunger$Year, hunger$Numeric, pch = 19, col = "blue")
lines(hunger$Year, lm1$fitted, lwd = 3, col = "darkgrey")
```

![plot of chunk unnamed-chunk-63](figure/unnamed-chunk-63.png) 


### Color by male/female

```r
plot(hunger$Year, hunger$Numeric, pch = 19)
points(hunger$Year, hunger$Numeric, pch = 19, col = ((hunger$Sex == "Male") * 
    1 + 1))
```

![plot of chunk unnamed-chunk-64](figure/unnamed-chunk-64.png) 


Now two lines
-------------
Separate lines for males and females

$$latex
HuF_i=bf_0+bf_1YF_i+ef_i
$$
* $bf_0=$ percent of girls hungry at Year 0
* $bf_1=$ decrease in percent of girls hungry per year
* $ef_i=$ everything we didn't measure

$$latex
HuM_i=bm_0+bm_1YM_i+em_i
$$
* $bm_0=$ percent of boys hungry at Year 0
* $bm_1=$ decrease in percent of boys hungry per year
* $em_1=$ everything we didn't measure

### Color by male/female

```r
lmM <- lm(hunger$Numeric[hunger$Sex == "Male"] ~ hunger$Year[hunger$Sex == "Male"])
lmF <- lm(hunger$Numeric[hunger$Sex == "Female"] ~ hunger$Year[hunger$Sex == 
    "Female"])
plot(hunger$Year, hunger$Numeric, pch = 19)
points(hunger$Year, hunger$Numeric, pch = 19, col = ((hunger$Sex == "Male") * 
    1 + 1))
lines(hunger$Year[hunger$Sex == "Male"], lmM$fitted, col = "black", lwd = 3)
lines(hunger$Year[hunger$Sex == "Female"], lmF$fitted, col = "red", lwd = 3)
```

![plot of chunk unnamed-chunk-65](figure/unnamed-chunk-65.png) 

About the same slope, but girl children went slightly less hungry.

### Two lines, same slope
Slide 11/16

One slope for both lines, $b_2Y_i$ - percent change of hungry for either males or females in a single year. This affects how we interpret the variables that we get out, fit the model and results.

#### Two lines, same sloper in R
Fitting the model from above, separate by Year and Sex in `lm`.


```r
lmBoth <- lm(hunger$Numeric ~ hunger$Year + hunger$Sex)
plot(hunger$Year, hunger$Numeric, pch = 19)
points(hunger$Year, hunger$Numeric, pch = 19, col = ((hunger$Sex == "Male") * 
    1 + 1))
abline(c(lmBoth$coeff[1], lmBoth$coeff[2]), col = "red", lwd = 3)
abline(c(lmBoth$coeff[1] + lmBoth$coeff[3], lmBoth$coeff[2]), col = "black", 
    lwd = 3)
```

![plot of chunk unnamed-chunk-66](figure/unnamed-chunk-66.png) 

Looks a lot like the plot from before.

### Two lines different slopes (interactions)
Slide 13/16

We can allow each line to have different slope.

#### In R

```r
lmBoth <- lm(hunger$Numeric ~ hunger$Year + hunger$Sex + hunger$Sex * hunger$Year)
plot(hunger$Year, hunger$Numeric, pch = 19)
points(hunger$Year, hunger$Numeric, pch = 19, col = ((hunger$Sex == "Male") * 
    1 + 1))
abline(c(lmBoth$coeff[1], lmBoth$coeff[2]), col = "red", lwd = 3)
abline(c(lmBoth$coeff[1] + lmBoth$coeff[3], lmBoth$coeff[2] + lmBoth$coeff[4]), 
    col = "black", lwd = 3)
```

![plot of chunk unnamed-chunk-67](figure/unnamed-chunk-67.png) 

Again, the slope is identical, but that's not always true, especially when including an interaction term.


```r
summary(lmBoth)
```

```
## 
## Call:
## lm(formula = hunger$Numeric ~ hunger$Year + hunger$Sex + hunger$Sex * 
##     hunger$Year)
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -25.20 -11.61  -2.14   7.26  46.14 
## 
## Coefficients:
##                            Estimate Std. Error t value Pr(>|t|)   
## (Intercept)                530.9361   191.7086    2.77   0.0057 **
## hunger$Year                 -0.2569     0.0958   -2.68   0.0075 **
## hunger$SexMale              59.5787   271.1169    0.22   0.8261   
## hunger$Year:hunger$SexMale  -0.0288     0.1355   -0.21   0.8317   
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Residual standard error: 13.5 on 856 degrees of freedom
## Multiple R-squared: 0.0233,	Adjusted R-squared: 0.0199 
## F-statistic: 6.82 on 3 and 856 DF,  p-value: 0.000152
```

Summary includes both terms and interaction term. In result indicated by colon ':'.

Coefficient -.0.0288 is small, which is why the slopes aren't too different.

Interactions for continuous variables
-------------------------------------
We can include quantitative temrs and interactions in multiple regression models.
Say we have an income variable, In, and interaction between income and year.

$$latex
Hu_i=b_0+b_1In_i+b_2Y_i+b_3In_i\times Y_i+e^+_i
$$

* $b_0=$ percent hungry at year zero for children with whose parents have no income
* $b_1=$ change in percent hungry for each dollar of income in year zero
* $b_2=$ change in percent hungry in one year for children whose parents have no income
* $b_3=$ increased change in percent hungry by year for each dollar of income - e.g. if income is $10000, then change in percent hungry in one year will be

$$latex
b_2+1e4\times b_3
$$

$e_i^+$ - everything we didn't measure

Regression in real world
========================
Things to pay attention to

* Confounders
* Complicated interactions - continuous vars
* Skewness
* Outliers
* Non-linear patterns
* Variance changes
* Units/scale issues
* Overloading regression
* Correlation and causation

The ideal data for regression
-----------------------------
Looks line an oval - multivariate, normal.


```r
library(UsingR)
data(galton)
plot(galton$parent, galton$child, col = "blue", pch = 19)
```

![plot of chunk unnamed-chunk-69](figure/unnamed-chunk-69.png) 


Confounders
-----------
In real life data can contain **confounders**: A variable that is correlated with both the outcome and the covariates.

* Confounders can change the regression line
* They can even change the sign of the line
* They can sometimes be detected by careful exploration

WHO Childhood hunger data
-------------------------

```r
download.file("http://apps.who.int/gho/athena/data/GHO/WHOSIS_000008.csv?profile=text&filt\ner=COUNTRY:*;SEX:*", 
    "./data/hunger.csv")
```

```
## Warning: cannot open: HTTP status was '0 (nil)'
```

```
## Error: cannot open URL
## 'http://apps.who.int/gho/athena/data/GHO/WHOSIS_000008.csv?profile=text&filt
## er=COUNTRY:*;SEX:*'
```

```r
hunger <- read.csv("./data/hunger.csv")
```

```
## Error: no lines available in input
```

```r
hunger <- hunger[hunger$Sex != "Both sexes", ]
head(hunger)
```

```
##                                 Indicator Data.Source     Country    Sex
## 2  Children aged <5 years underweight (%) NLIS_312819 Afghanistan Female
## 3  Children aged <5 years underweight (%) NLIS_312819 Afghanistan   Male
## 6  Children aged <5 years underweight (%) NLIS_312361     Albania   Male
## 7  Children aged <5 years underweight (%) NLIS_312361     Albania Female
## 9  Children aged <5 years underweight (%) NLIS_312879     Albania   Male
## 10 Children aged <5 years underweight (%) NLIS_312879     Albania Female
##    Year            WHO.region Display.Value Numeric Low High Comments
## 2  2004 Eastern Mediterranean          33.0    33.0  NA   NA       NA
## 3  2004 Eastern Mediterranean          32.7    32.7  NA   NA       NA
## 6  2000                Europe          19.6    19.6  NA   NA       NA
## 7  2000                Europe          14.2    14.2  NA   NA       NA
## 9  2005                Europe           7.3     7.3  NA   NA       NA
## 10 2005                Europe           5.8     5.8  NA   NA       NA
```


Hunger over time by region
--------------------------

```r
par(mfrow = c(1, 2))
plot(hunger$Year, hunger$Numeric, col = as.numeric(hunger$WHO.region), pch = 19)
plot(1:10, type = "n", xaxt = "n", yaxt = "n", xlab = "", ylab = "")
legend(1, 10, col = unique(as.numeric(hunger$WHO.region)), legend = unique(hunger$WHO.region), 
    pch = 19)
```

![plot of chunk unnamed-chunk-71](figure/unnamed-chunk-71.png) 

Huge amount of variation by region. Europ on bottom, blue on top, etc.


Region correlated with year
---------------------------

```r
anova(lm(hunger$Year ~ hunger$WHO.region))
```

```
## Analysis of Variance Table
## 
## Response: hunger$Year
##                    Df Sum Sq Mean Sq F value Pr(>F)  
## hunger$WHO.region   6    623   103.8    2.25  0.037 *
## Residuals         853  39316    46.1                 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

Moderate F and significant p

Region correlated with hunger
-----------------------------

```r
anova(lm(hunger$Numeric ~ hunger$WHO.region))
```

```
## Analysis of Variance Table
## 
## Response: hunger$Numeric
##                    Df Sum Sq Mean Sq F value Pr(>F)    
## hunger$WHO.region   6  76522   12754     129 <2e-16 ***
## Residuals         853  84211      99                   
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```


Large F and small p, strong correlation.

Including region - a complicated interaction
-------------------------------------------------

```r
plot(hunger$Year, hunger$Numeric, pch = 19, col = as.numeric(hunger$WHO.region))
lmRegion <- lm(hunger$Numeric ~ hunger$Year + hunger$WHO.region + hunger$Year * 
    hunger$WHO.region)
abline(c(lmRegion$coeff[1] + lmRegion$coeff[6], lmRegion$coeff[2] + lmRegion$coeff[12]), 
    col = 5, lwd = 3)
```

![plot of chunk unnamed-chunk-74](figure/unnamed-chunk-74.png) 

Correlated percent that are hungry to year, region, interaction bw year and region. If you include year and region, for every correlation, you'll get a different regression line. It starts to get complicated to identify which coefficients of lmregion to include in abline.

Income data
-----------
UCI data, census

```r
download.file("http://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data", 
    "./data/income.csv")
incomeData <- read.csv("./data/income.csv", header = FALSE)
income <- incomeData[, 3]
age <- incomeData[, 1]
```


Logs to address right-skew
--------------------------

```r
par(mfrow = c(1, 4))
smoothScatter(age, income)
hist(income, col = "blue", breaks = 100)
hist(log(income + 1), col = "blue", breaks = 100)
smoothScatter(age, log(income + 1))
```

![plot of chunk unnamed-chunk-76](figure/unnamed-chunk-76.png) 

most points on lower right in first graph. We can transform with log, however in this case we ended up with probably an unmeasured confounder, which we'd have to explore to build a model.

Outliers
--------
"outliers" ... are data points that do not appear to follow the pattern of the other data points.

Example - extreme points
------------------------

```r
set.seed(1235)
xVals <- rcauchy(50)
hist(xVals, col = "blue")
```

![plot of chunk unnamed-chunk-77](figure/unnamed-chunk-77.png) 


Example - outliers may be real
------------------------------

```r
# Add Tim Cook, CEO of Apple 2011 income
age <- c(age, 52)
income <- c(income, 3.78e+08)
smoothScatter(age, income)
```

```
## Warning: Binning grid too coarse for current (small) bandwidth: consider
## increasing 'gridsize'
```

![plot of chunk unnamed-chunk-78](figure/unnamed-chunk-78.png) 

It's not clear that you need to remove that point, because it is a real salary.

Example - does not fit the trend
--------------------------------
None of the points is extreme, but one point doesn't lie on a parabola.

Outliers - what you can do
--------------------------
* If you know they aren't real/of interest, remove them (but changes question!)
* Alternatively
 - Sensitivity analysis - is it a big difference if you leave it in/take it out?
 - Logs - if the data are right skewed (lots of outliers)
 - Robust methods - we've been doing averages, but there are more robust approaches ([Robust](), [rlm](http://stat.ethz.ch/R-manual/R-patched/library/MASS/html/rlm.html))
 
A line isn't always the best summary
------------------------------------
Slie 18/30

All the lines have same correlation but present different results.

Variance changes
----------------
Models assume there's a constant variability around the fit. 

```r
bupaData <- read.csv("ftp://ftp.ics.uci.edu/pub/machine-learning-databases/liver-disorders/bupa.data")
ggt <- bupaData[, 5]
aat <- bupaData[, 3]
plot(log(ggt), aat, col = "blue", pch = 19)
```

![plot of chunk unnamed-chunk-79](figure/unnamed-chunk-79.png) 


Plot the residuals
------------------

```r
lm1 <- lm(aat ~ log(ggt))
plot(log(ggt), lm1$residuals, col = "blue", pch = 19)
```

![plot of chunk unnamed-chunk-80](figure/unnamed-chunk-80.png) 

Variance increases over time.

Changing variance - what you can do
-----------------------------------
* Problem called heteroskedasticity
* examples:
 - Box-Cox Transform
 - Variance stabilization transform
 - Weighted least squares
 - Huber-white standard errors
 
Variation in units
------------------
Slide 23/30

The deaths in a country with large population is on top.

Relative units
--------------
Slide 24/30

What you can do is divide the deaths by some denominator, in this case # of deaths/1000 children

When there is variation in units
--------------------------------
* Standardize, but keep track
 - Affects model fits
 - Affects interpretation
 - Affects inference
 
Overloading regression
----------------------
Fewer terms may be better.
