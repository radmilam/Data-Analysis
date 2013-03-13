Week 2
======

Structure of Data Analysis
---------------------------

### Steps in data analysis
* Define the question
 - sci or biz question that you want answered
* Define the ideal data set
 - ideal data set
* Determine what data you can access
* Obtain the data
* Clean the data
* Exploratory data analysis
 - understand quirks of data set
* Statistical prediction/modeling
* Interpret results
 - what the predictions mean
* Challenge results
 - what potential failings of model are
* Synthesize/write up results
 - don't include every step performed
* Create reproducible code

### Defining a question
* Biz or sci question
* Type of data collected
* Applied stats to answer question
* More formal, theoretical description of data analysis

### Spam example


```r
library(kernlab)
data(spam)
dim(spam)
```

```
## [1] 4601   58
```


### Subsamplig our data set - generate a test and training set (prediction):

```r
set.seed(3435)
trainIndicator = rbinom(4601, size = 1, prob = 0.5)
```

trainIndicator will be:
 - 1 if part of training set
 - 0 if part of test set

generating binomial random variables of size 1 (1 head flip), fair coin (prob=0.5)

4601 - (emails in database)

```r
table(trainIndicator)
```

```
## trainIndicator
##    0    1 
## 2314 2287
```



```r
trainSpam = spam[trainIndicator == 1, ]
testSpam = spam[trainIndicator == 0, ]
dim(trainSpam)
```

```
## [1] 2287   58
```


### Exploratory data analysis
names - tells us names of the columns, in this case names of the variables in the data frame:
* num000, fraction of time that number, 000, appears
* words - fraction of time that word appears
* camel case words, like charSquarebracket
* type - spam or not spam, last column in data frame, what we're trying to predict.


```r
names(trainSpam)
```

```
##  [1] "make"              "address"           "all"              
##  [4] "num3d"             "our"               "over"             
##  [7] "remove"            "internet"          "order"            
## [10] "mail"              "receive"           "will"             
## [13] "people"            "report"            "addresses"        
## [16] "free"              "business"          "email"            
## [19] "you"               "credit"            "your"             
## [22] "font"              "num000"            "money"            
## [25] "hp"                "hpl"               "george"           
## [28] "num650"            "lab"               "labs"             
## [31] "telnet"            "num857"            "data"             
## [34] "num415"            "num85"             "technology"       
## [37] "num1999"           "parts"             "pm"               
## [40] "direct"            "cs"                "meeting"          
## [43] "original"          "project"           "re"               
## [46] "edu"               "table"             "conference"       
## [49] "charSemicolon"     "charRoundbracket"  "charSquarebracket"
## [52] "charExclamation"   "charDollar"        "charHash"         
## [55] "capitalAve"        "capitalLong"       "capitalTotal"     
## [58] "type"
```


We can `head` command to see what these variables look like
```
head(trainSpam)
```
### Summaries

```r
table(trainSpam$type)
```

```
## 
## nonspam    spam 
##    1381     906
```


### Plots

```r
plot(trainSpam$capitalAve ~ trainSpam$type)
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7.png) 


easier to see difference with log

```r
plot(log10(trainSpam$capitalAve + 1) ~ trainSpam$type)
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8.png) 


### Relationship between predictions

```r
plot(log10(trainSpam[, 1:4] + 1))
```

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 


**Clustering** (hierarhical)

Variables that have the same patterns are put close together.

```r
hCluster = hclust(dist(t(trainSpam[, 1:57])))
plot(hCluster)
```

![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10.png) 


### New clustering

```r
hClusterUpdated = hclust(dist(t(log10(trainSpam[, 1:55] + 1))))
plot(hClusterUpdated)
```

![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-11.png) 


### Statistical prediction/modeling

Take 55 variables that correspond to the fraction of time a word, number or character appear in an email.


```r
trainSpam$numType = as.numeric(trainSpam$type) - 1
costFunction = function(x, y) {
    sum(x != (y > 0.5))
}
cvError = rep(NA, 55)
library(boot)
# loop over the 55 variables
for (i in 1:55) {
    lmFormula = as.formula(paste("numType~", names(trainSpam)[i], sep = ""))
    # fit a predictive model that relates whether the email is ham or spam to
    # the fraction of times that character or word appears in an email.
    glmFit = suppressWarnings(glm(lmFormula, family = "binomial", data = trainSpam))
    # calculate error rates for these models
    cvError[i] = suppressWarnings(cv.glm(trainSpam, glmFit, costFunction, 2)$delta[2])
}
# pick the model with lowest error rate
which.min(cvError)
```

