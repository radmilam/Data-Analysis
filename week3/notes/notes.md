Exploratory Graphs
==================

Background - perceptual tasks
-----------------------------
Comparisons between quantitative measurements

Position vs. length

No pie charts - higher error rate compared to bar charts, easier to compare lengths than angles

* Use common scales when possible
* When possible use position comparisons
* Angle comparisons are frequently hard to interpret
* No 3D charts


```r
pData <- read.csv("./data/ss06pid.csv")
```


Boxplots
--------
Quantitative variables - what does distribution look like
* params: col, varwidth, names, horizontal
* line in middle is median
* upper/lower bounds of box are 25th and 75th percentile
* whiskers = 1.5 * 75th percentile, 1.5 * 25th percentile
* if there are values larger or smaller, they'll be represented as dots above or below the whiskers


```r
boxplot(pData$AGEP, col = "blue")
```

![plot of chunk unnamed-chunk-2](figure/unnamed-chunk-2.png) 


#### plot informs whether:
* the data has a large number of values spread out or compacted
* is the distribution symmetric - where does the black line fall in the box

To make comparisons of quantitative variables on a common scale, we can use boxplots



```r
boxplot(pData$AGEP ~ as.factor(pData$DDRS), col = "blue")
```

![Age broken down by difficulty dressing](figure/unnamed-chunk-3.png) 


What the above boxplots don't encode is how many individuals have difficulty dressing vs. ones that don't. We can encode that with `varwidth=TRUE`

```r
boxplot(pData$AGEP ~ as.factor(pData$DDRS), col = c("blue", "orange"), names = c("yes", 
    "no"), varwidth = T)
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4.png) 

Width is proportional to the number of observations we have in each group.

Barplots
--------
position


```r
barplot(table(pData$CIT), col = "blue")
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5.png) 


Histograms
----------
frequency

* params: breaks, freq, col, xlab, ylab, xlim, _ylim, main


```r
hist(pData$AGEP, col = "blue")
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.png) 


You can see the shape of the distribution as opposed to boxplot.

You can set the number of breaks

```r
hist(pData$AGEP, col = "blue", breaks = 100, main = "Age")
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7.png) 


Density plots
-------------
Like a histogram, but smoothed out
* params: col, lwd - line thickness, xlab, ylab, xlim, ylim


```r
dens <- density(pData$AGEP)
plot(dens, lwd = 3, col = "blue")
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8.png) 


Density is different from frequency in that it shows the percentage of the observations between 0 and 1. Smoothing introduces error

You can overlay distributions for different, say, genders

```r
densMales <- density(pData$AGEP[which(pData$SEX == 1)])
plot(dens, lwd = 3, col = "blue")
lines(densMales, lwd = 3, col = "orange")
```

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 


Scatterplots
------------
Visualize relationships between variables
* vars: 
 - x, y - points, same length
 - type
 - xlab, ylab - variable labels
 - xlim, ylim - limites
 - cex - size of points, 
 - col - color of point
 - bg - background of points for specific type of points
 - pch - type of point
`?par`


```r
plot(pData$JWMNP, pData$WAGP, pch = 19, col = "blue")
```

![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10.png) 



```r
plot(pData$JWMNP, pData$WAGP, pch = 19, col = "blue", cex = 0.5)
```

![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-11.png) 


Encodes color by sex

```r
plot(pData$JWMNP, pData$WAGP, pch = 19, col = pData$SEX, cex = 0.5)
```

![plot of chunk unnamed-chunk-12](figure/unnamed-chunk-12.png) 


Using size

```r
percentMaxAge <- pData$AGEP/max(pData$AGEP)
plot(pData$JWMNP, pData$WAGP, pch = 19, col = "blue", cex = percentMaxAge * 
    0.5)
```

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13.png) 


overlaying lines/points

```r
plot(pData$JWMNP, pData$WAGP, pch = 19, col = "blue", cex = 0.5)
lines(rep(100, dim(pData)[1]), pData$WAGP, col = "grey", lwd = 5)
points(seq(0, 200, length = 100), seq(0, 2e+06, length = 100), col = "red", 
    pch = 19)
