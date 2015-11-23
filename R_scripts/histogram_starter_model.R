
library(data.table)
library(parallel)
train<-fread("train_2013.csv")


rr1.raw  <- mclapply(train$RR1, function(x) as.numeric(strsplit(x,split = ' ')[[1]]),mc.cores =8)
rr1.raw <- unlist(rr1.raw)
rr1.raw[rr1.raw<0] <- 0
rr1.raw[rr1.raw>70] <- 0

n_readings = unlist(lapply(rr1.raw,length))
Y = rep(train$Expected,times = n_readings)


weights  <- unlist(mclapply(train$RadarQualityIndex, function(x) as.numeric(strsplit(x,split = ' ')[[1]]),mc.cores =8))
weights[weights<0 | weights >1]  <- 0


idx <- sample(length(weights),50000)

plot(rr1.raw[idx],Y[idx],ylim = c(0,10),xlim = c(0,10))


W <- weights
for(i in 1:length(W)){
  W[[i]][W[[i]]<0 | W[[i]]>1] <- 0
  W[[i]] <- W[[i]]/sum(W[[i]]) 

}

rr1.w <- mapply(FUN = '%*%',W,rr1)







rr1.mean<-unlist(mclapply(train[,RR1], function(x) mean(pmax(0,pmin(70,as.numeric(strsplit(x," ")[[1]])))),mc.cores=8) )
rr1.median<-unlist(mclapply(train[,RR1], function(x) median(pmax(0,pmin(70,as.numeric(strsplit(x," ")[[1]])))),mc.cores=8) )
rr1.sum<-unlist(mclapply(train[,RR1], function(x) sum(pmax(0,pmin(70,as.numeric(strsplit(x," ")[[1]])))),mc.cores=8) )
## in case there are any NAs, replace with 0

idx = which(!is.na(rr1.w))

## look at the data
## notice most observations are 0, and after that most between 0 and 0.5
## so using typical quantiles or breaks will merely subdivide a really small range of measurements
## So instead, we break off the most popular buckets, and then divide the remainder of the RR1 distribution
## So we are asking for the ranges of RR1, but forcing the first and second range starts to be 0 and 0.5
table(round(rr1.mean))

D = rr1.w[idx]
Y = E[idx]

breaks<-c(-Inf,0,quantile(D[D>0.5],probs = seq(0,1,length.out=9)))
names(breaks)<-NULL
##store the break length to use throughout the rest of the code, in case you want to measure more breaks than 10
n<-length(breaks)-1   

## create a matrix to store predictions for key points along the RR1 distribution
obs<-matrix(,n,10)

## now fill in with empirical values
for(i in 1:n){	
	## for the various cutpoints (breaks) in the RR1 distribution, measure the frequency
	##	of the bottom 10 levels of the target value (0mm,1mm,2mm,...9mm)
	obs[i,1:10]<-hist(
		pmin(70,pmax(0,Y[D>breaks[i]&D<=breaks[i+1]])),
		plot=F,
		breaks=c(0:(n-1),70)
		)$density
}

## convert histogram to cumulative distribution
## this ensures we have non-decreasing predictions as well (requirement)

O <- t(apply(obs,1,cumsum))



## look over the values again
## looks a little peculiar in that some higher ranges have lower outcomes, but it is empirical
observations

## now construct a prediction by using the matrix as a lookup table to all 70 predictions
##  i.e. we'll find the RR1 value for every record, figure out which row in our small prediction table
##  it corresponds to, and use that entire row of the matrix as our prediction "vector"

test<-fread("test_2014.csv",select=c("Id","RR1"))

## parse the readings inside each RR1 value, which are space-delimited
rr1.mean<-unlist(lapply(test[,RR1], function(x) mean(pmax(0,pmin(70,as.numeric(strsplit(x," ")[[1]]))))))
rr1.mean[is.na(rr1.mean)]<-0

## seed the predictions with 1, which means it will rain <= each column 100% of the time
predictions<-as.data.frame(cbind(test$Id,matrix(1,nrow=nrow(test),ncol=70)))
colnames(predictions)<-c("Id",paste0("Predicted",(seq(1:70)-1)))

## override the 100% values with our table lookup; want to improve this? smooth the edge
for(i in 1:n){predictions[rr1.mean>breaks[i]&rr1.mean<=breaks[i+1],2:(n+1)]<-as.data.frame(t(observations[i,1:n]))}

## output predictions; outputs as 184MB, but compresses to 4.3MB (lot of 1's)
##scipen turns off scientific notation (for ID values such as 100000); Kaggle rejects those
options("scipen"=1000, "digits"=8)  
write.table(predictions,"histogram_benchmark.csv",quote = FALSE, sep = ",",row.names=FALSE)

##how long did it take (2.9 minutes on a Windows i5 with 6GB memory and slow HDD)
stop<-Sys.time()
stop-start