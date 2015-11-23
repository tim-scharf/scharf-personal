# xgb_binary


xgb_binary <- function(train,
                       test,
                       y,
                       idx,
                       m,
                       model_dir,
                       NA_val  =  -999)
{
  require(xgboost)
  require(Matrix)
    
  # xgb data structures
  dtrain   <-   xgb.DMatrix(train[idx,]    ,missing = NA_val, label = y[idx])
  dvalid   <-   xgb.DMatrix(train[-idx,]   ,missing = NA_val, label = y[-idx])
  dtest    <-   xgb.DMatrix(test           ,missing = NA_val)
  
  
  param = list( 
    booster          =  'gbtree',
    #lambda           =  .001,
    #alpha            =  .001,
    objective        =  'binary:logistic',
    eval_metric      =  'logloss',
    max.depth        =   3, 
    eta              =   .01,
    gamma            =   0,
    min_child_weight =   0,
    subsample        =   runif (1,.4,.6),
    colsample_bytree =   runif (1,.6,.9),
    nrounds          =   2000
  )
  
  
#   if (m %%4==1){
#     DATA           <- readRDS(  sample(sort(list.files(model_dir,full.names = T))[1:20],1))
#     param          <- DATA$param
#     param$eta      <-  .1  
#     param$nrounds  <-  2000
#   }
#   
  
  model  <-    xgb.train(
    early.stop.round  = 10,
    watchlist         = list( valid_err = dvalid),
    print.every.n     = 5,
    params            = param,
    data              = dtrain,
    nrounds           = param$nrounds,
    verbose = 1)
  
  
  # save model
  #xgb.save(model,file.path(model_dir, paste('boost',cv_score,sep='_')))
  
  # save data and predictions
  DATA = list(param    = param,
              idx      = idx, 
              P_valid  = predict(model, newdata = dvalid, ntreelimit = model$bestInd), 
              P_test   = predict(model, newdata = dtest,  ntreelimit = model$bestInd) ,
              cv_score = model$bestScore,
              rounds   = model$bestInd,
              m        = m)
  
  saveRDS(DATA , file = file.path(model_dir, paste('DATA',m,DATA$cv_score,sep='_')))
  

  
  
}