```

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14.png) 


numeric variables as factors

```r
library(Hmisc)
ageGroups <- cut2(pData$AGEP, g = 5)
plot(pData$JWMNP, pData$WAGP, pch = 19, col = ageGroups, cex = 0.5)
```

![plot of chunk unnamed-chunk-15](figure/unnamed-chunk-15.png) 

`cut2` takes continuous variable and brakes it up into 5 equal intervals and assigns each point as a factor to those intervals.

It doesn't look like there's a difference in distributions across ages for this data.

If there's a lot of points

```r
x <- rnorm(1e+05)
y <- rnorm(1e+05)
plot(x, y, pch = 19)
```

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-16.png) 

The plot may not be informative. To fix:

sampling

```r
x <- rnorm(1e+05)
y <- rnorm(1e+05)
sampledValues <- sample(1:1e+05, size = 1000, replace = FALSE)
plot(x[sampledValues], y[sampledValues], pch = 19)
```

![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17.png) 


smooth scatter - smooth density plot

```r
x <- rnorm(1e+05)
y <- rnorm(1e+05)
smoothScatter(x, y)
```

```
## KernSmooth 2.23 loaded Copyright M. P. Wand 1997-2009
```

![plot of chunk unnamed-chunk-18](figure/unnamed-chunk-18.png) 

outline points are hard dots

hexbin

```r
x <- rnorm(1e+05)
y <- rnorm(1e+05)
hbo <- hexbin(x, y)
```

```
## Error: could not find function "hexbin"
```

```r
plot(hbo)
```

```
## Error: object 'hbo' not found
```

brakes the set of x and y values into hexagonal bins and then counts the number of variables that are in each hexagonal bin.

QQ-Plots
--------
Takes two variables and plots quantiles of x and y

```r
x <- rnorm(20)
y <- rnorm(20)
qqplot(x, y)
# abline takes c(slope, intercept)
abline(c(0, 1))
```

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20.png) 

For data that you want to see if it's normally distributed, you can do qq-plot with normal data vs observed data and see if there are large deviation from abline where the data are not normally distributed.

Matplot and spaghetti
---------------------
Observations over time or longitudinal

```r
x <- matrix(rnorm(20 * 5), nrow = 20)
matplot(x, type = "b")
```

![plot of chunk unnamed-chunk-21](figure/unnamed-chunk-21.png) 


Heatmaps
--------
Like a 2D histogram
* params: x, y, z, col

```r
image(1:10, 161:236, as.matrix(pData[1:10, 161:236]))
```

![plot of chunk unnamed-chunk-22](figure/unnamed-chunk-22.png) 

White lowest value, red highest.

matching intuition

```r
newMatrix <- as.matrix(pData[1:10, 161:236])
newMatrix <- t(newMatrix)[, nrow(newMatrix):1]
image(161:236, 1:10, newMatrix)
```

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-23.png) 


Maps
----

```r
library(maps)
map("world")
lat <- runif(40, -180, 180)
lon <- runif(40, -90, 90)
points(lat, lon, col = "blue", pch = 19)
```

![plot of chunk unnamed-chunk-24](figure/unnamed-chunk-24.png) 


Missing values and plots
------------------------

```r
x <- c(NA, NA, NA, 4, 5, 6, 7, 8, 9, 10)
y <- 1:10
plot(x, y, pch = 19, xlim = c(0, 11), ylim = c(0, 11))
```

![plot of chunk unnamed-chunk-25](figure/unnamed-chunk-25.png) 

NA values are skipped, pay attention to make right conclusions.
You can also do a boxplot. Create all values where x < 0 to be NA and see if there's a relationship between them

```r
set.seed(8)
x <- rnorm(100)
y <- rnorm(100)
y[x < 0] <- NA
boxplot(x ~ is.na(y))
```

![plot of chunk unnamed-chunk-26](figure/unnamed-chunk-26.png) 

From this we can see that if y == NA, x values are small and when y != NA, x values are big.

Expository Graphs
=================
Those are the graphs included in final analysis.

Axes
----

```r
plot(pData$JWMNP, pData$WAGP, pch = 19, col = "blue", cex = 0.5, xlab = "Travel time (min)", 
    ylab = "Last 12 month wages (dollars)")
