gen_param_binary_xgb_linear <- function(seed,missing=NULL){
  set.seed(seed)
  params = list( 
    booster          =   'gblinear',
    objective        =   'binary:logistic',
    eval_metric      =   'logloss', 
    eta              =   runif(1,.01,.2),
    subsample        =   runif(1,.4,.6),
    nrounds          =   1000,
    lambda           =   runif(1,.25,1.5),  ##tree default 1 related?
    alpha            =   0,
    lambda_bias      =   runif(1,0,.1), ## tree related?
    base_score       =   runif(1, .5,.8),
    nthread          =   12,
    missing          =   missing )
  
  return(params) } 