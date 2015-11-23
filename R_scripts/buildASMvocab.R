require(data.table)
require(doMC)
registerDoMC(cores = 7)

files = sort(list.files('/media/tim-ssd//backup//malware_data//asm',full.names = T))



start = proc.time()
M = foreach(file = iter(files))%dopar%
{
  corpus = fread(file, header=FALSE)
  t1 = corpus[,table(V1)]
  t1
}
time = proc.time() - start
print(time[3])
names(M) = substring(basename(files),1,20)
saveRDS(M,'asm_corpus_List')