```

![plot of chunk unnamed-chunk-27](figure/unnamed-chunk-27.png) 


Changing size and orientation

```r
plot(pData$JWMNP, pData$WAGP, pch = 19, col = "blue", cex = 0.5, xlab = "Travel time (min)", 
    ylab = "Last 12 month wages (dollars)", cex.lab = 2, cex.axis = 1.5)
```

![plot of chunk unnamed-chunk-28](figure/unnamed-chunk-28.png) 


Legends
-------

```r
plot(pData$JWMNP, pData$WAGP, pch = 19, col = "blue", cex = 0.5, xlab = "Travel time (min)", 
    ylab = "Last 12 month wages (dollars)")
legend(100, 2e+05, legend = "All surveyed", col = "blue", pch = 19, cex = 0.5)
```

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29.png) 


if more than one color

```r
plot(pData$JWMNP, pData$WAGP, pch = 19, cex = 0.5, xlab = "Travel time (min)", 
    ylab = "Wages (dollars)", col = pData$SEX)
legend(100, 2e+05, legend = c("men", "women"), col = c("black", "red"), pch = c(19, 
    19), cex = c(0.5, 0.5))
```

```
## Warning: the condition has length > 1 and only the first element will be
## used
```

![plot of chunk unnamed-chunk-30](figure/unnamed-chunk-30.png) 


Titles
------

```r
plot(pData$JWMNP, pData$WAGP, pch = 19, cex = 0.5, xlab = "Travel time (min)", 
    ylab = "Wages (dollars)", col = pData$SEX, main = "Wages earned versus commute time")
legend(100, 2e+05, legend = c("men", "women"), col = c("black", "red"), pch = c(19, 
    19), cex = c(0.5, 0.5))
```

```
## Warning: the condition has length > 1 and only the first element will be
## used
```

![plot of chunk unnamed-chunk-31](figure/unnamed-chunk-31.png) 


Multiple panels
---------------

```r
# orient panels
par(mfrow = c(1, 2))
hist(pData$JWMNP, xlab = "CT (min)", col = "blue", breaks = 100, main = "")
plot(pData$JWMNP, pData$WAGP, pch = 19, cex = 0.5, xlab = "Travel time (min)", 
    ylab = "Wages (dollars)", col = pData$SEX)
legend(100, 2e+05, legend = c("men", "women"), col = c("black", "red"), pch = c(19, 
    19), cex = c(0.5, 0.5))
```

```
## Warning: the condition has length > 1 and only the first element will be
## used
```

![plot of chunk unnamed-chunk-32](figure/unnamed-chunk-32.png) 


Adding text
-----------

```r
# orient panels
par(mfrow = c(1, 2))
hist(pData$JWMNP, xlab = "CT (min)", col = "blue", breaks = 100, main = "")
mtext(text = "(a)", side = 3, line = 1)
plot(pData$JWMNP, pData$WAGP, pch = 19, cex = 0.5, xlab = "Travel time (min)", 
    ylab = "Wages (dollars)", col = pData$SEX)
legend(100, 2e+05, legend = c("men", "women"), col = c("black", "red"), pch = c(19, 
    19), cex = c(0.5, 0.5))
```

```
## Warning: the condition has length > 1 and only the first element will be
## used
```

```r
mtext(text = "(b)", side = 3, line = 1)
```

![plot of chunk unnamed-chunk-33](figure/unnamed-chunk-33.png) 


Figure captions
---------------
slide 13/21

Graphical Workflow
------------------
**PDF**
* params: file, height, width

```
pdf(file="twoPanel.pdf", height=480, width=(2 * 480))
par(mfrow=c(1, 2))
hist(pData$JWMNP, xlab="CT (min)", col="blue", breaks=100, main="")
mtext(text="(a)", side=3, line=1)
plot(pData$JWMNP, 
     pData$WAGP, 
     pch=19, 
     cex=0.5,
     xlab="Travel time (min)",
     ylab="Wages (dollars)",
     col=pData$SEX)
legend(100, 200000, 
       legend=c("men", "women"), 
       col=c("black", "red"), 
       pch=c(19, 19), cex=c(0.5, 0.5))
