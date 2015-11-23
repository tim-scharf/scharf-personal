dir0 <- 'xgb_models_response/'
dir1 <- 'xgb_models_profit/'

files0 <- sort(list.files(dir0,full.names = T))
files1 <- sort(list.files(dir1,full.names=T))
D0 <- lapply(files0,readRDS)
D1 <- lapply(files1,readRDS)

D <- D1
n = length(D)
idx_list <- lapply(1:n,function(i) setdiff(1:length(y),D[[i]]$idx))
#out_of_folds <-sapply(D[1:15],function(d) setdiff(1:length(y),d$idx))
# t1 <- table(out_of_folds)
# idx_0 <- setdiff(1:length(y),out_of_folds)
# idx_1  <- which(t1==1)
# 
# needed <- unique(c(idx_0,idx_1))
# use_idx <- setdiff(1:length(y),needed)
# saveRDS(use_idx,'use_idx')
#L <- lapply(1:ncol(idx_list),function(i) length(setdiff(1:length(y),as.numeric(idx_list[,1:i]))  ) )


pred <- numeric(length = length(y)) 
k <- numeric(length = length(y))

for(j in 1:n){
  idx <- idx_list[[j]]
  pred[idx] <- pred[idx]  +   D[[j]]$P_valid
  k[idx]    <- k[idx] + 1
  
}

pred <- pred/k
pred[pred<0] <- 0

names(pred) <- id

obag <- data.table(id=id,pred=pred)

saveRDS(obag,'obag')

rmse <- sqrt(mean((pred-y)^2,na.rm=T))
