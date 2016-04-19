require(Metrics)
require(e1071)

outputRDS <- 'data/run0.rds'

list2env(readRDS(outputRDS),.GlobalEnv)
y <- readRDS('data/y.rds')

#class wise bias
err_mu <- ll(y,mean(y))

# mean adjusted loss
L <- apply(PCV,2,function(col) ll(y,col) )
M <- log(PCV/(1-PCV))  #inverse sigmoid


mu_loss <- rowMeans(L,na.rm=T)
mu_p <- rowMeans(PCV,na.rm=T)
mu_m <- rowMeans(M,na.rm=T)

e <- ecdf(mu_m)
w <- e(mu_m)

w[y==0] <- 1 - w[y==0]

saveRDS(w,'data/w.rds')

min_m <- apply(M,1,min,na.rm=T)
max_m <- apply(M,1,max,na.rm=T)
z <- apply(M,1,sd,na.rm=T)





H <- rbindlist (lapply(DATA,function(i)i$param))
