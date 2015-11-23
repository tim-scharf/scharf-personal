require(data.table)
require(xgboost)
require(doMC)
source('funx.R')
registerDoMC(8)
X <- makeMat('train.csv')
models <- readRDS('binary_models_xgb')
ooFold_P <- readRDS('binary_ooFold_P_xgb')
cv <- readRDS('binary_cv_xgb')

y  <- as.numeric(readRDS('y'))-1
pairs <- t(combn(unique(y),2))

P <- matrix(0,nrow = length(y),ncol = length(models))
for( i in 1:nrow(pairs))
  {
pair <- paste(as.character(pairs[i,]),collapse='_')  
pair_idx <- which(y %in% pairs[i,])
not_idx <- which(!y %in% pairs[i,])
order_idx <- order(c(pair_idx,not_idx))

part1 <- ooFold_P[[i]]
part2 <- rowMeans(sapply(models[[i]],predict,newdata = X[-pair_idx,]))
P[,i] <- c(part1,part2)[order_idx]
}

saveRDS(P,'P_binary')





