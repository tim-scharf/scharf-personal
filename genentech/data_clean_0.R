library(data.table)
library(bit64)
library(RcppCNPy)
library(lubridate)
setwd('~/repos/scharf-personal/genentech/')
source('funx.R')

P <- importPatients()
P <- excludePatients(P)

#buildFixed(P)


I <- P[,.(patient_id,is_screener)]


X <- fread('~/data/genentech/patient_activity_head.csv')
X <- excludePatients(X)
X[,date:=ym2numeric(activity_year,activity_month)]
X[,activity_year:=NULL]
X[,activity_month:=NULL]
setkey(X,patient_id)
train_idx <- I[,!is.na(is_screener)]

X_train <- X[train_idx]
X_test <- X[!train_idx]