mtext(text="(b)", side=3, line=1)
dev.off()
```

Same for **PNG**

You can tweak graph and copy it directly to pdf 

```
par(mfrow=c(1, 2))
hist(pData$JWMNP, xlab="CT (min)", col="blue", breaks=100, main="")
plot(pData$JWMNP, 
     pData$WAGP, 
     pch=19, 
     cex=0.5,
     xlab="Travel time (min)",
     ylab="Wages (dollars)",
     col=pData$SEX)
dev.copy2pdf(file="twoPanelv2.pdf")
```

Hierarchical clustering
-----------------------
Organizes things that are **close** into groups
produces dendrogram

How do we define close?
* most important step
 - Garbage in  -> garbage out: if we use a garbage variable, we'll produce garbage clustering
 
Euclidean distance
* Used for quantitative - continuous vairables

Manhattan distance
* distance on a grid (?)

example

```r
set.seed(1234)
par(mar = c(0, 0, 0, 0))
x <- rnorm(12, mean = rep(1:3, each = 4), sd = 0.2)
y <- rnorm(12, mean = rep(1, 2, 1, each = 4), sd = 0.2)
plot(x, y, col = "blue", pch = 19, cex = 2)
text(x + 0.05, y + 0.05, labels = as.character(1:12))
```

![plot of chunk unnamed-chunk-34](figure/unnamed-chunk-34.png) 


dist

```r
dataFrame <- data.frame(x = x, y = y)
dist(dataFrame)
```

```
##          1       2       3       4       5       6       7       8       9
## 2  0.34121                                                                
## 3  0.57494 0.24103                                                        
## 4  0.26382 0.52579 0.71862                                                
## 5  1.32830 1.03675 0.91736 1.55703                                        
## 6  1.34290 1.06378 0.96021 1.57850 0.08150                                
## 7  1.12653 0.84894 0.75866 1.36197 0.21110 0.21667                        
## 8  1.29969 0.95849 0.73405 1.45064 0.61704 0.69792 0.65063                
## 9  2.13630 1.83168 1.67836 2.35676 0.81161 0.81323 1.02071 1.09597        
## 10 2.06420 1.76999 1.63110 2.29239 0.73618 0.72567 0.93950 1.09785 0.14090
## 11 2.14702 1.85183 1.71074 2.37462 0.81886 0.80885 1.02259 1.16375 0.11624
## 12 2.05664 1.74663 1.58659 2.27232 0.74040 0.75095 0.95131 0.99022 0.10849
##         10      11
## 2                 
## 3                 
## 4                 
## 5                 
## 6                 
## 7                 
## 8                 
## 9                 
## 10                
## 11 0.08318        
## 12 0.19129 0.20803
```


#1
closest 2 points get picked, and merged, and so forth until we have 1 point left

```r
distxy <- dist(dataFrame)
hClustering <- hclust(distxy)
plot(hClustering)
```

![plot of chunk unnamed-chunk-36](figure/unnamed-chunk-36.png) 


To decide clusters things get broken into, we have to cut the dendrogram at some point.

#### Prettier dendrograms

```r
myplclust <- function(hclust, lab = hclust$labels, lab.col = rep(1, length(hclust$labels)), 
    hang = 0.1, ...) {
    y <- rep(hclust$height, 2)
    x <- as.numeric(hclust$merge)
    y <- y[which(x < 0)]
    x <- x[which(x < 0)]
    x <- abs(x)
    y <- y[order(x)]
    x <- x[order(x)]
    plot(hclust, labels = F, hang = hang, ...)
    text(x = x, y = y[hclust$order] - (max(hclust$height) * hang), labels = lab[hclust$order], 
        col = lab.col[hclust$order], srt = 90, adj = c(1, 0.5), xpd = NA, ...)
}
dataFrame <- data.frame(x = x, y = y)
distxy <- dist(dataFrame)
hClustering <- hclust(distxy)
myplclust(hClustering, lab = rep(1:3, each = 4), lab.col = rep(1:3, each = 4))
```

![plot of chunk unnamed-chunk-37](figure/unnamed-chunk-37.png) 


graph 79 on R Graph Gallery

Merging points:
* complete
 - Complete linkage - comparing points farthest apart
* average
 - uses average distance
 
#### heatmap()
visualizing quantitative data after they were clustered


```r
df <- data.frame(x = x, y = y)
set.seed(143)
dataMatrix <- as.matrix(dataFrame)[sample(1:12), ]
heatmap(dataMatrix)
```

![plot of chunk unnamed-chunk-38](figure/unnamed-chunk-38.png) 


K-Means Clustering
==================
Continuous - Euclidian distance is usually used in k-means clustering.

When determining a reasonable number of clusters, pick a large one, then go down.


```r
set.seed(1234)
par(mar = c(0, 0, 0, 0))
x <- rnorm(12, mean = rep(1:3, each = 4), sd = 0.2)
y <- rnorm(12, mean = rep(c(1, 2, 1), each = 4), sd = 0.2)
plot(x, y, col = "blue", pch = 19, cex = 2)
text(x + 0.05, y + 0.05, labels = as.character(1:12))
```

![plot of chunk unnamed-chunk-39](figure/unnamed-chunk-39.png) 

#### Starting centroids
1. Assign all the points to the closer centroid
2. Recalculate centroids by taking the euclidian distance between each of the points
3. Reassign points to centroids
4. Iterate

`kmeans()`
* params: 
 - x - data frame or matrix
 - centers - number of centers
 - iter.max - for large datasets not to run forever
 - nstart - number of starting points - kmeans is non-deterministic, you can restart multiple times and get an average cluster over those starts

```r
dataFrame <- data.frame(x, y)
kmeansObj <- kmeans(dataFrame, centers = 3)
names(kmeansObj)
```

```
## [1] "cluster"      "centers"      "totss"        "withinss"    
## [5] "tot.withinss" "betweenss"    "size"
```



```r
kmeansObj$cluster
```

```
##  [1] 3 3 3 3 1 1 1 1 2 2 2 2
```


#### Plot clusters

```r
par(mar = rep(0.2, 4))
plot(x, y, col = kmeansObj$cluster, pch = 19, cex = 2)
points(kmeansObj$centers, col = 1:3, pch = 3, cex = 3, lwd = 3)
```

![plot of chunk unnamed-chunk-42](figure/unnamed-chunk-42.png) 


#### With heatmaps

```r
set.seed(1234)
dataMatrix <- as.matrix(dataFrame)[sample(1:12), ]
kmeansObj2 <- kmeans(dataMatrix, centers = 3)
par(mfrow = c(1, 2), mar = rep(0.2, 4))
image(t(dataMatrix)[, nrow(dataMatrix):1], yaxt = "n")
image(t(dataMatrix)[, order(kmeansObj$cluster)], yaxt = "n")
```

![plot of chunk unnamed-chunk-43](figure/unnamed-chunk-43.png) 


Scrambled and unscrambled heatmaps - col1: x, col2: y

Principal components analysis and singular value decomposition
==============================================================
Compress large set of variables into a smaller one

Matrix data
-----------
No relation between variables and observation
column: variable
row: observation

```r
set.seed(12345)
par(mar = rep(0.2, 4))
dataMatrix <- matrix(rnorm(400), nrow = 40)
image(1:10, 1:40, t(dataMatrix)[, nrow(dataMatrix):1])
```

![plot of chunk unnamed-chunk-44](figure/unnamed-chunk-44.png) 


You can confirm there are no patterns with dendrogram

```r
par(mar = rep(0.2, 4))
heatmap(dataMatrix)
```

![plot of chunk unnamed-chunk-45](figure/unnamed-chunk-45.png) 


We can add a pattern that affects some rows

```r
# for each row
for (i in 1:40) {
    # flip a coin
    coinFlip <- rbinom(1, size = 1, prob = 0.5)
    # if coin is heads add a common pattern to that row
    if (coinFlip) {
        # pattern: first 5 variables are 0, last 5 are 3
        dataMatrix[i, ] <- dataMatrix[i, ] + rep(c(0, 3), each = 5)
    }
}
```



```r
par(mar = rep(0.2, 4))
heatmap(dataMatrix)
```

![plot of chunk unnamed-chunk-47](figure/unnamed-chunk-47.png) 


To find the patterns without looking at the entire data set we can:

1. take the means of rows and columns


```r
hh <- hclust(dist(dataMatrix))
dataMatrixOrdered <- dataMatrix[hh$order, ]
par(mfrow = c(1, 3))
image(t(dataMatrixOrdered)[, nrow(dataMatrixOrdered):1])
plot(rowMeans(dataMatrixOrdered), 40:1, , xlab = "Row", ylab = "Row Mean", pch = 19)
plot(colMeans(dataMatrixOrdered), xlab = "Column", ylab = "Column Mean", pch = 19)
```

![plot of chunk unnamed-chunk-48](figure/unnamed-chunk-48.png) 

In figure 2 mean of each row is plotted, we can see hihger values cluster on the top right.

What happens if there's more than one pattern?

SVD
---
#### Components: v

```r
svd1 <- svd(scale(dataMatrixOrdered))
par(mfrow = c(1, 3))
image(t(dataMatrixOrdered)[, nrow(dataMatrixOrdered):1])
plot(svd1$u[, 1], 40:1, , xlab = "Row", ylab = "First left singular vector - u", 
    pch = 19)
