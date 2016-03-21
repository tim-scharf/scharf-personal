xgb_train_binary_tree <- function(Xtrain,Xtest,y,iter,pct_train){
  require(doMC)
  require(e1071)
  registerDoMC(cores = 12)
  OUTPUT <- init_OUPUT(nrow(Xtrain),nrow(Xtest),iter,pct_train)
  
# get missing attr
  missing  <-  attr(Xtrain,'missing')
  dtest    <- Xtest
  
  foreach(idx = 1:iter(OUTPUT$IDX,by = 'col'))%dopar%{
    cat('building SVM model',i, '\n\n')  

    dtrain   <-   Xtrain[idx,]  #xgboost syntax
    dvalid   <-   Xtrain[-idx,]
    y_train   <-  factor(y[idx])
    y_val     <-  factor(y[-idx])
    
    
    model <- svm(
      x = dtrain,
      y = y_train,
      scale = T,
      type = 'C-classification',
      kernel  = 'radial',
      cost = .001,
      gamma = .001,
      tolerance = .005,
      fitted = F,
      cache = 2000,
      probability  = T)
      
      
      

    
    OUTPUT$PCV[-idx,i]    <-   attr( predict(model, newdata = dvalid,probability = T),'p')
    OUTPUT$PT[,i]          <-   predict(model, newdata = dtest,  ntreelimit = model$bestInd)
    
    OUTPUT$DATA[[i]]   <-  list(param  = param,
                                rounds   = model$bestInd,
                                cv_score = model$bestScore)
    
    
  }
  
  return(OUTPUT)
}