classifier_loop <- function(name = 'xgb_test_loop',
                            Xtrain.rds,
                            y.rds, 
                            Xtest.rds, 
                            train_func,
                            param_func,
                            data_checks_func,
                            iter,
                            pct_train,
                            missing){

#get data checks
Xtrain <- readRDS(Xtrain.rds)
Xtest <- readRDS(Xtest.rds)
y <- readRDS(y.rds)    
  
data_checks_func(Xtrain,Xtest,y)

# settings
n_train_full <- nrow(Xtrain)
n_test_full  <- nrow(Xtest)
n_train_samp  <- round(pct_train * n_train_full) # ~ 3.7 mill 

#initialize input matrices
PCV   <- matrix(NA,  nrow  =  n_train_full, ncol = iter)  # matrix n * m <== n * m ?? dumb
PT    <- matrix(NA,  nrow =  n_test_full, ncol = iter)
IDX   <- sapply( 1:iter,function(z) sample(n_train_full,n_train_samp))
DATA  <- vector(mode='list',length=iter)

dtest <- xgb.DMatrix(Xtest, missing = missing)
## LOOP this bitch

for(i in 1:iter){
   cat('working on model',i,'\n\n')
   idx     = IDX[,i]
   param   = param_func(i,missing = missing)
   
   train   = Xtrain[idx,]
   y_train = y[idx]
   
   valid   = Xtrain[-idx,]
   y_valid = y[-idx]
   
   
   results <- train_func(train, valid, y_train, y_valid, dtest, param)
    
   PCV[-idx,i] <- results$pcv_iter
   PT[,i]      <- results$pt_iter
   DATA[[i]] <- results$data_iter
  }

return(list(PCV=PCV,PT=PT,IDX=IDX,DATA=DATA))

}
