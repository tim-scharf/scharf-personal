source('params.R')

require(doMC)
registerDoMC(6)
D <- foreach(i=1:nDrivers) %dopar%
{ 
  thisDriver = loadDriver(drivers[i])
  air_land <- lapply(thisDriver,function(x)c(byAir(x),byLand(x)))
  M <- matrix(unlist(air_land),nrow = 200,byrow=T)
  M <- cbind(M,M[,1]/M[,2])
}

D <- abind(D,rev.along=0)#convert List to array
saveRDS(D,file = 'AL_R')
s
