treat_factors <- function(X,fac_cols, max_cat = 1024){
  #robust to NA
  
  X_fac <- copy(X[,fac_cols,with=F])
  X_fac[,(fac_cols):=lapply(.SD,factor,exclude = NULL),.SDcols=fac_cols]
  
  # add count columns
  fac_count_cols = paste('counts',fac_cols,sep='_')
  X_fac[,(fac_count_cols):= lapply(.SD,function(col)  table(col)[col]) ,.SDcols = fac_cols]
  
  #determine crowded factos
  levs <- X_fac[,lapply(.SD,function(i) length(levels(i))),.SDcols = fac_cols]
  fix_cols <- names(levs)[which(levs>=max_cat)]
  
  #ugly
  for(f in fix_cols){
    lev <- levels(X_fac[,get(f)])
    low_n <- length(lev)-max_cat
    low <- names(sort(table(X_fac[,get(f)]))[1:low_n ])
    X_fac[get(f) %in% low,(f):='low']
    X_fac[,(f):=factor(get(f))]
  }
  
  M <-sparse.model.matrix( ~ . - 1,data = X_fac)
  
  return(M)  
    

    
  }
  