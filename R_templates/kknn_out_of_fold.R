classes = levels(y)




#load_training run
load('K_master_train250_no_scale_F')
K <- K_no_scale[1:3];rm(K_no_scale)

score_pred <- function(k)((t(table(k==y,y))/as.numeric(table(y)))[,2])

get_param <- function(row){
  trans       <- row[[1]]
  i           <- K[[trans]]
  kernel      <- attr( i$fitted.values[[row[2]]],'kernel')
  k           <- attr( i$fitted.values[[row[2]]],'k')
  scale       <-  as.logical(as.character(as.list(i$call)$scale))
  PARAM_LIST  <-  list(kernel = kernel, k = k, trans = trans, scale = scale)
  PARAM_LIST
}



gen_best_params <- function(K){
  ## get accuracy_rates for every kernel(gaussian, cos, epan..),
  ## class (1,2,..9) and k value(i.e 1,2,3,...k) combination
  ACC <- mclapply(1:length(K),function(i) sapply(K[[i]]$fitted.values,score_pred),mc.cores = 4)
  
  ## find best params across this space, returned in matrix
  BEST <- sapply(ACC ,function(a) apply(a,1,max))
  ## indexes of best accuracy for each class,return in a matrix
  IDX <-  sapply(ACC,function(a)apply(a,1,which.max))
  
  K_IDX0  <-  apply(BEST,1,which.max)
  K_IDX1  <- IDX[cbind(1:nrow(IDX),K_IDX0)]
  
  ## this tells us, for each class,where to find best params
  K_IDX <- cbind(K_IDX0,K_IDX1)
  
  #go get params
  PARAMS <- apply(K_IDX,1,get_param)
  return(list(PARAMS = PARAMS, BEST = BEST))
  
}


P <- gen_best_params(K) 






run_model <- function(k,kernel,train,test,scale){
  
  model <- kknn( y ~ ., 
                 train  =  train,  
                 test   =  test, 
                 k      =  k ,
                 kernel =  kernel,
                 scale  =  scale)  
  
  model 
  
  
}




run_test <- function(P,TRAIN,TEST){
  PARAMS  <- P$PARAMS
  
  fold  <- foreach(i = 1:length(PARAMS))%dopar%{
    
    p  <-  PARAMS[[i]]
    
    
    model <- run_model(
      k      = p$k,
      kernel = p$kernel,
      scale  = p$scale,
      train  = TRAIN[[ p$trans ]],
      test   = TEST[[  p$trans ]]
    )
  }
  
  #pred_list  <-  lapply(fold,function(i) i$prob )
  #pred <- do.call(cbind,pred_list)
  #colnames(pred) <- as.character(outer(levels(y),paste('P',1:9,sep='_'),paste,sep='_'))
  #pred
  
  return(fold)
}



run_fold <- function(P,TRAIN){
  
  PARAMS  <- P$PARAMS 
  
  
  fold  <- foreach(i = 1:length(PARAMS))%dopar%{
    # p is for params
    p  <- PARAMS[[i]]
    
    
    model <- run_model(
      k      = p$k + 1, # add one more neighbor
      kernel = p$kernel,
      scale  = p$scale,
      train  = TRAIN[[ p$trans ]],
      test   = TRAIN[[ p$trans ]]  #use train for test
    )
    
    ## remove 1st nearest neighbor
    W   <-  model$W[,-1]
    CL  <-  model$CL[,-1]
    
    #canonical process matches test process
    # careful here
    probs = sapply(classes,function(z)  rowSums((CL==z) * W))
    probs = probs/rowSums(probs)
    
    probs
    
    
  }
  
  
  fold_probs <- do.call(cbind,fold) 
  colnames(fold_probs) <- as.character(outer(levels(y),paste('P',1:9,sep='_'),paste,sep='_'))
  
  fold_probs
  
}


fold  <- run_fold(P,DATA)

saveRDS(list(fold = fold, pred = NULL), file = 'META_RAW/knn_opt')

pred <- run_test(P,DATA,DATA_TEST)

save(pred, file= 'pred_final')
load('pred_final')
load('fold_P_dummy')
## fill holes

k2 <- kknn( y ~ ., train  =  DATA[[3]],  test = DATA_TEST[[3]], 
            k=250, kernel = 'rectangular' ,distance=2, scale = F)

k7 <- kknn( y ~ ., train  =  DATA[[2]],  test = DATA_TEST[[2]], 
            k=49, kernel = 'triweight' ,distance=2, scale = F)



