makeBasket <- function(item_col,n_col){
  basket <- na.omit(rep(as.character(item_col),times=n_col))
  basket <- paste(basket, collapse=' ')
  return(basket)
  }
