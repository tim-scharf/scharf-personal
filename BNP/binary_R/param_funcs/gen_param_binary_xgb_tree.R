gen_param_binary_xgb_tree <- function(seed,missing=NULL){
set.seed(seed)
params = list( 
  booster          =   'gbtree',
  objective        =   'binary:logistic',
  eval_metric      =   'logloss', 
  max.depth        =   sample(3:12, 1), 
  eta              =   runif(1,.01,.2),
  gamma            =   runif(1,0,2.5),
  min_child_weight =   runif(1,0,5),
  subsample        =   runif(1,.4,.6),
  colsample_bytree =   runif(1,.3,.9),
  nrounds          =   1000,
  lambda           =   runif(1,.25,1.5),  ##tree default 1 related?
  alpha            =   0,                 ## tree related?
  base_score       =   runif(1, .5,.8),
  nthread          =   12,
  missing          =   missing )

return(params) } 