xgb_loop_binary <- function(Xtrain, y, Xtest, 
                            model_dir  = 'xgb_loop', 
                            param_func = gen_param_binary, 
                            data_checks_func = data_checks_binary,
                            m = 10,
                            missing = NA,
                            pct_sample = .5){

require(data.table)
require(xgboost)

if(!dir.exists(model_dir)){dir.create(model_dir)}

#data checks
data_checks_func()

# settings
n_train_full <- nrow(Xtrain)
n_test_full  <- nrow(Xtest)
n_train_samp  <- round(pct_sample * n_train_full) # ~ 3.7 mill 

PCV <- matrix(NA, nrow = n_train_full, ncol = m)  # matrix n * m <== n * m ?? dumb
PT  <- matrix(NA,  nrow = n_test_full, ncol = m)
IDX <- sapply( 1:m,function(z) sample(n_train_full,n_train_samp))
DATA <- vector(mode='list',length=m)
dtest <- xgb.DMatrix(Xtest, missing = missing)
## LOOP this bitch

for(i in 1:m){ 
  cat('\n','working on model',i,'\n')
  idx      <-   IDX[,i]
  dtrain   <-   xgb.DMatrix(Xtrain[idx,] , missing = missing, label = y[idx])
  dvalid   <-   xgb.DMatrix(Xtrain[-idx,], missing = missing, label = y[-idx])
  
  param <- param_func(seed = i)
  
  model  <-    xgb.train(
    early.stop.round  = 15,
    watchlist         = list( valid_err = dvalid ),
    print.every.n     = 20,
    param             = param,
    data              = dtrain,
    nrounds           = param$nrounds,
    maximize          =  F,
    verbose  =  1)
  
  
  # predict validation and test data using trained model
  PCV[-idx,i] =  predict(model, newdata = dvalid, ntreelimit = model$bestInd)
  PT[,i]  =  predict(model, newdata = dtest,  ntreelimit = model$bestInd)
  
  
  # save model
  #xgb.save(model,file.path(model_dir, paste('boost',cv_score,sep='_')))
  
  # save data and predictions
  DATA[[i]] = list(param  = param,
              rounds   = model$bestInd,
              cv_score = model$bestScore)
  
  if(i%%100==0 | i==m) #save every 100 or when you are done
  {
    saveRDS(DATA ,  file = file.path(model_dir,    'PARAM_DATA.rds'))
    saveRDS(IDX  ,   file = file.path( model_dir,  'IDX.rds'))
    saveRDS(PCV  ,   file = file.path( model_dir,  'PCV.rds'))
    saveRDS(PT   ,    file = file.path( model_dir, 'PT.rds'))
  }
  
}



}
