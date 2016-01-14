setwd('~/repos/scharf-personal/numerai/')
require(data.table)
require(Rtsne)
X0 <- fread('~/data/numerai/numerai_datasets/numerai_training_data.csv')
X1 <- fread('~/data/numerai/numerai_datasets/numerai_tournament_data.csv')

X <- rbindlist(list(X0,X1),use.names = T,fill =T)

M0 <- model.matrix( ~ . -1 ,data = X[,1:15,with=F] )

M <- scale(M0)

n =20
A <- matrix(0, nrow = nrow(M),ncol = 2*n)

for(i in 1:n){

tsne_out <- Rtsne(M, pca = F, theta = .5, dims = 2,perplexity = i+20, verbose = T)
idx <- ((i*2)-1):(i*2)
A[,idx] <- tsne_out$Y
saveRDS(A,'tsneA.rds')

}



