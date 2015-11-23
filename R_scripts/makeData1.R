require(data.table)
require(entropy)
byte_dir = '/media/tim-ssd//backup//malware_data//byte'
asm_dir = '/media/tim-ssd//backup//malware_data//asm'

cols= paste0('V',1:256)

M = readRDS('byte_mat')

# sorted
byte_size = file.info(sort(list.files(byte_dir,full.names = T)))[,1]
asm_size = file.info(sort(list.files(asm_dir,full.names = T)))[,1]
tots = rowSums(M)
Id = row.names(M)
ntrpy = apply(M,1,entropy)

M = t(apply(M,1,function(x) x/sum(x)))

X = as.data.table(M)
X[,Id:=Id]
X[,byte_size:=byte_size]
X[,asm_size:=asm_size]
X[,tots:=tots]
X[,ntrpy:=ntrpy]




######################################
setkey(X,Id)



saveRDS(X,'DT')
