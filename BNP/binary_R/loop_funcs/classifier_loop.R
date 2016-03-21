classifier_loop <- function(Xtrain.rds,
                            y.rds, 
                            Xtest.rds, 
                            data_checks_func,
                            train_func,
                            iter,
                            pct_train){

#get data checks
Xtrain <- readRDS(Xtrain.rds)
Xtest  <- readRDS(Xtest.rds)
y <- readRDS(y.rds)
data_checks_func(Xtrain,Xtest,y)

#initialize output

OUTPUT <- train_func(Xtrain,Xtest,y,iter,pct_train)

}



