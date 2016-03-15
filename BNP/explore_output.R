require(Metrics)
list2env(readRDS('data/xgb_full_loop.rds'),.GlobalEnv)
loss_iter <- sapply(DATA,function(i) i$cv_score )

mu_p <- rowMeans(PCV,na.rm=T)
L <- apply(PCV,2,function(col)ll(y,col) )
loss <- rowMeans(L,na.rm=T)
y <- readRDS('data/y.rds')

z <- apply(PCV,1,sd,na.rm=T)
sk <- apply(PCV,1,skewness, na.rm=T)
k <- apply(PCV,1,kurtosis,na.rm=T)
q <- apply(PCV,1,quantile, probs = seq(0,1,length.out = 21),na.rm=T)
q <- t(q)

z <- ll(y,mean(y))
LZ <- L-z

DT <- data.table(mu_p=mu_p,k=k,sk=sk,y=y,z=z)

ggplot(data = DT, aes(z, fill=factor(y))) + geom_density(alpha = .2)
DATA[[1]]

H <- rbindlist (lapply(DATA,function(i)i$param))
