require(Rtsne)
set.seed(1234)
DT <- L[S[E[R]]]
DT[,noise:=runif(nrow(DT))]

M <- as.matrix(DT[,-'id',with=F])

grid = expand.grid(PCA = c(T,F), 
                   perplexity = c(15,20,25,30,35),
                   scale_it = c(T,F),
                   log_it = c(T,F))

results <- vector(mode='list', length = nrow(grid))

for(i in 1:nrow(grid)){
   M0 <- M
  if(grid[i,'log_it'])   M0 <- log1p(M0)
  if(grid[i,'scale_it']) M0 <- scale(M0)
  
results[[i]] <- Rtsne(M0, 
                      dims = 2, 
                      initial_dims = 75, 
                      perplexity = grid[i,'perplexity'], 
                      theta = .5,
                      pca = grid[i,'PCA'],
                      verbose = T,
                      max_iter = 2000)
}

plot(TSNE_raw$Y[idx,],pch = 19 , cex = .5, col= X$y[idx])
plot(TSNE_log1p$Y[idx,],pch = 19 , cex = .5, col= X$y[idx])
plot(TSNE_log1p$Y[idx,],pch = 19 , cex = .5, col= X$y[idx])
plot(TSNE_raw_scale$Y[idx,],pch = 19 , cex = .5, col= X$y[idx])
plot(TSNE_raw_scale_noPCA$Y[idx,],pch = 19 , cex = .5, col= X$y[idx])
plot(TSNE_raw_noPCA$Y[idx,],pch = 19 , cex = .5, col= X$y[idx])


plot(TSNE_raw_scale_noPCA$Y[idx,2],TSNE_raw_scale$Y[idx,1] ,pch = 19 , cex = .5, col= X$y[idx])

require(car)
scatter3d(x=TSNE_raw3$Y[idx,1],y=TSNE_raw3$Y[idx,2],z=TSNE_raw3$Y[idx,3],surface =F,
          point.col = as.numeric(X$y[idx]))
