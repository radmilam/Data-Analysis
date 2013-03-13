ANOVA With Multiple Factors
===========================

Key ideas

* Outcome is still quantitative (symmetrically distributed)
* You have multiple explanatory variables
* Goal is to identify contributions of different variables

A successful example
--------------------
"For the button, an A/B test of three new word choicesLearn More, Join Us Now, and Sign Up Now  revealed that Learn More garnered 18.6 percent more signups per visitor than the default of Sign Up. Similarly, a black-and-white photo of the Obama family outperformed the default turquoise image by 13.1 percent. Using both the family image and Learn More, signups increased by a thundering 40 percent."

[http://www.wired.com/business/2012/04/ff_abtesting/](http://www.wired.com/business/2012/04/ff_abtesting/)


Movie Data
----------

```r
if (!file.exists("./data/movies.txt")) {
    download.file("http://www.rossmanchance.com/iscam2/data/movies03RT.txt", 
        destfile = "./data/movies.txt")
}
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


[http://rossmanchance.org](http://rossmanchance.org)

We'll be using score as outcome and other variables as covariants.

Relating score to rating
------------------------
$$latex
S_i=b_0+b_1\cdot ind(Ra_i=" PG ") + b_2\cdot ind(Ra_i=" PG-13 ") + b_3\cdot ind(Ra_i= " R ") + e_i
$$

### Average values
* $b_0$ = average of the G movies
* $b_0+b_1$ = average of the PG movies
* $b_0+b_2$ = average of the PG-13 movies
* $b_0+b_3$ = average of the R movies

ANOVA in R
----------

```r
aovObject <- aov(movies$score ~ movies$rating)
aovObject
```

```
## Call:
##    aov(formula = movies$score ~ movies$rating)
## 
## Terms:
##                 movies$rating Residuals
## Sum of Squares            570     28149
## Deg. of Freedom             3       136
## 
## Residual standard error: 14.39 
## Estimated effects may be unbalanced
```

Degrees of freedom - number of parameters you're estimating, 3 in this case, 4 different levels, but one gets absorbed into the intercept term, $b_0$.


```r
aovObject$coeff
```

```
##        (Intercept)    movies$ratingPG movies$ratingPG-13 
##              67.65             -12.59             -11.81 
##     movies$ratingR 
##             -12.02
```

67.65 is the average rating for a G movie, etc.

Adding a second factor
----------------------
We may want to add another factor to the model and see what the relative contribution of the two factors is to the score.

$$latex
S_i=b_0+b_1\cdot ind(Ra_i=" PG ")+b_2 \cdot ind(Ra_i=" PG-13 ")+b_3\cdot ind(Ra_i=" R ") + \gamma_1\cdot ind(G_i=" action ")+\gamma_2 \cdot ind(G_i=" animated ")+\dots+e_i
$$

There are only 2 variables in this model: rating ($b$), genre ($\gamma$). They have multiple levels.

Second variable
---------------

```r
aovObject2 <- aov(movies$score ~ movies$rating + movies$genre)
aovObject2
```

```
## Call:
##    aov(formula = movies$score ~ movies$rating + movies$genre)
## 
## Terms:
##                 movies$rating movies$genre Residuals
## Sum of Squares            570         3935     24214
## Deg. of Freedom             3           12       124
## 
## Residual standard error: 13.97 
## Estimated effects may be unbalanced
```

There are more genres than ratings, so we're using more degrees of freedom and 124 degrees of freedom for the residuals, which we'll use for the inference.

ANOVA Summary
-------------

```r
summary(aovObject2)
```

```
##                Df Sum Sq Mean Sq F value Pr(>F)  
## movies$rating   3    570     190    0.97  0.408  
## movies$genre   12   3935     328    1.68  0.079 .
## Residuals     124  24214     195                 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

The first F-value measures amount of variation explained by the rating (in the score?) variable not taking into account anything else. P-value doesn't necessarily have anything going on. Genre variable has an F value too, but since it's the second variable, it represents additional variation that genre explains that rating didn't explain already. This variable is closer to statistical significance and is a value with rating already included in the model.

Order matters
-------------

```r
aovObject3 <- aov(movies$score ~ movies$genre + movies$rating)
summary(aovObject3)
```

```
##                Df Sum Sq Mean Sq F value Pr(>F)  
## movies$genre   12   4222     352    1.80  0.055 .
## movies$rating   3    284      95    0.48  0.694  
## Residuals     124  24214     195                 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

These are flipped, so we get different values. This matters if we have an **unbalanced design**, that is in this case, if levels of genre aren't distributed evenly between the levels of rating variable, there will be differences in all of the statistics.


```r
summary(aovObject2)
```

```
##                Df Sum Sq Mean Sq F value Pr(>F)  
## movies$rating   3    570     190    0.97  0.408  
## movies$genre   12   3935     328    1.68  0.079 .
## Residuals     124  24214     195                 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```


Adding a quantitative variable
------------------------------
slide 13/15

There are three variables in this model - box office is quantitative so only has one term.

What this says is that if we increase the box office by $1mil, we increase the model by $\eta_1$. We're constraining the unit differences to be the same.

ANOVA with quantitative variable in R
-------------------------------------
We can see the above in the summary table.


```r
aovObject4 <- aov(movies$score ~ movies$genre + movies$rating + movies$box.office)
summary(aovObject4)
```

```
##                    Df Sum Sq Mean Sq F value  Pr(>F)    
## movies$genre       12   4222     352    2.19   0.016 *  
## movies$rating       3    284      95    0.59   0.624    
## movies$box.office   1   4421    4421   27.47 6.7e-07 ***
## Residuals         123  19793     161                    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

We're seeing only one degree of freedom for box office.

Language
---------
* Units - one observation
* Treatments - conditions applied to units
* Factors - conditions controlled by experimenters
* Replicates - multiple (independent) units with the same factors/treatments


Binary outcomes
===============
#### Key ideas
* Frequently we care about outcomes that have two values
 - Alive/dead
 - Win/loss
 - Success/Failure
 - etc
* Called binary outcomes or 0/1 outcomes
* Linear regression (like we've seen) may not be the best

Example: Baltimore Ravens
-------------------------

### Ravens Data

```r
if (!file.exists("./data/movies.txt")) {
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


### Linear regression
$$latex
RW_i = b_0+b_1RS_i+e_i
$$

* $RW_i$ - 1 if a Ravens win, 0 if not
* $RS_i$ - Number of points Ravens scored
* $b_0$ - probability of a Ravens win if they score 0 points
* $b_0$ - increase in probability of a Ravans win for each additional point
* $e_i$ - variation due to everything we dind't measure - random variation, measurement error, etc

### Linear regression in R

```r
lmRavens <- lm(ravensData$ravenWinNum ~ ravensData$ravenScore)
summary(lmRavens)
```

```
## 
## Call:
## lm(formula = ravensData$ravenWinNum ~ ravensData$ravenScore)
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -0.730 -0.508  0.182  0.322  0.572 
## 
## Coefficients:
##                       Estimate Std. Error t value Pr(>|t|)  
## (Intercept)            0.28503    0.25664    1.11    0.281  
## ravensData$ravenScore  0.01590    0.00906    1.76    0.096 .
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Residual standard error: 0.446 on 18 degrees of freedom
## Multiple R-squared: 0.146,	Adjusted R-squared: 0.0987 
## F-statistic: 3.08 on 1 and 18 DF,  p-value: 0.0963
```

* Estimate Std/Intercept - probability that Ravens win if they don't score any points, which is weird, because we would expect that if they score 0 points, they don't win.
* Estimate Std/ravenScore - for every additional score they have, they get 0.01590 increase in probability of winning.

### Linear regression

```r
plot(ravensData$ravenScore, lmRavens$fitted, pch = 19, col = "blue", ylab = "Prob Win", 
    xlab = "Raven Score")
```

![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-11.png) 

We see that one of the probabilities is estimated to be >1. That shows a problem with linear regression on binary outcomes.

### Odds
Ways to represent these probabilities

Binary outcome 0/1
$$latex
RW_i
$$

Probability of winning (0, 1)
$$latex
Pr(RW_i\mid RS_i, b_0, b_1)
$$

Odds(0, $\infty$)
$$latex
\frac{Pr(RW_i\mid RS_i, b_0, b_1)}{1-Pr(RW_i\mid RS_i, b_0, b_1)}
$$

Log odds($-\infty$, $\infty$) - more stable results for analysis
$$latex
\log(\frac{Pr(RW_i\mid RS_i, b_0, b_1)}{1-Pr(RW_i\mid RS_i, b_0, b_1)})
$$

Linear vs. logistic regression
------------------------------

### Linear

$$latex
RW_i=b_0+b_1RS_i+e_i
$$

or

Expected value, average, of Ravens Win RW variable for specific score is
$$latex
E[RW_i\mid RS_i, b_0, b_1]=b_0+b_1RS_i
$$

#### Logistic
Model the probability of Ravens win
$$latex
Pr(RW_i\mid RS_i, b_0, b_1)=\frac{\exp(b_0+b_1RS_i)}{1+\exp(b_0+b_1RS_i)}
$$

or

$$latex
\log(\frac{Pr(RW_i\mid RS_i, b_0, b_1)}{1-Pr(RW_i\mid RS_i, b_0, b_1)})=b_0+b_1RS_i
$$
Modeling log-odds as a linear function - the advantage is that the number inside log is not a constraint number anymore, so we can have anything from $-\infty, \infty$, so we won't get the problem of getting an outcome outside of 0 or 1.

### Interpreting Logistic Regression
$$latex
\log(\frac{Pr(RW_i\mid RS_i, b_0, b_1)}{1-Pr(RW_i\mid RS_i, b_0, b_1)})=b_0+b_1RS_i
$$

* $b_0$ - Log odds of a Ravens win if they score zero points
* $b_1$ - Log odds ratio of win probability for each point scored (compared to zero points)
* $\exp(b_1)$ - Odds ratio of win probability for each point scored (compared to zero points)

Explaining Odds
---------------
Slide 11-15/22

Ravens logistic regression
--------------------------
Logistic regression performed with `glm` command. `glm` represents all generalized linear models, not just logistic.
To perform logistic regression with `glm`, set `family="binomial"`

```r
logRegRavens <- glm(ravensData$ravenWinNum ~ ravensData$ravenScore, family = "binomial")
summary(logRegRavens)
```

```
## 
## Call:
## glm(formula = ravensData$ravenWinNum ~ ravensData$ravenScore, 
##     family = "binomial")
## 
## Deviance Residuals: 
##    Min      1Q  Median      3Q     Max  
## -1.758  -1.100   0.530   0.806   1.495  
## 
## Coefficients:
##                       Estimate Std. Error z value Pr(>|z|)
## (Intercept)            -1.6800     1.5541   -1.08     0.28
## ravensData$ravenScore   0.1066     0.0667    1.60     0.11
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 24.435  on 19  degrees of freedom
## Residual deviance: 20.895  on 18  degrees of freedom
## AIC: 24.89
## 
## Number of Fisher Scoring iterations: 5
```

Intercept is the log-odds of the Ravens win when they score 0 points. Negative number means they're less likely to win than they are to lose. ravenScore is the log-odds ratio for a unit increase in the Ravens score. Every time they score, their log-odds ratio increases by 0.166 meaning the more points they score the more likely they are to win.

Ravens fitted values
--------------------

```r
plot(ravensData$ravenScore, logRegRavens$fitted, pch = 19, col = "blue", xlab = "Score", 
    ylab = "Prob Ravens Win")
```

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13.png) 

At first their probability increases a lot. The difference in probability of winning isn't much between scoring 40 to 50 points.

Odds ratios and confidence intervals
------------------------------------
To get the odds ratio, you need to exponentiate, since we get log-odds from `glm`. 

We're looking at the `ravenScore` variable

* log-odds ratios < 0 means that it's more likely for Ravens to lose
* after exponentiation, odds-ratio < 1 means that it's more likely for Ravens to lose

```r
exp(logRegRavens$coeff)
```

```
##           (Intercept) ravensData$ravenScore 
##                0.1864                1.1125
```



```r
exp(confint(logRegRavens))
```

```
## Waiting for profiling to be done...
```

```
##                          2.5 % 97.5 %
## (Intercept)           0.005675  3.106
## ravensData$ravenScore 0.996230  1.303
```

In this case, the confidence interval covers 1 (odds ratio of 1 means there's no difference in odds of winning as they score more points), so it's not clear that there is a relationship between the number of points that the Ravens score and their probability of winning.

ANOVA for logistic regression
-----------------------------

```r
anova(logRegRavens, test = "Chisq")
```

```
## Analysis of Deviance Table
## 
## Model: binomial, link: logit
## 
## Response: ravensData$ravenWinNum
## 
## Terms added sequentially (first to last)
## 
## 
##                       Df Deviance Resid. Df Resid. Dev Pr(>Chi)  
## NULL                                     19       24.4           
## ravensData$ravenScore  1     3.54        18       20.9     0.06 .
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

Instead of looking at residual sums of squares it looks at **deviance residuals**. Those have to do with the log-likelihood of the term.

Simpson's paradox
-----------------
Ignoring covariants can lead to wrong conclusions.

Interpreting Odds Ratios
------------------------
* Not probabilities
* Odds ratio of 1 = no difference in odds
* Log odds ratio of 0 = no difference in odds
* Odds ratio < 0.5 or > 2 commonly a "moderate effect"
* Relative risk $\frac{Pr(RW_i\mid RS_i=10)}{Pr(RW_i\mid RS_i=0)}$ often easier to interpret, harder to estimate - what's the probability of Ravens win given a different score.
* For small probabilities RR$\approx$OR but **they are not the same**!

More information
----------------
* Wikipedia on Logistic Regression
* [Logistic regression and glms in R](http://data.princeton.edu/R/glms.html)
* Brian Caffo's lecture notes on: Simpson's paradox, Case-control studies
* [Open Intro Chapter on Logistic Regression](http://www.openintro.org/stat/down/oiStat2_08.pdf)

Count outcomes
==============
Key ideas
* Many data take the form of counts
 - Calls to a call center in a fixed interval
 - Number of flu cases in an area
 - Number of cars that cross a bridge
* Data may also be in the form of rates
 - Percent of children passing a test
 - Percent of hits to a website from a country
* Linear regression with transformation is an option

Poisson distribution
--------------------
Has one parameter $\lambda$, rate, like the number of calls to a call center.

```r
set.seed(3433)
par(mfrow = c(1, 2))
poisData2 <- rpois(100, lambda = 100)
poisData1 <- rpois(100, lambda = 50)
hist(poisData1, col = "blue", xlim = c(0, 150))
hist(poisData2, col = "blue", xlim = c(0, 150))
```

![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17.png) 

* center of the distribution changes
* spread is different
* lambda controls mean and variance


```r
c(mean(poisData1), var(poisData1))
```

```
## [1] 49.85 49.38
```



```r
c(mean(poisData2), var(poisData2))
```

```
## [1] 100.12  95.26
```

Both mean and variance are very close to eachother.

Example: Leek Group Website Traffic
-----------------------------------
`julian()` counts from the number of observed days to 1970-01-01, easier to include in regression model.

### Website data

```r
download.file("http://dl.dropbox.com/u/7710864/data/gaData.rda", destfile = "./data/gaData.rda")
load("./data/gaData.rda")
gaData$julian <- julian(gaData$date)
head(gaData)
```

```
##         date visits simplystats julian
## 1 2011-01-01      0           0  14975
## 2 2011-01-02      0           0  14976
## 3 2011-01-03      0           0  14977
## 4 2011-01-04      0           0  14978
## 5 2011-01-05      0           0  14979
## 6 2011-01-06      0           0  14980
```


### Plot data

```r
plot(gaData$julian, gaData$visits, pch = 19, col = "darkgrey", xlab = "Julian", 
    ylab = "Visits")
```

![plot of chunk unnamed-chunk-21](figure/unnamed-chunk-21.png) 

Bump comes from Coursera class.

### Linear regression
$$latex
NH_i=b_0+b_1JD_i+e_i
$$

* $NH_i$ - number of hits to the website
* $JD_i$ - day of the year (Julian day)
* $b_0$ - number of hits on Julian day 0 (1970-01-01)
* $b_1$ - increase in number of hits per unit day
* $e_i$ - variation due to everything we didn't measure (in this model - no variable for when the coursera class started)

### Linear regression line

```r
plot(gaData$julian, gaData$visits, pch = 19, col = "darkgrey", xlab = "Julian", 
    ylab = "Visits")
lm1 <- lm(gaData$visits ~ gaData$julian)
abline(lm1, col = "red", lwd = 3)
```

![plot of chunk unnamed-chunk-22](figure/unnamed-chunk-22.png) 


### Linear vs. Poisson regression

#### Linear
$$latex
NH_i=b_0+b_1JD_i+e_1
$$
or, expected number of hits per particular julian day
$$latex
E[NH_i\mid JD_i, b_0, b_1]=b_0+b_1JD_i
$$

#### Poisson/log-linear
Called that because if you take the log of that mean number of hits, you make that a linear function.
$$latex
\log(E[NH_i\mid JD_i, b_0, b_1])=b_0+b_1JD_i
$$
or
$$latex
E[NH_i\mid JD_i, b_0, b_1]=\exp(b_0 + b_1JD_i)
$$

### Multiplicative differences
Multiplicative difference in the expected value.
$$latex
E[NH_i\mid JD_i, b_0,b_1] = exp(b_0+b_1JD_i)\\
E[NH_i\mid JD_i, b_0,b_1] = exp(b_0)exp(b_1JD_i)
$$
If $JD_i$ is increased by one unit, $E[NH_i\mid JD_i, b_0, b_1]$ is multiplied by $\exp(b_1)$

### Poisson regression in R

```r
plot(gaData$julian, gaData$visits, pch = 19, col = "darkgrey", xlab = "Julian", 
    ylab = "Visits")
glm1 <- glm(gaData$visits ~ gaData$julian, family = "poisson")
abline(lm1, col = "red", lwd = 3)
lines(gaData$julian, glm1$fitted, col = "blue", lwd = 3)
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-23.png) 


### Mean-variance relationship?

```r
plot(glm1$fitted, glm1$residuals, pch = 19, col = "grey", ylab = "Residuals", 
    xlab = "Fitted values")
```

![plot of chunk unnamed-chunk-24](figure/unnamed-chunk-24.png) 

If we assume Poisson distribution fits correctly, as the fitted value increases then the residuals get more variable as well, because the variance would be increasing in the y axis. That's not really true for this case.

### Model agnostic standard errors
If we don't want to assume that the mean and variance are the same.

```r
library(sandwich)
```



```r
confint.agnostic <- function(object, parm, level = 0.95, ...) {
    cf <- coef(object)
    pnames <- names(cf)
    if (missing(parm)) 
        parm <- pnames else if (is.numeric(parm)) 
        parm <- pnames[parm]
    a <- (1 - level)/2
    a <- c(a, 1 - a)
    pct <- stats:::format.perc(a, 3)
    fac <- qnorm(a)
    ci <- array(NA, dim = c(length(parm), 2L), dimnames = list(parm, pct))
    ses <- sqrt(diag(sandwich::vcovHC(object)))[parm]
    ci[] <- cf[parm] + ses %o% fac
    ci
}
```

### Estimating confidence intervals

```r
confint(glm1)
```

```
## Waiting for profiling to be done...
```

```
##                   2.5 %     97.5 %
## (Intercept)   -34.34658 -31.159716
## gaData$julian   0.00219   0.002396
```

The log and the multiplicative effect gives you the multiplicative change in the number of hits to the site given the one unit increase in the Julian day.


```r
confint.agnostic(glm1)
```

```
##                    2.5 %     97.5 %
## (Intercept)   -36.362675 -29.136997
## gaData$julian   0.002058   0.002528
```

Model agnostic intervals tend to be a bit wider.

### Rates
slide 16/19

Suppose we want to observe the expected number of hits to the site from simply statistics divided by the total number of hits to the site.

We can use this model to model the fraction of hits that go to the site from simply statistics.

### Fitting rates in R

```r
glm2 <- glm(gaData$simplystats ~ julian(gaData$date), 
            offset=log(visits+1), # offset term, the log of the total number of visits, +1 because there's a lot of 0 visits to the site
            family="poisson",
            data=gaData) # so r knows where to find visits variable
plot(julian(gaData$date),
     glm2$fitted,col="blue",
     pch=19,xlab="Date",
     ylab="Fitted Counts")
# just the total hits
points(julian(gaData$date),
       glm1$fitted,
       col="red",
       pch=19)
```

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29.png) 


