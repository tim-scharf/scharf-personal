require(data.table)
require(xgboost)
require(doMC)
source('funx.R')
##  takes a matrix X
##  fold_id vector fold_id
##  scalar fold
##  factor y with class labels

X <- makeMat('train.csv')
#Xtest <- makeMat('test.csv')

y  <- as.numeric(readRDS('y'))-1
num_classes  <- length(unique(y))
idx <- readRDS('meta_idx')
## build XGB mats
dtrain  <-   xgb.DMatrix(X[idx,],label = y[idx])
dvalid  <-   xgb.DMatrix(X[-idx,],label = y[-idx])

nrounds = 1000
max_depth = c(4,5,6,7,8,9,10)
eta = c(.1)
gamma = c(0,.25,.5,.75,1)
min_child_weight = c(1,2,3,4,5,6)
H <- expand.grid(max_depth,eta,gamma,min_child_weight)
colnames(H) <- c('max_depth','eta','gamma','min_child_wt')
eval_trees <- seq(100, nrounds,by =25)

scores <- matrix(0,ncol= length(eval_trees), nrow = dim(H)[1])

for(i in 1:nrow(H)){
  cat('workin on model #',i,'/',nrow(H),'\n')
  print(H[i,])
  
  #update param with Hypers from H
  param = list( 
    objective  =  'multi:softprob',
    eval_metric = 'mlogloss',
    max.depth  = H[i,1], 
    eta  =  H[i,2],
    gamma = H[i,3],
    min_child_weight = H[i,4],
    subsample  =  .5,
    colsample_bytree=1,
    num_class = 9
  )
  
  
  start = proc.time()[3]
  model <- xgb.train(params=param,
                     dtrain,
                     nrounds=1000)
  
  took <- proc.time()[3]-start
  cat('took',took,'secs\n') 
  
  p <- lapply(eval_trees, function(n) matrix( predict(model,newdata = dvalid, ntreelimit=n), ncol=9,byrow=T))
  scores[i,] <- sapply(p,multi_logLoss,truth=y[-idx])
  
  matplot(t(scores),type='l',ylim=c(.45,.5))
  saveRDS(scores,'scores')



}

 
min( as.numeric(cv[[11]]$test.mlogloss.mean))



# 
# history2 <- xgb.cv(params=param,xgb.DMatrix(X,label =y),nrounds=1000,nfold=16)
# trainerr <- as.numeric(history2$train.mlogloss.mean)
# testerr <- as.numeric(history2$test.mlogloss.mean)
# plot(testerr,ylim = c(.49,.52),pch =19,col='red',cex=.5)
# points(testerr,col='blue',pch=19)
# title('withNTRPY')
# abline(h=min(testerr))

# junk

#############################################################

preds <- lapply(models,function(m) matrix(predict(m,newdata=dvalid,ntreelimit=750),ncol=num_classes,byrow=T)) 
preds_raw <- lapply(models,function(m) matrix(predict(m,newdata=dvalid,ntreelimit=750,outputmargin=T),ncol=num_classes,byrow=T)) 
scores <- lapply(preds,multi_logLoss,truth=y[-idx])

P <- Reduce('+',preds)/length(preds)
P_raw <- Reduce('+',preds_raw)/length(preds_raw)
colnames(P) <- paste0('xgb',1:9)

score_avg  <- signif(multi_logLoss(P,y[-idx]),5)

I = xgb.importance(colnames(X), model=models[[1]]);I #takes a while

attr(P,'param') <- param

saveRDS(P,file.path('meta_dir',paste('xgb',score_avg,sep='_')))

history2 <- xgb.cv(params=param,data=dtrain,nrounds=1000,nfold=10)
trainerr <- as.numeric(history2$train.mlogloss.mean)
testerr <- as.numeric(history2$test.mlogloss.mean)
plot(testerr,ylim = c(.49,.52),pch =19,col='red',cex=.5)
points(testerr,col='blue',pch=19)
title('withNTRPY')
abline(h=min(testerr))