plot(svd1$v[, 1], xlab = "Column", ylab = "First right singular vector - v", 
    pch = 19)
```

![plot of chunk unnamed-chunk-49](figure/unnamed-chunk-49.png) 


Looking at v - the 5 values at the bottom right make sense because last 5 columns all have a particular value, unlike first 5.

#### Components: d and variance

```r
svd1 <- svd(scale(dataMatrixOrdered))
par(mfrow = c(1, 2))
plot(svd1$d, xlab = "Column", ylab = "Singular value", pch = 19)
plot(svd1$d^2/sum(svd1$d^2), xlab = "Column", ylab = "Percent of variance explained", 
    pch = 19)
```

![plot of chunk unnamed-chunk-50](figure/unnamed-chunk-50.png) 

The decreasing set of values in the first figure start with first left singular vector, then second, etc.

Figure 2 - first point explains 40 percent of the variance, etc. What people do is to add up the cumulative amounts of variance explained moving from left to right and identify patterns that explain some large percentage of the variance, 80, 90%. They can then compress the data by only considering components of SVD that represent those patterns.

Relationship to PCA
-------------------
Taking first PC vs first right singular vector, they're the same

```r
svd1 <- svd(scale(dataMatrixOrdered))
pca1 <- prcomp(dataMatrixOrdered, scale = T)
plot(pca1$rotation[, 1], svd1$v[, 1], pch = 19, xlab = "Principal Component 1", 
    ylab = "Right Singular Vector 1")
