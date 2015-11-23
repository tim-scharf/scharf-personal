require(doMC)
require(slam)
registerDoMC(8)

M = readRDS('asm_corpus_List')

vocab = unique(unlist(mclapply(M, function(m) unique(names(m)) ,mc.cores = 8  )))
N = length(M)


# build sparse matrix
i = mclapply(1:N,function(x) rep(x,length(M[[x]])) ,mc.cores = 8)
i = unlist(i)

j = sapply(M,function(m) match(names(m),vocab))
j = as.integer(unlist(j))

v = as.integer(unlist(M))

DTM = simple_triplet_matrix(i = i, j = j, v = v, dimnames = list(names(M),vocab))
saveRDS(DTM,file = 'DTM_full_asm')

