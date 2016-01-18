library(data.table)
library(bit64)
library(RcppCNPy)
library(lubridate)
setwd('~/repos/scharf-personal/genentech/')
data_dir <- '~/data/genentech'
source('funx.R')

P <- importPatients(data_dir = data_dir)
P <- excludePatients(P)

#buildFixed(P)


IDX <- P[,.(patient_id,is_screener)]


X <- fread( file.path(data_dir,'patient_activity_head.csv'))
X <- excludePatients(X)

setkey(X,patient_id)

train_idx <- IDX[,!is.na(is_screener)]

X_train <- X[train_idx]
X_test <- X[!train_idx]





