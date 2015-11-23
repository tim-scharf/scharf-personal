data_dir <-'xgb_pairwise/'
outfile <- ''
require(Metrics)
require(doMC)
source('funx.R')
registerDoMC(8)
files <- sample(list.files(data_dir,full.names = T))

#rep = strsplit(files,split='_')

#r <- as.numeric(unlist( lapply(rep, function(i) i[[4]])))>500

Z <- readRDS('Z')
id <- Z[bidder_id %in% train$bidder_id,bidder_id]


D <- lapply(files,readRDS)
idx_list <- lapply(D,function(d)  d$idx_val) 

y <- D[[1]]$y

ind_cv <- unlist(lapply(D, function(d)  d$cv_score))
print(mean(ind_cv))

cum_cv <- foreach (m = 1:length(D),.combine =c)%dopar%
{
  
  
  pred <- numeric(length = length(y)) 
  k    <- numeric(length = length(y))
  
  for(j in 1:m){
    idx <- idx_list[[j]]
    pred[idx] <- pred[idx]  +   D[[j]]$P_valid
    k[idx]    <- k[idx] + 1
    
  }
  
  pred <- pred/k
  auc(y,pred)

}



print(max(cum_cv))
plot(cum_cv, ylim = c(.9,1))

plot(pred[order(pred)], col =1+ y[order(pred)], pch=19,cex = y[order(pred)]+.5)





obag <- data.table(bidder_id=id,pred=pred)
setkey(obag,bidder_id)
saveRDS(obag,outfile)
