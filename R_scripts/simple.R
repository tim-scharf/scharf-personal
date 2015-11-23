
library(data.table)	
library(parallel)
library(doMC)
registerDoMC(8)
source('funx.R')

train = fread('train_2013.csv')
#train<-fread("train_2013.csv",select = c('RR1','RR2','RR3','RadarQualityIndex','Expected','TimeToEnd') )
test<-fread("test_2014.csv")


#Rtest <- buildX(test)
E = train$Expected
E[E>70] <- 70 #for plotting

R1 <-   getRR.int(DT = test,col='RR1')
R2 <-   getRR.int(DT = test,col='RR2')
R3 <-   getRR.int(DT = test,col='RR3')
NP <-   get_n_Pings(DT = test)
LW <-   getLogWater(DT = test)

D <- data.table(R1=R1,R2=R2,R3 = R3,NP = NP,LW = LW)

saveRDS(D,'D.int.test')

