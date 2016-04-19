
require(data.table)
require(Matrix)
require(xgboost)
require(methods)
require(utils)
require(binary)
devtools::load_all('~/repos/binary/')
setwd('~/repos/scharf-personal/numerai/')

run0  <-     classifier_loop(Xtrain.rds = 'data/Xtrain.rds',
                             Xtest.rds = 'data/Xtest.rds',
                             y.rds =  'data/y.rds',
                             data_checks_func = data_checks_binary,
                             train_func = xgb_train_binary_tree_weighted,
                             iter =2000,
                             pct_train = .10,
                             w = readRDS('data/w.rds'))

saveRDS(run0,'data/run0.rds')     
rm(run0)
gc()
# 
# 
run1  <-     classifier_loop(Xtrain.rds = 'data/Xtrain.rds',
                                 Xtest.rds = 'data/Xtest.rds',
                                 y.rds = 'data/y.rds',
                                 data_checks_func = data_checks_binary,
                                 train_func = xgb_train_binary_linear,
                                 iter = 1000,
                                 pct_train = .10)

saveRDS(run1,'data/run1.rds')    
