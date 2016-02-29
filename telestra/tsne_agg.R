setwd('~/repos/scharf-personal/telestra/')
require(data.table)
require(kknn)
require(doMC)
require(entropy)
registerDoMC(8)

tsne_list <- readRDS('TSNE_list.rds')
A <- matrix( unlist(lapply(tsne_list,function(i)i$Y)), ncol = length(tsne_list)*2)
idx <- readRDS('train_idx.rds')

X <- as.data.table(A[idx,])
Xtest <- as.data.table(A[-idx,])
y_raw <- readRDS('y.rds')[idx]
y <- factor(y_raw)

kmax  = 60

k_vals = c(2,4,8,16,32,64)


 # large sweep to check params
 k0 <- train.kknn(  y ~ ., data = X, kmax=kmax, kernel = c('biweight','triangular', 'epanechnikov',
                                                           'rectangular','cos','inv','gaussian','optimal',
                                                           'triweight') ,distance=2 )

  
     
     ## triangular K = 15 ~ .1915 err rate ,DATA[[2]]
     saveRDS(k0,file = 'kknn_master_train.rds')
     
 
k_obag  <-  foreach(k = iter(k_vals),.verbose = T)%dopar%{    
     
            kknn(  y  ~ ., 
                train  = X ,  
                test = X,
                k= k + 1 , 
                kernel = k0$best.parameters$kernel,
                distance = k0$distance)
             }

     ## build out of fold knn_raw
     ## already saved out of fold 'kknn_out_of_fold_k15_triangular'
k_test  <-  foreach(k = iter(k_vals),.verbose = T)%dopar%{   
                kknn( y ~ ., train  = X ,  
                     test = Xtest , 
                     k = k + 1, 
                     kernel = k0$best.parameters$kernel,
                     distance = k0$distance)
  }
     
gen_kknn_obag_probs <- function(model,y){
  ## remove 1st nearest neighbor
  W   <-  model$W[,-1]
  CL  <-  model$CL[,-1]
  D   <-  model$D[,-1]
  #canonical process matches test process
  # careful here
  probs = sapply(levels(y), function(lev)  rowSums((CL==lev) * W))
  probs = probs/rowSums(probs)
  return(cbind(probs,rowMeans(D)))
  
  
}

gen_kknn_test_probs <- function(model){
   return( cbind( model$prob,rowMeans(model$D)))
  
}     
     


P_obag <- lapply(k_obag,gen_kknn_obag_probs,y = y)
P_test <- lapply(k_test,gen_kknn_test_probs)

ncol = dim(P_obag[[1]])[2] * length(P_obag)

K <- matrix(unlist(P_obag), ncol = ncol)
K_test <- matrix(unlist(P_test), ncol = ncol)

saveRDS(K,'K.rds')
saveRDS(K_test,'K_test.rds')




