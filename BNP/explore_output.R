require(Metrics)
require(e1071)

outputRDS <- 'data/run0.rds'

list2env(readRDS(outputRDS),.GlobalEnv)
y <- readRDS('data/y.rds')

#class wise bias
err_mu <- ll(y,mean(y))

# mean adjusted loss
L <- apply(PCV,2,function(col) ll(y,col) )
M <- log(PCV/(1-PCV))

mu_loss <- rowMeans(L,na.rm=T)
mu_p <- rowMeans(PCV,na.rm=T)

mu_m <- rowMeans(M,na.rm=T)
min_m <- apply(M,1,min,na.rm=T)
max_m <- apply(M,1,max,na.rm=T)


z <- apply(M,1,sd,na.rm=T)


sk <- apply(M,1,skewness, na.rm=T)
k <- apply(M,1,kurtosis,na.rm=T)
q <- t(apply(M,1,quantile, probs = seq(0,1,length.out = 11),na.rm=T))

err_mu <- ll(y,mean(y))
LZ <- (L/err_mu)
LZ_mu <- rowMeans(LZ,na.rm = T)

DT <- data.table(mu_p=mu_p,k=k,sk=sk,y=y,z=z)

ggplot(data = DT, aes(z, fill=factor(y))) + geom_density(alpha = .2)
DATA[[1]]

H <- rbindlist (lapply(DATA,function(i)i$param))
