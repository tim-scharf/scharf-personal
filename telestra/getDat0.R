require(data.table)
setwd('~/repos/scharf-personal/telestra/')
X0 <- fread('~/data/telestra/train.csv')
X1 <- fread('~/data/telestra/test.csv')
X <- rbindlist(list(X0,X1),fill = T)
setkey(X,id)
idx <- which(!is.na(X$fault_severity))

X[,n_loc:=.N,by=location]
fac_cols = c('y_0','y_1','y_2','y_NA')
X[,fac:=factor(fault_severity,exclude = NULL,labels = fac_cols )]
X[,loc_num:=as.numeric(substr(X$location,10,stop = 20))]

X2 <- X[,as.list(table(fac)),by = location]
fac_cols_prop <- paste( 'prop',fac_cols,sep = '_' )
X2[,(fac_cols_prop):= .SD/(sum(.SD)),by = location]
X2[,loc_num:=as.numeric(substr(X2$location,10,stop = 20))]
X2[,entrpy:=apply(.SD,1,entropy),.SDcols=fac_cols,by = location]
setkey(X2,location)

logs <- fread('~/data/telestra/log_feature.csv')
setkey(logs, id,log_feature)
L <- dcast(logs, id~log_feature,value.var = 'volume',fill = 0)

severity_type <- fread('~/data/telestra/severity_type.csv')
severity_type[,V1:=1]
S <- dcast(severity_type, id~severity_type, value.var ='V1',fill = 0)
setkey(S,id)

events <- fread('~/data/telestra/event_type.csv')
events[,V1 :=1]
setkey(events,id, event_type)
E <- dcast(events, id ~ event_type, value.var = 'V1', fill = 0)

resource <- fread('~/data/telestra/resource_type.csv')
resource[,V1:=1]
setkey(resource, id, resource_type)
R <- dcast(resource, id~ resource_type, value.var = 'V1', fill = 0)
