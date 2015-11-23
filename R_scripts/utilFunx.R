
loadDriver = function(driver,folder=driverDir)
{ 
  trips = paste(1:200,'csv',sep='.')
  thisD <- lapply(trips,
        FUN=function(x)as.matrix(fread(input = file.path(folder,driver,x))))   
  thisD
}

randTrips <- function(rand_size,withhold,full_pool=D)
{

rand_pool <- expand.grid(trip=1:200,driver=(1:2736)[-withhold])  
rand_set <- rand_pool[sample(nrow(rand_pool),rand_size),]

X0 <- t(apply(rand_set,1,function(x)full_pool[x[1],,x[2]]))
X0
}


yhat2csv <- function(yhat,file)
  {
  if (any(dim(yhat)!=c(200,2736))){stop('dimensions of yhat wrong!!!')}
  colnames(yhat)=drivers
  rownames(yhat)=1:200
  driver_trip = as.vector(t(outer(drivers,1:nTrips,paste,sep='_')))
  prob = as.vector(yhat) 
  submission <- data.frame(driver_trip,prob)
  write.csv(submission,file, row.names=F, quote=F)
  }



plot_badTrips <- function(driver_idx)
{
  driver <- loadDriver(drivers[[driver_idx]])  
  idx <- idx_list[[driver_idx]]
  col_map <- unlist(lapply(driver[idx],function(x) dim(x)[1]))
  
  cols = rep(1:length(idx),col_map)
  data  <- do.call(rbind,driver[idx])
  plot(data,pch=19,cex=.2,col=cols)
  
}

