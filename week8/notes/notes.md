Multiple testing
================
Key ideas
* Hypothesis testing/significance analysis is commonly overused - people will often calculate multiple P-values and report lowest
* Correcting for multiple testing avoids false positives or discoveries
* Two key components
 * Error measure
 * Correction - statistical method used to control the error measure

Three eras of statistics
------------------------
**The age of Quetelet and his successors, in which huge census-level data sets were brought to bear on simple but important questions**: Are there more male than female births? Is the rate of insanity rising?

The classical period of Pearson, Fisher, Neyman, Hotelling, and their successors, intellectual giants
who **developed a theory of optimal inference capable of wringing every drop of information out of a scientific experiment**. The questions dealt with still tended to be simple Is treatment A better than treatment B?

**The era of scientific mass production**, in which new technologies typified by the microarray allow
a single team of scientists to produce data sets of a size Quetelet would envy. But now the flood of
data is accompanied by a deluge of questions, perhaps thousands of estimates or hypothesis tests
that the statistician is charged with answering together; not at all what the classical masters had in
mind. Which variables matter among the thousands measured? How do you relate unrelated
information?

[http://www-stat.stanford.edu/~ckirby/brad/papers/2010LSIexcerpt.pdf](http://www-stat.stanford.edu/~ckirby/brad/papers/2010LSIexcerpt.pdf)

Why correct for multiple tests?
-------------------------------
When testing multiple hypothesis, it's likely that one will correlate by conincidence. If we allow a 5% error and perform 20 hypothesis, then we'll find at least 1 error.

Types of errors
---------------
Suppose you are testing a hypothesis that a parameter equals zero (association exists) versus the alternative that it does not equal (no associacion) zero. These are the possible outcomes.

To perform a hypothesis test, we're going to look at P-value from some linear regression model, and see if it's less than some threshold. If it is, then you would say that $\beta\neq 0$ and if abouve, equal 0.

In each row you have a particular claim you could make. In each column you have the true state of the world.

$$latex
\begin{array}{cccc}
 & \beta=0 & \beta\neq0 & \text{HYPOTHESIS}\\
\text{Claim }\beta=0 & U & T & m-R\\
\text{Claim }\beta\neq0 & V & S & R\\
\text{Claims} & m_{0} & m-m_{0} & m
\end{array}
$$

* **Type I error or false positive** ($V$) Say that the parameter does not equal zero when it does
* **Type II error or false negative** ($T$) Say that the parameter equals zero when it doesn't

Error rates
-----------
* **False positive rate** - The rate at which false results ($\beta=0$) are called significant: $E\left[\frac{V}{m_0}\right]$, $m_0$ total number of significant variables.
* **Family wise error rate (FWER)** - The probability of at least one false positive $Pr(V\ge 1)$
* **False discovery rate (FDR)** - The rate at which claims of significance are false $E\left[\frac{V}{R}\right]$
* The false positive rate is closely related to the type I error rate [http://en.wikipedia.org/wiki/False_positive_rate](http://en.wikipedia.org/wiki/False_positive_rate)

Controlling the false positive rate
-----------------------------------
If P-values are correctly calculated calling all $P<\alpha$ significant will control the false positive rate at $\alpha$ level on average.

**Problem**: Suppose that you perform 10,000 tests and for all of them.

Suppose that you call all $P<0.05$ significant.

The expected number of false positives is: $10,000\cdot 0.05 = 500$ false positives.

**How do we avoid so many false positives?**

Controlling family-wise error rate (FWER)
-----------------------------------------
The Bonferroni correction is the oldest multiple testing correction.

Basic idea:
* Suppose you do $m$ tests
* You want to control FWER at level $\alpha$ so $Pr(V\ge 1) < \alpha$
* Calculate P-values normally
* Set $\alpha_{fwer}=\frac{\alpha}{m}$
 * $\alpha$ we had for the single hypothesis test
 * $m$ number of hypothesis tests we performed
* Call all P-values less than $\alpha_{fwer}$ significant

* **Pros**: Easy to calculate, conservative 
* **Cons**: May be very conservative

Controlling false discovery rate (FDR)
--------------------------------------
This is the most popular correction when performing lots of tests say in genomics, imagining, astronomy, or other signal-processing disciplines.

Basic idea:
* Suppose you do $m$ tests
You want to control FDR at level $\alpha$ so $E\left[\frac{V}{R}\right]$
* Calculate P-values normally
* Order the P-values from smallest to largest $P_{(1)}, \dots, P_{(m)}$
* Call any $P_{(i)}\le\alpha\times\frac{i}{m}$ significant

**Pros**: Still pretty easy to calculate, less conservative (maybe much less)
**Cons**: Allows for more false positives, may behave strangely under dependence

Example with 10 P-values
------------------------
Slide 12/19

* BH - slope determined by $\alpha$
* Bonferroni - $\frac{0.2}{m}$, we'd only call the two values below blue line significant.

Adjusted P-values
-----------------
* One approach is to adjust the threshold $\alpha$
* A different approach is to calculate "adjusted p-values"
* They are not p-values anymore
* But they can be used directly without adjusting $\alpha$

### Example:
* Suppose P-values are $P_1, \dots, P_m$
* You could adjust them by taking $P_i^{fwer}=\max(m\times P_i, 1)$, for each P-value.
* Then if you call all $P_i^{fwer}<\alpha$ significant you will control the FWER.

Case study I: no true positives
-------------------------------

```r
set.seed(1010093)
pValues <- rep(NA, 1000)
for (i in 1:1000) {
    y <- rnorm(20)
    x <- rnorm(20)
    pValues[i] <- summary(lm(y ~ x))$coeff[2, 4]
}
# Controls false positive rate
sum(pValues < 0.05)
```

```
## [1] 51
```



```r
# Controls FWER
sum(p.adjust(pValues, method = "bonferroni") < 0.05)
```

```
## [1] 0
```



```r
# Controls FDR
sum(p.adjust(pValues, method = "BH") < 0.05)
```

```
## [1] 0
```


Case study II: 50% true positives
---------------------------------

```r
set.seed(1010093)
pValues <- rep(NA, 1000)
for (i in 1:1000) {
    x <- rnorm(20)
    # First 500 beta=0, last 500 beta=2
    if (i <= 500) {
        y <- rnorm(20)
    } else {
        y <- rnorm(20, mean = 2 * x)
    }
    pValues[i] <- summary(lm(y ~ x))$coeff[2, 4]
}
trueStatus <- rep(c("zero", "not zero"), each = 500)
table(pValues < 0.05, trueStatus)
```

```
##        trueStatus
##         not zero zero
##   FALSE        0  476
##   TRUE       500   24
```



```r
# Controls FWER
table(p.adjust(pValues, method = "bonferroni") < 0.05, trueStatus)
```

```
##        trueStatus
##         not zero zero
##   FALSE       23  500
##   TRUE       477    0
```



```r
# Controls FDR
table(p.adjust(pValues, method = "BH") < 0.05, trueStatus)
```

```
##        trueStatus
##         not zero zero
##   FALSE        0  487
##   TRUE       500   13
```


### P-values versus adjusted P-values

```r
par(mfrow = c(1, 2))
plot(pValues, p.adjust(pValues, method = "bonferroni"), pch = 19)
plot(pValues, p.adjust(pValues, method = "BH"), pch = 19)
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7.png) 


Notes and resources
-------------------
Notes:
* Multiple testing is an entire subfield
* A basic Bonferroni/BH correction is usually enough
* If there is strong dependence between tests there may be problems
 * Consider method="BY"

Further resources:
* Multiple testing procedures with applications to genomics
* Statistical significance for genome-wide studies
* Introduction to multiple testing

Simulation for model checking
=============================
Basic ideas:
* Way back in the first week we talked about simulating data from distributions in R using the rfoo functions.
* In general simulations are way more flexible/useful
 * For bootstrapping as we saw in week 7
 * For evaluating models
 * For testing different hypotheses
 * For sensitivity analysis
* At minimum it is useful to simulate
 * A best case scenario
 * A few examples where you know your approach won't work
 * The importance of simulating the extremes
 
Simulating data from a model
----------------------------
Suppose that you have a regression model
$$latex
Y_i=b_0+b_1X_i+e_i
$$
Here is an example of generating data from this model where $X_i$ and $e_i$ are normal:

```r
set.seed(44333)
x <- rnorm(50)
e <- rnorm(50)
b0 <- 1
b1 <- 2
y <- b0 + b1 * x + e
```


Violating assumptions
---------------------

```r
set.seed(44333)
x <- rnorm(50)
e <- rnorm(50)
e2 <- rcauchy(50)
b0 <- 1
b1 <- 2
y <- b0 + b1 * x + e
y2 <- b0 + b1 * x + e2
```


Violating assumptions
---------------------

```r
par(mfrow = c(1, 2))
plot(lm(y ~ x)$fitted, lm(y ~ x)$residuals, pch = 19, xlab = "fitted", ylab = "residuals")
plot(lm(y2 ~ x)$fitted, lm(y2 ~ x)$residuals, pch = 19, xlab = "fitted", ylab = "residuals")
```

![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10.png) 


Repeated simulations
--------------------

```r
set.seed(44333)
betaNorm <- betaCauch <- rep(NA, 1000)
for (i in 1:1000) {
    x <- rnorm(50)
    e <- rnorm(50)
    e2 <- rcauchy(50)
    b0 <- 1
    b1 <- 2
    y <- b0 + b1 * x + e
    y2 <- b0 + b1 * x + e2
    betaNorm[i] <- lm(y ~ x)$coeff[2]
    betaCauch[i] <- lm(y2 ~ x)$coeff[2]
}
quantile(betaNorm)
```

```
##    0%   25%   50%   75%  100% 
## 1.500 1.906 2.013 2.100 2.596
```



```r
quantile(betaCauch)
```

```
##       0%      25%      50%      75%     100% 
## -278.352    1.130    1.965    2.804  272.391
```


Monte Carlo Error
-----------------

```r
boxplot(betaNorm, betaCauch, col = "blue", ylim = c(-5, 5))
```

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13.png) 


Simulation based on a data set
------------------------------

```r
library(UsingR)
```

```
## Loading required package: MASS
```

```r
data(galton)
nobs <- dim(galton)[1]
par(mfrow = c(1, 2))
hist(galton$child, col = "blue", breaks = 100)
hist(galton$parent, col = "blue", breaks = 100)
```

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14.png) 


Calculating means, variances
---------------------------

```r
lm1 <- lm(galton$child ~ galton$parent)
parent0 <- rnorm(nobs, sd = sd(galton$parent), mean = mean(galton$parent))
child0 <- lm1$coeff[1] + lm1$coeff[2] * parent0 + rnorm(nobs, sd = summary(lm1)$sigma)
par(mfrow = c(1, 2))
plot(galton$parent, galton$child, pch = 19)
plot(parent0, child0, pch = 19, col = "blue")
```

![plot of chunk unnamed-chunk-15](figure/unnamed-chunk-15.png) 


Simulating more complicated scenarios
-------------------------------------

```r
library(bootstrap)
```



```r
data(stamp)
nobs <- dim(stamp)[1]
hist(stamp$Thickness, col = "grey", breaks = 100, freq = F)
dens <- density(stamp$Thickness)
lines(dens, col = "blue", lwd = 3)
```

![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17.png) 


A simulation that is too simple
--------------------------------

```r
plot(density(stamp$Thickness), col = "black", lwd = 3)
for (i in 1:10) {
    newThick <- rnorm(nobs, mean = mean(stamp$Thickness), sd = sd(stamp$Thickness))
    lines(density(newThick), col = "grey", lwd = 3)
}
```

![plot of chunk unnamed-chunk-18](figure/unnamed-chunk-18.png) 


How density estimation works
----------------------------

Simulating from the density estimate
-------------------------------------

```r
plot(density(stamp$Thickness), col = "black", lwd = 3)
for (i in 1:10) {
    newThick <- rnorm(nobs, mean = stamp$Thickness, sd = dens$bw)
    lines(density(newThick), col = "grey", lwd = 3)
}
```

![plot of chunk unnamed-chunk-19](figure/unnamed-chunk-19.png) 


Increasing variability
-----------------------

```r
plot(density(stamp$Thickness), col = "black", lwd = 3)
for (i in 1:10) {
    newThick <- rnorm(nobs, mean = stamp$Thickness, sd = dens$bw * 1.5)
    lines(density(newThick, bw = dens$bw), col = "grey", lwd = 3)
}
```

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20.png) 


Notes and further resources
---------------------------
Notes:
* Simulation can be applied to missing data problems - simulate what missing data might be
* Simulation values are often drawn from standard distributions, but this may not be appropriate
* Sensitivity analysis means trying different simulations with different assumptions and seeing how estimates change

Further resources:
* Advanced Data Analysis From An Elementary Point of View
* The design of simulation studies in medical statistics
* Simulation studies in statistics
