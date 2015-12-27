require(data.table)
require(bit64)

setwd('~/repos/scharf-personal/walmart/')
source('funx.R')
X0 <- fread('~/data/walmart/train.csv')
X1 <- fread('~/data/walmart/test.csv')

X <- rbindlist(list(X0,X1), use.names = T, fill = T)
setkey(X,VisitNumber)

X[,purch:=ScanCount]
X[purch<0, purch := 0]
X[,ret:=ScanCount*-1]
X[ret<0, ret:=0]


X[, alpha:=as.character(factor(DepartmentDescription,exclude=  NULL,labels = 'alpha'))]
X[, beta:=as.character(factor(Upc,exclude =  NULL,labels = 'beta'))]
X[, gamma:=as.character(factor(FinelineNumber,exclude=  NULL,labels = 'gamma'))]

X[, delta:=as.character(factor(substring(FinelineNumber,1,1),exclude=  NULL,labels = 'delta'))]
X[, epsilon:=as.character(factor(substring(FinelineNumber,2,2),exclude=  NULL,labels = 'epsilon'))]

p_basket <-  X[ ,.(p_basket = paste(c(makeBasket(alpha,purch),
           makeBasket(beta,purch),
           makeBasket(gamma,purch),
           makeBasket(delta,purch),
           makeBasket(epsilon,purch)), collapse = ' ')),keyby = VisitNumber]

r_basket <-  X[ , .(r_basket=paste(c(makeBasket(alpha,ret),
                          makeBasket(beta,ret),
                          makeBasket(gamma,ret),
                          makeBasket(delta,ret),
                          makeBasket(epsilon,ret)), collapse = ' ')),keyby = VisitNumber]

n_purch <- X[,.(n_purch=sum(purch)), keyby = VisitNumber]
n_ret <- X[,.(n_ret= sum(ret)), keyby = VisitNumber]
day <- X[,.(day=Weekday[1]),keyby = VisitNumber]
y <- X[,.(y = TripType[1]),keyby = VisitNumber]

D <- p_basket[r_basket[n_ret[n_purch[day[y]]]]]

write.table(D, 'DATA.csv', quote = F, sep=',',row.names=F)

