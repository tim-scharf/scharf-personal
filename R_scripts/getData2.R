require(data.table)
require(parallel)
source('funx.R')

X = readRDS('X_raw_join')
X[,codesum:=NULL]
setkey(X,station_nbr,date)



factor_cols  <- c('day','month','item_nbr','store_nbr')
X[,(factor_cols):=mclapply(.SD,factor,mc.cores=8),.SDcols = factor_cols]


## removes M T -  and replaces with -999 for xgb .. probably should one-hot these
source('funx.R')
clean_cols  <- colnames(X)[sapply(X,is.character) & colnames(X)!='id']

#clean weather data and factor dates and store #
X[,(clean_cols):=mclapply(.SD,clean,mc.cores=8),.SDcols = clean_cols]



saveRDS(X, 'X_clean_join')




