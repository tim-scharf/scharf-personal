require(Matrix)
require(data.table)
X <- readRDS('X_clean_join')
setkey(X,station_nbr,date)
tables()


exclude  <- c( 'station_nbr','date','id','units')

xnam <- names(X)[!names(X)%in%exclude]
fmla <- as.formula(paste(" ~ -1 +", paste(xnam, collapse= "+")))


Xfull  <- sparse.model.matrix(fmla,data=X)
saveRDS(Xfull,'X_full_sparse')
#log the units for training
y  <- log1p(X$units)
saveRDS(y,'y')
id <- X$id
saveRDS(id,'X_id')
