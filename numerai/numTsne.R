setwd('~/data/numerai/')
require(data.table)
require(Rtsne)
X0 <- fread('numerai_datasets/numerai_training_data.csv')
X1 <- fread('numerai_datasets/numerai_tournament_data.csv')

X <- rbindlist(list(X0,X1),use.names = T,fill =T)

M0 <- model.matrix( ~ . -1 ,data = X[,1:15,with=F] )

M <- scale(M0)

tsne_out <- Rtsne(M, pca = F, theta = .5, dims = 2, verbose = T)

col = as.integer(factor(X$target,exclude = NULL))

idx <- sample(nrow(M),size = 40000)

plot(tsne_out$Y[idx,],col = col[idx],pch = 19, cex =.1)


