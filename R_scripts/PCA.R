# princoomp

require(data.table)

A = fread('~/malwarepy/doc2vec_asm.csv',header=T)
B = fread('~/malwarepy/doc2vec_byte.csv',header=T)

X0 = as.matrix(A[,1:100,with=F])
X1 = as.matrix(B[,1:100,with=F])

X = cbind(X0,X1)

P = princomp(X,cor = T)

DT = as.data.table(P$scores[,1:10])
DT[,Id:=A[,Id]]
setkey(DT,Id)

DT
saveRDS(DT,'PCA_10comp_asm_byte')
