require(data.table)
require(xgboost)
require(Matrix)
setwd('~/repos/scharf-personal/telestra/')
model_dir = 'xgb_models_final/'
if(!dir.exists(model_dir)){dir.create(model_dir)}

X <- readRDS('X.rds')
X_test <- readRDS('X_test.rds')
train_idx <- readRDS('train_idx.rds')
test_idx <- readRDS('test_idx.rds')

test_ids <- X_test[,id]



##!!!! !!!!

X[,id:=NULL]
X_test[,id:=NULL]


## data orgainze
Xtrain <-  as.matrix(X)
Xtest <-   as.matrix(X_test)

base_train  <- X[,.(V1,V2,V3)]
base_test  <-  X_test[,.(V1,V2,V3)]

y <- readRDS('y.rds')[train_idx]


## build XGB test mat
dtest   <-   xgb.DMatrix(Xtest)
setinfo(dtest,'base_margin',unlist(t(base_test)))

ntrain  <- round(.80* nrow(Xtrain)) # ~ 3.7 mill 


## LOOP this bitch

for(m in 1:200){ 
  cat('\n','working on model',m,'\n')
  set.seed(m)
  idx      <-   sample(nrow(Xtrain),ntrain)
  dtrain   <-   xgb.DMatrix(Xtrain[idx,] ,label = y[idx] )
  dvalid   <-   xgb.DMatrix(Xtrain[-idx,],label = y[-idx] )
  
  setinfo(dtrain,'base_margin',unlist(t(base_train[idx,])))
  setinfo(dvalid,'base_margin',unlist(t(base_train[-idx,])))
  
  
  param = list( 
    booster          =  'gbtree',
    #lambda           =  .001,
    #alpha            =  .001,
    objective        =   'multi:softprob', #'reg:linear',
    eval_metric      =   'mlogloss', #'rmse',
    max.depth        =   sample(3:5,1), 
    eta              =   runif(1,.005,.1),
    gamma            =   runif(0),
    min_child_weight =   runif(0),
    subsample        =   runif(1,.4,.6),
    colsample_bytree =   runif(1,.6,.9),
    nrounds          =   1000,
    num_class        =   3,
    nthread          =   5
  )
  
  #   if (m >50){
  #     DATA           <- readRDS(  sample(sort(list.files(model_dir,full.names = T))[1:20],1))
  #     param          <- DATA$param
  #     param$eta      <-  .1  
  #     param$nrounds  <-  2000
  #   }
  
  model  <-    xgb.train(
    early.stop.round  = 20,
    watchlist         = list( valid_err = dvalid),
    print.every.n     = 10,
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


