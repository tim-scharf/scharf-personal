#### set PARAMS   ############### 
options(scipen=100)
require(Metrics)
evalerror <- function(preds, dtrain) {
  labels <- getinfo(dtrain, "label")
  
  err <- mean(log(unlist(lapply(0:(length(labels)-1), function(i)  preds[ 9*i + labels[i+1]+1] ))))
  
  return(list(metric = "multi_logloss", value = -err))
}


normData <- function(DT,cols){
  require(entropy)
  DT[,sums:=rowSums(.SD),.SDcols=cols]
  DT[,nnz:=apply(.SD,1,function(x)sum(x!=0)),.SDcols=cols]
  DT[,ntrpy1:=apply(.SD,1,entropy),.SDcols = cols]
  DT[,var:=apply(.SD,1,var),.SDcols = cols]
  DT[,max:=apply(.SD,1,max),.SDcols = cols]
  #DT[,median_nz:=apply(.SD,1,function(x)median(x[x!=0])  ),.SDcols = cols]
  
  DT[,mu_nz:=apply(.SD,1,function(x)mean(x[x!=0])),.SDcols = cols]
  DT[,var_nz:=apply(.SD,1,function(x)var(x[x!=0])),.SDcols = cols]
  for (j in names(DT))
    set(DT,which(is.na(DT[[j]])),j,0)
  #tf <- function(x,y=DT[,sums]) {as.numeric(x)/y}
  #DT[,(cols):=lapply(.SD,tf),.SDcols=cols]
}

makeMat <- function(file)
{ require(data.table)
  X <- fread(file)
  feat_cols <- names(X[,!c('id','target'),with=F])     
  normData(X,feat_cols)
  M <- as.matrix(X[,!c('id','target'),with=F])
  M

}



# save results
writePred <- function(P,outfile,id = fread('test.csv')[,id])
{ 
  
  colnames(P) <- paste('Class',1:9,sep='_')
  final <- cbind(id,P)  
  write.table(final,file = outfile,quote=F,row.names=F,sep=',')
}

require(Metrics)
multi_logLoss <- function(p,truth){
  p = apply(p,2,function(col) col/rowSums(p))  
  z <- mapply(FUN = function(x,y) ll(actual = 1, predicted =  p[x,y]) ,x = seq_len(nrow(p)),y = truth+1)
  mean(z)
     }




##############3 cooker
getTemp <- function(p){

n=500
temp = seq(.9,1.5,length.out = n)
delta = matrix(0, nrow=n, ncol=9)
max_class = apply(p,1,which.max)

for(k in 1:9){
  k_idx <- which(max_class==k)
  x <- p[k_idx,]
  base_line = multi_logLoss(x,y[-idx][k_idx])
  for(i in 1:n){
    z = x**(temp[i])
    z_norm = apply(z,2,function(col) col/rowSums(z))
    score = multi_logLoss(p = z_norm,truth = y[-idx][k_idx])
    delta[i,k] <- score-base_line
  }
  
}


return( temp[apply(delta,2,which.min)])
}


cookPred <- function(p,heat){
  max_class <- apply(p,1,which.max)
  p_cooked <- p
  for(i in 1:9)
  {
    cook_idx <- which(max_class==i)
    p_cooked[cook_idx,] <- p_cooked[cook_idx,]**heat[i]
  
  }
  p_cooked2 <- apply(p_cooked,2,function(col) col/rowSums(p_cooked))
  return(p_cooked2)
}

softmax <- function(p,tau){t(apply(p,1,function(row) exp(row/tau)/ sum(exp(row/tau))))}


cookRaw <- function(p_raw){
  
  n=500
  temps = seq(.6,1.25,length.out = n)
  delta = matrix(0, nrow=n, ncol=9)
  max_class = apply(p_raw,1,which.max)
  
  for(k in 1:9){
    k_idx <- which(max_class==k)
    x <- p_raw[k_idx,]
    base_line = multi_logLoss(softmax(x,tau=1),y[-idx][k_idx])
  for(i in 1:n)
    {
    tau = temps[i]
    A <- softmax(x,tau=tau)
    loss <- multi_logLoss( A ,y[-idx][k_idx])
    delta[i,k] <- loss-base_line
    
  }
  
  
}

return(delta)}



merge_pred <- function(in_files){
  X    <- lapply(in_files,fread)
  out  <- paste(in_files,collapse='_BLEND_')
  X_mat <- lapply(X,function(x) as.matrix(x[,2:10,with=F]))
  P  <-  Reduce('+',X_mat)/length(X_mat)
  sub  <-  fread('sampleSubmission.csv')
  new_sub <- cbind(sub$id,P )
  colnames(new_sub) <- colnames(sub)
  write.table(new_sub,out,sep=',',row.names=F,quote=F)
}
