data_checks_binary <- function(Xtrain,Xtest,y){
  
  stopifnot( unique(y) %in% c(0,1) ) # y is binary
  stopifnot( length(y)==nrow(Xtrain) ) # y is samelength as nrow()
  stopifnot( ncol(Xtrain)==ncol(Xtest) ) # same columns
 # stopifnot( is.matrix(Xtrain) )  #Xtrain is matrix
#  stopifnot( is.matrix(Xtest) )  #Xtest is a matrix
  stopifnot( colnames(Xtrain)==colnames(Xtest) )
  
  
  
  
  
  
  
}