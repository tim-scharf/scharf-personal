require(data.table)
require(doMC)
registerDoMC(8)
train = readRDS('D.int')
test = readRDS('D.int.test')
E = D$E
source('funx.R')
sub = fread('sampleSubmission.csv')

D= train
train_idx = sample(dim(D)[1],1e6,replace=F)
cols =  names(D)[1:3]
A <- lapply(cols,function(x) buildM_rr.int(D[,get(x)],E=E,n_cuts=50))
names(A) <- cols
lapply(A,function(x)sum(is.na(x)))
P <- lapply(cols,function(x)  predictCDF(M=A[[x]], vec = test[,get(x)]  ))
lapply(P,function(x)sum(is.na(x)))

lapply(P,function(x)scoreP(P=x,E=E[-train_idx])   )

beta = c(.35,.35,.30)
P2 = lapply(1:length(P),function(i) beta[i]*P[[i]])
P_final <- Reduce('+',P2)

scoreP(P2,E[-train_idx])
print(score)


S  <- lapply(P,function(x)scoreP(P=x,E=E[-train_idx])   )


idx = sample(dim(D)[1],1e6,replace=F)
A <- buildLW(vec = train$LW[idx],E = E[idx],n_cuts = 50)
PA <- predictCDF(M=A, vec = train[idx,LW]  )
scoreP(PA,E[-idx])


P_final <- data.table(Id= sub$Id,P_final)
P_final[,Id:=sub$Id]


