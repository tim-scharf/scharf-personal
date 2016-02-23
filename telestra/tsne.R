require(Rtsne)


DT <- E[L[S[R]]]
DT[,id:=NULL]
DT[,n_loc:=X$n_loc]
DT[,loc_num:=X$loc_num]

TSNE <- Rtsne(as.matrix(DT), dims = 2, 
              initial_dims = 75, 
              perplexity = 30, 
              theta = .5,
              pca = T,
              verbose = T,
              max_iter = 1500)

idx <- !is.na(X$fault_severity)
plot(TSNE$Y[idx,],pch = 19 , cex = 1, col= X$fac[idx])


