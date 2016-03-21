xgb_train_binary_tree <- function(Xtrain,Xtest,y,iter,pct_train){
  
  n_train <- nrow(Xtrain)
  n_test <- nrow(Xtest)
  pct_cv <- pct_train
  
  OUTPUT <- init_OUPUT(n_train,n_test,iter,pct_train)
  
  # get missing attr
  missing <-  attr(Xtrain,'missing')
  dtest <- xgb.DMatrix(Xtest, missing = missing)
  
  for(i in 1:iter){
  cat('building model',i, '\n\n')  
  idx <- OUTPUT$IDX[,i]
  
  # index madness
  idx_prime <- (1:n_train)[-idx]
  idx_bool <- sample(c(T,F),length(idx_prime),replace=T,prob=c(pct_cv,1 - pct_cv))
  idx_stop <- idx_prime[idx_bool]
  idx_valid <- idx_prime[!idx_bool]
  
  #initialize 3 xgb.Dmatrices
  dtrain   <-   xgb.DMatrix( Xtrain[idx,]       ,  missing = missing, label = y[idx] )
  dstop    <-   xgb.DMatrix( Xtrain[idx_stop,]  ,  missing = missing, label = y[idx_stop] )
  dvalid   <-   xgb.DMatrix( Xtrain[idx_valid,] ,  missing = missing, label = y[idx_valid] )
  
  param = list( 
    booster          =   'gbtree',
    objective        =   'binary:logistic',
    eval_metric      =   'logloss', 
    max.depth        =   sample(3:10, 1), 
    eta              =   runif(1,.01,.1),
    gamma            =   runif(1,0,5),
    min_child_weight =   runif(1,0,5),
    subsample        =   runif(1,.4,.6),
    colsample_bytree =   runif(1,.3,.7),
    nrounds          =   1000,
    lambda           =   runif(1,0,3),  ##tree default 1 related?
    alpha            =   0,                 ## tree related?
    base_score       =   mean(y),
    nthread          =   12 )
  
  model <- xgb.train(
    early.stop.round  = 20,
    watchlist         = list( stop_err = dstop),
    print.every.n     = 25,
    param             = param,
    data              = dtrain,
    nrounds           = param$nrounds,
    maximize          = F,
    verbose  =  1 )
  
  OUTPUT$PCV[idx_valid,i]    <-   predict(model, newdata = dvalid, ntreelimit = model$bestInd)
  OUTPUT$PT[,i]              <-   predict(model, newdata = dtest,  ntreelimit = model$bestInd)
  
  OUTPUT$DATA[[i]]   <-  list(param  = param,
                         rounds   = model$bestInd,
                         cv_score = model$bestScore)
  

}

return(OUTPUT)
}