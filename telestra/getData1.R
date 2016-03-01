source('getDat0.R')
train_idx <- readRDS('train_idx.rds')

DT <- S[L[R[E]]]
DT[,n_loc:=X$n_loc]
DT[,loc_num:=X$loc_num]
DT[,e:=apply(.SD,1,entropy),.SDcols = names(DT)[-1]]

P <- readRDS('P.rds') 
P_test <- readRDS('P_test.rds')

X <- cbind(DT[train_idx],P)
X_test <- cbind(DT[test_idx],P_test)

saveRDS(X,'X.rds')
saveRDS(X_test,'X_test.rds')
