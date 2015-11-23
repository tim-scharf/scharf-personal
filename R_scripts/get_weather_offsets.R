require(data.table)
require(parallel)
X = fread('weather.csv')
source('funx.R')
X[,codesum:=NULL]
# 1] "station_nbr" "date"        "tmax"        "tmin"        "tavg"        "depart"     
# [7] "dewpoint"    "wetbulb"     "heat"        "cool"        "sunrise"     "sunset"     
# [13] "codesum"     "snowfall"    "preciptotal" "stnpressure" "sealevel"    "resultspeed"
# [19] "resultdir"   "avgspeed"
# weather data to gather
cols = names(X)[!names(X)%in%c('station_nbr','date')]
X[,date:=as.Date(date)]
setkey(X,station_nbr,date)

offsets = c(-5:-1,1:5)

W <- array(0,dim = c(nrow(X),length(cols),length(offsets)))
for(i in 1:length(offsets))
{
  offset <- offsets[i]
  

  X0  <-  copy(X)

  X0[,date:= date - offset]
  setkey(X0,station_nbr,date)
  
  DT <-  X0[X,cols,with=F]

  clean_cols  <- colnames(DT)
  DT[,(clean_cols):=mclapply(.SD,clean,na.val=NA,mc.cores=8),.SDcols = clean_cols]
  
  W[,,i] <- as.matrix(DT)
  
}



W_minus  <- apply(W[,,1:5],1:2,mean,na.rm=T)
W_plus  <- apply(W[,,6:10],1:2,mean,na.rm=T)

W_max  <- apply(W,1:2,max,na.rm=T)
W_min  <- apply(W,1:2,min,na.rm=T)



minus <- cbind(X[,station_nbr,date],W_minus)
plus <- cbind(X[,station_nbr,date],W_plus)
MAX <- cbind(X[,station_nbr,date],W_max)
MIN <- cbind(X[,station_nbr,date],W_min)


old  <-  names(minus)[3:ncol(minus)]
new_minus  <- paste0('minus_',names(X)[3:ncol(X)])
new_plus  <- paste0('plus_',names(X)[3:ncol(X)])
new_MAX  <- paste0('max_',names(X)[3:ncol(X)])
new_MIN  <- paste0('min_',names(X)[3:ncol(X)])


setnames(minus,old, new_minus)
setnames(plus,old, new_plus)
setnames(MAX,old, new_MAX)
setnames(MIN,old, new_MIN)


setkey(minus,station_nbr,date)
setkey(plus,station_nbr,date)
setkey(MAX,station_nbr,date)
setkey(MIN,station_nbr,date)

weather_offsets <- plus[minus[MAX[MIN]]]

f_dowle2(weather_offsets)


saveRDS(weather_offsets,'X_plus_minus_min_max')
