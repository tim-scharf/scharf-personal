require(data.table)
require(entropy)

setwd('~/repos/scharf-personal/telestra/')
X0 <- fread('data/train.csv')
X1 <- fread('data/test.csv')
X <- rbindlist(list(X0,X1),fill = T)
setkey(X,id)
idx <- which(!is.na(X$fault_severity))
test_idx <- which(is.na(X$fault_severity))

X[,n_loc:=.N,by=location]
X[,loc_num:=as.numeric(substr(X$location,10,stop = 20))]

fac_cols = c('y0','y1','y2','yNA')
X[,y:=factor(fault_severity,exclude = NULL,labels = fac_cols)]

X2 <- X[,as.list(table(y)),by = location]
y_prop <- paste( 'prop',fac_cols,sep = '_' )
X2[,(y_prop):= .SD/(sum(.SD)),by = location]
 
X2[,entrpy:=apply(.SD,1,entropy),.SDcols=fac_cols,by = location]
setkey(X2,location)

logs <- fread('data/log_feature.csv')
setkey(logs, id,log_feature)
L <- dcast(logs, id~log_feature,value.var = 'volume',fill = 0)

severity_type <- fread('data/severity_type.csv')
severity_type[,V1:=1]
S <- dcast(severity_type, id~severity_type, value.var ='V1',fill = 0)
setkey(S,id)

events <- fread('data/event_type.csv')
events[,V1 :=1]
setkey(events,id, event_type)
E <- dcast(events, id ~ event_type, value.var = 'V1', fill = 0)

resource <- fread('data/resource_type.csv')
resource[,V1:=1]
setkey(resource, id, resource_type)
R <- dcast(resource, id~ resource_type, value.var = 'V1', fill = 0)
