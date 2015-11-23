##

require(e1071)
require(data.table)
require(doMC)
registerDoMC(8)
source('funx.R')

X      <- log1p(makeMat('train.csv'))
X_test <- log1p(makeMat('test.csv'))

y <- readRDS('y')
n_folds  = 8
folds <- sample(n_folds,length(y),replace = T)


models = foreach(i = 1:n_folds)%dopar%{
idx  <- which(folds != i)
svm1 <- svm(x = X[idx,], y= y[idx],
            scale =T,
            type = 'C-classification',
            kernel = 'linear',
            cost = .1,
            probability =T)
svm1
}


preds  <- foreach(i = 1:n_folds)%dopar%
{
  test_idx  <- which(folds == i)  
  predict(models[[i]], newdata = X[test_idx,], probability = T, decision.values = T)
}
  
test_preds  <- foreach(i = 1:n_folds)%dopar%
{
  predict(models[[i]],newdata = X_test,probability = T, decision.values = T)
}


select = 'dec'
P <- matrix(0,nrow=dim(X)[1],ncol= ncol(attr(preds[[1]], select)))
for(i in 1:n_folds){ P[folds==i,] <- attr(preds[[i]], select) }

P_test <- lapply(test_preds,function(p)  attr(p, select))
P_test <- Reduce('+',P_test)/n_folds



L = list(fold = P, pred = P_test)
saveRDS(L,file = 'BLENDER/svm_binary')
