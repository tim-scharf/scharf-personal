require(data.table)
require(xgboost)
require(Matrix)
source('funx.R')

## build XGB mats
dtrain  <- xgb.DMatrix(M[train_idx,], label = y[train_idx], base_margin = base[train_idx])
dvalid  <- xgb.DMatrix(M[-train_idx,],label = y[-train_idx], base_margin = base[-train_idx])


param = list( 
              objective  =  'reg:linear',
              eval_metric = 'rmse',
              max.depth  = 4, 
              eta  =  .025,
              gamma = .25,
              min_child_weight = 2,
              subsample  =  .7,
              colsample_bytree=.8,
              nthread=8              )


system.time(
  bst1 <- xgb.train(
    params = param,
    watchlist  = list(train_err=dtrain, valid = dvalid),
    data = dtrain,
    nrounds =1000,
    verbose = 1
  )
)


history2 <- xgb.cv(params=param,dtrain,nrounds=500,nfold=8, prediction=T)

trainerr <- as.numeric(history2$dt$train.rmse.mean)
testerr <- as.numeric(history2$test.rmse.mean)
plot(trainerr)
points(testerr,col='blue',pch=19)
title('withNTRPY')
abline(h=min(testerr))



p <- predict(bst1,dtrain)

p <- (exp(p))-1
p[p<0] <- 0

id = readRDS('id_full')

P = data.table(id=id[!train_idx],units=p)

write.table(P,file = 'xgb_first_exp',quote=F,sep=',', row.names=F)
I = xgb.importance(colnames(X), model=bst1)
xgb.plot.importance(I)

feat <- I$Feature[1:100]
idx = which(colnames(Xtrain)%in%feat )


