require(data.table)
require(xgboost)
require(Matrix)
setwd('~/repos/scharf-personal/telestra/')
model_dir = 'xgb_models/'
if(!dir.exists(model_dir)){dir.create(model_dir)}

train_idx <- readRDS('train_idx.rds')
test_idx <- readRDS('test_idx.rds')
y  <-  readRDS('y.rds')


## data orgainze
Xtrain <-  readRDS('K.rds')
Xtest <-   readRDS('K_test.rds')
y  <-  y[train_idx]
# gc()


## build XGB test mat
dtest   <-   xgb.DMatrix(Xtest,missing=NA)

ntrain  <- round(.80* nrow(Xtrain)) # ~ 3.7 mill 




## LOOP this bitch

for(m in 1:20){ 
  cat('\n','working on model',m,'\n')
  set.seed(m)
  idx      <-   sample(nrow(Xtrain),ntrain)
  #idx      <-   readRDS('use_idx')
  dtrain   <-   xgb.DMatrix(Xtrain[idx,] ,missing = NA,label = y[idx])
  dvalid   <-   xgb.DMatrix(Xtrain[-idx,],missing = NA,label = y[-idx])
  
  
  
  param = list( 
    booster          =  'gbtree',
    #lambda           =  .001,
    #alpha            =  .001,
    objective        =   'multi:softprob', #'reg:linear',
    eval_metric      =   'mlogloss', #'rmse',
    max.depth        =   sample(3:6,1), 
    eta              =   runif(1,.005,.1),
    gamma            =   runif(1,0,4),
    min_child_weight =   runif(1,0,3),
    subsample        =   runif(1,.4,.6),
    colsample_bytree =   runif(1,.6,.9),
    nrounds          =   1000,
    num_class        =   3,
    nthread          =   5
    
  )
  
  #   if (m %%4==1){
  #     DATA           <- readRDS(  sample(sort(list.files(model_dir,full.names = T))[1:20],1))
  #     param          <- DATA$param
  #     param$eta      <-  .1  
  #     param$nrounds  <-  2000
  #   }
  
  
  model  <-    xgb.train(
    early.stop.round  = 10,
    watchlist         = list( valid_err = dvalid),
    print.every.n     = 5,
    params            = param,
    data              = dtrain,
    nrounds           = param$nrounds,
    maximize          =  F,
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





