# get data
require(data.table)
require(Matrix)
require(xgboost)
require(methods)
require(utils)

setwd('~/repos/scharf-personal/BNP/')
source('xgb_loop_binary.R')
source('gen_param_binary.R')
source('data_checks_binary.R')
source('treat_factors.R')
source('replaceNA.R')


X <- rbindlist(list(fread('~/data/BNP/train.csv'),fread('~/data/BNP/test.csv')),fill = T)
train_idx <- which(!is.na(X$target))
test_idx <- which(is.na(X$target))
data_cols <- paste0('v',1:131)
fac_cols  <- names(X)[sapply(X,is.character)]
num_cols <- setdiff(data_cols,fac_cols)

MFAC <- treat_factors(X,fac_cols = fac_cols,max_cat = 1024)

#patterns <- TrainFastImputation(as.data.frame(X[,num_cols,with=F]))
#MFI <- FastImputation(as.data.frame(X[,num_cols,with=F]),patterns )
#saveRDS(MFI,'M_num_imputed.rds')
# MTSNE <- cbind(MFI, as.matrix(MFAC))
# saveRDS(MTSNE,'data_objects/MTSNE.rds')

X999 <- replaceNA(X[,num_cols,with=F],-999)
M999 <- as(as.matrix(X999), "sparseMatrix")
M <- cBind(M999,MFAC)

Xtrain <- M[train_idx,]
Xtest <- M[test_idx,]

y <- X[train_idx,target]

xgb_loop_binary(Xtrain,y,Xtest, m = 1000 ,missing = -999)

