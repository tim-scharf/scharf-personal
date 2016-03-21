xgb_train_binary_linear <- function(Xtrain,Xtest,y,iter,pct_train){
  
  OUTPUT <- init_OUPUT(nrow(Xtrain),nrow(Xtest),iter,pct_train)
  
  # get missing attr
  dtest <- xgb.DMatrix(Xtest)
  
  for(i in 1:iter){
    cat('building model',i, '\n\n')  
    idx      <- OUTPUT$IDX[,i]
    dtrain   <-   xgb.DMatrix( Xtrain[idx,] , label = y[idx])
    dvalid   <-   xgb.DMatrix( Xtrain[-idx,], label = y[-idx])
    
    param = list( 
      booster          =   'gblinear',
      objective        =   'binary:logistic',
      eval_metric      =   'logloss', 
      nrounds          =   1000,
      eta              =   1,
      lambda           =   runif(1,0,2), 
      alpha            =   runif(1,0,2),
      lambda_bias      =   0, 
      base_score       =   runif(1, .5,.8),
      nthread          =   13)
    
    model <- xgb.train(
      early.stop.round  = 20,
      watchlist         = list( valid_err = dvalid),
      print.every.n     = 50,
      param             = param,
      data              = dtrain,
      nrounds           = param$nrounds,
      maximize          = F,
      verbose  =  1 )
    
    OUTPUT$PCV[-idx,i]    <-   predict(model, newdata = dvalid)
    OUTPUT$PT[,i]         <-   predict(model, newdata = dtest)
    
    OUTPUT$DATA[[i]]   <-  list(param  = param,
                                rounds   = model$bestInd,
                                cv_score = model$bestScore)
    
    
  }
  
  return(OUTPUT)
}