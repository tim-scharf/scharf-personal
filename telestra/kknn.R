require(kknn)

train_idx <- !is.na(X$fault_severity)

K <-as.data.table(TSNE$Y[train_idx,])
K[,y:=X[train_idx,fac]]


