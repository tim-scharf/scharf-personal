# rf



source('funx.R')
require(randomForest)
require(doMC)
registerDoMC(4)



X <- makeMat('train.csv')
X_test <- makeMat('test.csv')
y <- readRDS('y')


ntree=500
n_folds = 8
m_per_fold = 12
folds <- list()

idx = sample(n_folds,length(y),replace=T)



## run loops
for(i in 1:n_folds){
train_idx <- which(idx!=i)
test_idx  <- which(idx==i)

models  <- foreach(m = 1:m_per_fold)%dopar%
  {
               randomForest(x= X[train_idx,],
               y = y[train_idx],
               ntree = ntree,
               mtry = 15,
               sampsize = 10000,
               keep.forest=T,
               do.trace=50,
               nodesize=1)
}   
folds[[i]] <- models
print(i)
}







preds = list()
test_preds = list()
for(i in 1:n_folds)
{
train_idx <- which(idx!=i)
test_idx  <- which(idx==i)
P <- mclapply(folds[[i]],function(rf) predict(rf,newdata = X[test_idx,],type = 'prob'),mc.cores=8)
P_test <- mclapply(folds[[i]],function(rf) predict(rf,newdata = X_test,type = 'prob'),mc.cores=8)

preds[[i]] <- Reduce('+',P)/length(P)
test_preds[[i]] <- Reduce('+',P_test)/length(P_test)
}



P <- matrix(0,nrow=dim(X)[1],ncol= length(unique(y)))
for(i in 1:n_folds){ P[idx==i,] <- preds[[i]] }

P_test <- Reduce('+',test_preds)/length(test_preds)

L = list(fold_raw = P, pred_raw = P_test)
saveRDS(L,file= 'META_RAW/rf')



