###


build_pct <- function(X,col,cutoff=30){
  setkey(X,time)
  counts_by_bidder <- X[,unique(get(col)), by = bidder_id]
  t1 <- train[counts_by_bidder]
  t2 <- t1[, list(tot= sum(outcome,na.rm=T), count = sum(!is.na(outcome))), by = V1] 
  t3 <- t2[count>cutoff, list(V1=V1, pct=tot/count)]
  
  setnames(t3,'V1',col)
  
  setkeyv(t3,col)
  setkeyv(X,col)
  
  ztemp <- t3[X][,unique(pct,na.rm=T),    by = c('bidder_id',col)]
  
  zmax <- ztemp[,ifelse(sum(!is.na(V1))>cutoff, mean(tail(sort(V1),5 )),as.numeric(NA)), keyby = bidder_id]
  zmax[is.infinite(V1),V1:= NA]
  
  zmean <- ztemp[,ifelse(sum(!is.na(V1))>cutoff, mean(V1,na.rm=T),as.numeric(NA)), keyby = bidder_id]
  
  zmin <- ztemp[,ifelse(sum(!is.na(V1))>cutoff, mean(head(sort(V1),5 )),as.numeric(NA)), keyby = bidder_id]
  zmin[is.infinite(V1),V1:= NA]
  
  setkey(X,time)
  L = list(zmin,zmean,zmax)
  L
  
  
}


build_freq <- function(X,col,stat){
   z <-  X[, list(count = .N) ,  keyby = col  ]
   z1 <- X[,unique(get(col)), by = bidder_id]
   setnames(z1,'V1',col)
   setkeyv(z1,col)
   j = z[z1][, stat(as.numeric(count)), keyby = bidder_id ]
   j
}
  











