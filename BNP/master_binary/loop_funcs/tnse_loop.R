tnse_loop <- function( M, model_dir, meta )
{
require(Rtsne)
require(doMC) 
require(data.table)
if(!dir.exists(model_dir)){dir.create(model_dir)}
registerDoMC(2)

grid = expand.grid(PCA = c(T), 
                   perplexity = c(20,50,100,250),
                   scale_it = c(T),
                   asinh_it = c(T,F))

A <- foreach(i=1:nrow(grid),.verbose=T) %dopar%{
  PCA <- grid[i,'PCA']
  perplexity <- grid[i,'perplexity']
  scale_it <- grid[i,'scale_it']
  asinh_it <- grid[i,'asinh_it']
  
  data <- copy(M)
  if(asinh_it) data <- asinh(data)
  if(scale_it) data <- scale(data)
  print(i)
  z <-          Rtsne(X=data[1:300,],
                      perplexity = perplexity,
                      pca = PCA,
                      theta = .75,
                      verbose = T,
                      max_iter = 1000,
                      dims = 2,
                      initial_dims = 50)
  z
}

saveRDS(A,file.path(model_dir,'TSNE_list.rds')) }