
require(data.table)
require(kknn)
require(doMC)
require(entropy)
registerDoMC(8)
source('funx.R')

X <- makeMat('train.csv')
Xtest <- makeMat('test.csv')
y <- readRDS('y')
kmax  = 500

transforms = list(X, sqrt(X+3/8), log1p(X))
transforms_test = list(Xtest, sqrt(Xtest+3/8), log1p(Xtest))

DATA      = lapply(transforms,     function(d)  as.data.table(d)[,y:=y] )
DATA_TEST = lapply(transforms_test,function(d)  as.data.table(d))

K <- foreach(D = iter(DATA))%dopar%{
  k1 <- train.kknn( y ~ ., data = D, kmax=kmax, kernel = c('biweight','triangular', 'epanechnikov',
                                                         'rectangular','cos','inv','gaussian','optimal',
                                                         'triweight') ,distance=2 )
}

save(K,file = paste0('K_master_train_',kmax)

K_ <- foreach(D = iter(DATA))%dopar%{
  
  k1 <- train.kknn( y ~ ., data = DATA[[3]], scale = F, kmax=kmax, kernel = 'rectangular' ,distance=2 )

}




## triangular K = 15 ~ .1915 err rate ,DATA[[2]]
save(K,file = 'kknn_master_train')



k <- kknn( y ~ ., train  = DT ,  test = DT, k=15 + 1, kernel = 'triangular' ,distance=2)
## build out of fold knn_raw
## already saved out of fold 'kknn_out_of_fold_k15_triangular'

k_test <- kknn( y ~ ., train  = DATA[[2]] ,  test =DATA_TEST[[2]] , k=15, kernel = 'triangular' ,distance=2)
save(k_test,file ='knn_test_probs_k15_triangular')



