
source('funx.R')

Y = fread('trainLabels.csv') 
y = Y$Class
idx = match(Y$Id,rownames(C))

X = 1 - C[idx,idx]


Z = foreach(i = 1:nrow(X),.combine = rbind)%dopar%
  k.nearest.neighbors(i=i,distance_matrix = X, k=100)
   
a = t(apply(Z,1,function(x)y[x]))
p = t(apply(a,1,tabulate,nbins =9))/100
p[p==1] <- .9999
p[p==0]  <- 1 - .9999
mlogloss(p,y)

plot(a[,1])

a_ntrpy  <-  apply(a,1,entropy)
p_ntrpy  <-  apply(p,1,entropy)

P = cbind(p,a_ntrpy,p_ntrpy)
rownames(P) <- rownames(X)
colnames(P)[1:9] <- paste0('class',1:9)



mlogloss= function(yhat,actual){
  actual =as.integer(actual)
  p = sapply(1:length(actual), function(i) yhat[i,actual[i]])
  logLoss(rep(1,length(actual)),p)
}
# needs Cosin sim matrix C
