# get obag

make_obag <- function(n_train, model_dir,num_class=3){  
  
  files    <- sort(list.files(model_dir,full.names = T))
  n_models <- length(files)
  D        <- lapply(files,readRDS)
  
  
  idx_list <- lapply(1:n_models,function(i) setdiff(1:n_train,D[[i]]$idx))
  
  pred <-     matrix (0,nrow =   n_train,ncol = num_class) 
  k    <-     numeric(length = n_train)
  
  
  for(j in 1:n_models){
    idx <- idx_list[[j]]
    pred[idx,] <- pred[idx,]  +   matrix( D[[j]]$P_valid, ncol=num_class, byrow = T)
    k[idx]    <- k[idx] + 1
    
  }
  
  pred <- pred/k
  
  return(pred)
  
}






