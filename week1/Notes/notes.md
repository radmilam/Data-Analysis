Review
======
 

```r
# Integer (L)
x = 1L
y = 1
# integer
class(x)
```

```
## [1] "integer"
```

```r
# numeric
class(y)
```

```
## [1] "numeric"
```


Logical

```r
TRUE
```

```
## [1] TRUE
```

```r
FALSE
```

```
## [1] FALSE
```



Vectors
same class

```r
heights = c(188.2, 182, 193)
names = c("jeff", "roger", "andrew", "brian")
```


lists

```r
mylist = list(heights = heights, firstnames = names)
mylist
```

```
## $heights
## [1] 188.2 182.0 193.0
## 
## $firstnames
## [1] "jeff"   "roger"  "andrew" "brian"
```

```r
mylist$heights
```

```
## [1] 188.2 182.0 193.0
```

```r
mylist$firstnames
```

```
## [1] "jeff"   "roger"  "andrew" "brian"
```


matrices
* vectors with multiple dimensions
* left to right by row, 2 rows

```r
mymatrix = matrix(c(1, 2, 3, 4), byrow = T, nrow = 2)
mymatrix
```

```
##      [,1] [,2]
## [1,]    1    2
## [2,]    3    4
```



data frames - multiple vectors possibly of different class, same length

```r
df = data.frame(heights = c(heights, 199), firstnames = names)
df
```

```
##   heights firstnames
## 1   188.2       jeff
## 2   182.0      roger
## 3   193.0     andrew
## 4   199.0      brian
```


factors - qualitative variables that can be included in models

```r
smoker = c("yes", "no", "yes", "yes")
smokerFactor = as.factor(smoker)
smokerFactor
```

```
## [1] yes no  yes yes
## Levels: no yes
```


missing values - NA

```r
vector1 = c(199.2, 291, 192.5, NA)
is.na(vector1)
```

```
## [1] FALSE FALSE FALSE  TRUE
```


subsetting

```r
heights = c(heights, 192.3)
df = data.frame(heights = heights, firstNames = names)
```


just first value of heights

```r
heights[1]
```

```
## [1] 188.2
```


indices

```r
heights[c(1, 2, 4)]
```

```
## [1] 188.2 182.0 192.3
```


first row, and columns 1 to 2

```r
df[1, 1:2]
```

```
##   heights firstNames
## 1   188.2       jeff
```

```r
df$firstNames
```

```
## [1] jeff   roger  andrew brian 
## Levels: andrew brian jeff roger
```

```r
df[df$firstNames == "jeff"]
```

```
##   heights
## 1   188.2
## 2   182.0
## 3   193.0
## 4   192.3
```

```r
df[df$heights < 190, ]
```

```
##   heights firstNames
## 1   188.2       jeff
## 2   182.0      roger
```


Simulation
==========
distributions
* rfoo functions generate data

```r
heights = rnorm(10, mean = 188, sd = 3)
```


function(n, size, prob)
* n - number of scenarios
* size - number of coins "flipped"
* prob - each coins is fair, number of heads is added up

```r
rbinom(10, size = 10, prob = 0.5)
```

```
##  [1] 5 2 4 5 8 5 4 7 4 4
```


densities - probability of X values being in a some ranges - function(x, mean=0, sd=1, log=FALSE) log units

```r
x = seq(from = 5, to = 5, length = 10)
```


calc normal density of those points

```r
normalDensity = dnorm(x, mean = 0, sd = 1)
round(normalDensity, 2)
```

```
##  [1] 0 0 0 0 0 0 0 0 0 0
```


normal density - function(x, size, prob, log=FALSE)

```r
x = seq(0, 10, by = 1)
binomialDensity = dbinom(x, size = 10, prob = 0.5)
round(binomialDensity, 2)
```

```
##  [1] 0.00 0.01 0.04 0.12 0.21 0.25 0.21 0.12 0.04 0.01 0.00
```



sampling - function(x, size, replace=FALSE, prob=NULL)

```r
heights = rnorm(10, mean = 188, sd = 3)
```


sample with replacement may sample the same value, draw one random value from vector of heights, then replaces that value in vector of heights and then draws a new random sample from among the 10 values

```r
sample(heights, size = 10, replace = T)
```

```
##  [1] 188.6 188.6 184.9 190.0 186.1 181.5 185.8 188.2 188.6 190.0
```


value removed from heights vector, and so forth, in this case the we end up with the same vector because sizes are the same

```r
sample(heights, size = 10, replace = F)
```

```
##  [1] 190.0 185.8 184.9 188.6 186.1 188.5 186.1 188.2 193.3 181.5
```


sampling in accordance with probabilities - 0.4 prob that first value sampled, etc

```r
probs = c(0.4, 0.3, 0.2, 0.1, 0, 0, 0, 0, 0, 0)
sample(heights, size = 10, replace = T, prob = probs)
```

```
##  [1] 181.5 188.6 181.5 188.2 188.6 188.6 188.6 188.6 181.5 188.6
```


setting seed - allows generating same random values

```r
set.seed(12345)
rnorm(5, mean = 0, sd = 1)
```

```
## [1]  0.5855  0.7095 -0.1093 -0.4535  0.6059
```


