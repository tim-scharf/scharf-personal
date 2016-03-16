
require(data.table)
require(Matrix)
require(xgboost)
require(methods)
require(utils)

setwd('~/repos/scharf-personal/BNP/')
lapply(list.files('master_binary/',full.names = T,recursive = T),source,print.eval=F,echo = F)

run0  <-     classifier_loop(Xtrain.rds = 'data/Xtrain.rds',
                             Xtest.rds = 'data/Xtest.rds',
                             y.rds = 'data/y.rds',
                             data_checks_func = data_checks_binary,
                             train_func = xgb_train_binary_tree,
                             iter =2000,
                             pct_train = .25)

saveRDS(run0,'data/run0.rds')     
rm(run0)
gc()


run1  <-     classifier_loop(Xtrain.rds = 'data/Xtrain_median_imp.rds',
                                 Xtest.rds = 'data/Xtest_median_imp.rds',
                                 y.rds = 'data/y.rds',
                                 data_checks_func = data_checks_binary,
                                 train_func = xgb_train_binary_linear,
                                 iter = 2000,
                                 pct_train = .2)

saveRDS(run1,'data/run1.rds')    
