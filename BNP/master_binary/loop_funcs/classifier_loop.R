classifier_loop <- function(name = 'xgb_tester',
                            Xtrain.rds,
                            y.rds, 
                            Xtest.rds, 
                            train_func,
                            iter =10,
                            pct_train = .5){


dir.create()

#data checks
data_checks_func()

# settings
n_train_full <- nrow(Xtrain)
n_test_full  <- nrow(Xtest)
n_train_samp  <- round(pct_sample * n_train_full) # ~ 3.7 mill 

#initialize input matrices
PCV   <- matrix(NA, nrow = n_train_full, ncol = m)  # matrix n * m <== n * m ?? dumb
PT    <- matrix(NA,  nrow = n_test_full, ncol = m)
IDX   <- sapply( 1:m,function(z) sample(n_train_full,n_train_samp))
DATA  <- vector(mode='list',length=m)
dtest <- xgb.DMatrix(Xtest, missing = missing)
## LOOP this bitch

for(i in 1:m){ 

  
  
  
  model  <-    
  
  
  # predict validation and test data using trained model

  
  
  # save model
  #xgb.save(model,file.path(model_dir, paste('boost',cv_score,sep='_')))
  
  # save data and predictions

  
  if(i%%100==0 | i==m) #save every 100 or when you are done
  {
    saveRDS(DATA ,  file = file.path(model_dir,    'PARAM_DATA.rds'))
    saveRDS(IDX  ,   file = file.path( model_dir,  'IDX.rds'))
    saveRDS(PCV  ,   file = file.path( model_dir,  'PCV.rds'))
    saveRDS(PT   ,    file = file.path( model_dir, 'PT.rds'))
  }
  
}



}
