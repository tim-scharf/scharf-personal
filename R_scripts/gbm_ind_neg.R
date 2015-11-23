packages = c('gbm','doMC','data.table')
source('packages.R')
source('params.R')
source('utilFunx.R')
registerDoMC(detectCores())
data=('D_full')
D <- readRDS(data)

################ P A R A M S#################################################3

inner_loop = 250  # how many models to build per positive example

#tree params
ntree = 300 
min_obs = 4
eta = .025
depth = 4

#task params
outfile='gbm16full_negatives_same_params_as_best_call_rank_first'
write=T
P <- matrix(0,nrow=nTrips,ncol=nDrivers)
#  do stuff
###########################################################################

set.seed(1975)
P=foreach(i = 1:nDrivers,.combine = cbind)%dopar%
{ 
  X1 <- as.matrix(D[,,i])
  #positve data (our driver)
  X0 <- D[,,sample((1:nDrivers)[-i],inner_loop,replace = F)]
  y <- c(rep(1,nTrips),rep(0,nTrips)) #labels same for all inner_loops
  p = numeric(nTrips)
  
  
  for(j in 1:inner_loop)
  {
    #new negative data for each inner loop
    X <- rbind(X1,X0[,,j])
    
    # worker function
    gbm1 <- gbm.fit(X,y,distribution = 'bernoulli',
                    n.trees=ntree,
                    interaction.depth = depth,
                    shrinkage=eta,
                    n.minobsinnode=min_obs,
                    bag.fraction=.5,
                    verbose=F)
    
    p=p+rank(predict(gbm1,X1,n.trees=ntree,type='response'))
    
  }
  p
}




#################################################################
yhat <- apply(P,2,rank)
if(write)
{
  yhat2csv(yhat,outfile)
  #rm(list=ls())
  #q()
}


