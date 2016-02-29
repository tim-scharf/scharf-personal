require(Rtsne)
set.seed(1234)
DT <- L[S[E[R]]]
DT[,noise:=runif(nrow(DT))]

M <- as.matrix(DT[,-'id',with=F])

grid = expand.grid(PCA = c(T,F), 
                   perplexity = c(15,20,25,30,35),
                   scale_it = c(T,F),
                   log_it = c(T,F))

TSNE_list <- list()

for(i in 1:nrow(grid)){
   PCA <- grid[i,'PCA']
   perplexity <- grid[i,'perplexity']
   scale_it <- grid[i,'scale_it']
   log_it <- grid[i,'log_it']
   
   data <- copy(M)
   if(log_it) data <- log1p(data)
   if(scale_it) data <- scale(data)
   print(i)
   TSNE_list[[i]] <- Rtsne(X=data,
                 perplexity = perplexity,
                 pca = PCA,
                 theta = .5,
                 verbose = T,
                 max_iter = 1500,
                 dims = 2,
                 initial_dims = 75)
  saveRDS(TSNE_list,'TSNE_list.rds')
}


# plot(TSNE$Y[idx,],pch = 19 , cex = .5, col= X$y[idx])
# plot(TSNE_log1p$Y[idx,],pch = 19 , cex = .5, col= X$y[idx])
# plot(TSNE_log1p$Y[idx,],pch = 19 , cex = .5, col= X$y[idx])
# plot(TSNE_raw_scale$Y[idx,],pch = 19 , cex = .5, col= X$y[idx])
# plot(TSNE_raw_scale_noPCA$Y[idx,],pch = 19 , cex = .5, col= X$y[idx])
# plot(TSNE_raw_noPCA$Y[idx,],pch = 19 , cex = .5, col= X$y[idx])
# 
# 
# plot(TSNE_raw_scale_noPCA$Y[idx,2],TSNE_raw_scale$Y[idx,1] ,pch = 19 , cex = .5, col= X$y[idx])
# 
# require(car)
# scatter3d(x=TSNE_raw3$Y[idx,1],y=TSNE_raw3$Y[idx,2],z=TSNE_raw3$Y[idx,3],surface =F,
#           point.col = as.numeric(X$y[idx]))
