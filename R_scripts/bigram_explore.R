require(data.table)
B = readRDS('bigram_mat')


x = colSums(B)

idx = which(x>1000000)

D = B[,idx]

D2 = log1p(D)

P = prcomp(D,.scale=T)

Z = as.data.table(P$x[,1:10])
Z[,Id:=rownames(P)]
