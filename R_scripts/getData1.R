require(data.table)
require(parallel)
require(Matrix)
X = readRDS('X_raw_join')
 
## dealing with weather codesum..
codesum = strsplit(X$codesum,split = ' ')
codes = unique(unlist(codesum))

## careful with the RAM here
z = mclapply(codesum,function(x) tabulate(factor(x,levels=codes),nbins= length(codes)),mc.cores=8  )
z = matrix(unlist(z), ncol =length(codes), byrow=T)
colnames(z)  <- codes


Z <- as(object = z,'sparseMatrix')
## code sums are now in separate matrix and removed from data

saveRDS(Z,'X_weather_codes_sparse')

