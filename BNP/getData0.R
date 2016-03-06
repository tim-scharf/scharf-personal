# get data
require(data.table)
setwd('~/repos/scharf-personal/BNP/')
source('xgb_loop_binary.R')
source('gen_param_binary.R')
source('data_checks_binary.R')

X0 <- fread('~/data/BNP/train.csv')
X1 <- fread('~/data/BNP/test.csv')

data_cols <- paste0('v',1:131)
fac_cols  <- names(X0)[sapply(X0,is.character)]
num_cols <- setdiff(data_cols,fac_cols)

Xtrain <- as.matrix(X0[,num_cols,with=F])
Xtest <- as.matrix(X1[,num_cols,with=F])
y <- X0[,target]

xgb_loop_binary(Xtrain,y,Xtest, m = 1000)

