## stacking models
source('funx.R')
require(glmnet)
require(doMC)
registerDoMC(8)

raw_file = 'META_RAW//rf'
L = readRDS(raw_file)

X = L$fold_raw
X_test <- L$pred_raw
y <- readRDS('y')

start = proc.time()[3]
glm1  <-      cv.glmnet(x = X,
                        y = y,
                        family='multinomial',
                        parallel = T,
                        nfolds=12,
                        keep =T,
                        alpha=0,                     
                        type.logistic = 'modified.Newton')

print(proc.time()[3]-start)


s = glm1$lambda.1se
idx <- which(glm1$lambda==s)

X_fold <- glm1$fit.preval[,,idx]
X_pred <-drop(predict(glm1,newx = X_test,s = s,type = 'response'))

L = list(fold=X_fold, pred=X_pred)
saveRDS(L,'BLENDER/platt_scaled_rf')
