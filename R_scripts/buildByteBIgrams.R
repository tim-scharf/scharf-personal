require(data.table)
require(doMC)
registerDoMC(cores = 8)

files = sort(list.files('/media/tim-ssd/backup/malware_data/byte',full.names = T))

alpha = c(0:9,'A','B','C','D','E','F')
hex =  c('??',as.character(outer(alpha,alpha,FUN = 'paste0')))
bigram_lev = as.character(outer(hex,hex,FUN='paste0'))


start = proc.time()

M = foreach(file = iter(files))%dopar%
{
  
  corpus = fread(input = file,header = F)
  n = nrow(corpus)
  bigram = factor( corpus[,paste0(V1[1:(n-1)], V1[2:n])], levels = bigram_lev)
  t1 = tabulate(bigram,nbins = 66049)
  t1

}

time = proc.time() - start
print(time[3])



V = do.call(rbind,M)

rownames(V) = substring(basename(files),1,20)
saveRDS(V,'bigram_mat')

