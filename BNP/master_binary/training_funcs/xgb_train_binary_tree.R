xgb_train_binary_tree <- function(Xtrain,Xtest,y,iter,pct_train){
  
  OUTPUT <- init_OUPUT(nrow(Xtrain),nrow(Xtest),iter,pct_train)
  
  # get missing attr
  missing <-  attr(Xtrain,'missing')
  dtest <- xgb.DMatrix(Xtest, missing = missing)
  
  for(i in 1:iter){
  cat('building model',i, '\n\n')  
  idx <- OUTPUT$IDX[,i]
  dtrain   <-   xgb.DMatrix(Xtrain[idx,] , missing = missing, label = y[idx])
  dvalid   <-   xgb.DMatrix(Xtrain[-idx,], missing = missing, label = y[-idx])
  
  param = list( 
    booster          =   'gbtree',
    objective        =   'binary:logistic',
    eval_metric      =   'logloss', 
    max.depth        =   sample(3:12, 1), 
    eta              =   runif(1,.01,.2),
    gamma            =   runif(1,0,1),
    min_child_weight =   runif(1,0,3),
    subsample        =   runif(1,.4,.6),
    colsample_bytree =   runif(1,.3,.9),
    nrounds          =   1000,
    lambda           =   runif(1,.25,1.75),  ##tree default 1 related?
    alpha            =   0,                 ## tree related?
    base_score       =   mean(y)+ runif(1,-.1,.1),
    nthread          =   12 )
  
  model <- xgb.train(
    early.stop.round  = 20,
    watchlist         = list( valid_err = dvalid ),
    print.every.n     = 50,
    param             = param,
    data              = dtrain,
    nrounds           = param$nrounds,
    maximize          = F,
    verbose  =  1 )
  
  OUTPUT$PCV[-idx,i]    <-   predict(model, newdata = dvalid, ntreelimit = model$bestInd)
  OUTPUT$PT[,i]          <-   predict(model, newdata = dtest,  ntreelimit = model$bestInd)
  
  OUTPUT$DATA[[i]]   <-  list(param  = param,
                         rounds   = model$bestInd,
                         cv_score = model$bestScore)
  

}

return(OUTPUT)
}