


  dtrain   <-   xgb.DMatrix(Xtrain[idx,] ,missing = NA_val, label = y[idx])
  dvalid   <-   xgb.DMatrix(Xtrain[-idx,],missing = NA_val, label = y[-idx])
  
  
  


## data orgainze

y  <-  y_raw[train_idx]
gc()




require(data.table)
require(xgboost)
require(Matrix)



## LOOP this bitch


  

  
  param = list( 
    booster          =  'gbtree',
    #lambda           =  .001,
    #alpha            =  .001,
    objective        =  'reg:linear',
    eval_metric      =  'rmse',
    max.depth        =   sample(3:10,1), 
    eta              =   runif(1,.1,.3),
    gamma            =   runif(1,0,2),
    min_child_weight =   sample(0:10,1),
    subsample        =   runif(1,.4,.6),
    colsample_bytree =   runif(1,.6,.9),
    nrounds          =   2000
  )
  
  if (m %%4==1){
    DATA           <- readRDS(  sample(sort(list.files(model_dir,full.names = T))[1:20],1))
    param          <- DATA$param
    param$eta      <-  .1  
    param$nrounds  <-  2000
  }
  
  
  model  <-    xgb.train(
    early_stop_round  = 10,
    watchlist         = list( valid_err = dvalid),
    printEveryN       = 5,
    params            = param,
    data              = dtrain,
    nrounds           = param$nrounds,
    verbose= 1)
  
  
  # predict validation and test data using trained model
  P_valid =  predict(model, newdata=dvalid, ntreelimit = model$bestInd)
  P_test  =  predict(model, newdata=dtest,  ntreelimit = model$bestInd)
  
  # score the validation set
  cv_score      =  model$bestScore
  param$nrounds =  model$bestInd
  
  # save model
  #xgb.save(model,file.path(model_dir, paste('boost',cv_score,sep='_')))
  
  # save data and predictions
  DATA = list(param    = param,
              idx      = idx, 
              P_valid  = P_valid, 
              P_test   = P_test ,
              cv_score = cv_score,
              rounds   = model$bestInd)
  
  saveRDS(DATA , file = file.path(model_dir, paste('DATA',cv_score,sep='_')))
  
  
  
}






 



