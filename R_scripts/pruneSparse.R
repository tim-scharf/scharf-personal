require(slam)
require(tm)
require(data.table)
source('funx.R')
DTMraw = readRDS('DTM_full_asm')


DTM0 = as.DocumentTermMatrix(DTMraw,weighting = function(x)weightTf(x))

DTM0$v = log10(1+DTM0$v)

sparse_vals = seq(.7,.99,by=.02)

sparse = .75
for(sparse in sparse_vals){
DTM1 = removeSparseTerms(x = DTM0, sparse = sparse)
C = tcrossprod_simple_triplet_matrix(DTM1) / outer(row_norms(DTM1),row_norms(DTM1))
cat(eval_C_mat(C), '  ', sparse, '\n')
}

X = as.matrix(DTM1)
Id = rownames(X)
X = as.data.table(X)
X[,Id:=Id]
setkey(X,Id)
saveRDS(X,'DT0')

saveRDS(C,'cosine_sim_mat')
rm(list=setdiff(ls(), "C"))
