## stacking models
source('funx.R')
require(glmnet)
require(doMC)
require(data.table)
require(zoo)

registerDoMC(8)

Obag    =    readRDS('obag')
setkey(Obag,id)

DT = readRDS('X_full_DT')
DT[,id:=paste(store_nbr,item_nbr,date,sep='_')]
setkey(DT,id)

X = Obag[DT]
setkey(X,store_nbr,item_nbr,date)

X[,err:=(pred-log1p(units))^2]
X[,day_fac:=factor(day_nbr)]



M <- model.matrix( ~ -1 + pred:month:day_fac ,data= X[!is.na(units)])
y <- X[!is.na(units),log1p(units)]


start = proc.time()[3]
glm1  <-   cv.glmnet(x = M,
                     y = y,
                     lambda = exp(seq(-5,-10,length.out = 50)),
                     family='gaussian',
                     parallel = T,
                     nfolds=16,
                     keep = T,
                     alpha=1)

print(proc.time()[3]-start)

s = glm1$lambda.1se
idx <- which(glm1$lambda==s)

X_fold <- glm1$fit.preval[,,idx]
X_pred <-drop(predict(glm1,newx = X_test,s = s,type = 'response'))

L = list(fold=X_fold, pred=X_pred)
saveRDS(L,'BLENDER/glm')

