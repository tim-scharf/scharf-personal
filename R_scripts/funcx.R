#functions
setwd('~/NER/')
train_dir <- ('~/NER/train/')
test_dir <- ('~/NER/test/')
require(data.table)
require(Metrics)
require(doMC)

require(zoo)
require(data.table)
registerDoMC(8)

Y <- fread(input='TrainLabels.csv')
y <- Y$Prediction

train_subs <- unique(substr(list.files(train_dir),6,8))
test_subs  <- unique(substr(list.files(test_dir),6,8 ))




getRaw <- function(nClips,skip_n=0)
{
  
  files = sort(list.files(c(train_dir,test_dir),full.names = T))  
  M <- foreach(i = iter(files))%dopar%
{  
  X <- fread(input=i,select=c('Cz','FeedBackEvent'))
  X[,idx:=.I]  # all of indexed
  setkey(X,idx)
  
  
  
  event_idx <- which(X$FeedBackEvent==1)
  X[,FB:=as.integer(cut(idx,breaks=c(event_idx,max(idx)),right=F,dig.lab=10))]
  
  ## info on file for messiness
  file_info = basename(i)
  file_string = unlist(strsplit(file_info,split = '_'))
  
  subject = file_string[2]
  session = as.integer(substr(file_string[3],5,6))
  X[,session:=session]
  X[,subject:=subject]
  
  get <- as.numeric(outer(X = event_idx,Y= (skip_n+(0:(nClips-1))),'+'))
  
  D <- X[idx%in%get,]
  D[,idx:=NULL]
  D[,FeedBackEvent:=NULL]
  D[,EOG:=NULL]
  
  setkey(D,subject,session,FB)
  D
}

D <- rbindlist(M,use.names = T)
setkey(D,subject,session,FB)
}


buildData <- function()
{
  
  nClips=75
  skip_n=50
  D <- getRaw(nClips,skip_n)
  
  #normalize each channel by voltage and group SD
  D[,sub_sd:=sd(Cz),by = subject]
  A0 <- D[,list(Cz_norm=(Cz-mean(Cz[1:5]))/sub_sd),by=key(D)]
  A <- A0[,list(spline = smooth.spline(Cz_norm,spar =.5)$y  ),by = key(A0)]
  
  W <- A[, as.list(spline),by = key(A)]
  cols = names(W)[-c(1,2,3)]
  W[,(cols)  :=  lapply(.SD,function(x) x - mean(x) ),.SDcols  = cols,by = subject]
  
  spline = W[,list(spline=unlist(.SD)),.SDcols = cols,by =key(W) ]
  
  
  
#   
    var1 <- spline[,list(var1=var(spline)),by=key(spline)]
    max1 <- spline[,list(max1=which.max(spline)),by=key(spline)]
    min1 <- spline[,list(min1=which.min(spline)),by=key(spline)]
   p1 <- spline[,list(p1=mean(spline[1:25] )),by=key(spline)]
   p2 <- spline[,list(p2=mean(spline[25:50])),by=key(spline)]
   p3 <- p2[p1][,list(p3= p2-p1), by = key(p2)]

   gmax <- spline[,list(gmax=max(spline)),by=key(spline)]
   gmin <- spline[,list(gmin=min(spline)),by=key(spline)]
   




   get_idx  <- round(seq(1,100, length.out = 10))
   d1 <- spline[,as.list(combn(spline[get_idx],2,diff)),by=key(spline)]
   
    
X   <- d1[var1][max1][min1][p1][p2][p3][gmax][gmin][W]
}






plotSubject <- function(sub)
{   

  clipLength = dim(spline)[1]/340/26
  
  data <- spline[subject==sub]
  col_idx <-spline[train_subs,.GRP,by=key(spline)][sub] 
  
  xmax <- nClips
  
  
  
  val = matrix(data[,spline],nrow=clipLength)
  col = y[col_idx$.GRP]
  mat_idx <- as.logical(col)
  
  pos = rowMeans(val[,mat_idx])
  neg = rowMeans(val[,!mat_idx])
  glob = rowMeans(val)
  derr = neg-pos
  
  plot(derr,col='blue',pch=19,ylim=c(-1,1))
  points(glob,col='green',pch=19)
  title(main = c(sub))
  abline(v = 20+which.max(glob[20:60]),lwd=2,col='green')
  abline(v= which.min(derr))
  points(sign(diff(glob)))
  abline(h=0)
  
  }
  

