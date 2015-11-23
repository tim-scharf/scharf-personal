## make prediction
require(data.table)
data_dir = 'xgb_pairwise//'
files = rev(list.files(data_dir,full.names = T))

top_N = length(files)
#rep = strsplit(files,split='_')
#r <- as.numeric(unlist( lapply(rep, function(i) i[[4]])))>500

P <- lapply(files,function(x)readRDS(x)$P_test)

pred <- Reduce('+',P)/length(P)

ids <- readRDS('test_id')

dt <- data.table(bidder_id = ids, prediction = pred)
setkey(dt,bidder_id)
# crop
sub  <- fread('submissions/xgb_500_.935_binary_log')
setkey(sub,bidder_id)

Z <- dt[sub]
Z[is.na(prediction),prediction:=0]
Z[,i.prediction:=NULL]



file_name = 'submissions/xgb_100_binarylog948'
write.table(Z,file = file_name,row.names=F,quote=F,sep=',')