```
## [1] 53
```


Pick name of the model with lowest error rate

```r
names(trainSpam)[which.min(cvError)]
```

```
## [1] "charDollar"
```

If there's a lot of dollar signs in an email, it's probably spam.

### Get a measure of uncertainty


```r
# Calculate predicted values for the model that relate the type of the
# email: spam/ham, the fraction of time `$` appears in an email
predictionModel = glm(numType ~ charDollar, family = "binomial", data = trainSpam)
```

```
## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred
```

```r
# apply that model to the test set, the one we left out when building
# training set, so we can evaluate how well the prediction model works on
# a new data set
predictionTest = predict(predictionModel, testSpam)
predictedSpam = rep("nonspam", dim(testSpam)[1])
predictedSpam[predictionModel$fitted > 0.5] = "spam"
# table that shows the difference in results from our model and test set,
# we can see how often we made an error.
table(predictedSpam, testSpam$type)
```

```
##              
## predictedSpam nonspam spam
##       nonspam    1346  458
##       spam         61  449
```


Error rate:

```r
(61 + 458)/(1346 + 458 + 61 + 449)
```

```
## [1] 0.2243
```


### Interpret results

* Language:
 * Describes - descriptive analysis
 * Correlates with/associated with - inference
 * leads to/causes - causal analysis
 * predicts - prediction analysis

### Challenge results
Able to explain to others wheter (you think) analysis is strong or weak and help people make prediction based on the analysis.

Organizing Data Analysis
------------------------
* Exploratory figures - files you make for yourself, not necessarily shown to anybody
* raw scripts - not production quality
* final scripts - reproduce conclusion
* text of analysis differs from rmd files
* raw scripts - not final, can include date, maybe be discarted or sumarized in readme

Getting Data
============

Get/set working directory
--------------------------

What working directory are we in?
```
getwd()
```

setting working directory
```
setwd('/home/person/code/_R')
```
in windows
```
setwd("d:\\code\\_R\\someplace")
```

relative paths
```
setwd("./data")
```

#### getting data from internet

```
download.file()
```

