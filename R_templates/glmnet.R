## stacking models
source('funx.R')
require(glmnet)
require(doMC)
registerDoMC(8)

X =      makeMat('train.csv')
X_test = makeMat('test.csv')

X <- log1p(X)
X_test  <- log1p(X_test)

y <- as.numeric(readRDS('y')[-DATA$idx])-1

start = proc.time()[3]
glm1  <-   cv.glmnet(x = X,
                     y = y,
                     family='multinomial',
                     parallel = T,
                     nfolds=16,
                     keep =T,
                     alpha=1,                     
                     type.logistic = 'modified.Newton')

print(proc.time()[3]-start)

s = glm1$lambda.1se
idx <- which(glm1$lambda==s)

X_fold <- glm1$fit.preval[,,idx]
X_pred <-drop(predict(glm1,newx = X_test,s = s,type = 'response'))

L = list(fold=X_fold, pred=X_pred)
saveRDS(L,'BLENDER/glm')

