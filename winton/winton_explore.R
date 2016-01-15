setwd('winton/')
require(data.table)
X0 <- fread('~/data/winton/train.csv')
X1 <- fread('~/data/winton/test_2.csv')
f_cols <- names(X0)[2:26]

XF0 <- X0[,f_cols,with=F]
XF1 <- X1[,f_cols,with=F]

tt <- mapply(function(x,y)   t.test(x,y), XF0,XF1)
hist(X0$Feature_7,250,col = 'red',freq = F)                     # centered at 4
hist(X1$Feature_7,250,col=rgb(1,0,0,1/4),freq=F,add = T)         

plot( p1, , # centered at 4
plot( p0, col=rgb(0,0,1,1/4), xlim=c(-.25,.25), add=T)  # first histogram


