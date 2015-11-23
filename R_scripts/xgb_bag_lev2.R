require(data.table)
require(xgboost)
require(Matrix)

model_dir = 'xgb_lev2/'
Obag    =    readRDS('obag')
setkey(Obag,id)

sub = fread('submissions//xgb_top40_final_xmas')
setkey(sub,id)
use_idx <- which(sub$id %in% X$id)

DT = readRDS('X_full_DT')
DT[,id:=paste(store_nbr,item_nbr,date,sep='_')]
setkey(DT,id)

X = Obag[DT]
X[!is.na(pred) & month==12 &day_nbr==25,pred:=0]
setkey(X,id)

##!!!! !!!!
use_idx <- which(sub$id %in% X$id)
X[is.na(pred), pred:=log1p(sub$units[use_idx])]



M <- model.matrix( ~ -1 + pred + item_nbr + cal + day , data= X)


train_idx  <- which(!is.na(X$units))



## data orgainze
Xtrain <-  M[train_idx,]
Xtest <-   M[-train_idx,]

base_train  <- X[train_idx,pred]
base_test  <- X[-train_idx,pred]

y <- X[train_idx,log1p(units)]
gc()


## build XGB test mat
dtest   <-   xgb.DMatrix(Xtest, base_margin = base_test)

ntrain  <- round(.80* nrow(Xtrain)) # ~ 3.7 mill 




## LOOP this bitch

for(m in 1:2000){ 
  cat('\n','working on model',m,'\n')
  set.seed(m)
  idx      <-   sample(nrow(Xtrain),ntrain)
  dtrain   <-   xgb.DMatrix(Xtrain[idx,] ,label = y[idx]  ,base_margin = base_train[idx] )
  dvalid   <-   xgb.DMatrix(Xtrain[-idx,],label = y[-idx] ,base_margin = base_train[-idx] )
  
  
  
  param = list( 
    booster          =  'gbtree',
    #lambda           =  .001,
    #alpha            =  .001,
    objective        =  'reg:linear',
    eval_metric      =  'rmse',
    max.depth        =   sample(2:6,1), 
    eta              =   .01,
    gamma            =   runif(1,0,2),
    min_child_weight =   1,
    subsample        =   .6,
    colsample_bytree =   runif(1,.8,1),
    nrounds          =   2000
  )
  
#   if (m >50){
#     DATA           <- readRDS(  sample(sort(list.files(model_dir,full.names = T))[1:20],1))
#     param          <- DATA$param
#     param$eta      <-  .1  
#     param$nrounds  <-  2000
#   }
  
  
  model  <-    xgb.train(
    early_stop_round  = 10,
    watchlist         = list( valid_err = dvalid),
    printEveryN       = 10,
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


