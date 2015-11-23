require(data.table)
require(xgboost)
require(doMC)
source('funx.R')
require(Metrics)

raw <- fread('train.csv')
X <- as.matrix(raw[,2:94,with=F])
mode(X) <- 'double'
y  <- as.numeric(readRDS('y'))-1

# gonna generate k * (k-1)/2 binary classification models
pairs <- t(combn(unique(y),2))

models <- list()
ooFold_P <- list()
cv <- list()

param = list( 
  objective  =  'binary:logistic',
  eval_metric = 'logloss',
  max.depth  = 5, 
  eta  =  .1,
  gamma = 0,
  min_child_weight = .5,
  subsample  =  .7,
  colsample_bytree=1,
  nrounds = 500
)


for(i in 1:nrow(pairs)){
  pair <- paste(as.character(pairs[i,]),collapse='_')  
  pair_idx <- which(y %in% pairs[i,])
  y_binary  <- as.numeric((y==pairs[i,1])[pair_idx])   # first col is positive case always
  dPairs <- xgb.DMatrix(X[pair_idx,],label = y_binary)
  

#get best trees to build
  check_n_Trees <- xgb.cv(params=param,dPairs,nrounds=param$nrounds,nfold=12,verbose = F)
  
  best_iter  <- which.min(as.numeric(check_n_Trees$test.logloss.mean))
  
  #store out of fold predictions for class pair
  pred <- xgb.cv(params=param,dPairs,nrounds=best_iter,nfold=12,prediction = T,verbose=F)$pred
  attr(pred,'param') <- param
  attr(pred,'nrounds') <- best_iter
  



    ith_models <- list()

for(m in 1:20){
  cat('workin on model #',i, m,'\n')
  
  ith_models[[m]] <- 
   xgb.train(
      params = param,
      data = dPairs,
      nrounds = best_iter,
      verbose = 0)
  
}

  models[[pair]] <- ith_models
  cv[[pair]] <- check_n_Trees 
  ooFold_P[[pair]] <- pred

}



saveRDS(models,'binary_models_xgb')
saveRDS(ooFold_P ,'binary_ooFold_P_xgb')
saveRDS(cv ,'binary_cv_xgb')