abline(c(0, 1))
```

![plot of chunk unnamed-chunk-51](figure/unnamed-chunk-51.png) 


Components of the SVD - variance explained
------------------------------------------

```r
constantMatrix <- dataMatrixOrdered * 0
for (i in 1:dim(dataMatrixOrdered)[1]) {
    # matrix where every row is the same
    constantMatrix[i, ] <- rep(c(0, 1), each = 5)
}
svd1 <- svd(constantMatrix)
par(mfrow = c(1, 3))
image(t(constantMatrix)[, nrow(constantMatrix):1])
plot(svd1$d, xlab = "Column", ylab = "Singular value", pch = 19)
plot(svd1$d^2/sum(svd1$d^2), xlab = "Column", ylab = "Percent of variance explained", 
    pch = 19)
```

![plot of chunk unnamed-chunk-52](figure/unnamed-chunk-52.png) 


100% of the variance is explained by the first d value. Reason is that if we take u and v and multiply them together, we can reproduce the matrix exactly, so all the variation in the matrix is explained by one pattern.

If the data was random, each singular vector would explain approximately 1/the number of columns variance in the data set.

What if we add a second pattern?
--------------------------------

```r
set.seed(678910)
for (i in 1:40) {
    # flip a coin
    coinFlip1 <- rbinom(1, size = 1, prob = 0.5)
    coinFlip2 <- rbinom(1, size = 1, prob = 0.5)
    
    # if coin is heads, add a common pattern to that row
    if (coinFlip1) {
        dataMatrix[i, ] <- dataMatrix[i, ] + rep(c(0, 5), each = 5)
    }
    if (coinFlip2) {
        dataMatrix[i, ] <- dataMatrix[i, ] + rep(c(0, 5), 5)
    }
}
hh <- hclust(dist(dataMatrix))
dataMatrixOrdered <- dataMatrix[hh$order, ]
```


Now cluster the data set and plot

```r
svd2 <- svd(scale(dataMatrixOrdered))
par(mfrow = c(1, 3))
image(t(dataMatrixOrdered)[, nrow(dataMatrixOrdered):1])
plot(rep(c(0, 1), each = 5), xlab = "Column", ylab = "Pattern 1", pch = 19)
plot(rep(c(0, 1), 5), xlab = "Column", ylab = "Pattern 2", pch = 19)
```

![plot of chunk unnamed-chunk-54](figure/unnamed-chunk-54.png) 

We can see that there are 2 patterns in the data set:
* values high on right hand side and low on left hand side
* stripes - low - high - low - high

The two patterns overlap each other

In the second plot, we can see Pattern 1 is low for first 5 columns then high for next 5. Pattern 2 is flip/flopping.

v and patterns of variance in rows
----------------------------------
svd2 <- svd(scale(dataMatrixOrdered))

```r
par(mfrow = c(1, 3))
image(t(dataMatrixOrdered)[, nrow(dataMatrixOrdered):1])
plot(svd2$v[, 1], xlab = "Column", ylab = "First right singular vector", pch = 19)
plot(svd2$v[, 2], xlab = "Column", ylab = "Second right singular vector", pch = 19)
```

![plot of chunk unnamed-chunk-55](figure/unnamed-chunk-55.png) 

The first figure flip flops low/high, but also first 5 values are lower than second 5. In second figure, the patterns are flipped. Together they explain most of the variation in the matrix.

d and variance explained
------------------------

```r
svd2 <- svd(scale(dataMatrixOrdered))
par(mfrow = c(1, 2))
plot(svd2$d, xlab = "Column", ylab = "Singular value", pch = 19)
plot(svd2$d^2/sum(svd1$d^2), xlab = "Column", ylab = "Percent of variance explained", 
    pch = 19)