### Fitting rates in R
date vs fraction of hits just from simply statistics.

```r
glm2 <- glm(gaData$simplystats ~ julian(gaData$date), offset = log(visits + 
    1), family = "poisson", data = gaData)
plot(julian(gaData$date), gaData$simplystats/(gaData$visits + 1), col = "grey", 
    xlab = "Date", ylab = "Fitted Rates", pch = 19)
lines(julian(gaData$date), glm2$fitted/(gaData$visits + 1), col = "blue", lwd = 3)
```

![plot of chunk unnamed-chunk-30](figure/unnamed-chunk-30.png) 



More information
----------------
* pscl package - the function zeroinfl fits zero inflated models.
* [Regression models for count data in R](http://cran.r-project.org/web/packages/pscl/vignettes/countreg.pdf)
* wikipedia: Poisson regression, overdispersion
* [Log-linear models and multiway tables](http://ww2.coastal.edu/kingw/statistics/R-tutorials/loglin.html)



Model checking and model selection
==================================
* Sometimes model checking/selection not allowed
* Often it can lead to problems
 - Overfitting
 - Overtesting
 - Biased inference - confidence intervals and p-values
* But you don't want to miss something obvious

Linear regression - basic assumptions
-------------------------------------
* Variance is constant - for each observation you have constant variance for the term that represents the error or the stochastic variation.
* You are summarizing a linear trend
* You have all the right terms in the model
* There are no big outliers

Model checking - constant variance
----------------------------------
x values equally spaced between 0 and 3, y values have increasing variance.

```r
set.seed(3433)
par(mfrow = c(1, 2))
data <- rnorm(100, mean = seq(0, 3, length = 100), sd = seq(0.1, 3, length = 100))
lm1 <- lm(data ~ seq(0, 3, length = 100))
plot(seq(0, 3, length = 100), data, pch = 19, col = "grey")
abline(lm1, col = "red", lwd = 3)
plot(seq(0, 3, length = 100), lm1$residuals, , pch = 19, col = "grey")
abline(c(0, 0), col = "red", lwd = 3)
```

![plot of chunk unnamed-chunk-31](figure/unnamed-chunk-31.png) 

Second graph subtracts the abline just to illustrate increase in variance over time. If this happens, CI and P-values won't necessarily have their claimed properties if you use the standard estimates that you get from `lm`.

What to do
----------
* See if another variable explains the increased variance
* Use the vcovHC {sandwich} variance estimators (if n is big)

Using the sandwich estimate
---------------------------

```r
set.seed(3433)
par(mfrow = c(1, 2))
data <- rnorm(100, mean = seq(0, 3, length = 100), sd = seq(0.1, 3, length = 100))
lm1 <- lm(data ~ seq(0, 3, length = 100))
vcovHC(lm1)
```

```
##                         (Intercept) seq(0, 3, length = 100)
## (Intercept)                 0.05410                -0.04765
## seq(0, 3, length = 100)    -0.04765                 0.05369
```

```r
summary(lm1)$cov.unscaled
```

```
##                         (Intercept) seq(0, 3, length = 100)
## (Intercept)                 0.03941                -0.01960
## seq(0, 3, length = 100)    -0.01960                 0.01307
```

intercept/intercept - variance of the intercept estimate
seq(0, 3, length=100)/seq(0, 3, length=100) - variance of the estimate for the covariant of interest, the X variable. The remaining numbers are variances between the terms which aren't often used in the analysis.

With standard linear model, the variances are bigger. This model will underestimate the amount of variability in the data, so you'll be more confident in measured association than you should be.

Model checking - linear trend
-----------------------------
When there isn't a linear trend and we're trying to model it as a linear trend.

```r
set.seed(3433)
par(mfrow = c(1, 2))
data <- rnorm(100, mean = seq(0, 3, length = 100)^3, sd = 2)
lm1 <- lm(data ~ seq(0, 3, length = 100))

plot(seq(0, 3, length = 100), data, pch = 19, col = "grey")
abline(lm1, col = "red", lwd = 3)

plot(seq(0, 3, length = 100), lm1$residuals, , pch = 19, col = "grey")
abline(c(0, 0), col = "red", lwd = 3)
```

![plot of chunk unnamed-chunk-33](figure/unnamed-chunk-33.png) 

We would expect to see a cloud/oval shape on the right.

What to do
----------
* Use Poisson regression (if it looks exponential/multiplicative)
* Use a data transformation (e.g. take the log)
* Smooth the data/fit a nonlinear trend (next week's lectures)
* Use linear regression anyway
 - Interpret as the linear trend between the variables
 - Use the vcovHC{sandwich} variance estimators (if n is big)

Model checking - missing covariate
----------------------------------
Variance is increasing from left to right, but we also have a second covariant, z. If we color the points by the z variable, we see that blue points tend to be a bit higher than green points. we can also take a boxplot and see the mean for green is much lower than blue.

```r
set.seed(3433)
par(mfrow = c(1, 3))
z <- rep(c(-0.5, 0.5), 50)
data <- rnorm(100, mean = (seq(0, 3, length = 100) + z), sd = seq(0.1, 3, length = 100))
lm1 <- lm(data ~ seq(0, 3, length = 100))
plot(seq(0, 3, length = 100), data, pch = 19, col = ((z > 0) + 3))
abline(lm1, col = "red", lwd = 3)
plot(seq(0, 3, length = 100), lm1$residuals, pch = 19, col = ((z > 0) + 3))
abline(c(0, 0), col = "red", lwd = 3)
boxplot(lm1$residuals ~ z, col = ((z > 0) + 3))
```

![plot of chunk unnamed-chunk-34](figure/unnamed-chunk-34.png) 


What to do
----------
* Use exploratory analysis to identify other variables to include
* Use the vcovHC {sandwich} variance estimators (if n is big)
* Report unexplained patterns in the data

Model checking - outliers
-------------------------
Generated x and y that are independed of each other. Some y values are high and low.

To identify how much influence a data point will have on analysis,

* Fit the model with all the data points and get an estimate of the slope of the line.
* Then delete the point and refit the line.
* If the two slopes are very different, then that point was having a major impact on the linear regression line.


```r
set.seed(343)
par(mfrow = c(1, 2))
betahat <- rep(NA, 100)
x <- seq(0, 3, length = 100)
y <- rcauchy(100)
lm1 <- lm(y ~ x)
plot(x, y, pch = 19, col = "blue")
abline(lm1, col = "red", lwd = 3)
for (i in 1:length(data)) {
    betahat[i] <- lm(y[-i] ~ x[-i])$coeff[2]
}
plot(betahat - lm1$coeff[2], col = "blue", pch = 19)
abline(c(0, 0), col = "red", lwd = 3)
```

![plot of chunk unnamed-chunk-35](figure/unnamed-chunk-35.png) 

Points near the edges will often have a big influence.

What to do
-----------
* If outliers are experimental mistakes - remove and document them
* If they are real - consider reporting how sensitive your estimate is to the outliers
* Consider using a robust linear model fit like rlm {MASS} - will downweight points that are likely to be outliers.

Robust linear modeling
----------------------

```r
library(MASS)
```



```r
set.seed(343)
x <- seq(0, 3, length = 100)
y <- rcauchy(100)
lm1 <- lm(y ~ x)
rlm1 <- rlm(y ~ x)
lm1$coeff
```

```
## (Intercept)           x 
##      0.3523     -0.4011
```

Fairly large coefficients for the intercept and slope.


```r
rlm1$coeff
```

```
## (Intercept)           x 
##    0.008527   -0.017892
```

Intercept and slope much lower, x, y independent, so this is correct.

Robust linear modeling
----------------------
Another way to look at this.
* blue - `lm`
* green - `rlm`

```r
par(mfrow = c(1, 2))
plot(x, y, pch = 19, col = "grey")
lines(x, lm1$fitted, col = "blue", lwd = 3)
lines(x, rlm1$fitted, col = "green", lwd = 3)
plot(x, y, pch = 19, col = "grey", ylim = c(-5, 5), main = "Zoomed In")
lines(x, lm1$fitted, col = "blue", lwd = 3)
lines(x, rlm1$fitted, col = "green", lwd = 3)
```

![plot of chunk unnamed-chunk-39](figure/unnamed-chunk-39.png) 

`lm` is being dragged down by the outlier points, whereas `rlm` downweights the points and creates a line with slope closer to 0, since x, y are independent.

Model checking - default plots
------------------------------
A lot of the plots are automated.
* Fitted values vs Residuals
 - differences in variation - if the fitted values increase you get an increase in variation then you may be looking at something that's more like count data or you may be seeing an outlier value.
 - labels interesting points in terms of outliers.
* qq plot
 - x axis has the normal 0, 1 distribution
 - y axis is the standardized residuals so they should look like a normal 0, 1 if all model assumptions hold true.
 - if there's a big deviation from the 45 degree line, you might expect that the normal assumption may be violated by the data you're looking at.
 

```r
set.seed(343)
par(mfrow = c(1, 2))
x <- seq(0, 3, length = 100)
y <- rnorm(100)
lm1 <- lm(y ~ x)
plot(lm1)
```

![plot of chunk unnamed-chunk-40](figure/unnamed-chunk-401.png) ![plot of chunk unnamed-chunk-40](figure/unnamed-chunk-402.png) 


Model checking - deviance
-------------------------
* Commonly reported for GLM's, tells something about model fit
* Usually compares the model where every point gets its own parameter to the model you are using - **saturated model** - model that perfectly fits the data and you compare that to the model that you're using to see if your model still explains most of the variation, even if using a much smaller number of parameters.
* On it's own it doesn't tell you what is wrong
* In large samples the deviance may be big even for "conservative" models
* You can not compare deviances for models with different sample sizes

$R^2$ may be a bad summary
---------------------------

Model selection
----------------
* Many times you have multiple variables to evaluate
* Options for choosing variables
 - Domain-specific knowledge
 - Exploratory analysis
 - Statistical selection
* There are many statistical selection options
 - Step-wise
 - AIC
 - BIC
 - Modern approaches: Lasso, Ridge-Regression, etc.
* Statistical selection may bias your inference
 - If possible, do selection on a held out sample
 
Error measures
---------------
* $R^2$ alone isn't enough - more variables = bigger $R^2$
* Adjusted $R^2$ is $R^2$ taking into account the number of estimated parameters
* AIC also penalizes models with more parameters
* BIC does the same, but with a bigger penalty

Movie Data
----------

```r
download.file("http://www.rossmanchance.com/iscam2/data/movies03RT.txt", destfile = "./data/movies.txt")
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


Model selection - step
----------------------
We want to do a model, but we don't know which variables to pick. We include all variables `data=movies`. `step` will go through and it will consider deleting one of the variables and recompute the AIC score to see if it got better or worse. If better it will delete another term, etc.

There are three ways `step` works. It can either be **forward selection** start with no variables and add one by one, **backward selection** start with all the variables in the model, **both** where it adds or deletes terms.


```r
movies <- movies[, -1]
lm1 <- lm(score ~ ., data = movies)
aicFormula <- step(lm1)
```

```
## Start:  AIC=727.5
## score ~ rating + genre + box.office + running.time
## 
##                Df Sum of Sq   RSS AIC
## - genre        12      2575 22132 721
## - rating        3        40 19596 722
## - running.time  1       237 19793 727
## <none>                      19556 728
## - box.office    1      3007 22563 746
## 
## Step:  AIC=720.8
## score ~ rating + box.office + running.time
## 
##                Df Sum of Sq   RSS AIC
## - rating        3       491 22623 718
## <none>                      22132 721
## - running.time  1      1192 23324 726
## - box.office    1      2456 24588 734
## 
## Step:  AIC=717.9
## score ~ box.office + running.time
## 
##                Df Sum of Sq   RSS AIC
## <none>                      22623 718
## - running.time  1       935 23557 722
## - box.office    1      3337 25959 735
```



```r
aicFormula
```

```
## 
## Call:
## lm(formula = score ~ box.office + running.time, data = movies)
## 
## Coefficients:
##  (Intercept)    box.office  running.time  
##      37.2364        0.0824        0.1275
```

This model only includes box office and running time. The returned coefficients may be biased because of the `step` function being done first.

Model selection - regsubsets
----------------------------
Looks at all possible subsets of variables and it'll calculate the BIC score.

```r
library(leaps)
regSub <- regsubsets(score ~ ., data = movies)
plot(regSub)
```

![plot of chunk unnamed-chunk-44](figure/unnamed-chunk-44.png) 


Model selection - bic.glm
-------------------------
BIC score. 

Does model averaging. Calculates the posterior probabilities that a term should be in the model. The coefficients are slightly corrected from the coefficients that you would get if you just fit the model directly. So that allows for some understanding that you've done some selection before inference.


```r
library(BMA)
bicglm1 <- bic.glm(score ~ ., data = movies, glm.family = "gaussian")
print(bicglm1)
```

```
## 
## Call:
## bic.glm.formula(f = score ~ ., data = movies, glm.family = "gaussian")
## 
## 
##  Posterior probabilities(%): 
##       rating        genre   box.office running.time 
##          0.0        100.0        100.0         18.2 
## 
##  Coefficient posterior expected values: 
##           (Intercept)               ratingPG            ratingPG-13  
##                45.263                  0.000                  0.000  
##               ratingR  genreaction/adventure          genreanimated  
##                 0.000                 -0.120                  7.628  
##           genrecomedy       genredocumentary             genredrama  
##                 2.077                  8.642                 13.041  
##          genrefantasy            genrehorror           genremusical  
##                 1.504                 -3.458                -12.255  
##       genrerom comedy            genresci-fi          genresuspense  
##                 1.244                 -3.324                  3.815  
##          genrewestern             box.office           running.time  
##                17.563                  0.100                  0.016
```


Notes and further resources
---------------------------
* Exploratory/visual analysis is key
* Automatic selection produces an answer - but may bias inference
* You may think about separating the sample into two groups - for seection step and inference.
* The goal is not to get the "causal" model - not necessarily the exact model, just one estimate.
* Lars package - advanced feature selection for sort-of high dimensional feature selection (eg lasso)
* Elements of machine learning
