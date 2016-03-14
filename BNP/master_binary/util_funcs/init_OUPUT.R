init_OUPUT <- function(n_train_full,n_test_full,iter,pct_train){
  #initialize input matrices
  n_train_samp  <- round(pct_train * n_train_full)
  
  return(list(
  PCV   = matrix(NA_real_,  nrow  =  n_train_full, ncol = iter),  # matrix n * m <== n * m ?? dumb
  PT    = matrix(NA_real_,  nrow =  n_test_full, ncol = iter),
  IDX   =  sapply( 1:iter,function(z) sample(n_train_full,n_train_samp)),
  DATA  = vector(mode='list',length=iter)))
}