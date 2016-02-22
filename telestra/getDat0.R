require(data.table)
setwd('repos/scharf-personal/telestra/')
X0 <- fread('~/data/telestra/train.csv')
X1 <- fread('~/data/telestra/test.csv')
X <- rbindlist(list(X0,X1),fill = T)
X[,n_loc:=.N,by=location]


logs <- fread('~/data/telestra/log_feature.csv')
setkey(logs, id,log_feature)
L <- dcast(logs, id~log_feature,value.var = 'volume',fill = 0)

S <- fread('~/data/telestra/severity_type.csv')

events <- fread('~/data/telestra/event_type.csv')
events[,V1 :=1]
setkey(events,id, event_type)

E <- events[CJ(unique(id),unique(event_type))][,as.list(V1),by =id]

resource <- fread('~/data/telestra/resource_type.csv')
resource[,V1:=1]
setkey(resource, id, resource_type)

R <- resource[CJ(unique(id),unique(resource_type))][,as.list(V1),by =id]

tables(
)