```

![plot of chunk unnamed-chunk-56](figure/unnamed-chunk-56.png) 


We can see that first and second values explain most of the variance. This would suggest that there are two patterns in the data set but they aren't necessarily the two patterns we observed in singular vectors. Each of the singular vectors may represent multiple patterns mashed together.

fast.svd function {corpcor}
---------------------------
* params: m, tol

```r
bigMatrix <- matrix(rnorm(10000 * 40), nrow = 10000)
system.time(svd(scale(bigMatrix)))
```

```
##    user  system elapsed 
##    0.29    0.02    0.43
```


```r
library(corpcor)
# fast.svd only calculates singular values/vectors for values above the
# tolerance, this way it calculates all
system.time(fast.svd(scale(bigMatrix), tol = 0))
```

```
##    user  system elapsed 
##    0.22    0.05    0.27
```


Missing values
--------------
SVD cannot be performed on missing values, 19/25.
One option is to impute those values

Imputing {impute}
-----------------
```
source("http://bioconductor.org/biocLite.R")
biocLite("impute")
then install from directory
to cite: citation("impute")
```
There's a bunch of ways but for exploratory analysis use impute package. knn approach

```r
library(impute)
dataMatrix2 <- dataMatrixOrdered
dataMatrix2[sample(1:100, size = 40, replace = F)] <- NA
dataMatrix2 <- impute.knn(dataMatrix2)$data
svd1 <- svd(scale(dataMatrixOrdered))
svd2 <- svd(scale(dataMatrix2))
par(mfrow = c(1, 2))
plot(svd1$v[, 1], pch = 19)
plot(svd2$v[, 1], pch = 19)
```

![plot of chunk unnamed-chunk-59](figure/unnamed-chunk-59.png) 

Compared to the complete data set, they're very similar, however if the dataset is missing a large number of data, it may not always work.

Face example
-------------
21/25
Advanced data analysis from an elementary point of view
Elements of statistical learning
