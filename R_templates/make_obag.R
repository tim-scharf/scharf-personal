# get obag

make_obag <- function(y, model_dir){  
  
  files <- sort(list.files(model_dir,full.names = T))
  D     <- lapply(files,readRDS)
  n     <- length(D)
  
  idx_list <- lapply(1:n,function(i) setdiff(1:length(y),D[[i]]$idx))
  
  pred <-     numeric(length = length(y)) 
  k    <- numeric(length = length(y))
  
  for(j in 1:n){
    idx <- idx_list[[j]]
    pred[idx] <- pred[idx]  +   D[[j]]$P_valid
    k[idx]    <- k[idx] + 1
    
  }
  
     pred <- pred/k
     
     return(pred)
     
  }