### Ex: Baltimore camera data
[link](https://data.baltimorecity.gov/Transportation/Baltimore-Fixed-Speed-Cameras/dz54-2aru)


```r
fileUrl <- "https://data.baltimorecity.gov/api/views/dz54-2aru/rows.csv?accessType=DOWNLOAD"
# parameter method='curl' needed for mac for https
download.file(fileUrl, destfile = "./data/cameras.csv")
```

```
## Error: unsupported URL scheme
```

```r
list.files("./data")
```

```
## [1] "cameras.csv"
```


```r
dateDownloaded <- date()
dateDownloaded
```

```
## [1] "Mon Feb 04 00:22:47 2013"
```


```r
cameraData <- read.table("./data/cameras.csv", sep = ",", header = TRUE)
head(cameraData)
```

```
##                          address direction      street  crossStreet
## 1       S CATON AVE & BENSON AVE       N/B   Caton Ave   Benson Ave
## 2       S CATON AVE & BENSON AVE       S/B   Caton Ave   Benson Ave
## 3 WILKENS AVE & PINE HEIGHTS AVE       E/B Wilkens Ave Pine Heights
## 4        THE ALAMEDA & E 33RD ST       S/B The Alameda      33rd St
## 5        E 33RD ST & THE ALAMEDA       E/B      E 33rd  The Alameda
## 6        ERDMAN AVE & N MACON ST       E/B      Erdman     Macon St
##                 intersection                      Location.1
## 1     Caton Ave & Benson Ave (39.2693779962, -76.6688185297)
## 2     Caton Ave & Benson Ave (39.2693157898, -76.6689698176)
## 3 Wilkens Ave & Pine Heights  (39.2720252302, -76.676960806)
## 4     The Alameda  & 33rd St (39.3285013141, -76.5953545714)
## 5      E 33rd  & The Alameda (39.3283410623, -76.5953594625)
## 6         Erdman  & Macon St (39.3068045671, -76.5593167803)
```


with csv
```
cameraData <- read.csv('./data/cameras.csv')
head(cameraData)
```

### Excel Files
```
read.xlsx()
read.xlsx2()
requires {xlsx package}
```

### Picking files
```
cameradata <- read.csv(file.choose())
```

###Connections to files
```
readLines()
```

```
con <- file("./data/cameras.csv", "r")
cameraData <- read.csv(con)
close(con)
head(cameraData)
```

```
con <- url("http://simplystatistics.org", "r")
simplyStats <- readLines(con)
close(con)
head(simplyStats)
```

### Reading JSON files {RJSONIO}

```
library(RJSONIO)
fileUrl <- "https://data.baltimorecity.gov/api/views/dz54-2aru/rows.json?accessType=DOWNLOAD"
download.file(fileUrl, destfile="./data/camera.json")
con = file("./data/camera.json")
jsonCamera = fromJson(con)
close(con)
head(jsonCamera)
```
```
$meta
$meta$View
$meta$view$id
```

### Writing data - write.table()
```
comeraData <- read.csv("./data/cameras.csv")
tmpData <- cameraData[,-1]
write.table(tmpData, file="./data/camerasModified.csv", sep=",")
cameraData2 <- read.csv("./data/camerasModified.csv")
head(cameraData2)
```

### Writing data - save(), save.image()
```
cameraData <- read.csv("./data/cameras.csv")
tmpData <- cameraData[,-1]
save(tmpData, cameraData, file="./data/cameras.rda")
```

# reading saved data - load()
```
# removes every variable loaded into R
rm(list=ls())
ls()
```

```
load("./data/cameras.rda")
```

### paste() and paste0()
* `paste0` same as `paste`, but with `sep=""`

```
for(i in 1:5){
  fileName = paste0("./data", i, ".csv")
  print(fileName)
}

```

### Getting data off webpages {XML}
```
library(XML)
con = url("http://scholar.google.com/citations?user=HI-I6C0AAAAJ&hl=en")
htmlCode = readLines(con)
close(con)
htmlCode
```

#### Easier
```
url <- "http://scholar.google.com/citations?user=HI-I6C0AAAAJ&hl=en"
html3 <- htmlTreeParse(url)
xpathSApply(html3, "//title", xmlValue)
xpathSApply(html3, "//td[@id='col-citeby']", xmlValue)
```
### Further resources
* httr - simplifies working with http
* RMySQL
* bigmemory - **for data larger than RAM**
* RHadoop - interfacing with hadoop
* foreign - loading data from SAS, SPSS, Octave

Summarizing Data
================
### Earthquake Data

```r
fileUrl = "http://earthquake.usgs.gov/earthquakes/catalogs/eqs7day-M1.txt"
download.file(fileUrl, destfile = "./data/earthquakeData.csv")
dataDownloaded <- date()
dateDownloaded
```

```
## [1] "Sun Feb 03 16:59:55 2013"
```


```r
eData <- read.csv("./data/earthquakeData.csv")
head(eData)
```

```
##   Src     Eqid Version                               Datetime   Lat    Lon
## 1  nc 71934381       1 Sunday, February  3, 2013 14:20:23 UTC 38.76 -122.7
## 2  ci 15280961       0 Sunday, February  3, 2013 14:18:03 UTC 35.84 -117.7
## 3  ak 10649991       1 Sunday, February  3, 2013 14:17:24 UTC 59.81 -152.0
## 4  nc 71934371       0 Sunday, February  3, 2013 14:16:06 UTC 38.84 -122.8
## 5  nc 71934356       0 Sunday, February  3, 2013 14:00:56 UTC 38.81 -122.8
## 6  ak 10649984       1 Sunday, February  3, 2013 13:44:18 UTC 63.46 -148.9
##   Magnitude Depth NST              Region
## 1       2.2   2.3  43 Northern California
## 2       2.2   1.0  46  Central California
## 3       2.0  12.3  10     Southern Alaska
## 4       1.2   1.7  14 Northern California
## 5       1.1   2.7  24 Northern California
## 6       1.3   9.5   7      Central Alaska
```



```r
# see if the correct number of variables was loaded
dim(eData)
```

```
## [1] 987  10
```

```r
# see if you get the expected names
names(eData)
```

```
##  [1] "Src"       "Eqid"      "Version"   "Datetime"  "Lat"      
##  [6] "Lon"       "Magnitude" "Depth"     "NST"       "Region"
```

```r
nrow(eData)
```

```
## [1] 987
```


See if some variables went out of expected range, are in different units


```r
quantile(eData$Lat)
```

```
##     0%    25%    50%    75%   100% 
## -61.32  34.18  38.82  60.11  67.76
```


```r
summary(eData)
```

```
##       Src            Eqid        Version   
##  ak     :354   00401044:  1   2      :402  
##  nc     :244   00401050:  1   1      :186  
##  ci     :150   00401055:  1   0      :162  
##  us     :129   00401057:  1   3      : 66  
##  pr     : 25   00401185:  1   4      : 31  
##  uw     : 22   00401230:  1   6      : 30  
##  (Other): 63   (Other) :981   (Other):110  
##                                      Datetime        Lat       
##  Monday, January 28, 2013 20:37:09 UTC   :  2   Min.   :-61.3  
##  Saturday, February  2, 2013 03:39:51 UTC:  2   1st Qu.: 34.2  
##  Wednesday, January 30, 2013 16:36:59 UTC:  2   Median : 38.8  
##  Friday, February  1, 2013 00:03:31 UTC  :  1   Mean   : 40.8  
##  Friday, February  1, 2013 00:09:20 UTC  :  1   3rd Qu.: 60.1  
##  Friday, February  1, 2013 00:12:09 UTC  :  1   Max.   : 67.8  
##  (Other)                                 :978                  
##       Lon         Magnitude        Depth            NST       
##  Min.   :-180   Min.   :1.00   Min.   :  0.0   Min.   :  0.0  
##  1st Qu.:-149   1st Qu.:1.30   1st Qu.:  3.8   1st Qu.: 11.0  
##  Median :-123   Median :1.70   Median : 10.0   Median : 19.0  
##  Mean   :-105   Mean   :2.09   Mean   : 27.8   Mean   : 33.6  
##  3rd Qu.:-117   3rd Qu.:2.30   3rd Qu.: 28.1   3rd Qu.: 36.0  
##  Max.   : 180   Max.   :6.90   Max.   :585.2   Max.   :608.0  
##                                                               
##                  Region   
##  Central Alaska     :159  
##  Northern California:151  
##  Central California : 96  
##  Southern California: 95  
##  Southern Alaska    : 90  
##  Santa Cruz Islands : 33  
##  (Other)            :363
```



```r
class(eData)
```

```
## [1] "data.frame"
```


Check if variables in each row are good

```r
sapply(eData[1, ], class)
```

```
##       Src      Eqid   Version  Datetime       Lat       Lon Magnitude 
##  "factor"  "factor"  "factor"  "factor" "numeric" "numeric" "numeric" 
##     Depth       NST    Region 
## "numeric" "integer"  "factor"
```



```r
unique(eData$Src)
```

```
##  [1] nc ci ak hv us pr uw mb nn se uu nm
## Levels: ak ci hv mb nc nm nn pr se us uu uw
```



```r
length(unique(eData$Src))
```

```
## [1] 12
```


Table of **qualitative** variables, quantitative table will be large

```r
table(eData$Src)
```

```
## 
##  ak  ci  hv  mb  nc  nm  nn  pr  se  us  uu  uw 
## 354 150  18   6 244   4  19  25   3 129  13  22
```


#### Relationships

```r
table(eData$Src, eData$Version)
```

```
##     
##        0   1   2   3   4   5   6   7   8   9   A   B   C   E
##   ak   0 100 238  16   0   0   0   0   0   0   0   0   0   0
##   ci  70   2  73   3   2   0   0   0   0   0   0   0   0   0
##   hv   0   7   9   1   1   0   0   0   0   0   0   0   0   0
##   mb   0   1   5   0   0   0   0   0   0   0   0   0   0   0
##   nc  67  67  61  36   9   3   1   0   0   0   0   0   0   0
##   nm   0   0   0   0   0   0   0   0   0   0   3   1   0   0
##   nn   0   0   0   0   0   0   0   0   0  19   0   0   0   0
##   pr  25   0   0   0   0   0   0   0   0   0   0   0   0   0
##   se   0   0   0   0   0   0   0   0   0   0   3   0   0   0
##   us   0   0   1   6  13  19  29  20  20  11   5   1   1   3
##   uu   0   0   6   0   6   1   0   0   0   0   0   0   0   0
##   uw   0   9   9   4   0   0   0   0   0   0   0   0   0   0
```


Missing data or does some characteristic exists

```r
eData$Lat[1:10] > 40
```

```
##  [1] FALSE FALSE  TRUE FALSE FALSE  TRUE FALSE FALSE  TRUE FALSE
```



```r
any(eData$Lat[1:10] > 40)
```

```
## [1] TRUE
```



```r
all(eData$Lat[1:10] > 40)
```

```
## [1] FALSE
```


#### Subsetting


```r
head(eData[eData$Lat > 0 & eData$Lon > 0, c("Lat", "Lon")])
```

```
##       Lat    Lon
## 17  36.50  70.79
## 70  17.26 147.21
## 112 29.41 141.94
## 128 42.81 143.08
## 129 46.51  14.64
## 145 34.26  24.98
```


### Peer review data

```r
fileUrl1 <- "http://dl.dropbox.com/u/7710864/data/reviews-apr29.csv"
fileUrl2 <- "http://dl.dropbox.com/u/7710864/data/solutions-apr29.csv"
download.file(fileUrl1, destfile = "./data/reviews.csv")
download.file(fileUrl2, destfile = "./data/solutions.csv")
reviews <- read.csv("./data/reviews.csv")
solutions <- read.csv("./data/solutions.csv")
head(reviews, 2)
```

```
##   id solution_id reviewer_id      start       stop time_left accept
## 1  1           3          27 1304095698 1304095758      1754      1
## 2  2           4          22 1304095188 1304095206      2306      1
```


```r
head(solutions, 2)
```

```
##   id problem_id subject_id      start       stop time_left answer
## 1  1        156         29 1304095119 1304095169      2343      B
## 2  2        269         25 1304095119 1304095183      2329      C
```


#### Find if there are missing values

```r
is.na(reviews$time_left[1:10])
```

```
##  [1] FALSE FALSE FALSE FALSE FALSE FALSE FALSE  TRUE FALSE FALSE
```


#### total number of NAs

```r
sum(is.na(reviews$time_left))
```

```
## [1] 84
```



```r
table(is.na(reviews$time_left))
```

```
## 
## FALSE  TRUE 
##   115    84
```


When looking at a table, R hides NAs by default, to enable
```
table(reviews$time_left, useNA="ifany")
```

#### Summarizing rows/columns
```
rowSums()
rowMeans()
colSums()
colMeans()
```
May need to set `na.rm=TRUE` as a param to the above functions to ignore NA values.

Data Munging Basics
===================

Fixing character vectors - tolower(), toupper()
-----------------------------------------------

```r
cameraData <- read.csv("./data/cameras.csv")
names(cameraData)
```

```
## [1] "address"      "direction"    "street"       "crossStreet" 
## [5] "intersection" "Location.1"
```



```r
tolower(names(cameraData))
```

```
## [1] "address"      "direction"    "street"       "crossstreet" 
## [5] "intersection" "location.1"
```


strsplit()
----------

```r
splitNames = strsplit(names(cameraData), "\\.")
splitNames[[5]]
```

```
## [1] "intersection"
```



```r
splitNames[[6]]
```

```
## [1] "Location" "1"
```



```r
splitNames[[6]][1]
```

```
## [1] "Location"
```



```r
firstElement <- function(x) {
    x[1]
}
sapply(splitNames, firstElement)
```

```
## [1] "address"      "direction"    "street"       "crossStreet" 
## [5] "intersection" "Location"
```


Peer review experiment data
---------------------------

```r
fileUrl1 <- "http://dl.dropbox.com/u/7710864/data/reviews-apr29.csv"
fileUrl2 <- "http://dl.dropbox.com/u/7710864/data/solutions-apr29.csv"
download.file(fileUrl1, destfile = "./data/reviews.csv")
download.file(fileUrl2, destfile = "./data/solutions.csv")
reviews <- read.csv("./data/reviews.csv")
solutions <- read.csv("./data/solutions.csv")
head(reviews, 2)
```

```
##   id solution_id reviewer_id      start       stop time_left accept
## 1  1           3          27 1304095698 1304095758      1754      1
## 2  2           4          22 1304095188 1304095206      2306      1
```


Fixing character vectors - sub(), gsub()
----------------------------------------

```r
names(reviews)
```

```
## [1] "id"          "solution_id" "reviewer_id" "start"       "stop"       
## [6] "time_left"   "accept"
```

```r
sub("_", "", names(reviews), )
```

```
## [1] "id"         "solutionid" "reviewerid" "start"      "stop"      
## [6] "timeleft"   "accept"
```

```r
gsub("_", "", names(reviews), )
```

```
## [1] "id"         "solutionid" "reviewerid" "start"      "stop"      
## [6] "timeleft"   "accept"
```


Quantitative variables in ranges - cut()
----------------------------------------

To look at ranges, precision of variables

```r
reviews$time_left[1:10]
```

```
##  [1] 1754 2306 2192 2089 2043 1999 2130   NA 1899 2024
```


```r
timeRanges <- cut(reviews$time_left, seq(0, 3600, by = 600))
timeRanges[1:10]
```

```
##  [1] (1.2e+03,1.8e+03] (1.8e+03,2.4e+03] (1.8e+03,2.4e+03]
##  [4] (1.8e+03,2.4e+03] (1.8e+03,2.4e+03] (1.8e+03,2.4e+03]
##  [7] (1.8e+03,2.4e+03] <NA>              (1.8e+03,2.4e+03]
## [10] (1.8e+03,2.4e+03]
## 6 Levels: (0,600] (600,1.2e+03] (1.2e+03,1.8e+03] ... (3e+03,3.6e+03]
```

```r
class(timeRanges)
```

```
## [1] "factor"
```

```r
table(timeRanges, useNA = "ifany")
```

```
## timeRanges
##           (0,600]     (600,1.2e+03] (1.2e+03,1.8e+03] (1.8e+03,2.4e+03] 
##                30                32                25                28 
##   (2.4e+03,3e+03]   (3e+03,3.6e+03]              <NA> 
##                 0                 0                84
```


cut2() from {Hmisc}
------
Look at quantiles, in this case 6 ranges

```r
library(Hmisc)
```

```
## Loading required package: survival
```

```
## Loading required package: splines
```

```
## Hmisc library by Frank E Harrell Jr
## 
## Type library(help='Hmisc'), ?Overview, or ?Hmisc.Overview') to see overall
## documentation.
## 
## NOTE:Hmisc no longer redefines [.factor to drop unused levels when
## subsetting.  To get the old behavior of Hmisc type dropUnusedLevels().
```

```
## Attaching package: 'Hmisc'
```

```
## The following object(s) are masked from 'package:survival':
## 
## untangle.specials
```

```
## The following object(s) are masked from 'package:base':
## 
## format.pval, round.POSIXt, trunc.POSIXt, units
```

```r
timeRanges <- cut2(reviews$time_left, g = 6)
table(timeRanges, useNA = "ifany")
```

```
## timeRanges
## [  22, 384) [ 384, 759) [ 759,1150) [1150,1496) [1496,1909) [1909,2306] 
##          20          19          19          19          19          19 
##        <NA> 
##          84
```


Adding an extra variable to data frame
---------------------------------------

```r
timeRanges <- cut2(reviews$time_left, g = 6)
reviews$timeRanges <- timeRanges
head(reviews, 2)
```

```
##   id solution_id reviewer_id      start       stop time_left accept
## 1  1           3          27 1304095698 1304095758      1754      1
## 2  2           4          22 1304095188 1304095206      2306      1
##    timeRanges
## 1 [1496,1909)
## 2 [1909,2306]
```


Merging data - merge()
----------------------
* Merges data frames

```r
names(reviews)
```

```
## [1] "id"          "solution_id" "reviewer_id" "start"       "stop"       
## [6] "time_left"   "accept"      "timeRanges"
```

```r
names(solutions)
```

```
## [1] "id"         "problem_id" "subject_id" "start"      "stop"      
## [6] "time_left"  "answer"
```

```r
mergedData <- merge(reviews, solutions, all = TRUE)
head(mergedData)
```

```
##   id      start       stop time_left solution_id reviewer_id accept
## 1  1 1304095119 1304095169      2343          NA          NA     NA
## 2  1 1304095698 1304095758      1754           3          27      1
## 3  2 1304095119 1304095183      2329          NA          NA     NA
## 4  2 1304095188 1304095206      2306           4          22      1
## 5  3 1304095127 1304095146      2366          NA          NA     NA
## 6  3 1304095276 1304095320      2192           5          28      1
##    timeRanges problem_id subject_id answer
## 1        <NA>        156         29      B
## 2 [1496,1909)         NA         NA   <NA>
## 3        <NA>        269         25      C
## 4 [1909,2306]         NA         NA   <NA>
## 5        <NA>         34         22      C
## 6 [1909,2306]         NA         NA   <NA>
```


If column names don't match

```r
mergedData2 <- merge(reviews, solutions, by.x = "solution_id", by.y = "id", 
    all = T)
head(mergedData2[, 1:6], 3)
```

```
##   solution_id id reviewer_id    start.x     stop.x time_left.x
## 1           1  4          26 1304095267 1304095423        2089
## 2           2  6          29 1304095471 1304095513        1999
## 3           3  1          27 1304095698 1304095758        1754
```


```r
reviews[1, 1:6]
```

```
##   id solution_id reviewer_id      start       stop time_left
## 1  1           3          27 1304095698 1304095758      1754
```


Sorting values - sort()
-----------------------

```r
mergedData2$reviewer_id[1:10]
```

```
##  [1] 26 29 27 22 28 22 29 23 25 29
```

```r
sort(mergedData2$reviewer_id)[1:10]
```

```
##  [1] 22 22 22 22 22 22 22 22 22 22
```


Ordering values - order()
-------------------------
Rearrange by particular value, give => list of vars to order, na.last, decreasing


```r
mergedData2$reviewer_id[1:10]
```

```
##  [1] 26 29 27 22 28 22 29 23 25 29
```

```r
order(mergedData2$reviewer_id)[1:10]
```

```
##  [1]  4  6 14 22 23 24 27 32 37 39
```



```r
mergedData2$reviewer_id[order(mergedData2$reviewer_id)]
```

```
##   [1] 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22
##  [24] 22 22 22 22 22 22 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23
##  [47] 23 23 23 23 23 23 23 23 23 23 23 23 24 24 24 24 24 24 24 24 24 24 24
##  [70] 24 24 24 24 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25
##  [93] 25 25 25 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26
## [116] 26 26 26 26 26 26 26 27 27 27 27 27 27 27 27 27 27 27 27 27 27 27 27
## [139] 27 27 27 27 27 27 27 27 27 27 27 27 27 27 28 28 28 28 28 28 28 28 28
## [162] 28 28 28 28 28 28 28 28 28 28 28 28 28 28 28 28 28 29 29 29 29 29 29
## [185] 29 29 29 29 29 29 29 29 29 29 29 29 29 29 29 NA NA NA NA NA NA
```


Reordering a data frame
-----------------------

```r
head(mergedData2[, 1:6], 3)
```

```
##   solution_id id reviewer_id    start.x     stop.x time_left.x
## 1           1  4          26 1304095267 1304095423        2089
## 2           2  6          29 1304095471 1304095513        1999
## 3           3  1          27 1304095698 1304095758        1754
```


Sorted by reviewer_id then id

```r
sortedData <- mergedData2[order(mergedData2$reviewer_id, mergedData2$id), ]
head(sortedData[, 1:6], 3)
```

```
##    solution_id id reviewer_id    start.x     stop.x time_left.x
## 4            4  2          22 1304095188 1304095206        2306
## 14          14 12          22 1304095280 1304095301        2211
## 6            6 16          22 1304095303 1304095471        2041
```


Reshaping data - example
------------------------
From [paper](http://vita.had.co.nz/papers/tidy-data.pdf)

```r
misShaped <- as.data.frame(matrix(c(NA, 5, 1, 4, 2, 3), byrow = TRUE, nrow = 3))
names(misShaped) <- c("treatmentA", "treatmentB")
misShaped$people <- c("John", "Jane", "Mary")
misShaped
```

```
##   treatmentA treatmentB people
## 1         NA          5   John
## 2          1          4   Jane
## 3          2          3   Mary
```

This gives us observations in rows in variables columns.

melt() function in {reshape2} will reshape the data so that in each row we have a particular observation and in column a variable
* id.vars - which variable is an id for observation
* measure.vars - variable we're going to collect
variable.name

```r
library(reshape2)
melt(misShaped, id.vars = "people", varialbe.name = "treatment", value.name = "value")
```

```
##   people   variable value
## 1   John treatmentA    NA
## 2   Jane treatmentA     1
## 3   Mary treatmentA     2
## 4   John treatmentB     5
## 5   Jane treatmentB     4
## 6   Mary treatmentB     3
```


Data is modeled easier after this transform.
