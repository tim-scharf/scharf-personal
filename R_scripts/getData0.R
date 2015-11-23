require(data.table)

train_raw      = fread('train.csv')
test_raw       = fread('test.csv')
key            = fread('key.csv')
weather        = fread('weather.csv')
weather_offsets=readRDS('X_weather_offsets_raw')

setkey(train_raw,store_nbr)
setkey(test_raw,store_nbr)
setkey(key,store_nbr)


# add the weather stations to the data 
D_train = key[train_raw]
D_test  = key[test_raw]


#all together train and test, NA's populate the units values for test data
D      = rbind(D_train,D_test,fill = T)
D[,date:=as.Date(date)]
weather[,date:=as.Date(date)]


# now add the weather 
setkey(weather,station_nbr,date)
setkey(weather_offsets,station_nbr,date)
setkey(D,station_nbr,date)
X = weather_offsets[weather[D]]



X[,date:=as.Date(date)]
X[,day:=weekdays(date)]
X[,month:=months(date)]
X[,day_nbr:= as.numeric(substring(X$date,9))]  ## thinking 1st and 15th bump??

X[,id:=paste(store_nbr,item_nbr,date,sep='_')]
#length(unique(X$id))
#[1] 5144517
# nrow(X)
#[1] 5144517

setkey(X,id)

saveRDS(X,'X_raw_join')
