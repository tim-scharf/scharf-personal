X = fread('train_2013.csv',select='Expected')
X[Expected>70,Expected:=70]

E <- X$E

E <- E[E>5]

loss  <- function(z,p){ mean((p-z)^2)}


p <- sapply(0:69,function(z)sum(E<=z)/length(E))
p2 <- sapply(0:69,function(z)sum(E[-train_idx]<=z)/length(E[-train_idx]))

M = t(sapply(E,function(z)as.numeric(0:69>=z)))
err <- apply(M,1,loss,p=p)

for( i in  0:80){
  idx = which(E<=i)
  cat(i,' ',sum(err[idx]/sum(err)),'\n')
}




