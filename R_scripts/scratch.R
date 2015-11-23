
source('funcx.R')

skip_n=0
nClips=175
D <- getData(nClips,skip_n)
cols <- names(D)[2:57]

A0 <- D[,lapply(.SD,function(x)(x-mean(x[1:8]))/sd(x)  ), .SDcols = cols,by=key(D)]
A <- A0[,list(mu=rowMeans(.SD)),.SDcols = cols,by = key(A0)]
spline = A[,list(spline = smooth.spline(mu,spar=.5)$y),by = key(A)]

W <- spline[,as.list(spline),by=key(spline)]
cols= names(W)[-c(1,2,3)]
setkey(W,subject,session,FB)


### this affex everything
a0 <- W[,  colMeans(.SD)   ,.SDcols =cols,by=c('subject') ] ##
alpha <- a0[, list(mx=max(which(diff(sign(diff(V1[1:52])))==2),25)),by = key(alpha)]       
setkey(alpha,subject)
setkey(W,subject)

off_idx <- W[alpha]$mx
mat <- as.matrix(W[,cols,with=F])
M <- t(mapply(function(row,idx)mat[row,idx:(idx+125)], 1:nrow(mat),off_idx    ))

n=length(cols)
par(mfrow=c(3,2))
idx = seq(1,26)
lapply(idx,function(i)
plot(x = rep(1:n),as.numeric(z[i,cols,with=F]) ,col = 'green',main = z[i,subject])
)


i=3
plot(as.numeric(z[i,(cols),with=F]),col = 'black',pch='-')
points(as.numeric(z[i+1,cols,with=F]),col='red',pch='+',)
title(main=z[i,subject])
