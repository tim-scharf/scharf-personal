require(data.table)
setwd("~/repos/scharf-personal/rossman")

X <- fread('train.csv')
X0 <- fread('test.csv')

X[,dt:=as.Date(Date, format =  "%Y-%m-%d" )]
X[,date_num:=as.numeric(dt)]
X[,month_num:=month(dt)]
X[,wday_num:=wday(dt)]
X[,mday_num:=mday(dt)]
X[,yday_num:=yday(dt)]
X[,mu_sales:= mean(Sales), by = Store]
X[,SchoolHoliday:=as.numeric(SchoolHoliday)]
X[,StateHoliday_mu:=mean(Sales), by = StateHoliday]

data_cols = c('Open','Promo','StateHoliday_mu','SchoolHoliday','date_num',
              'month_num','wday_num','mday_num','yday_num','mu_sales')

y <- X[,Sales]
X <- as.matrix(X[,data_cols,with=F])

