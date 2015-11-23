
source('params.R')

require(doMC)
registerDoMC(8)
D <- foreach(i=1:nDrivers) %dopar%
{ thisDriver = loadDriver(drivers[i])
  M=unlist(lapply(thisDriver,function(x)dim(x)[1]))
  matrix(M,nrow=200)
  }
D <- abind((D),rev.along=0)
saveRDS(D,file = 'TRIP_TIME')
