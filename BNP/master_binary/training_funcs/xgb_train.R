xgb_train <- function(train, valid, y_train, y_valid, dtest, param){
  
  dtrain   <-   xgb.DMatrix(train , missing = params$missing, label = y_train)
  dvalid   <-   xgb.DMatrix(valid, missing =  params$missing, label = y_valid)
  
  model <- xgb.train(
    early.stop.round  = 20,
    watchlist         = list( valid_err = dvalid ),
    print.every.n     = 50,
    param             = param,
    data              = dtrain,
    nrounds           = param$nrounds,
    maximize          = F,
    verbose  =  1 )
  
  pcv_iter         <-   predict(model, newdata = dvalid, ntreelimit = model$bestInd)
  pt_iter          <-   predict(model, newdata = dtest,  ntreelimit = model$bestInd)
  
  data_iter  <-  list(param  = param,
                   rounds   = model$bestInd,
                   cv_score = model$bestScore)
  
  return(pcv,pt,data_iter)
}

