source('make_obag_tele.R')
source('make_test_pred_tele.R')


train_idx <- readRDS('train_idx.rds')
y <- readRDS('y.rds')[train_idx]

model_dir = 'xgb_models/'
n_train = length(train_idx)

P      <- make_obag(n_train,model_dir,num_class = 3)
P_test <- make_test_pred(model_dir,num_class = 3)

saveRDS(P, 'P.rds')
saveRDS(P_test, 'P_test.rds')
