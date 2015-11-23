source('params.R')

require(doMC)
registerDoMC(8)
D <- foreach(i=1:nDrivers) %dopar%
{ 
  thisDriver = loadDriver(drivers[i])
  maxV <- lapply(thisDriver,function(x)max(vel_raw(x)))
  M <- matrix(unlist(maxV),nrow = 200,byrow=T)

}

D <- abind(D,rev.along=0)#convert List to array
saveRDS(D,file = 'MAX_VEL_RAW')

