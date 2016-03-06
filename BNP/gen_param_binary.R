gen_param_binary <- function(seed){
set.seed(seed)
params = list( 
  booster          =  'gbtree',
  objective        =   'binary:logistic',
  eval_metric      =   'logloss', 
  max.depth        =   sample(3:8, 1), 
  eta              =   runif(1,.01,.2),
  gamma            =   runif(1,0,3),
  min_child_weight =   runif(1,0,3),
  subsample        =   runif(1,.4,.6),
  colsample_bytree =   runif(1,.3,.9),
  nrounds          =   1500,
  lambda           =  1,
  alpha            =  0,
  base_score       =  runif(1, .2,.8),
  nthread          =   8 )

return(params) } 