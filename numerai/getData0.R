require(data.table)
require(Matrix)
require(xgboost)
require(methods)
require(utils)

setwd('~/repos/scharf-personal/numerai/')

X0 <-  fread('data/numerai_training_data.csv')
X1 <-  fread('data/numerai_tournament_data.csv')

data_cols <- paste0('feature',1:21)


#z <- sapply(data_cols,function(col)  t.test(X0[,get(col)], X1[,get(col)]))




Xtrain <- as.matrix(X0[,mget(data_cols)])
Xtest <-  as.matrix(X1[,mget(data_cols)])
y <- X0[,target]

attr(Xtrain,'missing') <- ('no_missing')
saveRDS(Xtrain,'data/Xtrain.rds')
saveRDS(Xtest,'data/Xtest.rds')
saveRDS(as.numeric(y),'data/y.rds')



