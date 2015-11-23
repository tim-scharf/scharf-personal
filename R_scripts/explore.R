require(data.table)
require(parallel)
require(Matrix)

##import raw data
train_raw      = fread('train.csv')
test_raw       = fread('test.csv')
key            = fread('key.csv')
weather        = fread('weather.csv');weather[,codesum:=NULL]
weather_offsets=readRDS('X_plus_minus')


#all together train and test, NA's populate the units values for test data
# join stores to weather stations
setkey(train_raw,store_nbr)
setkey(test_raw,store_nbr)
setkey(key,store_nbr)

X_test  <-  key[test_raw]
D  <-  key[train_raw]


D[,keep:=mean(units)!=0,keyby=c('store_nbr','item_nbr')]
X_train <- D[keep==T,]
X_train[,keep:=NULL]

 
 #discard some test samples
idx <- which(X_test[,paste(store_nbr,item_nbr)] %in%  X_train[,paste(store_nbr,item_nbr)])  
 X <- rbind(X_train,X_test[idx],fill=T)


# convert date char to Date class - weather offsets has this done
X[,date:=as.Date(date)]
weather[,date:=as.Date(date)]


# now join weather and weahter_offsets to store 
setkey(weather,        station_nbr,date)
setkey(weather_offsets,station_nbr,date)
setkey(X,              station_nbr,date)

X <- weather[weather_offsets[X]]

 
## ~ #GB data.table ##### 


X[,month_num   := as.numeric(date)%%365]
X[,month   := month(date)]
 
X[,cal     := as.numeric(date)]
X[,day_num     := as.numeric(date)%%7]
X[,day     := weekdays(date)]
X[,day_nbr := as.numeric(substring(X$date,9))]  ## thinking 1st and 15th bump??

source('funx.R')
factor_cols  <- c('item_nbr','store_nbr','day','month')
X[,(factor_cols):=mclapply(.SD,factor,mc.cores=8),.SDcols = factor_cols]

#clean weather data and factor dates and store #
clean_cols  <- colnames(X)[sapply(X,is.character)]
X[,(clean_cols):=mclapply(.SD,clean,na.val=NA,mc.cores=8),.SDcols = clean_cols]

# saveRDS(X,'X_full_DT') 
 ##attributes


id <- X[,paste(store_nbr,item_nbr,date,sep='_')]
y  <- X[,log1p(units)] 

 
####build matrix

exclude = c('station_nbr','date','units')
xnam <- names(X)[!names(X)%in%exclude]
fmla <- as.formula(paste(" ~  -1 +", paste(xnam, collapse= "+")))

f_dowle3(X) ## takes NA tp -999
FULL <- model.matrix(fmla,data=X)

attr(FULL,'y')  <- y 
attr(FULL,'id')   <- id 

 ###

saveRDS(FULL,'X_full_min_max)')

 

# store_dir  <-'store_data/' 
# for(i in 1:length(unique(X$store_nbr)))
# {
# DATA = X[store_nbr==i]
# y  <- X[store_nbr==i,log1p(units)] #log the units for training
# id <- DATA[,paste(store_nbr,item_nbr,date,sep='_')]
# STORE  <- model.matrix(fmla,data=DATA)
# print(dim(STORE))
# attr(STORE,'y')  <- y
# attr(STORE,'id') <- id
# saveRDS(STORE, file =file.path(store_dir, paste0('store_nbr',i)  ))
# 
# 
# }













