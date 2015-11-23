require(data.table)
X <- fread('sampleSubmission.csv')


cols = rainbow(9)

par(mfrow = c(3,3))
for(k in 1:9){
  plot(X2[,k],X3[,k],col=cols[k],cex=.2,pch= 19,
       xlab = 'X2',ylab='X3',main = paste('Class ',k))
  abline(a=0,b=1,lwd = 2)
}

sub1 <- cbind(X$id, X0)
colnames(sub1) <- colnames(X)
write.table(sub1,'sub1',sep=',',row.names=F,quote=F)

sub2 <- cbind(X$id, X1)
colnames(sub2) <- colnames(X)
write.table(sub2,'sub2',sep=',',row.names=F,quote=F)

sub3 <- cbind(X$id, (X1+X0)/2)
colnames(sub3) <- colnames(X)
write.table(sub3,'sub3',sep=',',row.names=F,quote=F)

