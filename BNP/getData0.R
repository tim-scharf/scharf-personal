# get data
require(data.table)
setwd('~/repos/scharf-personal/BNP/')

X0 <- fread('~/data/BNP/train.csv')
X1 <- fread('~/data/BNP/test.csv')
fac_cols <- names(X0)[sapply(X0,is.character)]


