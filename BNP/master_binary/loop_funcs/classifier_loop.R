classifier_loop <- function(name = 'xgb_test_loop',
                            Xtrain.rds,
                            y.rds, 
                            Xtest.rds, 
                            train_func = xgb_train,
                            param_func = gen_param_binary_xgb_tree,
                            data_checks_func,
                            iter =50,
                            pct_train = .5,
                            missing = -999){

#get data checks
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



}
