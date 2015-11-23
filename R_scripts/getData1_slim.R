require(data.table)
require(bit64)
require(entropy)
require(moments)
source('funx.R')

DT <- readRDS('X_full')

X <- clean_time(DT)
setkey(X,time)

## counts
 X[, device_freq  :=as.numeric(.N),  by = device  ] # 6 types
 X[, url_freq     :=as.numeric(.N),  by = url     ] # 6 types
 X[, ip_freq      :=as.numeric(.N),  by = ip      ] # 6 types
 X[, country_freq :=as.numeric(.N),  by = country ] # 6 types
 X[, auction_freq :=as.numeric(.N),  by = auction ] # 6 types
 
 #z <- X[, length(unique(auction)),  by = c('bidder_id','time')]
 
 
 #X[, crowded :=  .N  , by = c('auction','time') ]



# X[, auction_flow:= c(0,diff(time)), by = auction ]


# 
# X[, endflag:=bidder_id %in%   tail(bidder_id,10), by = auction]
# X[, startflag:=bidder_id %in% head(bidder_id,10), by = auction]


FEAT <- list(
  
     X[,   length(time),by = bidder_id],  #N total bids
#    X[,   length(unique(auction)), by = bidder_id],
#    X[,   length(unique(time)) ,   by = bidder_id],
#    X[,   length(unique(url)) ,    by = bidder_id],
#    X[,   length(unique(country)), by = bidder_id],
#    X[,   length(unique(ip)), by = bidder_id],
#    X[,   length(unique(device)), by = bidder_id],

      X[,median(diff(time)) ,  by = bidder_id],
#     X[,mean  (diff(time)) ,  by = bidder_id],
#     X[,sd    (diff(time)) ,  by = bidder_id],
#     X[,max    (diff(time)) ,  by = bidder_id],
#      X[,min    (diff(time)) ,  by = bidder_id],
#     X[,skewness    (diff(time)) ,  by = bidder_id],
#     X[,kurtosis    (diff(time)) ,  by = bidder_id],
#     
#   X[, as.numeric(entropy(table(diff(time)))), by = bidder_id],
#   X[, entropy(rle(ip)$lengths), by  = bidder_id],
#   X[, entropy(rle(url)$lengths), by  = bidder_id],
#   X[, entropy(rle(device)$lengths), by  = bidder_id],
#   X[, entropy(rle(country)$lengths), by  = bidder_id], #10
#   X[, entropy(rle(auction)$lengths), by  = bidder_id],
#   
#  X[,mean(device_freq), by = bidder_id],
#   X[,mean(url_freq), by = bidder_id],
#   X[,mean(ip_freq), by = bidder_id],
#   X[,mean(country_freq), by = bidder_id],
#   X[,mean(auction_freq), by = bidder_id],
#   
#   X[,max(device_freq), by = bidder_id],
#   X[,max(url_freq), by = bidder_id],
#   X[,max(ip_freq), by = bidder_id],
#   X[,max(country_freq), by = bidder_id],
#   X[,max(auction_freq), by = bidder_id],
#   
#   X[,min(device_freq), by = bidder_id],
#   X[,min(url_freq), by = bidder_id],
#   X[,min(ip_freq), by = bidder_id],
#   X[,min(country_freq), by = bidder_id],
#   X[,min(auction_freq), by = bidder_id],
# 
#   
  
  readRDS('same_bidder_diff_auction')

#   
#   X[, max(crowded), by = bidder_id]
#   ,
#   X[, sum(same_time_diff_auction), by = bidder_id],
#   
#   
#   X[, sum(consec__auction_bids), by = bidder_id] #total consecutive bids across auctions
#   ,
#   X[, median(auction_flow),by = bidder_id]
#   ,  
#   X[, var(auction_flow),by = bidder_id]
#   ,

#   

)

colnames <- paste('feat',1:length(FEAT),sep='_')
lapply(FEAT, function(i)    i[is.infinite(V1), V1:=NA]            )
lapply( 1:length(FEAT),function(i)  setnames(FEAT[[i]],'V1',  colnames[i])     )
lapply( 1:length(FEAT),function(i)  setkey(FEAT[[i]],bidder_id))


Z <- Reduce(merge,FEAT)


saveRDS(Z,'Z_slim')


