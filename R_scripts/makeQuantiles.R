#make various Quantile Data
source('params.R')
require(doMC)
registerDoMC(8)

p=seq(0,1,length.out=10)

func1=jerk
D <- foreach(i = 1:nDrivers)%dopar%
{ 
    thisDriver  <-  loadDriver(drivers[i]) # load the driver
    data  <-  lapply(thisDriver,func1)     # apply function
    q <- lapply(data,quantile,probs=p)     # get quantiles
    M <- matrix(unlist(q),nrow=nTrips,byrow=T) # 
    M

}

D = abind(D,rev.along=0)


saveRDS(D,file = 'Q_jerk')



