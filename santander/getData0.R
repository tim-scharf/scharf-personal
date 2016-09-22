# get data
require(data.table)
require(Matrix)
require(xgboost)
require(methods)
require(utils)
require(FastImputation)
require(feather)
require(bit64)

setwd('~/repos/scharf-personal/santander/')

X0 <- fread('data/train.csv')
X1 <- fread('data/test.csv')



train_idx <- which(!is.na(X$target))
test_idx <- which(is.na(X$target))

fac_cols  <- names(X)[sapply(X,is.character)]
num_cols <- setdiff(data_cols,fac_cols)

MFAC <- treat_factors(X,fac_cols = fac_cols,max_cat = 2**20)


Xmed <- replaceNA_med(X[,num_cols,with=F])
X999 <- replaceNA(X[,num_cols,with=F],-999)

M999 <- as(as.matrix(X999), "sparseMatrix")
Mmed <- as(as.matrix(Xmed), 'sparseMatrix')

M <- cBind(M999,MFAC)
M_med <- cbind(Mmed,MFAC)

Xtrain <- M_med[train_idx,]
Xtest <- M_med[test_idx,]




y <- X[train_idx,target]

attr(Xtrain,'missing') <- ('no_missing')
saveRDS(Xtrain,'data/Xtrain_median_imp.rds')
saveRDS(Xtest,'data/Xtest_median_imp.rds')
saveRDS(y,'data/y.rds')



