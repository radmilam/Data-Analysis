#Integer (L)
x = 1L
y = 1
class(x) #integer
class(y) #numeric

#Logical
TRUE
FALSE

#Vectors
# same class
heights = c(188.2, 182, 193)
names = c('jeff', 'roger', 'andrew', 'brian')

#lists
mylist = list(heights=heights, firstnames=names)
mylist
mylist$heights
mylist$firstnames

#matrices
#vectors with multiple dimensions
#left to right by row, 2 rows
mymatrix = matrix(c(1, 2, 3, 4), byrow=T, nrow=2)
mymatrix

#data frames
#multiple vectors possibly of different class, same length
df = data.frame(heights=c(heights, 199), firstnames=names)
df

#factors
#qualitative variables that can be included in models
smoker = c('yes', 'no', 'yes', 'yes')
smokerFactor = as.factor(smoker)
smokerFactor

#missing values - NA
vector1 = c(199.2, 291, 192.5, NA)
is.na(vector1)

#subsetting
heights = c(heights, 192.3)
df = data.frame(heights=heights, firstNames=names)
# just first value of heights
heights[1]
# indices
heights[c(1, 2, 4)]
#first row, and columns 1 to 2
df[1, 1:2]
df$firstNames
df[df$firstNames=='jeff']
df[df$heights < 190,]


